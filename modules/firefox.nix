{
  flake.modules.homeManager.firefox =
    { pkgs, ... }:
    {
      programs.firefox = {
        enable = true;
        # Lets the 1Password desktop app talk to the extension (NixOS module
        # already wraps BrowserSupport).
        nativeMessagingHosts = [ pkgs._1password-gui ];
        policies = {
          DisableTelemetry = true;
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
          };
        };
      };
    };
}
