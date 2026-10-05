local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local localPlayer = Players.LocalPlayer
local RecommendedQuest = {
	Changed = simplesignal.new()
}
local v = nil

function RecommendedQuest.HasBook()
	if v == nil then
		return false
	end

	for _, child in v:GetChildren() do
		if child.Name == "Book of Guidance" then
			return true
		end
	end

	return false
end

RecommendedQuest.BOOK = "Book of Guidance"
local v2 = nil
local flag = false

local function playerPosition()
	local character = localPlayer.Character
	local humanoidRootPart

	if character ~= nil then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart == nil then
		return nil
	end

	return humanoidRootPart.Position
end

-- equivalent calls inferred from this helper; original call sites unknown
local function same(p, p2)
	if p == nil or p2 == nil then
		return p == p2
	end

	return p.Key == p2.Key
end

local function compute()
	if RecommendedQuest.HasBook() then
		local Regions = require(ReplicatedStorage.Regions)
		local v3 = nil
		local v4 = 1e999
		local character = localPlayer.Character
		local humanoidRootPart

		if character ~= nil then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		local position

		if humanoidRootPart ~= nil then
			position = humanoidRootPart.Position
		end

		for k, v5 in Quests.Holder do
			local offerNpc = v5.OfferNpc

			if not (typeof(offerNpc) == "string" and v5.NoSave ~= true and (v5.Rewards == nil or v5.Rewards.Power == nil) and Quests.GetQuestCategory(k) == "Combat") then
				continue
			end

			if Quests.CanAddQuest(localPlayer, k) ~= true then
				continue
			end

			local level = (v5.Requirements == nil or typeof(v5.Requirements.Level) ~= "number") and 0 or v5.Requirements.Level
			local npcSpawn = Regions.GetNpcSpawn(offerNpc)
			local v7 = (position == nil or npcSpawn == nil) and 1e999 or (npcSpawn - position).Magnitude
			local v8

			if v3 == nil or v3.Level < level then
				v8 = true
			elseif level == v3.Level then
				v8 = v7 < v4
			else
				v8 = false
			end

			if not v8 then
				continue
			end

			v3 = {
				Key = k,
				Name = v5.QuestInstance.Name,
				Npc = offerNpc,
				Icon = Regions.GetNpcIcon(offerNpc),
				Position = npcSpawn,
				Level = level
			}
			v4 = v7
		end

		-- equivalent call inferred; original call site unknown
		if same(v2, v3) then
			return
		end

		v2 = v3
		RecommendedQuest.Changed:Fire(v3)
	else
		if v2 == nil then
			return
		end

		v2 = nil
		RecommendedQuest.Changed:Fire(nil)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refresh()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		compute()
	end)
end

function RecommendedQuest.Get()
	return v2
end

task.spawn(function()
	local data = Utility.GetData(localPlayer, true)

	if data == nil then
		return
	end

	local quests = data:WaitForChild("Quests")
	local holder = quests:WaitForChild("Holder")
	local completed = quests:WaitForChild("Completed")
	local lastTime = quests:WaitForChild("LastTime")
	local goal = data:WaitForChild("Exp"):WaitForChild("Goal")
	local inventory = data:WaitForChild("Inventory"):WaitForChild("Inventory")
	v = inventory
	inventory.ChildAdded:Connect(refresh)
	inventory.ChildRemoved:Connect(refresh)
	holder.ChildAdded:Connect(refresh)
	holder.ChildRemoved:Connect(refresh)
	completed.ChildAdded:Connect(refresh)
	completed.ChildRemoved:Connect(refresh)
	goal.Changed:Connect(refresh)
	lastTime.Changed:Connect(function()
		refresh() -- equivalent call inferred; original call site unknown
		task.delay(Quests.QuestCD + 1, refresh)
	end)
	refresh() -- equivalent call inferred; original call site unknown
end)
return RecommendedQuest