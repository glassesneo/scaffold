{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    devShell = forAllSystems (
      system: pkgs: let
        swiftPackages = with pkgs.swiftPackages; [
          swift-unwrapped
          swiftpm
        ];
      in
        pkgs.mkShell {
          packages =
            [
              pkgs.sourcekit-lsp
              pkgs.swift-format
            ]
            ++ swiftPackages;
        }
    );
  };
}
