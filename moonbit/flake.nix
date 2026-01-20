{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {nixpkgs, ...}: let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {inherit system;};

    moonbit = pkgs.stdenvNoCC.mkDerivation {
      pname = "moonbit";
      version = "latest";

      src = pkgs.fetchzip {
        url = "https://cli.moonbitlang.com/binaries/latest/moonbit-darwin-aarch64.tar.gz";
        sha256 = "sha256-aW8nfLXSHv3kIhkBuO9dkMkdetjeX603hiyqiDum7BA=";
        stripRoot = false;
      };

      installPhase = ''
        mkdir -p $out
        cp -R . $out/
        if [ -d $out/bin ]; then
          chmod +x $out/bin/*
        fi
      '';

      meta = {
        description = "MoonBit language toolchain";
        homepage = "https://www.moonbitlang.com";
        platforms = ["aarch64-darwin"];
      };
    };
  in {
    packages.${system} = {
      moonbit = moonbit;
      default = moonbit;
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = [moonbit];
    };
  };
}
