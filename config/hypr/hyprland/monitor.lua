hl.monitor({
    output = "eDP-1",
    mode = "1920x1200@144.00",
    position = "0x0",
    scale = 1.20
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "preferred",
    position = "auto",
    scale = 1,
    mirror = "eDP-1"
})

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
    mirror = "eDP-1"
})



-- Lid Switch
hl.bind("switch:on:Lid Switch", hl.dsp.dpms({action = "off"}), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.dpms({action = "on"}), { locked = true })
