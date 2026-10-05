local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local _ = ReplicatedStorage:WaitForChild("client").legacyControllers
local modules = ReplicatedStorage:WaitForChild("client").modules
require(modules.legacyLocalPlayerData)
require(ReplicatedStorage:WaitForChild("shared").modules.Worlds)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2.shared.modules:WaitForChild("fx"))
local localPlayer = Players.LocalPlayer
local QuestTrackerController = {
	Quests = {
		Tutorial4 = {
			Started = function()
				if not localPlayer:GetAttribute("FishingPolesExperiment") then
					return
				end

				local trainingRod = workspace:WaitForChild("world"):WaitForChild("interactables"):WaitForChild("Training Rod")
				local highlight = Instance.new("Highlight", trainingRod)
				highlight.Name = "TutorialHighlight"
				highlight.FillColor = Color3.fromRGB(85, 170, 255)
				highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
			end,
			Finished = function()
				local tutorialHighlight = workspace:WaitForChild("world"):WaitForChild("interactables"):WaitForChild("Training Rod"):FindFirstChild("TutorialHighlight")

				if tutorialHighlight then
					tutorialHighlight:Destroy()
				end
			end,
			Goals = {
				["Purchase any Fishing Rod"] = function()
					local tutorialHighlight = workspace:WaitForChild("world"):WaitForChild("interactables"):WaitForChild("Training Rod"):FindFirstChild("TutorialHighlight")

					if tutorialHighlight then
						tutorialHighlight:Destroy()
					end
				end
			}
		}
	}
}

function QuestTrackerController.Start(_)
	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
	local quests = require(ReplicatedStorage3.client.modules.legacyLocalPlayerData).fetch():WaitForChild("Quests")

	local function update(instance)
		local value = instance.TypeOfQuest.Value
		QuestTrackerController.Quests[value].Started()
		instance.Changed:Connect(function()
			if instance.Parent == nil then
				QuestTrackerController.Quests[value].Finished()
			end
		end)

		for _, child in pairs(instance:GetChildren()) do
			if not string.find(child.Name, "_Goal") then
				continue
			end

			local instance2 = instance:FindFirstChild(string.split(child.Name, "_Goal")[1])

			if instance2:IsA("NumberValue") then
				local v = instance2
				local v2 = child
				instance2.Changed:Connect(function()
					if v.Value >= v2.Value then
						QuestTrackerController.Quests[value].Goals[v.Name]()
					end
				end)

				if instance2.Value >= child.Value then
					QuestTrackerController.Quests[value].Goals[instance2.Name]()
				end
			elseif instance2:IsA("BoolValue") then
				local v = instance2
				instance2.Changed:Connect(function()
					if v.Value == true then
						QuestTrackerController.Quests[value].Goals[v.Name]()
					end
				end)

				if instance2.Value == true then
					QuestTrackerController.Quests[value].Goals[instance2.Name]()
				end
			end
		end
	end

	quests.ChildAdded:Connect(function(child)
		local typeOfQuest = child:WaitForChild("TypeOfQuest", 30)

		if not (typeOfQuest and QuestTrackerController.Quests[typeOfQuest.Value]) then
			return
		end

		update(child)
	end)

	for _, child in pairs(quests:GetChildren()) do
		local v = child
		task.spawn(function()
			local typeOfQuest = v:WaitForChild("TypeOfQuest", 30)

			if not (typeOfQuest and QuestTrackerController.Quests[typeOfQuest.Value]) then
				return
			end

			update(v)
		end)
	end
end

return QuestTrackerController