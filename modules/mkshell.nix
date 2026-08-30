{ pkgs, ... }:
{
  flake.modules.homeManager.mkshell =
    { pkgs, ... }:
    let
      # Single-file bash script; shellcheck runs as part of the build.
      mkshell = pkgs.writeShellApplication {
        name = "mkshell";
        text = builtins.readFile ./mkshell/mkshell;
        runtimeInputs = with pkgs; [
          coreutils
          gnugrep
          gnused
          gawk
        ];
      };
    in
    {
      home.packages = [ mkshell ];
    };
}
