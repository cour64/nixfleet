{
  flake.modules.homeManager.cli-tools =
    { pkgs, ... }:
    {
      programs = {
        fd = {
          enable = true;
          hidden = true;
          ignores = [
            "node_modules/"
            ".git/"
            "dist/"
            "build/"
            ".DS_Store"
          ];
        };

        fzf = {
          enable = true;
          enableZshIntegration = true;
          changeDirWidget = {
            command = "fd --type d";
            options = [ "--preview 'tree -C {} | head -200'" ];
          };
          fileWidget = {
            command = "fd --type f";
            options = [
              "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
            ];
          };
          tmux.enableShellIntegration = true;
          defaultOptions = [
            "--highlight-line"
            "--info=inline-right"
            "--ansi"
            "--layout=reverse"
            "--border=none"
          ];
          colors = {
            "bg+" = "#283457";
            "bg" = "#16161e";
            "border" = "#27a1b9";
            "fg" = "#c0caf5";
            "gutter" = "#16161e";
            "header" = "#ff9e64";
            "hl+" = "#2ac3de";
            "hl" = "#2ac3de";
            "info" = "#545c7e";
            "marker" = "#ff007c";
            "pointer" = "#ff007c";
            "prompt" = "#2ac3de";
            "query" = "#c0caf5";
            "scrollbar" = "#27a1b9";
            "separator" = "#ff9e64";
            "spinner" = "#ff007c";
          };
        };

        zoxide = {
          enable = true;
          enableZshIntegration = true;
        };

        eza = {
          enable = true;
          enableZshIntegration = true;
          git = true;
          colors = "auto";
          icons = "auto";
        };

        bottom.enable = true;
        ripgrep.enable = true;

        bat = {
          enable = true;
          config = {
            pager = "less -FR";
            theme = "tokyonight";
          };
          themes = {
            tokyonight = {
              src = pkgs.fetchFromGitHub {
                owner = "folke";
                repo = "tokyonight.nvim";
                rev = "b262293ef481b0d1f7a14c708ea7ca649672e200";
                sha256 = "sha256-pMzk1gRQFA76BCnIEGBRjJ0bQ4YOf3qecaU6Fl/nqLE=";
              };
              file = "extras/sublime/tokyonight_night.tmTheme";
            };
          };
        };
      };
    };
}
