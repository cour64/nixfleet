{ self, inputs, ... }:
let
  username = "brendan";

  homeManager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "home-manager-backup";
    users.${username}.imports = [ self.modules.homeManager.brendan ];
  };
in
{
  flake.modules.darwin.brendan =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.darwinModules.home-manager ];

      system.primaryUser = username;

      users.users.${username} = {
        home = "/Users/${username}";
        description = username;
        shell = pkgs.zsh;
      };

      home-manager = homeManager;
    };

  flake.modules.nixos.brendan =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        home = "/home/${username}";
        description = username;
        shell = pkgs.zsh;
      };

      # Required for 1Password CLI integration and system unlock on NixOS.
      programs._1password-gui.polkitPolicyOwners = [ username ];

      home-manager = homeManager;
    };

  flake.modules.homeManager.brendan =
    { pkgs, lib, ... }:
    {
      imports =
        with self.modules.homeManager;
        [
          fonts
          packages
          zsh
          git
          ssh
          tmux
          cli-tools
          ghostty
          nvim
          direnv
          onepassword
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
          applications
          nodejs
        ];

      home.username = username;
      home.homeDirectory =
        if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";
      home.stateVersion = "24.11";
      home.preferXdgDirectories = true;
      xdg.enable = true;
      programs.home-manager.enable = true;

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        SHELL = "${pkgs.zsh}/bin/zsh";
        LANG = "en_GB.UTF-8";
        LC_ALL = "en_GB.UTF-8";
      };
    };
}
