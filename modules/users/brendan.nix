{ self, inputs, ... }:
let
  username = "brendan";

  homeManager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "home-manager-backup";
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

      home-manager = homeManager // {
        users.${username}.imports = with self.modules.homeManager; [
          brendan
          applications
          nodejs
        ];
      };
    };

  flake.modules.nixos.brendan =
    { pkgs, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
        self.modules.nixos.hyprland
        self.modules.nixos.steam
      ];

      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "input"
          "docker"
        ];
        home = "/home/${username}";
        description = username;
        shell = pkgs.zsh;
      };

      # Required for 1Password CLI integration and system unlock on NixOS.
      programs._1password-gui.polkitPolicyOwners = [ username ];

      home-manager = homeManager // {
        users.${username}.imports = with self.modules.homeManager; [
          brendan
          hyprland
          kanshi
          firefox
          opencode
          omp
        ];
      };
    };

  flake.modules.homeManager.brendan =
    { pkgs, ... }:
    {
      imports = with self.modules.homeManager; [
        fonts
        packages
        zsh
        git
        ssh
        tmux
        cli-tools
        ghostty
        herdr
        nvim
        direnv
        mkshell
        onepassword
      ];

      home.username = username;
      home.homeDirectory =
        if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";
      home.stateVersion = "26.05";
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
