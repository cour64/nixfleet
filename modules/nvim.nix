{
  flake.modules.homeManager.nvim =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      programs.neovim = {
        enable = true;

        # Home Manager would otherwise write its generated init.lua into
        # $XDG_CONFIG_HOME/nvim, which is the symlink to this repo below.
        # Sideloading passes it via wrapper args instead, leaving the directory
        # entirely ours.
        sideloadInitLua = true;

        withPython3 = false;
        withRuby = false;
        withNodeJs = false;

        # Editor infrastructure, plus the servers for Nix and Lua: those are the
        # languages this configuration is written in, and it gets edited from
        # anywhere rather than from inside one project.
        #
        # Project language servers, SDKs and formatters are deliberately absent.
        # Projects supply those through devenv/direnv, so Neovim only ever sees
        # the toolchain a project actually uses. See
        # modules/nvim/lua/config/lsp.lua for the contract.
        extraPackages =
          with pkgs;
          [
            # Telescope
            ripgrep
            fd

            # Treesitter parser compilation (cc/make come from Xcode CLT)
            tree-sitter

            # This repo's own languages
            nixd
            nixfmt
            lua-language-server
            stylua
          ]
          # clipboard = "unnamedplus" shells out to a platform helper. Darwin has
          # pbcopy/pbpaste built in; Linux needs these for Wayland and X11.
          ++ lib.optionals stdenv.hostPlatform.isLinux [
            wl-clipboard
            xclip
          ];
      };

      programs.zsh.shellAliases = {
        vi = "nvim";
        vim = "nvim";
      };

      # An out-of-store symlink keeps the Lua editable without a rebuild and lets
      # lazy.nvim write lazy-lock.json back into the repo. A normal Home Manager
      # link would point into the read-only store and break `:Lazy update`.
      xdg.configFile."nvim".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfleet/modules/nvim";
    };
}
