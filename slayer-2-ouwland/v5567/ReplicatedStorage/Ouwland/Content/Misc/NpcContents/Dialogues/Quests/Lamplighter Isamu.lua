local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
return {
	["Ill walk the order"] = {
		QuestInstance = Quests.Quest("The Plate Trial", Quests.QuestTask("Rounds", 5)),
		Rewards = {
			["Firstlight Lantern Schematic"] = {
				Quantity = 1
			}
		},
		Category = "Dialogue",
		LogCompletion = true,
		NoSave = true,
		CompletionNotify = {
			Npc = "Lamplighter Isamu",
			Text = "Every plate, in its order. The drawings are yours."
		},
		Position = vector.create(1079, 1422, -781)
	}
}