{
  flake.modules.darwin.nix = {
    nix.settings.experimental-features = "nix-command flakes";
    nix.optimise.automatic = true;
    nixpkgs.config.allowUnfree = true;
  };

  flake.modules.homeManager.nix = {
    nixpkgs.config.allowUnfree = true;
  };
}
