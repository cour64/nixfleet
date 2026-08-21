{ self, inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      inherit (pkgs) lib;

      sharedHomeModules = with self.modules.homeManager; [
        brendan
        fonts
        packages
        applications
        zsh
        git
        ssh
        tmux
        cli-tools
        ghostty
        nvim
        direnv
        nodejs
        onepassword
      ];

      evalHome =
        targetSystem:
        let
          targetPkgs = import inputs.nixpkgs {
            system = targetSystem;
            config.allowUnfree = true;
            overlays = [
              (final: prev: {
                unstable = import inputs.nixpkgs-unstable {
                  inherit (prev) system;
                  config.allowUnfree = true;
                };
              })
            ];
          };
          hm = inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = targetPkgs;
            modules = [
              { nixpkgs.config.allowUnfree = true; }
            ]
            ++ sharedHomeModules;
          };
        in
        # Forces evaluation of the portable option set and instantiates every
        # package derivation, so a package unavailable on the target platform
        # fails here rather than on a future Linux machine.
        pkgs.writeText "home-${targetSystem}-eval" ''
          homeDirectory=${hm.config.home.homeDirectory}
          ghostty=${lib.boolToString hm.config.programs.ghostty.enable}
          identityAgent=${hm.config.programs.ssh.settings."*".data.IdentityAgent}
          packages=${
            builtins.hashString "sha256" (lib.concatMapStringsSep " " (p: p.drvPath) hm.config.home.packages)
          }
        '';
    in
    {
      formatter = pkgs.nixfmt-tree;

      checks = {
        home-portable = evalHome system;
        home-x86_64-linux = evalHome "x86_64-linux";
        home-aarch64-linux = evalHome "aarch64-linux";
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        workmac = self.darwinConfigurations.workmac.config.system.build.toplevel;
      };
    };
}
