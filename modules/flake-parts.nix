# Enable the flake.modules option used by the dendritic pattern.
{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];
}
