-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()


-- Use the defaults as a base
config.hyperlink_rules = wezterm.default_hyperlink_rules()


-- config.exit_behavior = 'Hold'
config.window_close_confirmation = 'AlwaysPrompt'
config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}

config.font_size = 13.8
config.warn_about_missing_glyphs = true
config.freetype_load_target = 'HorizontalLcd' -- https://wezfurlong.org/wezterm/config/lua/config/freetype_load_target.html

-- Monaspace:  https://monaspace.githubnext.com/
-- Based upon, contributed to:  https://gist.github.com/ErebusBat/9744f25f3735c1e0491f6ef7f3a9ddc3
config.font = wezterm.font(
  { -- Normal text
  family='Monaspace Neon',
  harfbuzz_features={ 'calt', 'liga', 'dlig', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08' },
  stretch='UltraCondensed', -- This doesn't seem to do anything
})

config.font_rules = {
  { -- Italic
    intensity = 'Normal',
    italic = true,
    font = wezterm.font({
      -- family="Monaspace Radon",  -- script style
      family='Monaspace Radon', -- courier-like
      style = 'Italic',
    })
  },

  { -- Bold
    intensity = 'Bold',
    italic = false,
    font = wezterm.font( {
      family='Monaspace Krypton',
      family='Monaspace Krypton',
      -- weight='ExtraBold',
      weight='Bold',
      })
  },

  { -- Bold Italic
    intensity = 'Bold',
    italic = true,
    font = wezterm.font( {
      family='Monaspace Radon',
      style='Italic',
      weight='Bold',
      }
    )
  },
}

config.color_scheme = 'tokyonight_night'

-- and finally, return the configuration to wezterm
return config