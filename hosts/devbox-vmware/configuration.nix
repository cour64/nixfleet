# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/swaywm/nixos.nix
    ../../modules/fonts/nixos.nix
    ../../modules/1password/nixos.nix
    ../../modules/dbeaver/nixos.nix
    ../../modules/docker/nixos.nix
  ];

  nix.settings.experimental-features = "nix-command flakes";

  virtualisation.vmware.guest.enable = true;
  fileSystems."/mnt/macos/brendan" = {
    device = ".host:/brendan";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options = [
      "defaults"
      "allow_other"
      "uid=1000"
      "gid=100"
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_DIRS = "/etc/xdg";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_DIRS = "/usr/local/share/:/usr/share/";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.brendan = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${username}" = {
      imports = [
        ../../modules/shell/home.nix
        ../../modules/ghostty/home.nix
        ../../modules/direnv/home.nix
      ];
      home.username = username;
      home.homeDirectory = homeDir;
      home.stateVersion = "24.11";
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        HOME = homeDir;
        SHELL = pkgs.zsh;
        LANG = "en_GB.UTF-8";
        LC_ALL = "en_GB.UTF-8";
      };
      home.preferXdgDirectories = true;
      xdg.enable = true;
      programs.home-manager.enable = true;
    };
    extraSpecialArgs = { inherit inputs; inherit username; };
    backupFileExtension = "home-manager-backup";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
