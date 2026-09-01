{
  flake.modules.nixos.steam =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };

      # 32-bit drivers for Steam's runtime and many games.
      hardware.graphics.enable32Bit = true;

      programs.gamemode.enable = true;

      services.udev.packages = [ pkgs.game-devices-udev-rules ];
    };
}
