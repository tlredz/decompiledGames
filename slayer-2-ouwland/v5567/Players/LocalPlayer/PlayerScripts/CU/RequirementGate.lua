local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRequirements = require(ReplicatedStorage.CAM.Global.Collectibles.ItemRequirements)
local PlayerProgression = require(ReplicatedStorage.CAM.Global.PlayerProgression)
local Regions = require(ReplicatedStorage.Regions)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local localPlayer = Players.LocalPlayer
local data = Utility.GetData(localPlayer, true)
local v = {}

local function apply(instance)
	local npc = instance:GetAttribute("Npc")
	local side = instance:GetAttribute("Side")

	if typeof(npc) ~= "string" and typeof(side) ~= "string" then
		return
	end

	local v2

	if typeof(npc) == "string" then
		v2 = Regions.NpcRequirements[npc]
	end

	local enabled = typeof(npc) ~= "string" or ItemRequirements.Passes(data, v2)

	if typeof(side) == "string" then
		enabled = enabled and table.find(PlayerProgression.SidesFor(localPlayer), side) ~= nil
	end

	if instance:IsA("ProximityPrompt") then
		instance.Enabled = enabled
	elseif instance:IsA("GuiObject") then
		instance.Visible = not enabled

		if instance:IsA("TextLabel") then
			instance.Text = ItemRequirements.Describe(v2, data)
		end
	end
end

local function refresh()
	for k in v do
		if k.Parent == nil then
			v[k] = nil
		else
			apply(k)
		end
	end
end

local function track(proximityPrompt)
	v[proximityPrompt] = true
	apply(proximityPrompt)

	if proximityPrompt:IsA("ProximityPrompt") then
		proximityPrompt:GetPropertyChangedSignal("Enabled"):Connect(function()
			if proximityPrompt.Enabled and v[proximityPrompt] then
				apply(proximityPrompt)
			end
		end)
	end
end

local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function watch(k: string)
	if v2[k] then
		return
	end

	v2[k] = true

	if k == "Items" then
		local inventory = data:WaitForChild("Inventory"):WaitForChild("Inventory")
		inventory.ChildAdded:Connect(refresh)
		inventory.ChildRemoved:Connect(refresh)
	else
		local resolved = ItemRequirements.Resolve(data, k == "Level" and "Exp.Goal" or k)

		if resolved ~= nil then
			resolved.Changed:Connect(refresh)
		end
	end
end

watch("Race") -- equivalent call inferred; original call site unknown

for _, npcRequirement in Regions.NpcRequirements do
	for k in npcRequirement do
		watch(k)
	end
end

for _, v3 in CollectionService:GetTagged("RequirementGate") do
	track(v3)
end

CollectionService:GetInstanceAddedSignal("RequirementGate"):Connect(track)
CollectionService:GetInstanceRemovedSignal("RequirementGate"):Connect(function(p)
	v[p] = nil
end)