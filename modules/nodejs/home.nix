{ pkgs, ... }:

{
  home.packages = [
    pkgs.nodejs_24
  ];

  # Set npm prefix
  home.file.".npmrc".text = ''
    prefix=$HOME/.npm-global
  '';

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  # Add npm global bin to PATH
  home.sessionPath = [
    "$HOME/.npm-global/bin"
  ];

  # Ensure the directory exists
  home.activation.npmGlobalDir = ''
    mkdir -p $HOME/.npm-global/bin
  '';
}
