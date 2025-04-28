{ pkgs, config, ... }:
{
  home.file."${config.xdg.configHome}/ghostty/config" = {
    source = ./config;
  };
}
