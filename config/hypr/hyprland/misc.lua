local colors = require("colors")

hl.config({
    misc = {
        vrr = 1,
        focus_on_activate = true,
        animate_manual_resizes = true,
        animate_mouse_windowdragging = true,
        enable_swallow = false,
        swallow_regex = "(foot|kitty|allacritty|Alacritty)",
        disable_hyprland_logo = true,
        force_default_wallpaper = 0,
        allow_session_lock_restore = true,
        initial_workspace_tracking = false,
        background_color = colors.on_background,
    },
    xwayland = {
        force_zero_scaling = true,
    },
})
