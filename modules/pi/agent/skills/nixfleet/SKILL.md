---
name: nixfleet
description: Brendan's systems are managed declaratively with Nix (nixfleet flake at ~/nixfleet). Use whenever changing system, app, or tool configuration — packages, dotfiles, editor/terminal/browser settings, themes, services, or pi's own settings — instead of editing local config files. Also use when a change doesn't take effect or a file keeps reverting.
---

# Nixfleet: declarative system configuration

All system and application configuration on this machine is declared in the
nixfleet flake at `~/nixfleet`. Editing local files directly (`~/.zshrc`,
`~/.config/ghostty/config`, `~/.pi/agent/settings.json`, browser settings,
etc.) is wrong: they are symlinks into the Nix store or this flake, and the
rest are reset on the next rebuild.

## The one rule

To change configuration: edit the relevant module in `~/nixfleet`, then
rebuild. Never edit the target files themselves.

1. Find the module: `rg -il "<app or option name>" ~/nixfleet/modules`
2. Edit it (read neighboring modules first to match existing conventions and
   comment style — this repo documents the "why" in comments).
3. `git add` (see caveat below), rebuild, and verify.

## Rebuild commands

```bash
# NixOS host (legion):
sudo nixos-rebuild switch --flake ~/nixfleet#legion

# macOS host (workmac):
sudo darwin-rebuild switch --flake ~/nixfleet#workmac  # nix-darwin 26.05
```

## Repo layout (dendritic flake-parts + import-tree)

- `flake.nix` — inputs (nixpkgs 26.05 + `nixpkgs-unstable` overlay).
- `modules/` — every `*.nix` file here is auto-imported as a flake-parts
  module; each defines `flake.modules.homeManager.<name>` (or
  `.darwin`/`.nixos`). Files/dirs starting with `_` are skipped by
  import-tree.
- `modules/users/brendan.nix` — which home-manager modules the user imports;
  add new user modules here.
- `modules/hosts/legion.nix` / `workmac.nix` — host composition.
- Some modules carry data files next to them (e.g. `modules/nvim/`);
  `modules/pi/agent/` is pi's config directory, symlinked from `~/.pi/agent`.

Home-manager modules are shared between both hosts unless explicitly imported
on only one (host lists live in `modules/hosts/`).

## Caveats

- **Untracked files are invisible to Nix.** Path flakes in a git repo only see
  *tracked* files. `git add` any new/renamed files (not just edits) before
  rebuilding, or the build won't see them.
- **pi's writes land in this repo.** `~/.pi/agent` is a symlink to
  `modules/pi/agent`, so settings changes pi makes itself (`/settings`,
  Ctrl+S model save, new skills) show up as uncommitted diffs there — commit
  them to keep them, or `git restore` to discard. Mutable runtime state
  (sessions, npm, models-store.json, auth.json) is gitignored; `auth.json`
  holds credentials and never gets committed.
- **Prefer unstable for fast-moving tools**: `pkgs.unstable.<pkg>` (pi, gh,
  oxlint, typescript...). Stable 26.05 for everything else.
- A failed rebuild leaves no partial state; to discard experimental edits,
  `git -C ~/nixfleet restore <file>` and rebuild again.
