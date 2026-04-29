{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
      systems = import systems;
      perSystem = {pkgs, ...}: {
        devShells = {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              go
              gopls
              delve
            ];
          };
        };
      };
    });
}
