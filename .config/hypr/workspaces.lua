-- Workspace pinning and app placement.
--
-- shikane owns the physical display layout (mode, position, scale); these rules
-- only decide which workspace lands on which output, and what opens where.

-- Persistent keeps all ten alive even when empty. The bar widget only renders
-- workspaces that exist (beyond the 1-5 it hardcodes), so without this 6-10
-- vanish from the bar whenever they have no windows.

-- Primary monitor.
for ws = 1, 5 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = "HDMI-A-1", persistent = true })
end

-- Secondary monitor.
for ws = 6, 10 do
  hl.workspace_rule({ workspace = tostring(ws), monitor = "DP-1", persistent = true })
end

-- Map apps to workspaces.
o.window("com.mitchellh.ghostty", { workspace = "1" })
o.window("jetbrains.*", { workspace = "2", group = "set always" })
o.window("code", { workspace = "2", group = "set always" })
o.window("cursor", { workspace = "2", group = "set always" })
o.window("brave-browser", { workspace = "3" })
o.window("zen", { workspace = "3" })
o.window("slack", { workspace = "8" })
o.window("signal", { workspace = "9", group = "set always" })
o.window("BeeperTexts", { workspace = "9", group = "set always" })
o.window("chrome-discord.com__channels_@me-Default", { workspace = "9", group = "set always" })
o.window("Spotify", { workspace = "10" })
-- cliamp is a TUI in ghostty; omarchy-launch-tui gives it app-id org.omarchy.cliamp
o.window("org.omarchy.cliamp", { workspace = "10" })

-- The file chooser shares ghostty's class, so exempt it from the workspace 1
-- rule above and let it float instead.
o.window(
  { class = "^(com\\.mitchellh\\.ghostty)$", title = "^(termfilechooser)$" },
  { workspace = "unset", tag = "+floating-window" }
)
