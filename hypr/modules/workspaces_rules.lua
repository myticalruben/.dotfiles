for x = 1, 9 do
	if 1 == 9 then
		hl.workspace_rule({ workspace = x .. "", monitor = "HDMI-A-1", default = true })
	end

	hl.workspace_rule({ workspace = x .. "", monitor = "VGA-1", default = true })
end
