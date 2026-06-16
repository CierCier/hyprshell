local colors = require("colors")

hl.config({
    misc = {
        vrr = 0,
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
    opengl = {
        nvidia_anti_flicker = false,
    },
    render = {
        direct_scanout = 2,
        new_render_scheduling = true,
    },
    xwayland = {
        force_zero_scaling = true,
    },
	cursor = {
		zoom_factor = 1.0,
	},
})

require("hyprland.utils")


local ZOOM_FACTOR_MIN = 1.0
local ZOOM_FACTOR_MAX = 3.0

local zoom_factor = 1.0
local zoom_factor_increment = 0.4

    -- 2. Clamp the value between MIN and MAX bounds
    -- 2. Clamp the value between MIN and MAX bounds
local zoom_update = function(inc)
	local new_zoom = zoom_factor + inc
    
    if new_zoom < ZOOM_FACTOR_MIN then
        zoom_factor = ZOOM_FACTOR_MIN
    elseif new_zoom > ZOOM_FACTOR_MAX then
        zoom_factor = ZOOM_FACTOR_MAX
    else
        zoom_factor = new_zoom
    end

	hl.config({ 
		cursor = {
			zoom_factor = zoom_factor
		}
	})

end


bindm("bracketright", function() zoom_update(zoom_factor_increment) end, {repeating = true } )
bindm("bracketleft", function() zoom_update(-zoom_factor_increment) end, {repeating = true } )
