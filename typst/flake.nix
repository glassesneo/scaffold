{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    typix = {
      url = "github:loqusion/typix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    typst-packages = {
      url = "github:typst/packages";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    systems,
    nixpkgs,
    flake-parts,
    typix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (top: {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = import systems;
      perSystem = {
        pkgs,
        system,
        ...
      }: let
        mkApp = drv: {
          type = "app";
          program = "${drv}/bin/${drv.pname or drv.name}";
        };
        typixLib = typix.lib.${system};

        src = typixLib.cleanTypstSource ./.;

        typstPackagesSrc = pkgs.symlinkJoin {
          name = "typst-packages-src";
          paths = [
            "${inputs.typst-packages}/packages"
          ];
        };

        typstPackagesCache = pkgs.stdenv.mkDerivation {
          name = "typst-packages-cache";
          src = typstPackagesSrc;
          dontBuild = true;
          installPhase = ''
            mkdir -p "$out"
            cp -LR --reflink=auto --no-preserve=mode -t "$out" "$src"/*
          '';
        };

        commonArgs = {
          typstSource = "main.typ";
          fontPaths = [
            "${pkgs.udev-gothic}/share/fonts/udev-gothic"
          ];
          typstOpts = {};
          virtualPaths = [];
        };

        build-drv = typixLib.buildTypstProject (
          commonArgs
          // {
            inherit src;
            XDG_CACHE_HOME = typstPackagesCache;
          }
        );

        # Compile a Typst project, and then copy the result
        # to the current directory
        build-script = typixLib.buildTypstProjectLocal (
          commonArgs
          // {
            inherit src;
            XDG_CACHE_HOME = typstPackagesCache;
          }
        );

        # Watch a project and recompile on changes
        watch-script = typixLib.watchTypstProject commonArgs;
      in {
        checks = {
          inherit build-drv build-script watch-script;
        };
        packages = {
          default = build-drv;
        };
        apps = rec {
          default = watch;
          build = mkApp build-script;
          watch = mkApp watch-script;
        };
        devShells = {
          default = typixLib.devShell {
            inherit (commonArgs) fontPaths virtualPaths;
            packages = [
              pkgs.tinymist
              pkgs.typstyle
              pkgs.tdf
              # WARNING: Don't run `typst-build` directly, instead use `nix run .#build`
              # See https://github.com/loqusion/typix/issues/2
              # build-script
              watch-script
            ];
          };
        };
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
          };
        };
      };
    });
}
