{ inputs, ... }:
{
  flake.modules.darwin.nix = {
    nix.settings.experimental-features = "nix-command flakes";
    nix.optimise.automatic = true;
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (prev) system;
          config.allowUnfree = true;
        };
      })
    ];
  };

  flake.modules.homeManager.nix = {
    nixpkgs.config.allowUnfree = true;
  };
}
