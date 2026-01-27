{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {nixpkgs, ...}: let
    eachSystem = fn: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: fn system nixpkgs.legacyPackages.${system});
  in {
    devShell = eachSystem (
      system: pkgs:
        pkgs.mkShell {
          packages = [];
        }
    );
  };
}
