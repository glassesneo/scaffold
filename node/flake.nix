{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    systems,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (top: {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = import systems;
      perSystem = {
        pkgs,
        lib,
        self',
        ...
      }: let
        pname = "";
        version = "0.1.0";
        src = lib.cleanSource ./.;

        nodejs = pkgs.nodejs_26;
        pnpm = pkgs.pnpm_11;
        pnpmDeps = pkgs.fetchPnpmDeps {
          inherit pname version src;
          fetcherVersion = 4;
          hash = lib.fakeHash;
        };
        mkPnpmDerivation = attrs:
          pkgs.stdenv.mkDerivation ({
              inherit pname version src pnpmDeps;

              nativeBuildInputs = [
                nodejs
                pnpm
                pkgs.pnpmConfigHook
              ];
            }
            // attrs);

        emptyInstallPhase = ''
          mkdir -p $out
          touch $out/done
        '';
      in {
        packages.default = mkPnpmDerivation {
          buildPhase = ''
            runHook preBuild
            pnpm run build
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -r dist $out/
            runHook postInstall
          '';
        };
        checks = {
          build = self'.packages.default;

          typecheck = mkPnpmDerivation {
            pname = "${pname}-typecheck";

            buildPhase = ''
              runHook preBuild
              pnpm run typecheck
              runHook postBuild
            '';

            installPhase = emptyInstallPhase;
          };

          lint = mkPnpmDerivation {
            pname = "${pname}-lint";

            buildPhase = ''
              runHook preBuild
              pnpm run lint
              runHook postBuild
            '';

            installPhase = emptyInstallPhase;
          };
        };

        devShells = {
          default = pkgs.mkShellNoCC {
            packages = [
              nodejs
              pnpm
              pkgs.typescript-language-server
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
