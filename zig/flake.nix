{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    zls-overlay = {
      url = "github:zigtools/zls/0.15.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        zig-overlay.follows = "zig-overlay";
      };
    };
  };

  outputs = inputs @ {
    self,
    systems,
    nixpkgs,
    flake-parts,
    zig-overlay,
    zls-overlay,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (top: {
      imports = [];
      systems = import systems;
      perSystem = {
        pkgs,
        system,
        ...
      }: let
        zig = zig-overlay.packages.${system}."0.15.2";
        zls = zls-overlay.packages.${system}.zls.overrideAttrs (old: {
          nativeBuildInputs = [zig];
        });
      in {
        devShells = {
          default = pkgs.mkShellNoCC {
            packages = [
              zig
              zls
            ];
          };
        };
      };
    });
}
