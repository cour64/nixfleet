{ inputs, ... }:
let
  nix = {
    nix.settings.experimental-features = "nix-command flakes";
    nix.optimise.automatic = true;
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
      })
    ];
  };
in
{
  flake.modules.darwin.nix = nix;
  flake.modules.nixos.nix = nix;

  flake.modules.homeManager.nix = {
    nixpkgs.config.allowUnfree = true;
  };
}
