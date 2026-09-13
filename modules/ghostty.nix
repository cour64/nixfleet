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
          # Term + Mono: Iosevka's default Nerd patch leaves icons double-width
          # against the narrow Latin glyphs. Term metrics and Mono cell width
          # keep powerline/prompt icons aligned.
          font-family = "IosevkaTerm Nerd Font Mono";
          font-size = 12;
          shell-integration = "zsh";
          command = "${pkgs.zsh}/bin/zsh";
        };
      };
    };
}
