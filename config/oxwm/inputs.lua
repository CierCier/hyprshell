-- Input configuration
-- Automatically configure all touchpads

-- Function to get all touchpad device names
local function get_touchpads()
    local touchpads = {}
    local handle = io.popen("xinput list --name-only")
    if handle then
        for line in handle:lines() do
            -- Match lines containing "Touchpad" (case-insensitive)
            if line:lower():match("touchpad") then
                table.insert(touchpads, line)
            end
        end
        handle:close()
    end
    return touchpads
end

-- Function to configure a touchpad
local function configure_touchpad(device)
    -- Enable Tap to Click
    oxwm.autostart("xinput set-prop '" .. device .. "' 'libinput Tapping Enabled' 1 2>/dev/null || true")
    
    -- Enable Natural Scrolling
    oxwm.autostart("xinput set-prop '" .. device .. "' 'libinput Natural Scrolling Enabled' 1 2>/dev/null || true")
    
    -- Disable "Disable While Typing" (DWT)
    oxwm.autostart("xinput set-prop '" .. device .. "' 'libinput Disable While Typing Enabled' 0 2>/dev/null || true")
    
    -- Scroll Speed (default is 1.0, adjust to taste: 0.5 = slower, 2.0 = faster)
    oxwm.autostart("xinput set-prop '" .. device .. "' 'libinput Scrolling Factor' 1.0 2>/dev/null || true")
    
    -- Pointer Acceleration Speed (-1.0 to 1.0, default 0.0)
    oxwm.autostart("xinput set-prop '" .. device .. "' 'libinput Accel Speed' 0.0 2>/dev/null || true")
    
    -- Acceleration Profile (adaptive=1,0,0  flat=0,1,0  custom=0,0,1)
    oxwm.autostart("xinput set-prop '" .. device .. "' 'libinput Accel Profile Enabled' 1, 0, 0 2>/dev/null || true")
    
    -- Horizontal Scrolling
    oxwm.autostart("xinput set-prop '" .. device .. "' 'libinput Horizontal Scroll Enabled' 1 2>/dev/null || true")
    
end

-- Apply settings to all detected touchpads
local touchpads = get_touchpads()
for _, touchpad in ipairs(touchpads) do
    configure_touchpad(touchpad)
end

-- Function to get all keyboard device names
local function get_keyboards()
    local keyboards = {}
    local handle = io.popen("xinput list --name-only")
    if handle then
        for line in handle:lines() do
            -- Match lines containing "keyboard" but exclude "XTEST" (case-insensitive)
            if line:lower():match("keyboard") and not line:match("XTEST") then
                table.insert(keyboards, line)
            end
        end
        handle:close()
    end
    return keyboards
end

-- Function to configure a keyboard
local function configure_keyboard(device)
    -- This applies globally to all keyboards, so we only need to run once
    -- Rate: characters per second (default ~25)
    -- Delay: milliseconds before repeat starts (default ~660ms)
    oxwm.autostart("xset r rate 350 40")
end

-- Apply settings to all detected keyboards
local keyboards = get_keyboards()
if #keyboards > 0 then
    configure_keyboard(keyboards[1])
end


