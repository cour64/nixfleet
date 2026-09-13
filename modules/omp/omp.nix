{ inputs, ... }:
{
  flake.modules.homeManager.omp =
    { lib, ... }:
    {
      imports = [ inputs.omp.homeManagerModules.default ];

      programs.omp.enable = true;

      # Settings live in ./config.yml (tracked, omp's native YAML format).
      # `programs.omp.settings` stays unset so the upstream module's own
      # generated-config activation is off. omp flocks and atomically
      # rewrites config.yml at runtime (/settings, model selector), so it is
      # installed as a writable copy; the next switch re-imposes the tracked
      # state over runtime changes.
      home.activation.ompConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/.omp/agent"
        run install -m 600 ${./config.yml} "$HOME/.omp/agent/config.yml"
      '';

      # lsp.json is read-only to omp, so the tracked file is symlinked.
      # Strict JSON only — omp parses it with JSON.parse and silently ignores
      # files it cannot parse; keep documentation in this comment. Entries:
      #   oxlint   oxc language server (oxlint --lsp, stdio). Lint-only
      #            (isLinter excludes it from type-intelligence ops).
      #            Activates per project via rootMarkers (.oxlintrc.json);
      #            add "package.json" to run in every JS/TS project.
      home.file.".omp/agent/lsp.json".source = ./lsp.json;

      # mcp.json: same rules as lsp.json (strict JSON, omp reads it; edit the
      # tracked file then /mcp reload — /mcp enable|disable cannot rewrite the
      # symlink, so keep the enabled state here).
      #   nixos   mcp-nixos: NixOS/nixpkgs/home-manager/darwin options search.
      home.file.".omp/agent/mcp.json".source = ./mcp.json;
    };
}
