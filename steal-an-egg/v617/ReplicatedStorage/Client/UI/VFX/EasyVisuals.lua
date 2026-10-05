local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dropshadow = require(script.Dropshadow)
local Gradient = require(script.Gradient)
require(script.Layers)
local GradientTemplates = require(script.GradientTemplates)
local Stroke = require(script.Stroke)
local t = require(ReplicatedStorage.Packages.t)
local VisibilityGate = require(script.VisibilityGate)
local v = {
	UIStroke = true,
	UIGradient = true
}
local class = {}
class.__index = class
class.Gradient = Gradient
class.Stroke = Stroke
class.Dropshadow = Dropshadow
class.Templates = GradientTemplates
class.CurrentEffects = {}
local presets = script.Presets
local strict = t.strict(t.union(t.instanceIsA("GuiObject"), t.instanceIsA("UIStroke")))
local strict2 = t.strict(t.string)
local strict3 = t.strict(t.number)
local strict4 = t.strict(t.union(t.ColorSequence, t.Color3))
local strict5 = t.strict(t.union(t.NumberSequence, t.number))

local function broadcast(p, p2: string)
	for _, effectObject in p.EffectObjects do
		local v2 = effectObject[p2]

		if v2 then
			v2(effectObject)
		end
	end
end

local function absorb(list, items)
	if not items then
		return
	end

	for _, item in items do
		list[#list + 1] = item
	end
end

local function teardown(data)
	for _, v2 in data.detached do
		v2.Parent = data.host
	end

	for _, watcher in data.watchers do
		if typeof(watcher) == "table" and typeof(watcher.Destroy) == "function" then
			watcher:Destroy()
		else
			watcher:Disconnect()
		end
	end

	table.clear(data.detached)
	table.clear(data.watchers)

	for _, effectObject in data.EffectObjects do
		local destroy = effectObject.Destroy

		if destroy then
			destroy(effectObject)
		end
	end

	data.lifeWatch:Disconnect()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchLifetime(object)
	local host = object.host
	return host.AncestryChanged:Connect(function()
		if host:IsDescendantOf(game) then
			return
		end

		teardown(object)
	end)
end

local function stashExisting(object)
	local detached = object.detached
	local children = object.host:GetChildren()

	for _, v2 in children do
		if not v[v2.ClassName] then
			continue
		end

		detached[#detached + 1] = v2
		v2.Parent = nil
	end
end

function class.new(host, childName: string, value: number?, value2: number?, flag: boolean?, color, alpha, flag2: boolean?, chain)
	strict(host)
	strict2(childName)
	local child = presets:FindFirstChild(childName)
	assert(child, (`EasyVisuals has no preset named {childName}`))

	if value then
		strict3(value)
	end

	if value2 then
		strict3(value2)
	end

	if color then
		strict4(color)
	end

	if alpha then
		strict5(alpha)
	end

	local object = setmetatable({
		host = host,
		EffectObjects = {},
		detached = {},
		watchers = {},
		isPaused = false,
		resumesWhenShown = flag2 == nil or flag2,
		drift = value or 0.007,
		width = value2 or 1,
		lifeWatch = nil,
		Diagnostic = "DIAGNOSTIC VALUE"
	}, class)
	local module = require(child)
	local v2 = module({
		Host = host,
		Drift = object.drift,
		Width = object.width,
		Color = color,
		Alpha = alpha,
		Chain = chain
	})
	assert(typeof(v2) == "table", "an effect preset must hand back a table")

	if flag then
		stashExisting(object)
	end

	local watchers = object.watchers
	local connections = v2.Connections

	if connections then
		for _, connection in connections do
			watchers[#watchers + 1] = connection
		end
	end

	local effectObjects = object.EffectObjects
	local effects = v2.Effects

	if effects then
		for _, effect in effects do
			effectObjects[#effectObjects + 1] = effect
		end
	end

	object.lifeWatch = watchLifetime(object)
	local v3 = VisibilityGate.Watch(host, function()
		for _, effectObject in object.EffectObjects do
			local suspend = effectObject.Suspend

			if suspend then
				suspend(effectObject)
			end
		end
	end, function()
		if object.resumesWhenShown then
			for _, effectObject in object.EffectObjects do
				local wake = effectObject.Wake

				if wake then
					wake(effectObject)
				end
			end
		end
	end)

	if v3 then
		local watchers2 = object.watchers
		watchers2[#watchers2 + 1] = v3
	end

	return object
end

function class:Destroy()
	teardown(self)
end

function class.Suspend(p)
	for _, effectObject in p.EffectObjects do
		local suspend = effectObject.Suspend

		if suspend then
			suspend(effectObject)
		end
	end
end

function class.Wake(p)
	for _, effectObject in p.EffectObjects do
		local wake = effectObject.Wake

		if wake then
			wake(effectObject)
		end
	end
end

return table.freeze(class)