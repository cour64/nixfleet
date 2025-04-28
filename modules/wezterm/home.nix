{ pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      -- This can be a minimal config that loads your main module
      return require('nix-hm/wezterm')
    '';
  };

  xdg.configFile = {
    "wezterm/nix-hm" = {
      source = ./dotfiles;
      recursive = true;
    };
  };
}
