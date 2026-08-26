-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- ---------------------------------------------------------------------------
-- Personal look'n'feel
-- ---------------------------------------------------------------------------

-- Don't fade when the active window changes (e.g. moving between windows in a
-- group) -- the fade reads as lag when cycling quickly.
hl.animation({ leaf = "fadeSwitch", enabled = false })

-- Keep the focused window fully opaque. Omarchy tags most windows
-- "default-opacity" and applies "0.985 0.96" at the end of its own windows.lua;
-- re-applying the rule here (user config loads later) overrides just the active
-- value and leaves unfocused windows dimmed as before.
o.window({ tag = "default-opacity" }, { opacity = "1.0 0.96" })
