{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = {nixpkgs, ...}: let
    eachSystem = fn: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: fn system nixpkgs.legacyPackages.${system});
  in {
    devShells = eachSystem (
      system: pkgs: let
        ghc = pkgs.haskell.packages.ghc96.ghcWithPackages (hpkgs:
          with hpkgs; [
            haskell-language-server
            fourmolu
          ]);
      in
        pkgs.mkShell {
          packages = [ghc];
        }
    );
  };
}
