local colors = require("colors")

hl.config({
    general = {
        gaps_in = 2,
        gaps_out = 4,
        gaps_workspaces = 2,
        border_size = 2,
        col = {
            active_border = colors.primary_fixed,
            inactive_border = colors.outline,
        },
        resize_on_border = true,
        -- no_focus_fallback = true, -- Check if this exists in 0.55
        layout = "dwindle",
        allow_tearing = true,
    },

    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true,
    },

    decoration = {
        rounding = 8,
        blur = {
            enabled = true,
            xray = false,
            special = false,
            new_optimizations = true,
            size = 8,
            passes = 3,
            brightness = 1,
            noise = 0.01,
            contrast = 1,
            popups = true,
            popups_ignorealpha = 0.6,
        },
        dim_inactive = false,
        dim_strength = 0.4,
        dim_special = 0,
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})
