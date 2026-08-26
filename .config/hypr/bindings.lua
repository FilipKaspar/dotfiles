-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- ---------------------------------------------------------------------------
-- Personal bindings
-- ---------------------------------------------------------------------------

-- Omarchy 4 claims these three keys for its own apps; unbind before rebinding.

hl.unbind("SUPER + SHIFT + SLASH") -- was: 1Password
o.bind("SUPER + SHIFT + SLASH", "Passwords", "bitwarden-desktop")

hl.unbind("SUPER + SHIFT + A") -- was: ChatGPT
o.bind("SUPER + SHIFT + A", "Gemini", { webapp = "https://gemini.google.com" })

-- Keep the clipboard manager on SUPER+V. Omarchy 4 moved it to SUPER+CTRL+V
-- and gave SUPER+V to universal paste, so both defaults have to go.
hl.unbind("SUPER + V")
hl.unbind("SUPER + CTRL + V")
o.bind("SUPER + V", "Clipboard Manager", "omarchy-shell shell toggle omarchy.clipboard")

-- Media keys. omarchy-swayosd-client was removed in Omarchy 4; the shell now
-- owns media control and targets the focused monitor itself.
o.bind("SUPER + ALT + M", "Pause/Play", "omarchy-shell media playPause")
o.bind("SUPER + ALT + B", "Previous", "omarchy-shell media previous")
o.bind("SUPER + ALT + N", "Next", "omarchy-shell media next")

-- Also switch audio output on SUPER+Mute, alongside the Omarchy default of
-- SHIFT+Mute.
o.bind("SUPER + XF86AudioMute", "Switch audio output", "omarchy-audio-output-switch")

-- Custom scripts from ~/.local/bin.
o.bind("SUPER + Multi_Key", "Open Apps", "list_active_apps")
o.bind("SUPER + grave", "Toggle floating focus", "focus-toggle-float")

-- Todo list (willy.todos shell plugin, see ~/.config/omarchy/plugins/).
o.bind("SUPER + SHIFT + T", "Todos", "omarchy-shell shell toggle willy.todos")
