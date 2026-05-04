{
  description = "A collection of project templates";

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
      flake = {
        templates = {
          minimal = {
            path = ./minimal;
            description = "A minimal environment";
          };
          moonbit = {
            path = ./moonbit;
            description = "A simple MoonBit development environment";
          };
          gcc = {
            path = ./gcc;
            description = "A simple GCC development environment";
          };
          go = {
            path = ./go;
            description = "A simple Go development environment";
          };
          node = {
            path = ./node;
            description = "A simple Node.js development environment";
          };
          haskell = {
            path = ./haskell;
            description = "A simple Haskell development environment";
          };
          swift = {
            path = ./swift;
            description = "A simple Swift development environment";
          };
          zig = {
            path = ./zig;
            description = "A simple Zig development environment";
          };
        };
      };
      perSystem = {pkgs, ...}: {
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
          };
        };
      };
    });
}
