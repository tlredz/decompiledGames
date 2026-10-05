local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local npcs = ReplicatedStorage.Ouwland.Content.Misc.Npcs
local activeNpcs = ReplicatedStorage.Ouwland.Content.Misc.ActiveNpcs
local WindTrainer = require(npcs["Wind Trainer"])
local WindTrainee = require(activeNpcs["Wind Trainee"])
local npcCode = WindTrainee.SendOver.Settings.NpcCode
local v = {
	CompletionNotify = {
		Npc = WindTrainer.Name,
		Text = gameSettings.TrainerCompliments
	}
}
return {
	["Ill learn Wind Breathing(Lv 25)"] = {
		OfferNpc = WindTrainer.Name,
		QuestInstance = Quests.Quest("Wind Breathing Training", {
			Quests.QuestTask("Push ups", 1, "Pushups"),
			Quests.QuestTask("Boulder Split", 1, nil, "Push ups"),
			Quests.QuestTask("Boulder Push", 1, nil, "Boulder Split"),
			Quests.QuestTask("Aim Training", 1, "Target Shooting", "Boulder Push"),
			Quests.QuestTask("Meditate", 1, "Meditation", "Aim Training"),
			Quests.QuestTask("Defeat the Wind Trainee", 1, npcCode, "Meditate")
		}),
		Rewards = {
			Exp = 900,
			Wen = 405,
			Power = "Wind"
		},
		Requirements = {
			Level = 25
		},
		Category = "Combat",
		WenCostOnAccept = 3000,
		ItemCostOnAccept = {
			["Demon Horns"] = 50
		},
		CompletionNotify = {
			Npc = WindTrainer.Name,
			Text = "Hah. You did not hold back. That is Wind Breathing: a storm that does not stop."
		},
		TaskSpecs = {
			["Push ups"] = v,
			["Boulder Split"] = v,
			["Boulder Push"] = v,
			["Aim Training"] = v,
			Meditate = v
		},
		Markers = {
			["Defeat the Wind Trainee"] = {
				Icon = "",
				Position = WindTrainee.SendOver.Spawning.Locations[1] + vector.create(0, 3, 0)
			}
		}
	}
}