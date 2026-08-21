{
  flake.modules.darwin.packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        coreutils
        ffmpeg
      ];
    };

  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        tree
        wget
        curl
        jq
        gum
        hostctl
        gh
      ];
    };
}
