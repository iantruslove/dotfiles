-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 140
config.initial_rows = 50

-- or, changing the font size and color scheme.
config.font_size = 12
-- config.color_scheme = 'Monokai Soda'
config.color_scheme = 'Selenized Dark (Gogh)'
-- config.color_scheme = 'Modus Vivendi (Gogh)'

config.keys = {
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = wezterm.action.SendString '\n',
  },
}

wezterm.on(
  'update-right-status',
  function(window, pane)
    local process = pane:get_foreground_process_name() or ''
    local title = pane:get_title() or ''

    if title:find('ian@nuc') then
      window:set_config_overrides({
          color_scheme = 'Sequoia Moonlight',
      })
    else
      window:set_config_overrides({
      })
    end
end)

-- Finally, return the configuration to wezterm:
return config
