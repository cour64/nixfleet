{
  # 1Password on macOS refuses to launch unless its bundle is a real directory
  # at /Applications/1Password.app, so Home Manager's symlink into
  # ~/Applications can never satisfy it (nixpkgs#254944). nix-darwin's modules
  # rsync the bundle into place from the store, and install the CLI at
  # /usr/local/bin/op, which is where the GUI looks for it to offer CLI
  # integration. The copy is root-owned and read-only, so it still cannot
  # self-update: version bumps come from `nix flake update` as with everything
  # else here.
  flake.modules.darwin.onepassword = {
    programs._1password.enable = true;
    programs._1password-gui.enable = true;
  };

  flake.modules.homeManager.onepassword =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      # `op plugin init <tool>` appends an alias here, so sourcing the file
      # picks up new plugins without a rebuild. It is runtime state that op
      # owns, not something Nix writes, so guard on it existing: a machine
      # where no plugin is configured yet just skips this.
      pluginAliases = "${config.xdg.configHome}/op/plugins.sh";
    in
    {
      home.packages = [
        pkgs._1password-cli
      ]
      # On Darwin the GUI comes from the nix-darwin module above. Adding it here
      # would only recreate the ~/Applications symlink that cannot be launched.
      ++ lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs._1password-gui;

      # Ordered after Home Manager's own aliases (1100) so the op wrappers win.
      # An `if` rather than `[[ … ]] && source`, which would leave $? at 1 and
      # paint the first prompt's arrow red on machines without the file.
      programs.zsh.initContent = lib.mkOrder 1200 ''
        if [[ -f "${pluginAliases}" ]]; then
          source "${pluginAliases}"
        fi
      '';
    };
}
