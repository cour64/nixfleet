{ self, ... }:
{
  flake.modules.homeManager.kanshi =
    { pkgs, ... }:
    let
      tv = "HDMI-A-1";
      builtin = "eDP-1";
    in
    {
      services.kanshi = {
        enable = true;
        settings = [
          {
            profile.name = "tv";
            profile.outputs = [
              { criteria = tv; }
              { criteria = builtin; status = "disable"; }
            ];
          }
          {
            profile.name = "builtin";
            profile.outputs = [ { criteria = builtin; } ];
          }
        ];
      };
    };
}
