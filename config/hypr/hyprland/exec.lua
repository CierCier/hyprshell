require("hyprland.utils")


start_once = {
  "hyprpm reload",
  -- "np-applet",
  -- "awww-daemon",
  "/usr/lib/polkit-kde-authentication-agent-1",
  "clipse -listen",
  "hyprlauncher -d",
  "noctalia" -- noctalia v5
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
