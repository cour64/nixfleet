{
  flake.modules.darwin.homebrew =
    { config, ... }:
    {
      nix-homebrew = {
        enable = true;
        enableRosetta = true;
        user = config.system.primaryUser;
        autoMigrate = true;
      };

      homebrew = {
        enable = true;
        # Only apps without usable Darwin packages in the pinned nixpkgs.
        casks = [
          "httpie-desktop"
          "balenaetcher"
          "raycast"
          "cursor"
          "cursor-cli"
        ];
        onActivation = {
          cleanup = "uninstall";
          autoUpdate = true;
          upgrade = true;
        };
      };

      environment.pathsToLink = [ "/opt/homebrew/bin" ];
    };
}
