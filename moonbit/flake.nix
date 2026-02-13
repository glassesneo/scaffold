{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    skills-deployer = {
      url = "github:glassesneo/skills-deployer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moonbit-overlay = {
      url = "github:glassesneo/moonbit-overlay/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moonbit-agent-guide = {
      url = "github:moonbitlang/moonbit-agent-guide";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    skills-deployer,
    moonbit-overlay,
    moonbit-agent-guide,
    ...
  }: let
    eachSystem = fn: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: fn system nixpkgs.legacyPackages.${system});
  in {
    apps = eachSystem (system: pkgs: {
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
    });
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
