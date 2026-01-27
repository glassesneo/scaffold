{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    zls-overlay.url = "github:zigtools/zls/0.15.0";
  };

  outputs = {
    nixpkgs,
    zig-overlay,
    zls-overlay,
    ...
  }: let
    eachSystem = fn: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: fn system nixpkgs.legacyPackages.${system});
  in {
    devShell = eachSystem (
      system: pkgs: let
        zig = zig-overlay.packages.${system}."0.15.1";
        zls = zls-overlay.packages.${system}.zls.overrideAttrs (old: {
          nativeBuildInputs = [zig];
        });
      in
        pkgs.mkShell {
          packages = [
            zig
            zls
          ];
        }
    );

    # packages = forAllSystems (
    # system: pkgs: {
    # default = pkgs.stdenv.mkDerivation {
    # pname = "zig-template";
    # version = "0.1.0";
    # src = ./.;
    # nativeBuildInputs = [
    # pkgs.zig_0_15.hook
    # ];
    # };
    # }
    # );
  };
}
