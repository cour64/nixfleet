{
  flake.modules.nixos.steam = {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };

    # 32-bit drivers for Steam's runtime and many games.
    hardware.graphics.enable32Bit = true;
  };
}
