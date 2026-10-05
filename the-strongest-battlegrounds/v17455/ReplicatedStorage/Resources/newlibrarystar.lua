local modules = script:WaitForChild("Modules")
return {
	particles = require(modules.Particles),
	screen = require(modules.Screen),
	light = require(modules.Light),
	effects = require(modules.Effects),
	highlight = require(modules.Highlight),
	util = require(modules.Util)
}