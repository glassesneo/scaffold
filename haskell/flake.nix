{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = {nixpkgs, ...}: let
    allSystems = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    forAllSystems = fn: nixpkgs.lib.genAttrs allSystems (system: fn system nixpkgs.legacyPackages.${system});
  in {
    devShells = forAllSystems (
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
