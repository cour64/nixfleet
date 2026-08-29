let
  packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        coreutils
        ffmpeg
      ];
    };
in
{
  flake.modules.darwin.packages = packages;
  flake.modules.nixos.packages = packages;

  flake.modules.homeManager.packages =
    { pkgs, lib, ... }:
    {
      home.packages =
        with pkgs;
        [
          tree
          wget
          curl
          jq
          # Not backported to 26.05; merged into unstable on 2026-08-25.
          unstable.tuicr
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
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
