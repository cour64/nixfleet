{ self, inputs, ... }:
{
  flake.modules.nixos.hyprland = {
    imports = [
      inputs.noctalia.nixosModules.default
      inputs.noctalia-greeter.nixosModules.default
      self.modules.nixos.nvidia
    ];

    nixpkgs.overlays = [
      inputs.noctalia.overlays.default
      inputs.noctalia-greeter.overlays.default
    ];

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };

    programs.noctalia-greeter = {
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
  };

  flake.modules.homeManager.hyprland = {
    imports = [ inputs.noctalia.homeModules.default ];

    wayland.windowManager.hyprland = {
      enable = true;
      # UWSM owns the session; the Home Manager systemd integration conflicts with it.
      systemd.enable = false;
      # home.stateVersion is 24.11, which would still emit hyprland.conf.
      configType = "lua";
      extraConfig = ''
        local mainMod = "SUPER"
        local ipc = "noctalia msg "

        hl.on("hyprland.start", function()
          hl.exec_cmd("noctalia")
        end)

        hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

        hl.config({
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
        };
      };
    };
  };
}
