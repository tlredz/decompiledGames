local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rods = ReplicatedStorage.shared.modules.library.rods
local mastery = rods.mastery
require("@self/Util")
local Quests = {}

local function RefreshList()
	local v = {}

	for _, moduleScript in script:GetDescendants() do
		if not moduleScript:IsA("ModuleScript") or moduleScript:GetAttribute("QuestIgnore") then
			continue
		end

		local module = require(moduleScript)

		for k, v2 in module do
			if typeof(v2) ~= "table" then
				continue
			end

			v2.Id = k
			v2.QuestType = v2.QuestType or "Side"
			v[k] = v2
		end
	end

	local module = require(rods)
	local module2 = require(mastery)

	for k, v2 in module2.Mastery do
		for k2, quest in v2.Quests do
			v[`{k}/{k2}-MASTERY`] = {
				Id = `{k}/{k2}-MASTERY`,
				DisplayName = `{k}: {quest.Name}`,
				Icon = "rbxassetid://18162767851",
				IconColor = module[k].Color,
				QuestType = "Mastery",
				NoAutoTrack = true,
				Description = "",
				CompletedDescription = "Claim your rewards in the Equipment Bag!",
				List = { quest.Goal },
				Prerequisites = {
					Level = v2.MinimumLevel
				},
				Rewards = quest.Reward.Info and #quest.Reward.Info > 0 and typeof(quest.Reward.Info[1]) == "table" and quest.Reward.Info or { quest.Reward.Info }
			}
		end
	end

	Quests = v
end

script.ChildAdded:Connect(function()
	task.wait(1)
	RefreshList()
end)
script.ChildRemoved:Connect(function()
	task.wait(1)
	RefreshList()
end)
RefreshList()
return Quests