local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HoverBob = require(script.HoverBob)
require(script.TaggedSprites)
local Log = require(ReplicatedStorage.Packages.Log)
local SpriteSheet = require(script.SpriteSheet)
local TextGlitch = require(script.TextGlitch)
local v = Log.new()
local v2 = {
	HoverBob = HoverBob.Bind,
	SpriteSheet = SpriteSheet.Bind,
	TextGlitch = TextGlitch.Bind
}
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v3 = {}
local v4 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function stopEffect(instance)
	local v5 = v3[instance]

	if v5 == nil then
		return
	end

	v3[instance] = nil
	local success, result = pcall(v5)

	if not success then
		v:AtError():Log((`UI effect cleanup failed on {instance:GetFullName()}: {result}`))
	end
end

local function startEffect(instance)
	stopEffect(instance) -- equivalent call inferred; original call site unknown
	local uIEffect = instance:GetAttribute("UIEffect")

	if uIEffect == nil then
		return
	end

	if typeof(uIEffect) ~= "string" then
		v:AtError():Log((`{instance:GetFullName()} UIEffect must be a string`))
		return
	end

	local v5 = v2[uIEffect]

	if v5 == nil then
		v:AtError():Log((`{instance:GetFullName()} asks for unknown UIEffect "{uIEffect}"`))
		return
	end

	local success, result = pcall(v5, instance)

	if success then
		v3[instance] = result
	else
		v:AtError():Log((`UI effect {uIEffect} failed on {instance:GetFullName()}: {result}`))
	end
end

local function watch(instance)
	if v4[instance] ~= nil then
		return
	end

	v4[instance] = instance:GetAttributeChangedSignal("UIEffect"):Connect(function()
		startEffect(instance)
	end)
	instance.Destroying:Once(function()
		local connection = v4[instance]
		v4[instance] = nil

		if connection ~= nil then
			connection:Disconnect()
		end

		stopEffect(instance) -- equivalent call inferred; original call site unknown
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function consider(instance)
	if instance:GetAttribute("UIEffect") == nil then
		return
	end

	watch(instance)
	startEffect(instance)
end

for _, descendant in playerGui:GetDescendants() do
	consider(descendant) -- equivalent call inferred; original call site unknown
end

playerGui.DescendantAdded:Connect(function(descendant)
	if descendant:GetAttribute("UIEffect") == nil then
		return
	end

	task.defer(function()
		if descendant.Parent ~= nil then
			consider(descendant) -- equivalent call inferred; original call site unknown
		end
	end)
end)
local UIEffects = {}

function UIEffects.Bind(p)
	watch(p)
	startEffect(p)
end

function UIEffects.Unbind(instance)
	local v5 = v3[instance]

	if v5 == nil then
		return
	end

	v3[instance] = nil
	local success, result = pcall(v5)

	if not success then
		v:AtError():Log((`UI effect cleanup failed on {instance:GetFullName()}: {result}`))
	end
end

return UIEffects