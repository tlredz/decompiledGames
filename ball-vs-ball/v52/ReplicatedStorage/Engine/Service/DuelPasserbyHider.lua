local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Observers = require(packages:WaitForChild("Observers"))
local v = {
	"BasePart",
	"Decal",
	"ParticleEmitter",
	"Trail",
	"Beam",
	"Fire",
	"Smoke",
	"Sparkles"
}
local v2 = { "BillboardGui", "Highlight" }
local DuelPasserbyHider = {}
DuelPasserbyHider.__index = DuelPasserbyHider

-- equivalent calls inferred from this helper; original call sites unknown
local function isTransparencyModifierClass(instance)
	for _, className in ipairs(v) do
		if instance:IsA(className) then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isEnabledToggleClass(humanoid)
	for _, className in ipairs(v2) do
		if humanoid:IsA(className) then
			return true
		end
	end

	return false
end

function DuelPasserbyHider.new()
	local object = setmetatable({}, DuelPasserbyHider)
	object.active = false
	object.excludedUserIds = {}
	object.hidden = {}
	Observers.observeCharacter(function(p, p2)
		if object.active and not object:_isExcluded(p) then
			object:_hideCharacter(p, p2)
		end

		return function()
			object:_restorePlayer(p)
		end
	end)
	return object
end

function DuelPasserbyHider:_applyHideToInstance(humanoid, enabledsByHumanoid, displayDistanceTypesByHumanoid)
	-- equivalent call inferred; original call site unknown
	if isTransparencyModifierClass(humanoid) then
		humanoid.LocalTransparencyModifier = 1
		return
	end

	-- equivalent call inferred; original call site unknown
	if isEnabledToggleClass(humanoid) then
		if enabledsByHumanoid[humanoid] == nil then
			enabledsByHumanoid[humanoid] = humanoid.Enabled
		end

		humanoid.Enabled = false
	elseif humanoid:IsA("Humanoid") then
		if displayDistanceTypesByHumanoid[humanoid] == nil then
			displayDistanceTypesByHumanoid[humanoid] = humanoid.DisplayDistanceType
		end

		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
end

function DuelPasserbyHider:_isExcluded(p2)
	return self.excludedUserIds[p2.UserId] == true
end

function DuelPasserbyHider:_hideCharacter(p, folder)
	if self.hidden[p] then
		return
	end

	local v3 = {
		character = folder,
		originalEnabled = {},
		originalDisplayDistanceType = {},
		descendantAddedConnection = nil
	}
	self.hidden[p] = v3

	for _, descendant in ipairs(folder:GetDescendants()) do
		self:_applyHideToInstance(descendant, v3.originalEnabled, v3.originalDisplayDistanceType)
	end

	v3.descendantAddedConnection = folder.DescendantAdded:Connect(function(descendant)
		self:_applyHideToInstance(descendant, v3.originalEnabled, v3.originalDisplayDistanceType)
	end)
end

function DuelPasserbyHider:_restoreEntry(data)
	local character = data.character

	if character and character.Parent then
		for _, descendant in ipairs(character:GetDescendants()) do
			-- equivalent call inferred; original call site unknown
			if isTransparencyModifierClass(descendant) then
				descendant.LocalTransparencyModifier = 0
			end
		end
	end

	for k, enabled in pairs(data.originalEnabled) do
		if k.Parent then
			k.Enabled = enabled
		end
	end

	for k, displayDistanceType in pairs(data.originalDisplayDistanceType) do
		if k.Parent then
			k.DisplayDistanceType = displayDistanceType
		end
	end

	if data.descendantAddedConnection then
		data.descendantAddedConnection:Disconnect()
	end
end

function DuelPasserbyHider:_restorePlayer(p)
	local v3 = self.hidden[p]

	if not v3 then
		return
	end

	self.hidden[p] = nil
	self:_restoreEntry(v3)
end

function DuelPasserbyHider:start(list)
	local excludedUserIds = {}

	for _, v4 in ipairs(list) do
		excludedUserIds[v4] = true
	end

	self.excludedUserIds = excludedUserIds
	self.active = true

	for k in pairs(self.hidden) do
		if self:_isExcluded(k) then
			self:_restorePlayer(k)
		end
	end

	for _, v4 in ipairs(Players:GetPlayers()) do
		if self:_isExcluded(v4) or self.hidden[v4] or not v4.Character then
			continue
		end

		self:_hideCharacter(v4, v4.Character)
	end
end

function DuelPasserbyHider:stop()
	self.active = false
	self.excludedUserIds = {}

	for k in pairs(self.hidden) do
		self:_restorePlayer(k)
	end
end

return DuelPasserbyHider