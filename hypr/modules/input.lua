hl.config({
	input = {

		kb_layout = "us",
	    follow_mouse = 1,
        sensitivity = 0.5,
        touchpad = {
            natural_scroll = false,
            tap_to_click = true,
        },
	},
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})
