-- Extra autostart processes.
-- o.launch_on_start("my-service")

o.launch_on_start("hyprsunset")

-- Start on workspace 1 rather than wherever the last session left off.
o.exec_on_start("hyprctl dispatch workspace 1")

-- Both dock into the system tray, which isn't up yet when Hyprland starts.
o.exec_on_start("sleep 10 && QT_QPA_PLATFORM=xcb uwsm-app -- aw-qt")
o.exec_on_start("sleep 10 && uwsm-app -- bitwarden-desktop")
