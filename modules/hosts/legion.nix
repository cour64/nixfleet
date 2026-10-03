{ self, inputs, ... }:
{
  flake.nixosConfigurations.legion = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.modules.nixos.legion ];
  };

  flake.modules.nixos.legion = {
    imports = [
      ./_legion/hardware.nix
    ]
    ++ (with self.modules.nixos; [
      nix
      fonts
      packages
      zsh
      onepassword
      keyring
      docker
      brendan
    ]);

    nixpkgs.hostPlatform = "x86_64-linux";
    system.configurationRevision = self.rev or self.dirtyRev or null;
    system.stateVersion = "26.05";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "legion";
    # Kiff dev stack (docker compose): Caddy TLS endpoints resolve to loopback.
    # The web origin is a real domain (ilow.stream) because the atproto PDS
    # rejects OAuth client_ids whose TLD is a local one (.test/.local/…).
    # pds.test stays: the PDS issuer was never affected, and moving it would
    # invalidate every dev account.
    networking.hosts = {
      "127.0.0.1" = [ "kiff.ilow.stream" "pds.test" ];
    };
    networking.networkmanager.enable = true;

    time.timeZone = "Europe/London";

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

    services.xserver.xkb = {
      layout = "gb";
      variant = "";
    };
    console.keyMap = "uk";

    services.openssh.enable = true;
  };
}
