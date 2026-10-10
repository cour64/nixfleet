{
  flake.modules.homeManager.claude =
    { config, ... }:
    {
      # Claude Code's config directory lives in this repo, same pattern as
      # modules/pi/agent: out-of-store symlink keeps it writable, so plugin
      # installs, settings changes, and new skills land in the working tree —
      # commit them to keep them. Runtime state (projects, todos, plugins
      # caches, credentials) is gitignored inside that directory.
      home.file.".claude".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfleet/modules/claude";
    };
}