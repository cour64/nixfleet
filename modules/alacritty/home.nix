{ pkgs, config, ... }:
{
  programs.alacritty = {
    enable = true;
    theme = "tokyo_night";
    settings = {
      startup_mode = "SimpleFullscreen";
      font = {
        normal.family = "Monaspace Neon";
        bold.family = "Monaspace Neon";
        italic.family = "Monaspace Neon";
        bold_italic.family = "Monaspace Neon";
        size = 12;
      };
    };
  };
}
