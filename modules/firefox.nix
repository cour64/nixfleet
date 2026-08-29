{
  flake.modules.homeManager.firefox =
    { pkgs, config, ... }:
    {
      programs.firefox = {
        enable = true;
        # New Linux home: use the 26.05 XDG profile path, not ~/.mozilla/firefox.
        configPath = "${config.xdg.configHome}/mozilla/firefox";
        # Lets the 1Password desktop app talk to the extension (NixOS module
        # already wraps BrowserSupport).
        nativeMessagingHosts = [ pkgs._1password-gui ];
        policies = {
          DisableTelemetry = true;
          # Compact mode: browser.uidensity 0=normal 1=compact 2=touch.
          # compactmode.show keeps the density option visible in Customize.
          Preferences = {
            "browser.uidensity" = {
              Value = 1;
              Status = "active";
            };
            "browser.compactmode.show" = {
              Value = true;
              Status = "active";
            };
          };
          ExtensionSettings = {
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
              default_area = "navbar";
              private_browsing = true;
            };
            "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
              installation_mode = "force_installed";
              default_area = "navbar";
              private_browsing = true;
            };
            "{4520dc08-80f4-4b2e-982a-c17af42e5e4d}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/tokyo-night-milav/latest.xpi";
              installation_mode = "force_installed";
            };
          };
        };
      };
    };
}
