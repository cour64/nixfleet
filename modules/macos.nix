{
  flake.modules.darwin.macos =
    { pkgs, ... }:
    {
      security.pam.services.sudo_local.touchIdAuth = true;

      environment.shells = [
        pkgs.bashInteractive
        pkgs.zsh
      ];

      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToEscape = true;

      system.defaults = {
        dock = {
          orientation = "bottom";
          autohide = true;
          magnification = false;
          tilesize = 32;
          showhidden = true;
          "show-recents" = false;
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
          _HIHideMenuBar = false;
        };
        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
        menuExtraClock.ShowSeconds = true;
        loginwindow.GuestEnabled = false;
      };
    };
}
