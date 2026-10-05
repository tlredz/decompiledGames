require("../roblox_packages/conch")
local module = require("../roblox_packages/vide")
local source = module.source
return {
	opened = source(false),
	focused = source(false),
	logs = source({})
}