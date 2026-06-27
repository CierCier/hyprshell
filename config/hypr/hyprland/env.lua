hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GLFW_IM_MODULE", "ibus")
hl.env("INPUT_METHOD", "fcitx")
hl.env("EGL_PLATFORM", "wayland")


-- Themes
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Others
hl.env("DBUS_SESSION_BUS_ADDRESS", "unix:path=/run/user/1000/bus")



-- nvidia specific
-- detect nvidia gpu

local function has_nvidia_gpu()
	local handle = io.popen("lspci -nnk | grep -i nvidia")
	local result = handle:read("*a")
	handle:close()
	return result ~= ""
end


if has_nvidia_gpu() then
	hl.env("__GL_THREADED_OPTIMIZATIONS", "1")
	hl.env("LIBVA_DRIVER_NAME", "nvidia")
	hl.env("GBM_BACKEND", "nvidia-drm")
	hl.env("__GL_GSYNC_ALLOWED", "0")
	hl.env("__GL_VRR_ALLOWED", "1")
	hl.env("WLR_DRM_NO_MODIFIERS", "1")
	hl.env("WLR_NO_HARDWARE_CURSORS", "1")
end
