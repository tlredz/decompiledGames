local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local QuestShared = require(ReplicatedStorage.shared.modules.QuestShared)
local Quests = require(ReplicatedStorage.shared.modules.Quests)
local QuestTypes = require(ReplicatedStorage.shared.modules.QuestTypes)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local localPlayer = game.Players.LocalPlayer
local color = Color3.new(1, 1, 1)
local v = Component.new({
	Tag = "QuestAvailable"
})

function v:Construct()
	self.trove = Trove.new()
	self.gui = script.AcceptGui:Clone()
	self.gui.Enabled = false
	self.gui.Parent = self.Instance
	self.trove:Add(self.gui)
	self.associatedQuests = {}
	local navTag = self.Instance:GetAttribute("Nav/Tag") or self.Instance:GetAttribute("UID")

	for k, quest in Quests do
		if quest.AcceptIndicatorTag and (navTag == quest.AcceptIndicatorTag or self.Instance:HasTag(quest.AcceptIndicatorTag)) then
			table.insert(self.associatedQuests, k)
		end
	end

	task.spawn(function()
		self.gui.Adornee = self.Instance:WaitForChild("HumanoidRootPart", 60)
	end)
end

function v.Start(data)
	local fetched = legacyLocalPlayerData.fetch()

	local function updateGui()
		local gui = data.gui
		local settingValue = SettingsController:GetSettingValue("questIndicators")

		if settingValue == "None" then
			gui.Enabled = false
			return
		end

		for _, associatedQuest in data.associatedQuests do
			if not QuestShared:CanGet(localPlayer, associatedQuest) then
				continue
			end

			local questData = QuestShared:GetQuestData(localPlayer, associatedQuest)

			if not (questData and (settingValue ~= "Major" or questData.QuestType == "Major")) then
				continue
			end

			local questType = QuestTypes[questData.QuestType]
			gui.typeIcon.Image = questType.IconBillboard
			gui.typeIcon.ImageColor3 = questType.Color
			gui.typeIcon.distanceLabel.UIGradient.Color = ColorSequence.new(questType.Color:Lerp(color, 0.35), color)
			gui.Enabled = true
			return
		end

		gui.Enabled = false
	end

	data.trove:Add(fetched:WaitForChild("QuestActive").ChildAdded:Connect(updateGui))
	data.trove:Add(fetched:WaitForChild("QuestActive").ChildRemoved:Connect(updateGui))
	data.trove:Add(fetched:WaitForChild("QuestFinished").ChildAdded:Connect(updateGui))
	data.trove:Add(fetched:WaitForChild("QuestFinished").ChildRemoved:Connect(updateGui))
	data.trove:Add(SettingsController:GetSettingChangedSignal("questIndicators"):Connect(updateGui))
	updateGui()
end

function v.Stop(p)
	p.trove:Destroy()
end

return v