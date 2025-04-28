{
  inputs,
  username,
  pkgs,
  super,
  lib,
  ...
}:

let
  homeDir = "/Users/${username}";
in
{
  # imports = [
  #   ../modules/aerospace/darwin.nix
  # ];

  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    inputs.nur.overlays.default
    inputs.nix-vscode-extensions.overlays.default
  ];
  nixpkgs.hostPlatform = "aarch64-darwin"; # The platform the configuration will be used on.

  fonts.packages = with pkgs; [
    nerd-fonts.monaspace
    monaspace
  ];

  homebrew.enable = true;
  homebrew.casks = [
    "1password"
    "1password-cli"
    "the-unarchiver"
    "raycast"
    "linear-linear"
    "firefox"
    "google-chrome"
    "discord"
    "imageoptim"
    "dbeaver-community"
    "orbstack"
    "httpie"
    "hammerspoon"
  ];
  homebrew.onActivation.cleanup = "zap";
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.upgrade = true;
  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;
    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;
    # User owning the Homebrew prefix
    user = username;
    # Automatically migrate existing Homebrew installations
    autoMigrate = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${username}" = {
      imports = [
        ../modules/shell/home.nix
        ../modules/vscode/home.nix
        ../modules/firefox/home.nix
        ../modules/wezterm/home.nix
        ../modules/direnv/home.nix
        ../modules/darwin-core/home.nix
        ../modules/awscli/home.nix
      ];
      fonts.fontconfig.enable = true;
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
    extraSpecialArgs = {
      inherit inputs;
      inherit username;
    };
    backupFileExtension = "home-manager-backup";
  };

  security.pam.services.sudo_local.touchIdAuth = true;
  programs.zsh.enable = true;
  environment.shells = [
    pkgs.bashInteractive
    pkgs.zsh
  ];
  environment.systemPackages = [ pkgs.coreutils ];
  environment.pathsToLink = [
    "/opt/homebrew/bin" # Apple silicon
  ];

  users.users."${username}" = {
    home = homeDir;
    description = username;
    shell = pkgs.zsh;
  };

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;
  system.defaults = {
    dock = {
      orientation = "left";
      autohide = true;
      magnification = false; # Enable dock icon magnification (false to disable)
      tilesize = 32; # Set the size of app icons
      showhidden = true;
      "show-recents" = false; # Disable recent apps and documents in the dock
      "show-process-indicators" = true;
      "mouse-over-hilite-stack" = true;
      "appswitcher-all-displays" = true;
      mineffect = "suck";
    };
    finder = {
      FXPreferredViewStyle = "clmv";
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
      AppleShowAllFiles = true;
      _FXShowPosixPathInTitle = true;
      QuitMenuItem = true;
    };
    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticWindowAnimationsEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticInlinePredictionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      NSDisableAutomaticTermination = false;
      AppleSpacesSwitchOnActivate = true;
      AppleScrollerPagingBehavior = true;
      NSWindowShouldDragOnGesture = true;
      NSTableViewDefaultSizeMode = 1;
      ApplePressAndHoldEnabled = false;
      NSScrollAnimationEnabled = true;
      NSUseAnimatedFocusRing = false;
      AppleMetricUnits = 1;
      AppleMeasurementUnits = "Centimeters";
      AppleTemperatureUnit = "Celsius";
      AppleShowScrollBars = "Always";
      NSWindowResizeTime = 0.3;
      AppleFontSmoothing = 2;
      _HIHideMenuBar = true;
    };
    universalaccess = {
      closeViewScrollWheelToggle = true;
      closeViewZoomFollowsFocus = true;
      reduceTransparency = true;
      reduceMotion = true;
    };
    # WindowManager = {
    #   GloballyEnabled = false;
    #   AppWindowGroupingBehavior = true;
    # };
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
    menuExtraClock.ShowSeconds = true;
    loginwindow.GuestEnabled = false;
  };
  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
