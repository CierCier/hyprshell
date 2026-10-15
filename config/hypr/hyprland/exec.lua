require("hyprland.utils")


start_once = {
  -- "hyprctl plugin load /etc/hypr/plugins/csgo-vulkan-fix.so" -- disabled: upstream Hyprland API break,
  -- "np-applet",
  -- "awww-daemon",
  -- "/usr/lib/polkit-kde-authentication-agent-1",
  "clipse -listen",
  "hyprlauncher -d",
  -- "noctalia" -- disabled while testing nonchalant (double bar/notifications)
  "qs",
}

on_start(function()
	for _,cmd in ipairs(start_once) do
		run(cmd)
	end
end)



start_always = {
	"nwg-look -a",
	"hyprctl setcursor rose-pine-hyprcursor 24"
}
-- Always run on reload

for _,cmd in ipairs(start_always) do
	run(cmd)
end
