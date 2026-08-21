{
  flake.modules.homeManager.applications =
    { pkgs, lib, ... }:
    {
      home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
        with pkgs;
        [
          the-unarchiver
          google-chrome
          discord
          dbeaver-bin
          orbstack
          temurin-bin
        ]
      );
    };
}
