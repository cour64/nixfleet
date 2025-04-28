{ ... }:
{
  services.aerospace.enable = true;
  services.aerospace.settings = builtins.fromTOML (builtins.readFile ./aerospace.toml);
}
