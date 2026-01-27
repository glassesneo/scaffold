{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    nixpkgs,
    typix,
    ...
  }: let
    eachSystem = fn: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: fn system nixpkgs.legacyPackages.${system});
    mkApp = drv: {
      type = "app";
      program = "${drv}/bin/${drv.pname or drv.name}";
    };
  in {
    checks = eachSystem (
      system: pkgs: let
        typixLib = typix.lib.${system};

        src = typixLib.cleanTypstSource ./.;
        # Watch a project and recompile on changes
        watch-script = typixLib.watchTypstProject commonArgs;

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
      in {
        inherit build-drv build-script watch-script;
      }
    );

    packages = eachSystem (
      system: pkgs: let
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
      in {
        default = typixLib.buildTypstProject (
          commonArgs
          // {
            inherit src;
            XDG_CACHE_HOME = typstPackagesCache;
          }
        );
      }
    );

    apps = eachSystem (
      system: pkgs: let
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
        build-script = typixLib.buildTypstProjectLocal (
          commonArgs
          // {
            inherit src;
            XDG_CACHE_HOME = typstPackagesCache;
          }
        );
        watch-script = typixLib.watchTypstProject commonArgs;
      in rec {
        default = watch;
        build = mkApp build-script;
        watch = mkApp watch-script;
      }
    );

    devShells = eachSystem (
      system: pkgs: let
        typixLib = typix.lib.${system};
        commonArgs = {
          typstSource = "main.typ";
          fontPaths = [
            "${pkgs.udev-gothic}/share/fonts/udev-gothic"
          ];
          typstOpts = {};
          virtualPaths = [];
        };
        watch-script = typixLib.watchTypstProject commonArgs;
      in {
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
      }
    );
  };
}
