let
  zsh = {
    programs.zsh.enable = true;
  };
in
{
  flake.modules.darwin.zsh = zsh;
  flake.modules.nixos.zsh = zsh;

  flake.modules.homeManager.zsh =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      programs.zsh = {
        enable = true;
        autocd = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        enableCompletion = true;
        defaultKeymap = "viins";
        localVariables.KEYTIMEOUT = 1;
        setOptions = [
          "interactive_comments"
          "prompt_subst"
        ];
        completionInit = ''
          autoload -Uz compinit
          zstyle ':completion:*' menu select
          compinit
          _comp_options+=(globdots)
        '';
        dotDir = "${config.xdg.configHome}/zsh";
        # Autoloaded on first call rather than defined on every shell startup.
        siteFunctions.tat = ''
          # Attach to, or create, a tmux session named after the current directory.
          local name=$(basename "$PWD" | sed -e 's/\.//g')

          if tmux has-session -t "$name" 2>/dev/null; then
            tmux attach -t "$name"
          elif [ -f .envrc ]; then
            direnv exec / tmux new-session -s "$name"
          else
            tmux new-session -s "$name"
          fi
        '';
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
        historySubstringSearch.enable = true;
        shellAliases = {
          ".." = "cd ..";
          "upos" =
            if pkgs.stdenv.hostPlatform.isDarwin then
              "nix flake update && sudo darwin-rebuild switch --flake ~/nixfleet#workmac"
            else
              "nix flake update && sudo nixos-rebuild switch --flake ~/nixfleet";
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
        envExtra = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
          # Non-interactive shells never reach precmd, so load the project hook here.
          if [[ ! -o interactive && -n "$PROJECT_ZSH_HOOK" && -r "$PROJECT_ZSH_HOOK" ]]; then
            source "$PROJECT_ZSH_HOOK"
          fi
        '';
        initContent = lib.mkMerge (
          [
            (lib.mkOrder 500 ''
              stty stop undef

              # Prompt. NEWLINE stays inline rather than moving to
              # localVariables, which Home Manager emits at order 540 -- after
              # this block already needs it.
              autoload -Uz add-zsh-hook vcs_info
              add-zsh-hook precmd vcs_info
              zstyle ':vcs_info:git:*' formats 'on %F{magenta} %b%f'
              NEWLINE=$'\n'
              PROMPT=''${NEWLINE}'%B%F{cyan}%~%f%b %B''${vcs_info_msg_0_}%b''${NEWLINE}%B%(?.%F{green}.%F{red})➜ %f%b '
              RPROMPT="%n@%m [%*]"
            '')
            (lib.mkOrder 550 ''
              # Keybindings. defaultKeymap already ran `bindkey -v` at order 530.
              # menuselect is provided by zsh/complist; load it before binding.
              zmodload zsh/complist
              bindkey -M menuselect 'h' vi-backward-char
              bindkey -M menuselect 'k' vi-up-line-or-history
              bindkey -M menuselect 'l' vi-forward-char
              bindkey -M menuselect 'j' vi-down-line-or-history
              bindkey -v '^?' backward-delete-char

              # Block cursor in normal mode, beam in insert. zle-line-init covers
              # each new prompt; the preexec hook restores the beam while a
              # command runs after leaving normal mode.
              function zle-keymap-select () {
                case $KEYMAP in
                  vicmd) echo -ne '\e[1 q';;
                  viins|main) echo -ne '\e[5 q';;
                esac
              }
              zle -N zle-keymap-select
              zle-line-init() {
                zle -K viins
                echo -ne "\e[5 q"
              }
              zle -N zle-line-init
              _zsh_cursor_beam() { echo -ne '\e[5 q' }
              add-zsh-hook preexec _zsh_cursor_beam

              autoload edit-command-line; zle -N edit-command-line
              bindkey '^e' edit-command-line
              bindkey -M vicmd '^e' edit-command-line
            '')
            (lib.mkOrder 650 ''
              # Expand the alias under the cursor on demand, rather than on every
              # space. compinit already binds this to ^Xa; Ctrl-Space is the
              # one-chord alternative.
              bindkey -M viins '^ ' _expand_alias
            '')
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            # mkAfter so this lands after the direnv hook: direnv exports
            # PROJECT_ZSH_HOOK from its own precmd, and hooks run in registration
            # order, so registering earlier would leave the first prompt in a new
            # directory without the hook loaded.
            (lib.mkAfter ''
              # Per-directory shell integration. direnv can only export variables, so
              # projects needing functions or completions point PROJECT_ZSH_HOOK at a
              # script and the shell sources it on entry, unloading it again on exit.
              _project_zsh_hook() {
                [[ $PROJECT_ZSH_HOOK == "$_PROJECT_ZSH_HOOK_LOADED" ]] && return
                [[ -n $_PROJECT_ZSH_HOOK_UNLOAD ]] && eval $_PROJECT_ZSH_HOOK_UNLOAD
                _PROJECT_ZSH_HOOK_UNLOAD=
                _PROJECT_ZSH_HOOK_LOADED=$PROJECT_ZSH_HOOK
                [[ -n $PROJECT_ZSH_HOOK && -r $PROJECT_ZSH_HOOK ]] && source $PROJECT_ZSH_HOOK
              }
              add-zsh-hook precmd _project_zsh_hook
            '')
          ]
        );
      };
    };
}
