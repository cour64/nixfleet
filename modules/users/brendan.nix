{ self, ... }:
let
  username = "brendan";
in
{
  flake.modules.darwin.brendan =
    { pkgs, ... }:
    {
      system.primaryUser = username;

      users.users.${username} = {
        home = "/Users/${username}";
        description = username;
        shell = pkgs.zsh;
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "home-manager-backup";
        users.${username} = {
          imports = with self.modules.homeManager; [
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
        };
      };
    };

  flake.modules.homeManager.brendan =
    { pkgs, ... }:
    {
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
