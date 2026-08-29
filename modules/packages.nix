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
      ];

      # Stable nixpkgs lags upstream; take gh and its extensions from unstable.
      programs.gh = {
        enable = true;
        package = pkgs.unstable.gh;
        extensions = [ pkgs.unstable.gh-stack ];
      };
    };
}
