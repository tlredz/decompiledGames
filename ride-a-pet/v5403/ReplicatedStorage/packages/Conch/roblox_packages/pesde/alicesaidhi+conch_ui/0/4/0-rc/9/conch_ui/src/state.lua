require("../roblox_packages/conch")
local output = require(script.Parent.output)
local module = require("../roblox_packages/vide")
local source = module.source
local create_stream = output.create_stream()
create_stream.max_line_length = workspace.CurrentCamera.ViewportSize.X / 11
return {
	opened = source(false),
	focused = source(false),
	alignment = source("bottom"),
	current_stream = source(create_stream),
	logs = create_stream,
	history = {}
}