local module = require("./root")
require("./branch")
local module2 = require("./mount")
local module3 = require("./create")
local module4 = require("./apply")
local module5 = require("./source")
local module6 = require("./effect")
local module7 = require("./derive")
local module8 = require("./cleanup")
local module9 = require("./untrack")
local module10 = require("./read")
local module11 = require("./batch")
local module12 = require("./context")
local module13 = require("./switch")
local module14 = require("./show")
local module15 = require("./indexes")
local module16 = require("./values")
local module17 = require("./spring")
local spring, v3 = module17()
local module18 = require("./action")
local action = module18()
local module19 = require("./changed")
local module20 = require("./timeout")
local _, v5 = module20()
local module21 = require("./flags")

local function step(p: number)
	if game then
		debug.profilebegin("VIDE STEP")
	end

	if game then
		debug.profilebegin("VIDE SPRING")
	end

	v3(p)

	if game then
		debug.profileend()
	end

	if game then
		debug.profilebegin("VIDE SCHEDULER")
	end

	v5(p)

	if game then
		debug.profileend()
	end

	if game then
		debug.profileend()
	end
end

local game2 = game

if game2 then
	local RunService = game:GetService("RunService")
	game2 = RunService.Heartbeat:Connect(function(dt: number)
		task.defer(step, dt)
	end)
end

local Lib = {
	version = {
		major = 0,
		minor = 4,
		patch = 1
	},
	root = module,
	mount = module2,
	create = module3,
	source = module5,
	effect = module6,
	derive = module7,
	switch = module13,
	show = module14,
	indexes = module15,
	values = module16,
	cleanup = module8,
	untrack = module9,
	read = module10,
	batch = module11,
	context = module12,
	spring = spring,
	action = action,
	changed = module19,
	strict = nil,
	defaults = nil,
	defer_nested_properties = nil,
	apply = function(p)
		return function(p2)
			module4(p, p2)
			return p
		end
	end,
	step = function(p: number)
		if game2 then
			game2:Disconnect()
			game2 = nil
		end

		step(p)
	end
}
setmetatable(Lib, {
	__index = function(_, p)
		if module21[p] ~= nil then
			return module21[p]
		end

		error(`{tostring(p)} is not a valid member of vide`, 0)
	end,
	__newindex = function(_, p, p2)
		if module21[p] == nil then
			error((`{tostring(p)} is not a valid member of vide, 0`))
		else
			module21[p] = p2
		end
	end
})
return Lib