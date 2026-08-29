{
  flake.modules.homeManager.opencode = {
    programs.opencode = {
      enable = true;
      settings = {
        # Binary comes from Nixpkgs; do not let OpenCode self-update.
        autoupdate = false;
        autoshare = false;
      };
    };
  };
}
