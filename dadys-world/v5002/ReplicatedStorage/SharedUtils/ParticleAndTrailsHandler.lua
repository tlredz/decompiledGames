local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterVisibilityHandler = require(ReplicatedStorage.SharedUtils.CharacterVisibilityHandler)
local SettingsFlags = require(ReplicatedStorage.SharedUtils.SettingsFlags)
local ParticleAndTrailsHandler = {}
local v = true
local effects = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function isEffectVisible(instance)
	if not v then
		return false
	end

	local model = instance:FindFirstAncestorWhichIsA("Model")
	return not model or model == workspace or not CharacterVisibilityHandler:IsHidden(model)
end

local function addObject(effect)
	if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
		return
	end

	local model = effect:FindFirstAncestorWhichIsA("Model")

	if model then
		if model == workspace or model:GetAttribute("IsPreviewSkin") then
			return
		end
	end

	local effectVisible = isEffectVisible(effect) -- equivalent call inferred; original call site unknown
	effect.Enabled = effectVisible
	effects[#effects + 1] = effect
end

local function removeObject(p)
	local index = table.find(effects, p)

	if index then
		table.remove(effects, index)
	end
end

local function refresh(ancestor)
	for _, v2 in pairs(effects) do
		if not (ancestor == nil or v2:IsDescendantOf(ancestor)) then
			continue
		end

		local effectVisible = isEffectVisible(v2) -- equivalent call inferred; original call site unknown
		v2.Enabled = effectVisible
	end
end

CharacterVisibilityHandler.VisibilityChanged:Connect(function(p)
	refresh(p)
end)

function ParticleAndTrailsHandler.AddTag(_, tag: string)
	if not tag or typeof(tag) ~= "string" then
		return
	end

	for _, v2 in pairs(CollectionService:GetTagged(tag)) do
		task.spawn(addObject, v2)
	end

	CollectionService:GetInstanceRemovedSignal(tag):Connect(removeObject)
	CollectionService:GetInstanceAddedSignal(tag):Connect(addObject)
end

local modules = ReplicatedStorage:WaitForChild("Modules", 60)

if not modules then
	warn("[TextureMover] Modules folder not found")
	return
end

local myDataController = modules:FindFirstChild("MyDataController")

if not myDataController then
	local clientUI = modules:FindFirstChild("ClientUI")
	myDataController = clientUI and clientUI:WaitForChild("MyDataController", 60)
end

if not myDataController then
	warn("[TextureMover] MyDataController module not found")
	return
end

local module = require(myDataController)
module:onReplicaReady(function(object)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateSetting()
		local particleToggle = object.Data.Settings and object.Data.Settings.ParticleToggle
		v = SettingsFlags:GetEffective(particleToggle, "ParticleToggle") == true
		refresh()
	end

	object:ListenToChange({ "Settings", "ParticleToggle" }, function(_, _)
		updateSetting() -- equivalent call inferred; original call site unknown
	end)
	updateSetting() -- equivalent call inferred; original call site unknown
end)
return ParticleAndTrailsHandler