{ self, inputs, ... }:
{
  flake.modules.nixos.hyprland =
    { lib, pkgs, ... }:
    let
      # Not-restart-on-switch markers for uwsm's session units.
      # restartIfChanged=false is emitted as X-RestartIfChanged=false into the
      # [Service] section; targets and slices need the directive set
      # explicitly via unitConfig.
      uwsmService = {
        restartIfChanged = false;
        overrideStrategy = "asDropin";
      };
      uwsmUnit = {
        overrideStrategy = "asDropin";
        unitConfig."X-RestartIfChanged" = "no";
      };
    in
    {
      imports = [
        inputs.noctalia.nixosModules.default
        inputs.noctalia-greeter.nixosModules.default
        self.modules.nixos.nvidia
      ];

      # Do not use the upstream overlays: they callPackage against this flake's
      # nixpkgs and miss Cachix. Alias the packages CI actually built.
      nixpkgs.overlays = [
        (_final: prev: {
          noctalia = inputs.noctalia.packages.${prev.stdenv.hostPlatform.system}.default;
          noctalia-greeter = inputs.noctalia-greeter.packages.${prev.stdenv.hostPlatform.system}.default;
        })
      ];

      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };

      # switch-to-configuration-ng restarts package-shipped user units whose
      # store path changed (e.g. uwsm after a nixpkgs update). Stopping
      # wayland-session-bindpid@.service fires its OnSuccess= -> session
      # shutdown, tearing the whole Hyprland session down mid-switch; the
      # rebuild's terminal dies with it and switch-to-configuration aborts
      # (exit 101), leaving the switch half-applied. Same root cause as nixpkgs
      # PR #536457 (GNOME): mark uwsm's session units as not-restart-on-switch.
      # Drop-ins overlay the package's own units, so they stay intact.
      # NOTE: NixOS appends .service/.target to the attribute name, so template
      # names must NOT include the suffix — "wayland-wm@.service" produced a
      # drop-in under wayland-wm@.service.service.d/, which nothing loads.
      systemd.user.services = {
        "wayland-session-bindpid@" = uwsmService;
        "wayland-wm@" = uwsmService // {
          # uwsm's default service PATH is only coreutils/findutils/grep/sed/
          # systemd, but Hyprland's start-hyprland watchdog execvp()s
          # "Hyprland" by bare name. Without its bin dir on PATH the session
          # dies at login ("fork(): execvp failed: No such file or
          # directory"), the greeter falls back to a non-systemd launch, and
          # everything keyed to graphical-session.target (kanshi, portals)
          # never starts.
          # The rest mirrors /etc/set-environment's PATH: every command
          # Hyprland execs (terminal keybinds, app launchers) inherits this
          # PATH, and home-manager installs (ghostty, pi) live in the
          # per-user profile, not /run/current-system/sw/bin — without those
          # dirs the uwsm session can't find any user commands. systemd does
          # not expand $HOME/%h in Environment=, so the paths are literal.
          environment.PATH = lib.mkForce (lib.makeBinPath [ pkgs.hyprland ]
            + ":/run/wrappers/bin:/home/brendan/.nix-profile/bin:/home/brendan/.local/state/nix/profile/bin:/etc/profiles/per-user/brendan/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin");
        };
        "wayland-wm-env@" = uwsmService;
        "wayland-wm-app-daemon" = uwsmService;
        "wayland-session-waitenv" = uwsmService;
        fumon = uwsmService;
      };

      systemd.user.targets = {
        "wayland-session@" = uwsmUnit;
        "wayland-session-pre@" = uwsmUnit;
        "wayland-session-envelope@" = uwsmUnit;
        "wayland-session-xdg-autostart@" = uwsmUnit;
        "wayland-session-shutdown" = uwsmUnit;
      };

      systemd.user.slices = {
        "session-graphical.slice" = uwsmUnit;
        "app-graphical.slice" = uwsmUnit;
        "background-graphical.slice" = uwsmUnit;
      };

      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };

      services.displayManager.noctalia-greeter = {
        enable = true;
        settings = {
          session.default = "Hyprland (uwsm-managed)";
          user.default = "brendan";
          keyboard.layout = "gb";
          appearance = {
            scheme = "Tokyo-Night";
            theme_mode = "dark";
            font_family = "Inter";
          };
        };
      };

      nix.settings = {
        extra-substituters = [ "https://noctalia.cachix.org" ];
        extra-trusted-public-keys = [
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        ];
      };

      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      security.polkit.enable = true;
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      hardware.bluetooth.enable = true;
      hardware.bluetooth.settings.General.AlwaysPairable = true;

      services.blueman.enable = true;

      programs.thunar.enable = true;
    };

  flake.modules.homeManager.hyprland =
    { pkgs, ... }:
    {
      imports = [ inputs.noctalia.homeModules.default ];

      # Adwaita instead of Hyprland's default hyprcursor theme.
      home.pointerCursor = {
        enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
        hyprcursor.enable = true;
      };

      wayland.windowManager.hyprland = {
        enable = true;
        # UWSM owns the session; the Home Manager systemd integration conflicts with it.
        systemd.enable = false;
        # 26.05 defaults to lua; keep this explicit so a stateVersion bump cannot
        # silently switch the file format.
        configType = "lua";
        extraConfig = ''
          local mainMod = "SUPER"
          local ipc = "noctalia msg "

          hl.on("hyprland.start", function()
            hl.exec_cmd("noctalia")
            hl.exec_cmd("hyprctl setcursor Adwaita 24")
          end)

          hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
          hl.env("XCURSOR_THEME", "Adwaita")
          hl.env("XCURSOR_SIZE", "24")

          hl.config({
            animations = {
              enabled = false,
            },
            general = {
              gaps_in = 5,
              gaps_out = 10,
            },
            decoration = {
              rounding = 4,
              rounding_power = 2,
              shadow = {
                enabled = true,
                range = 4,
                render_power = 3,
                color = 0xee1a1a1a,
              },
              blur = {
                enabled = true,
                size = 3,
                passes = 2,
                vibrancy = 0.1696,
              },
            },
            input = {
              kb_layout = "gb",
              follow_mouse = 1,
            },
          })

          hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("ghostty"))
          hl.bind(mainMod .. " + Q", hl.dsp.window.close())
          hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
          hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
          hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
          hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))
          hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
          hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
          hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
          hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
          hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
          hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
          hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
          hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

          for i = 1, 9 do
            hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
            hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
          end

          hl.bind(mainMod .. "+Space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
          hl.bind(mainMod .. "+S", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
          hl.bind(mainMod .. "+comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
          hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher"))

          hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"))
          hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"))
          hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"))
          hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"))
          hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"))

          hl.window_rule({
            match = { class = "dev.noctalia.Noctalia" },
            float = true,
            size = { 1080, 920 },
          })

          -- 1Password's Electron dialogs (SSH authorize, unlock) get tiled and
          -- their buttons clipped; keep them floating and centered instead.
          hl.window_rule({
            match = { class = "1Password" },
            float = true,
            pin = true,
            center = true,
          })

          hl.layer_rule({
            name = "noctalia",
            match = {
              namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
            },
            no_anim = true,
            ignore_alpha = 0.5,
            blur = true,
            blur_popups = true,
          })
        '';
      };

      programs.noctalia = {
        enable = true;
        systemd.enable = false;
        settings = {
          theme = {
            mode = "dark";
            source = "builtin";
            builtin = "Tokyo-Night";
          };
          shell = {
            font_family = "Inter";
            polkit_agent = true;
            # Disable Noctalia's own UI animations (panels, toasts, OSD).
            animation.enabled = false;
          };
          bar.default = {
            # Built-in default is 100px inset from each end.
            margin_ends = 0;
            thickness = 28;
            padding = 10;
            scale = 0.9;
          };
        };
      };
    };
}
