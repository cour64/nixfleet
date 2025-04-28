{ lib, pkgs, ... }:
{
  home.file.".hammerspoon" = {
    source = ./hammerspoon;
    recursive = true;
  };
  # services.skhd = {
  #   enable = true;
  #   package = pkgs.skhd;
  #   config = ''
  #     # open terminal
  #     cmd - return : open -n -a "WezTerm"

  #     # open firefox
  #     cmd + shift - return : open -n -a "Firefox"
  #   '';
  # };
  # home.activation = {
  #   # First, clean up any existing Home Manager Apps folder before anything else
  #   cleanUpPreLinkTargets = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
  #     app_folder="$(echo ~/Applications)/Home Manager Apps"
  #     run rm -rf "$app_folder"
  #   '';

  #   # First, clean up any existing Home Manager Apps folder before anything else
  #   cleanUpPreLinkGeneration = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
  #     app_folder="$(echo ~/Applications)/Home Manager Apps"
  #     run rm -rf "$app_folder"
  #   '';

  #   # This should be removed once
  #   # https://github.com/nix-community/home-manager/issues/1341 is closed.
  #   aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #     app_folder="$(echo ~/Applications)/Home Manager Apps"
  #     home_manager_app_folder="$genProfilePath/home-path/Applications"

  #     # NB: aliasing ".../home-path/Applications" to "~/Applications/Home Manager Apps" doesn't
  #     #     work (presumably because the individual apps are symlinked in that directory, not
  #     #     aliased). So this makes "Home Manager Apps" a normal directory and then aliases each
  #     #     application into there directly from its location in the nix store.
  #     run rm -rf "$app_folder"
  #     run mkdir -p "$app_folder"

  #     find "$newGenPath/home-path/Applications" -type l -exec readlink -f {} \; | while IFS= read -r app;
  #     do
  #       app_name="$(basename "$app")"
  #       run /usr/bin/osascript \
  #         -e "tell app \"Finder\"" \
  #         -e "make new alias file at POSIX file \"$app_folder\" to POSIX file \"$app\"" \
  #         -e "set name of result to \"$app_name\"" \
  #         -e "end tell"
  #     done
  #   '';
  # };
}
