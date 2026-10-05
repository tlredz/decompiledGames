if not game then
	local module = require("test/relative-string")
	script = module
end

local root = require(script.root)
local mount = require(script.mount)
local create = require(script.create)
local apply = require(script.apply)
local source = require(script.source)
local effect = require(script.effect)
local derive = require(script.derive)
local cleanup = require(script.cleanup)
local untrack = require(script.untrack)
local read = require(script.read)
local batch = require(script.batch)
local context = require(script.context)
local switch = require(script.switch)
local show = require(script.show)
local maps = require(script.maps)
local indexes, values = maps()
local spring = require(script.spring)
local spring2, v5 = spring()
local action = require(script.action)
local action2 = action()
local changed = require(script.changed)
local throw = require(script.throw)
local flags = require(script.flags)

local function step(p: number)
	if game then
		debug.profilebegin("VIDE STEP")
		debug.profilebegin("VIDE SPRING")
	end

	v5(p)

	if game then
		debug.profileend()
		debug.profileend()
	end
end

local game2 = game

if game2 then
	local RunService = game:GetService("RunService")
	game2 = RunService:IsClient()

	if game2 then
		local RunService2 = game:GetService("RunService")
		game2 = RunService2.Heartbeat:Connect(function(dt: number)
			task.defer(step, dt)
		end)
	end
end

local Vide = {
	version = {
		major = 0,
		minor = 3,
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
setmetatable(Vide, {
	__index = function(_, p)
		if p == "strict" then
			return flags.strict
		end

		throw((`{tostring(p)} is not a valid member of vide`))
	end,
	__newindex = function(_, p, strict)
		if p == "strict" then
			flags.strict = strict
		else
			throw((`{tostring(p)} is not a valid member of vide`))
		end
	end
})
return Vide