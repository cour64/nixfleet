{
  flake.modules.homeManager.nodejs =
    { pkgs, lib, ... }:
    {
      home.packages = [ pkgs.nodejs_26 ];

      home.file.".npmrc".text = ''
        prefix=$HOME/.npm-global
      '';

      home.sessionVariables = {
        NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      };

      home.sessionPath = [ "$HOME/.npm-global/bin" ];

      home.activation.npmGlobalDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.npm-global/bin"
      '';
    };
}
