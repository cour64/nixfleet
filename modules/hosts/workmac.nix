{ self, inputs, ... }:
{
  flake.darwinConfigurations.workmac = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      inputs.nix-homebrew.darwinModules.nix-homebrew
      self.modules.darwin.workmac
    ];
  };

  flake.modules.darwin.workmac = {
    imports = with self.modules.darwin; [
      nix
      fonts
      macos
      homebrew
      packages
      zsh
      onepassword
      brendan
    ];

    nixpkgs.hostPlatform = "aarch64-darwin";
    system.configurationRevision = self.rev or self.dirtyRev or null;
    system.stateVersion = 5;
  };
}
