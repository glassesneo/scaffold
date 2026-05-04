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
  };

  outputs = inputs @ {
    self,
    systems,
    nixpkgs,
    flake-parts,
    zig-overlay,
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
      in {
        devShells = {
          default = pkgs.mkShellNoCC {
            packages =
              [
                zig
              ]
              ++ (with pkgs; [
                gcc
                vscode-extensions.vadimcn.vscode-lldb.adapter

                # LSP & static analysis
                clang-tools # clangd, clang-tidy, clang-format

                # Build helpers
                gnumake
                bear
              ]);
          };
        };
      };
    });
}
