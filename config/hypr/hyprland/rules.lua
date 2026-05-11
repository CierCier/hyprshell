require("hyprland.utils")
local colors = require("colors")

-- Window Rules
frule("clipse", "800 650")
frule("(thunar|org\\.kde\\.dolphin)", "800 600", "filemanager-float")
frule("(org\\.pulseaudio\\.pavucontrol|blueberry\\.py|org\\.gnome\\.Settings)", "800 600", "settings-float")
frule("(rmpc|Cider|cider)", "1080 540", "music-float")
frule("(steam|Steam)")

hl.window_rule({
    name = "fullscreen-immediate",
    match = { fullscreen = true },
    immediate = true,
    opacity = "1.0 override"
})

hl.window_rule({
    name = "pin-bordercolor",
    match = { pin = 1 },
    border_color = colors.primary_fixed .. " " .. colors.primary_fixed_dim
})

-- Layer Rules
hl.layer_rule({
    name = "gtk-layer-shell-blur",
    match = { namespace = "gtk-layer-shell" },
    blur = true,
    ignore_alpha = 0,
    xray = 0
})

-- Permissions
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
hl.permission("/usr/bin/obs", "screencopy", "allow")
