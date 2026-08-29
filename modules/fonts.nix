let
  fonts =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
    };
in
{
  flake.modules.darwin.fonts = fonts;
  flake.modules.nixos.fonts = fonts;

  flake.modules.homeManager.fonts =
    { pkgs, lib, ... }:
    {
      fonts.fontconfig.enable = true;
      # System fonts.packages covers Darwin and NixOS hosts. Standalone Home
      # Manager on Linux has no system module, so install the face there too.
      home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [
        pkgs.nerd-fonts.jetbrains-mono
      ];
    };
}
