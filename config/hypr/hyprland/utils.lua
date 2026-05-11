local mainMod = "SUPER"

set_main_mod = function(mod)
    -- override current main mod
    mainMod = mod
end

-- Shorthands
disp = hl.dsp
exec = hl.dsp.exec_cmd
bind = hl.bind
run = hl.exec_cmd

-- Main mod binding
bindm = function(key, action, opts)
    hl.bind(mainMod .. " + " .. key, action, opts)
end

-- Program execution binding
bind_run = function(key, cmd, opts)
    bindm(key, exec(cmd), opts)
end

-- Smart Helpers
focus = function(val)
    if val == "left" or val == "right" or val == "up" or val == "down" then
        return disp.focus({ direction = val })
    end
    return disp.focus({ workspace = val })
end

move = function(val)
    if val == "left" or val == "right" or val == "up" or val == "down" then
        return disp.window.move({ direction = val })
    end
    return disp.window.move({ workspace = val })
end

-- Rule helpers
frule = function(class, size, name)
    hl.window_rule({
        name = name or (class:gsub("[^%w]", "") .. "-float"),
        match = { class = class },
        float = true,
        size = size
    })
end

-- Workspace helper
workspaces = function()
    for i = 1, 10 do
        local key = i % 10
        bindm(tostring(key), focus(i))
        bindm("SHIFT + " .. tostring(key), move(i))
    end
end

-- Event helpers
on_start = function(fn)
    hl.on("hyprland.start", fn)
end
