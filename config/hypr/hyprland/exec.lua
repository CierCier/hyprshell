require("hyprland.utils")

-- Start once at startup
on_start(function()
    run("hyprpm reload")
    run("nm-applet")
    run("awww-daemon")
    run("/usr/lib/polkit-kde-authentication-agent-1")
    run("/usr/lib/xdg-desktop-portal-hyprland")
    run("clipse -listen")
    run("hyprlauncher -d")
    run("qs -c noctalia-shell")
end)

-- Always run on reload
run("nwg-look -a")
run("hyprctl setcursor rose-pine-hyprcursor 20")
