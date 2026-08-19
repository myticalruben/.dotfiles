-- Catch-all rule: an empty output name matches every monitor Hyprland finds,
-- so the config works on any machine without knowing the connector names.
-- Per-machine overrides (specific resolution, position, scale) belong in
-- modules/local.lua, which is not versioned. See modules/local.lua.example.
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "1",
})
