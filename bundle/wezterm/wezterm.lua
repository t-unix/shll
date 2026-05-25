local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Runtime OS detection. Single config file works on macOS / Linux / Windows.
local triple = wezterm.target_triple
local is_macos   = triple:find("darwin") ~= nil
local is_windows = triple:find("windows") ~= nil
local mod_key    = is_macos and "CMD" or "SUPER"

-- Font + appearance ---------------------------------------------------------

config.font      = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium" })
config.font_size = 14.0

config.colors = {
  background = "#000000",
}

config.enable_tab_bar = false

if is_macos then
  config.native_macos_fullscreen_mode = false
end

config.set_environment_variables = {
  TERM = "xterm-256color",
}

config.send_composed_key_when_left_alt_is_pressed  = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Outer-tmux launcher --------------------------------------------------------
-- Looks for `wezterm-outer-tmux.sh` in $HOME/bin (the install/render skill
-- drops it there). On Windows, fall back to the default shell.

if not is_windows then
  local launcher = os.getenv("HOME") .. "/bin/wezterm-outer-tmux.sh"
  local f = io.open(launcher, "r")
  if f then
    f:close()
    config.default_prog = { launcher }
  end
end

-- Key bindings ---------------------------------------------------------------

config.keys = {
  -- Alt+F → fullscreen (cross-platform)
  { key = "f", mods = "ALT", action = wezterm.action.ToggleFullScreen },

  -- Cmd/Super+R → outer-tmux prefix (C-], 0x1D)
  { key = "r", mods = mod_key, action = wezterm.action.SendString("\x1d") },

  -- Cmd/Super+E → inner-tmux prefix (C-\, 0x1C)
  { key = "e", mods = mod_key, action = wezterm.action.SendString("\x1c") },

  -- Cmd/Super+W → C-_ (0x1F) — utility chord
  { key = "w", mods = mod_key, action = wezterm.action.SendString("\x1f") },

  -- Ctrl+S → C-_ — portable fallback for Linux WMs that swallow Super
  { key = "s", mods = "CTRL", action = wezterm.action.SendString("\x1f") },
}

return config
