require("hyprland.utils")

-- Variables
local terminal = "kitty"
local browser = "zen-browser"
local screenshot = "/home/cier/.local/bin/hypr-sc"
local filemanager = "thunar"
local qsipc = "qs -c noctalia-shell ipc call"
local powermenu = qsipc .. " sessionMenu toggle"
local settings = "XDG_CURRENT_DESKTOP=GNOME gnome-control-center"
local musicplayer = "kitty --class rmpc -e rmpc"
local clipboard = "kitty --class clipse -e clipse"


-- Basic binds
bindm("Q", disp.window.close())
bind_run("L", "hyprlock")
bind_run("Escape", powermenu)
bind_run("SHIFT + R", "hyprctl reload")

bind_run("M", musicplayer)
bind_run("I", settings)
bind_run("ALT + Space", qsipc .. " launcher toggle")
bind_run("V", clipboard)

-- Focus
bindm("Left", focus("left"))
bindm("Right", focus("right"))
bindm("Up", focus("up"))
bindm("Down", focus("down"))
bindm("BracketLeft", focus("left"))
bindm("BracketRight", focus("right"))

-- Move window
bindm("SHIFT + Left", move("left"))
bindm("SHIFT + Right", move("right"))
bindm("SHIFT + Up", move("up"))
bindm("SHIFT + Down", move("down"))

-- Mouse binds
bindm("mouse:272", disp.window.drag(), { mouse = true })
bindm("mouse:273", disp.window.resize(), { mouse = true })
bindm("R", disp.window.resize(), { mouse = true })

-- Kill
bind_run("SHIFT + ALT + Q", "hyprctl kill")

-- Layout
bindm("SHIFT + Space", disp.window.float({ action = "toggle" }))
bindm("F", disp.window.fullscreen({ mode = "fullscreen" }))
bindm("ALT + F", disp.window.fullscreen({ mode = "maximized" }))

-- Programs
bind_run("Return", terminal)
bind_run("W", browser)
bind_run("E", filemanager)

-- Audio / Media
bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
bind("XF86AudioRaiseVolume", exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"),
    { locked = true, repeating = true })
bind("XF86AudioLowerVolume", exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%-"),
    { locked = true, repeating = true })

bind("XF86AudioNext", exec("playerctl next"), { locked = true })
bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true })
bind("XF86AudioPrev", exec("playerctl previous || playerctl position 0"), { locked = true })

-- Brightness
bind("XF86MonBrightnessUp", exec("brightnessctl set +2%"), { locked = true })
bind("XF86MonBrightnessDown", exec("brightnessctl set 2%-"), { locked = true })

-- Screenshots
bind_run("SHIFT + S", screenshot .. " area")
bind_run("S", "grimblast copy area")
bind_run("Print", screenshot .. " screen")
bind_run("SHIFT + E", screenshot .. " edit")
bind_run("SHIFT + T", screenshot .. " ocr")
bind_run("C", "hyprpicker -a")

-- Workspaces
workspaces()

bind("ALT + Tab", focus("e+1"))
