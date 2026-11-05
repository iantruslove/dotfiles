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

config.color_scheme = 'Sequoia Moonlight'

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

return config
