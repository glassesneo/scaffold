{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = {
    nixpkgs,
    zig-overlay,
    ...
  }: let
    eachSystem = fn: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: fn system nixpkgs.legacyPackages.${system});
  in {
    devShell = eachSystem (
      system: pkgs: let
        zig = zig-overlay.packages.${system}."0.15.1";
      in
        pkgs.mkShell {
          packages =
            [zig]
            ++ (with pkgs; [
              gcc

              # LSP & static analysis
              clang-tools # clangd, clang-tidy, clang-format

              # Build helpers
              gnumake
              bear
            ]);
        }
    );
  };
}
