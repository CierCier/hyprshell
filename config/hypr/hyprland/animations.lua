hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.curve("overshot", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.1} } })
hl.curve("crazyshot", { type = "bezier", points = { {0.1, 1.5}, {0.76, 0.92} } })
hl.curve("easeInOut", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })

hl.animation({ leaf = "windowsIn",  enabled = true, speed = 3, bezier = "easeInOut", style = "popin 60%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "easeInOut", style = "popin 60%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "overshot", style = "slide 60%" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 2, bezier = "easeInOut", style = "slide" })
