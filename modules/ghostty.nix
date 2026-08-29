{
  flake.modules.homeManager.ghostty =
    { pkgs, ... }:
    {
      programs.ghostty = {
        enable = true;
        package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
        enableZshIntegration = true;
        settings = {
          theme = "tokyonight";
          font-family = "Iosevka Nerd Font";
          font-size = 14;
          shell-integration = "zsh";
          command = "${pkgs.zsh}/bin/zsh";
        };
      };
    };
}
