local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local localPlayer = Players.LocalPlayer
local quests = Utility.GetData(localPlayer, true):WaitForChild("Quests")
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function apply(proximityPrompt)
	local requiresQuestDone = proximityPrompt:GetAttribute("RequiresQuestDone")

	if typeof(requiresQuestDone) ~= "string" then
		return
	end

	local enabled = Quests.GetPlayerQuestState(localPlayer, requiresQuestDone) == "Done"

	if proximityPrompt:IsA("ProximityPrompt") then
		proximityPrompt.Enabled = enabled
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function track(proximityPrompt)
	v[proximityPrompt] = true
	apply(proximityPrompt) -- equivalent call inferred; original call site unknown
end

for _, v2 in ipairs(CollectionService:GetTagged("QuestGate")) do
	track(v2) -- equivalent call inferred; original call site unknown
end

CollectionService:GetInstanceAddedSignal("QuestGate"):Connect(track)
CollectionService:GetInstanceRemovedSignal("QuestGate"):Connect(function(p)
	v[p] = nil
end)

local function refresh()
	for k in pairs(v) do
		if k.Parent == nil then
			v[k] = nil
		else
			apply(k) -- equivalent call inferred; original call site unknown
		end
	end
end

quests.DescendantAdded:Connect(refresh)
quests.DescendantRemoving:Connect(function()
	task.defer(refresh)
end)