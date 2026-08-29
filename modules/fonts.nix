let
  fonts =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        inter
        nerd-fonts.iosevka
      ];
    };
in
{
  flake.modules.darwin.fonts = fonts;
  flake.modules.nixos.fonts = fonts;

  flake.modules.homeManager.fonts =
    { pkgs, lib, ... }:
    {
      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = [ "Inter" ];
          serif = [ "Inter" ];
          monospace = [ "Iosevka Nerd Font" ];
        };
      };

      # System fonts.packages covers Darwin and NixOS hosts. Standalone Home
      # Manager on Linux has no system module, so install the faces there too.
      home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [
        pkgs.inter
        pkgs.nerd-fonts.iosevka
      ];

      gtk = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        enable = true;
        font = {
          name = "Inter";
          size = 11;
        };
      };
    };
}
