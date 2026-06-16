hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GLFW_IM_MODULE", "ibus")
hl.env("INPUT_METHOD", "fcitx")
hl.env("EGL_PLATFORM", "wayland")


-- Themes
hl.env("QT_QPA_PLATFORMTHEME", "hyprqt6engine")

-- Others
hl.env("DBUS_SESSION_BUS_ADDRESS", "unix:path=/run/user/1000/bus")
