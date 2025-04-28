{
  pkgs,
  config,
  lib,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  opPathDarwin = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  opPathNixos = "~/.1password/agent.sock";
  opPath = if isDarwin then opPathDarwin else opPathNixos;

  opSshSignDarwin = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  opSshSignNixos = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
  opSshSign = if isDarwin then opSshSignDarwin else opSshSignNixos;
in
{
  home.packages = with pkgs; [
    tree
    wget
    curl
    jq
  ];

  programs = {
    ssh = {
      enable = true;
      extraConfig = ''
        IdentityAgent ${opPath}
      '';
    };

    git = {
      enable = true;
      userName = "Brendan de la Cour";
      userEmail = "brendan.dlc@gmail.com";
      aliases = {
        prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      };
      extraConfig = {
        branch.autosetuprebase = "always";
        color.ui = true;
        core.askPass = ""; # needs to be empty to use terminal for ask pass
        credential.helper = "store"; # want to make this more secure
        github.user = "cour64";
        push.default = "tracking";
        init.defaultBranch = "main";
        gpg = {
          format = "ssh";
        };
        "gpg \"ssh\"" = {
          program = opSshSign;
        };
        commit = {
          gpgsign = true;
        };
        user = {
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJoUGfDKcUsxnBG1iHx57qcH9qGvuglqWWzLUTtZ/NHl";
        };
      };
    };

    zsh = {
      enable = true;
      envExtra = ''
        EDITOR="nvim"
        VISUAL="nvim"
      '';
      autocd = true;
      # defaultKeymap = "vicmd";
      enableVteIntegration = true;
      autosuggestion = {
        enable = true;
      };
      syntaxHighlighting = {
        enable = true;
      };
      enableCompletion = true;
      completionInit = ''
        autoload -Uz compinit
        zstyle ':completion:*' menu select
        zmodload zsh/complist
        compinit
        _comp_options+=(globdots)
      '';
      dotDir = ".config/zsh";
      history = {
        append = true;
        expireDuplicatesFirst = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        path = "${config.xdg.dataHome}/zsh/zsh_history";
        save = 20000;
        size = 20000;
        share = true;
      };
      historySubstringSearch = {
        enable = true;
      };
      shellAliases = {
        ".." = "cd ..";
        "update-workmac" = "darwin-rebuild switch --flake ~/nixfleet#workmac";
        "gs" = "git status";
        "ga" = "git add";
        "gc" = "git commit -m";
        "gp" = "git pull";
        "gr" = "git pull --rebase";
        "gst" = "git stash -u";
        "gsta" = "git stash apply";
        "gstp" = "git stash pop";
        "gclear" = "git checkout -- .";
        "gb" = "git checkout";
        "gbn" = "git checkout -b";
        "ls" = "eza -a";
        "ll" = "eza -la";
        "la" = "eza -alRT --level 2";
        "less" = "bat";
      };
      plugins = [
        {
          name = "zsh-you-should-use";
          src = pkgs.zsh-you-should-use;
          file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
        }
      ];
      initContent = builtins.readFile ./zshrc;
    };

    tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "tmux-256color";
      historyLimit = 100000;
      clock24 = true;
      keyMode = "vi";
      mouse = true;
      focusEvents = true;
      secureSocket = true;
      baseIndex = 1;
      escapeTime = 0;
      newSession = false;
      prefix = "C-b";
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-vim 'session'
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-boot 'on'
            set -g @continuum-save-interval '10'
          '';
        }
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.fingers
        tmuxPlugins.tokyo-night-tmux
        {
          plugin = tmuxPlugins.extrakto;
          extraConfig = ''
            set -g @extrakto_filter_order 'line'
          '';
        }
      ];
      extraConfig = ''
        bind-key x kill-pane
        set -g detach-on-destroy off

        unbind %
        unbind '"'
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        set -g display-time 4000
      '';
    };

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
      changeDirWidgetCommand = "fd --type d";
      changeDirWidgetOptions = [
        "--preview 'tree -C {} | head -200'"
      ];
      # defaultCommand = "fd --type f";
      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [
        "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
      ];
      tmux = {
        enableShellIntegration = true;
      };
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
      git = true;
      colors = "auto";
      icons = "auto";
    };

    bottom = {
      enable = true;
    };

    ripgrep = {
      enable = true;
    };

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
            repo = "tokyonight.nvim"; # Correct repo name
            rev = "b262293ef481b0d1f7a14c708ea7ca649672e200";
            sha256 = "sha256-pMzk1gRQFA76BCnIEGBRjJ0bQ4YOf3qecaU6Fl/nqLE=";
          };
          file = "extras/sublime/tokyonight_night.tmTheme";
        };
      };
    };
  };
}
