hl.config({
    input = {
        kb_layout = "us",
        numlock_by_default = true,
        repeat_delay = 400,
        repeat_rate = 50,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = false,
            clickfinger_behavior = true,
            scroll_factor = 0.2,
        },
        special_fallthrough = true,
        follow_mouse = 1,
    },

})


hl.device({
    name = "logitech-g102-lightsync-gaming-mouse",
    sensitivity = 1.0,
    accel_profile = "custom 1600 0.3, 1.2",
})
