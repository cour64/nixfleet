{
  flake.modules.homeManager.pi =
    { pkgs, config, ... }:
    let
      # Installed through pi's own package manager (see docs/packages.md).
      # Pinned so `pi update --extensions` doesn't move them; browse
      # https://pi.dev/packages for what's available. To bump one: edit the
      # version and rebuild — the piPackages activation below materializes
      # the new version into ~/.pi/agent automatically.
      # piPackages = [
      # Web search, URL fetching, GitHub cloning, PDF extraction,
      # YouTube/local video understanding. Needs an API key for a search
      # provider (configures itself via /web-access or on first use).
      #       "npm:pi-web-access@0.29.0"
      # Real-time code feedback: LSP, linters, formatters, type-checking.
      # Uses PATH servers (typescript, oxlint are in modules/packages.nix).
      #       "npm:pi-lens@4.2.1"
      # Single-agent delegation and scripted multi-agent workflows.
      #       "npm:pi-subagents@0.69.0"
      # Replaces pi's find/grep with the embedded Rust fff search engine
      # (ships its own native lib; needs no fff binary). /fff-health to
      # verify after install.
      #        "npm:@ff-labs/pi-fff@0.10.6"
      # Token-efficient autonomous task execution with context collapse
      # (runs subtasks in isolated sessions and returns only the result).
      #        "npm:pi-boomerang@0.7.0"
      # "Lazy senior dev mode" skills for pi. Pinned to a tag; `pi update
      # --extensions` won't move it — bump by editing the ref here.
      # "git:github.com/DietrichGebert/ponytail@v4.10.0"
      # ];
    in
    {
      home.packages = [
        # pi coding agent; unstable tracks upstream much closer than 26.05
        # (0.85.1 vs 0.75.4).
        pkgs.unstable.pi-coding-agent
        # Standalone fff TUI file manager (dylanaraps/fff) — a separate
        # project from the @ff-labs/pi-fff extension above, which embeds its
        # own engine and does not use this binary. Install so the user has a
        # fuzzy file picker on PATH alongside pi.
        pkgs.fff
      ];

      # pi's entire config directory lives in this repo. An out-of-store
      # symlink keeps it writable, so pi's own changes (/settings, Ctrl+S
      # model save, new skills, settings.json) land in the working tree —
      # commit them to keep them. Runtime state (sessions, npm, auth.json,
      # models-store.json) is gitignored inside that directory instead of
      # being managed piecemeal here.
      home.file.".pi/agent".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfleet/modules/pi/agent";
    };
}
