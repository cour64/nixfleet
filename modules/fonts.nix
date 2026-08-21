{
  flake.modules.darwin.fonts =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
    };

  flake.modules.homeManager.fonts =
    { pkgs, lib, ... }:
    {
      fonts.fontconfig.enable = true;
      home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [
        pkgs.nerd-fonts.jetbrains-mono
      ];
    };
}
