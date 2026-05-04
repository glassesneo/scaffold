{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    skills-deployer = {
      url = "github:glassesneo/skills-deployer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moonbit-overlay = {
      url = "github:glassesneo/moonbit-overlay/stable";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    moonbit-agent-guide = {
      url = "github:moonbitlang/moonbit-agent-guide";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    systems,
    nixpkgs,
    flake-parts,
    skills-deployer,
    moonbit-overlay,
    moonbit-agent-guide,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (top: {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = import systems;
      perSystem = {
        pkgs,
        system,
        ...
      }: {
        devShells = {
          default = pkgs.mkShellNoCC {
            packages = [
              moonbit-overlay.packages.${system}.default
            ];
          };
        };
        apps = {
          deploy-skills = skills-deployer.lib.mkDeploySkills pkgs {
            defaultMode = "symlink";
            skills = let
              mkMoonbitSkill = subdir: {
                source = moonbit-agent-guide;
                inherit subdir;
                targetDirs = [".claude/skills" ".agents/skills"];
              };
            in {
              moonbit-agent-guide = mkMoonbitSkill "moonbit-agent-guide";
              moonbit-refactoring = mkMoonbitSkill "moonbit-refactoring";
            };
          };
        };
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
          };
        };
      };
    });
}
