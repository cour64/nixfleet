{
  flake.modules.homeManager.tmux =
    { pkgs, lib, ... }:
    {
      programs.tmux = {
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
    };
}
