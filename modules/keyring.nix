{
  flake.modules.nixos.keyring = {
    # Fills the freedesktop Secret Service gap: 1Password does not implement
    # it, so libsecret clients (Discord, Electron apps, …) need a daemon to
    # talk to. Seahorse is its GUI manager and provides ssh-askpass.
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;

    # The gnome-keyring module only wires PAM unlocking for `login`; the
    # noctalia greeter authenticates through greetd's PAM service instead.
    security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
