{ username, pkgs, ... }:
{
  programs.wayland.enable = true;
  services.dbus.enable = true;
  services.gnome-keyring.enable = true;
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function (action, subject) {
      if (
        subject.isInGroup("users") &&
        [
          "org.freedesktop.login1.reboot",
          "org.freedesktop.login1.reboot-multiple-sessions",
          "org.freedesktop.login1.power-off",
          "org.freedesktop.login1.power-off-multiple-sessions",
        ].indexOf(action.id) !== -1
      ) {
        return polkit.Result.YES;
      }
    });
  '';

  environment.systemPackages = with pkgs; [
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
    swaynag # error bar
    swaybar # simple status bar
    swaybg # set wallpaper
    wmenu # dmenu for wayland
    xdg-utils # Set of command line tools that assist applications with a variety of desktop integration tasks
  ];

  # enable Sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = [ ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
        user = username;
      };
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
