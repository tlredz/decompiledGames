local Quests = require(game.ReplicatedStorage:WaitForChild("Quests"))
local questUpdate = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("QuestUpdate")
local bindableEvent = Instance.new("BindableEvent")
local QuestController = {
	Network = bindableEvent
}
local questsCompleted = {}
QuestController.QuestsCompleted = questsCompleted

function QuestController.GetQuest(_, p: string, p2: string)
	local quest = Quests[p]

	for _, v2 in pairs(quest) do
		if v2.Name == p2 then
			return v2
		end
	end

	return nil
end

function QuestController.OnStart(_)
	for k, quest in pairs(Quests) do
		questsCompleted[k] = {}

		for _, v2 in pairs(quest) do
			questsCompleted[k][v2.Name] = false
		end
	end

	questUpdate.OnClientEvent:Connect(function(p, data)
		if data and data.Context == "Complete" then
			if questsCompleted[data.InternalQuestName] == nil then
				questsCompleted[data.InternalQuestName] = {}
			end

			questsCompleted[data.InternalQuestName][data.Name] = true
		end

		bindableEvent:Fire("Update", p)
	end)
end

return QuestController