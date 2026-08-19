require("modules.envs")
require("modules.mics")
require("modules.input")
require("modules.master")
require("modules.general")
require("modules.monitors")
require("modules.autostart")
require("modules.decoration")
require("modules.animations")
require("modules.window_rules")
require("modules.keysbindings")
require("modules.workspaces_rules")

-- Machine-specific overrides. Not versioned, optional: pcall keeps the config
-- working on a fresh machine where modules/local.lua does not exist yet.
-- See modules/local.lua.example.
pcall(require, "modules.local")
