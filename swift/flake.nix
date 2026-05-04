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
      perSystem = {pkgs, ...}: let
        swiftPackages = with pkgs.swiftPackages; [
          swift-unwrapped
          swiftpm
        ];
      in {
        devShells = {
          default = pkgs.mkShellNoCC {
            packages =
              [
                pkgs.sourcekit-lsp
                pkgs.swift-format
              ]
              ++ swiftPackages;
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
