{
  pkgs,
  config,
  ...
}:
let
  opPath = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  opSshSign = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  updateCommand = "sudo darwin-rebuild switch --flake ~/nixfleet#workmac";
in
{
  home.packages = with pkgs; [
    tree
    wget
    curl
    jq
    gum
    neovim
  ];

  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
      extraConfig = ''
        IdentityAgent ${opPath}
      '';
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "Brendan de la Cour";
          email = "brendan.delacour@se.com";
        };
        aliases = {
          prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        };
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
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJa3S25gbOWCPHrB22QO1W4GrAMfqTGY3al6Y4q7JZP";
        };
      };
    };

    zsh = {
      enable = true;
      autocd = true;
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
      dotDir = "${config.xdg.configHome}/zsh";
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
        "upos" = "git add . && nix flake update && git add . && ${updateCommand}";
        "gs" = "git status";
        "ga" = "git add";
        "gaa" = "git add .";
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
        "cat" = "bat";
      };
      plugins = [
        {
          name = "zsh-you-should-use";
          src = pkgs.zsh-you-should-use;
          file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
        }
      ];
      initContent = builtins.readFile ./zshrc;
      envExtra = ''
        if [[ ! -o interactive && -n "$WORKSPACE_CLI_ACTIVE" ]] && command -v workspace >/dev/null; then
          compdef() { :; }
          eval "$(workspace shell-init zsh 2>/dev/null)"
        fi
      '';
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
        (tmuxPlugins.vim-tmux-navigator.overrideAttrs (old: {
          env = lib.filterAttrs (_: v: !(builtins.isList v)) (old.env or { });
        }))
        (tmuxPlugins.tokyo-night-tmux.overrideAttrs (old: {
          env = lib.filterAttrs (_: v: !(builtins.isList v)) (old.env or { });
        }))
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
      enableZshIntegration = true;
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
