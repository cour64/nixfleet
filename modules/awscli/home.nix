{ pkgs, ... }:

{
  programs.awscli = {
    enable = true;
    settings = {
      "default" = {
        region = "eu-west-1";
        output = "json";
      };
    };
  };
}
