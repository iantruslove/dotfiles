-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.enable_kitty_keyboard = true

config.initial_cols = 140
config.initial_rows = 50

config.font_size = 12

config.enable_tab_bar = false

config.window_frame = {
  border_left_width = 1,
  border_right_width = 1,
  border_bottom_height = 1,
  border_top_height = 1,

  border_left_color = '#444444',
  border_right_color = '#444444',
  border_bottom_color = '#444444',
  border_top_color = '#444444',
}

-- config.color_scheme = 'Selenized Dark (Gogh)'
-- config.color_scheme = 'Modus Vivendi (Gogh)'
-- config.color_scheme = 'Monokai Soda'
config.color_scheme = 'Sequoia Moonlight'
-- config.color_scheme = 'Tomorrow Night Blue'
-- config.color_scheme = 'tlh (terminal.sexy)'

config.keys = {
  -- Fix shift-enter for claude code
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = wezterm.action.SendString '\n',
  },
  -- fix ctrl-backspace for ssm emacs
  {
    key = 'Backspace',
    mods = 'CTRL',
    action = wezterm.action.SendString('\x1b\x7f'),
  },

}

-- Switch theme based on ssh
wezterm.on(
  'update-right-status',
  function(window, pane)
    local process = pane:get_foreground_process_name() or ''
    local title = pane:get_title() or ''

    if title:find('ian@nuc') then
      window:set_config_overrides({
          color_scheme = 'Sequoia Moonlight'
      })
    else
      window:set_config_overrides({
      })
    end
end)

return config
