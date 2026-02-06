{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    moonbit-overlay = {
      url = "github:glassesneo/moonbit-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    moonbit-overlay,
    ...
  }: let
    eachSystem = fn: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: fn system nixpkgs.legacyPackages.${system});
  in {
    devShell = eachSystem (
      system: pkgs:
        pkgs.mkShell {
          packages = [
            moonbit-overlay.packages.${system}.default
          ];
        }
    );
  };
}
