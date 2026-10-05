local root = require(script.Parent.root)
require(script.Parent.branch)
local mount = require(script.Parent.mount)
local create = require(script.Parent.create)
local apply = require(script.Parent.apply)
local source = require(script.Parent.source)
local effect = require(script.Parent.effect)
local derive = require(script.Parent.derive)
local cleanup = require(script.Parent.cleanup)
local untrack = require(script.Parent.untrack)
local read = require(script.Parent.read)
local batch = require(script.Parent.batch)
local context = require(script.Parent.context)
local switch = require(script.Parent.switch)
local show = require(script.Parent.show)
local indexes = require(script.Parent.indexes)
local values = require(script.Parent.values)
local spring = require(script.Parent.spring)
local spring2, v3 = spring()
local action = require(script.Parent.action)
local action2 = action()
local changed = require(script.Parent.changed)
local timeout = require(script.Parent.timeout)
local _, v5 = timeout()
local flags = require(script.Parent.flags)

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
	root = root,
	mount = mount,
	create = create,
	source = source,
	effect = effect,
	derive = derive,
	switch = switch,
	show = show,
	indexes = indexes,
	values = values,
	cleanup = cleanup,
	untrack = untrack,
	read = read,
	batch = batch,
	context = context,
	spring = spring2,
	action = action2,
	changed = changed,
	strict = nil,
	defaults = nil,
	defer_nested_properties = nil,
	apply = function(p)
		return function(p2)
			apply(p, p2)
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
		if flags[p] ~= nil then
			return flags[p]
		end

		error(`{tostring(p)} is not a valid member of vide`, 0)
	end,
	__newindex = function(_, p, p2)
		if flags[p] == nil then
			error((`{tostring(p)} is not a valid member of vide, 0`))
		else
			flags[p] = p2
		end
	end
})
return Lib