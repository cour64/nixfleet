# nixfleet

Dendritic Nix flake for Brendan's machines. Darwin and NixOS share system
aspects where the options exist on both; macOS defaults and Homebrew stay
Darwin-only. Shared Home Manager aspects evaluate on Darwin and Linux.

The flake tracks Nixpkgs 26.05 (`nixpkgs-26.05-darwin`), nix-darwin
`nix-darwin-26.05`, and Home Manager `release-26.05`. A `nixpkgs-unstable`
input is present. Modules can use `pkgs.unstable.<pkg>` when a package
needs a newer build than 26.05.

## Structure

- `flake.nix` — inputs and `flake-parts` + `import-tree` entrypoint
- `modules/` — aspect modules auto-imported by `import-tree`
  - `hosts/` — host composition (`workmac`, `legion`)
  - `users/` — user identity and Home Manager imports
  - feature aspects (`zsh`, `git`, `ghostty`, `onepassword`, …)

Paths containing `/_` are ignored by `import-tree`.

## Rebuild (macOS)

```bash
sudo darwin-rebuild switch --flake ~/nixfleet#workmac
```

Update inputs, then rebuild:

```bash
nix flake update
sudo darwin-rebuild switch --flake ~/nixfleet#workmac
```

Or use the `upos` alias after activation.

## Applications and updates

Prefer Nix packages. Installed GUI apps live in the Nix store and update only
through flake updates + rebuild — do not use in-app update buttons. On macOS,
Home Manager links app bundles under `~/Applications/Home Manager Apps`.

Homebrew is limited to apps without usable Darwin packages in the pinned
Nixpkgs 26.05 set:

- `httpie-desktop`
- `balenaetcher`

## Neovim

Nix provides the `nvim` binary, editor infrastructure (`ripgrep`, `fd`,
`tree-sitter`) and the servers for Nix and Lua — the languages this repo is
written in, edited from anywhere rather than from inside one project. Plugins
are managed by lazy.nvim; the Lua config lives in `modules/nvim/` and is
symlinked out-of-store so it is editable without a rebuild.

Project language servers, SDKs and formatters are **not** installed globally.
Each project supplies its own through devenv + direnv. Neovim declares every
server in `modules/nvim/lua/config/lsp.lua` but only starts those whose command
is on `PATH`, so a TypeScript checkout never attempts the C# or Python servers.
Run `:LspAvailable` to see what the current project provides.

Because Neovim inherits `PATH` at startup, launch it from inside the project
directory so direnv has already loaded the environment.

What to add to a project's devenv per language:

| Language      | Servers and formatters                                           |
| ------------- | ---------------------------------------------------------------- |
| Python        | `basedpyright`, `ruff`                                           |
| TypeScript/JS | `vtsls`, `vscode-langservers-extracted`, `nodePackages.prettier`  |
| C#            | `roslyn-ls`, `dotnet-sdk`, `csharpier`                           |

## Linux / NixOS portability

Portable system aspects are exported to both `flake.modules.darwin.*` and
`flake.modules.nixos.*`: `nix`, `fonts`, `packages`, `zsh`, `onepassword`,
and the `brendan` user. `macos` and `homebrew` are Darwin-only. The NixOS
user also pulls in Hyprland, Noctalia (bar, launcher, dock, notifications),
and the Noctalia greeter on greetd.

The NixOS host is `legion` (`modules/hosts/legion.nix`, hardware under
`modules/hosts/_legion/` so `import-tree` skips it). Compose further
`self.modules.nixos` aspects the same way `workmac` composes Darwin. The
login screen is the Noctalia greeter; it starts the UWSM Hyprland session
by default. The Legion is AMD iGPU + RTX 3070 Ti (PRIME offload): Hyprland
runs on AMD, and `nvidia-offload <app>` uses the NVIDIA GPU. Confirm
`amdgpuBusId` with `lspci -d ::03xx` if you have more than one NVMe drive
(often `PCI:6:0:0`). Firefox (with uBlock Origin and 1Password) and Steam
are NixOS-only. For NVIDIA games, `nvidia-offload steam` or a Steam launch
option.

`Super+Return` opens Ghostty. `Super+Space` opens the Noctalia launcher.
Rebuild with:

```bash
sudo nixos-rebuild switch --flake ~/nixfleet#legion
```

## 1Password

1Password GUI and CLI are installed from Nix. SSH agent and Git commit signing
are configured declaratively.

On macOS the GUI cannot be used through Home Manager's `~/Applications` symlink:
1Password refuses to launch unless its bundle is a real directory at
`/Applications/1Password.app` ([nixpkgs#254944][1p-issue]). So Darwin uses
nix-darwin's `programs._1password-gui`, which copies the bundle out of the store
into `/Applications`, plus `programs._1password`, which puts the CLI at
`/usr/local/bin/op` where the GUI expects it. The copy is root-owned and
read-only, so in-app updates still cannot apply — use `nix flake update`.

[1p-issue]: https://github.com/NixOS/nixpkgs/issues/254944

On NixOS the same `programs._1password` and `programs._1password-gui` options
install CLI and GUI system-wide. The `brendan` user module sets
`polkitPolicyOwners` so CLI integration and system authentication work.

One-time manual step after the first install:

1. Open 1Password
2. Settings → Developer
3. Enable **Use the SSH agent**
