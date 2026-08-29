{
  flake.modules.homeManager.ghostty =
    { pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;
        package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
        enableZshIntegration = true;
        settings = {
          # Ghostty 1.2+ ships Title Case names; "tokyonight" no longer exists.
          theme = "TokyoNight Night";
          font-family = "Iosevka Nerd Font";
          font-size = 14;
          shell-integration = "zsh";
          command = "${pkgs.zsh}/bin/zsh";
        };
      };
    };
}
