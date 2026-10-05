local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local npcs = ReplicatedStorage.Ouwland.Content.Misc.Npcs
local activeNpcs = ReplicatedStorage.Ouwland.Content.Misc.ActiveNpcs
local InsectTrainer = require(npcs["Insect Trainer"])
local InsectTrainee = require(activeNpcs["Insect Trainee"])
local npcCode = InsectTrainee.SendOver.Settings.NpcCode
local v = {
	CompletionNotify = {
		Npc = InsectTrainer.Name,
		Text = gameSettings.TrainerCompliments
	}
}
return {
	["Ill learn Insect Breathing(Lv 25)"] = {
		OfferNpc = InsectTrainer.Name,
		QuestInstance = Quests.Quest("Insect Breathing Training", {
			Quests.QuestTask("Meditate", 1, "Meditation"),
			Quests.QuestTask("Aim Training", 1, "Target Shooting", "Meditate"),
			Quests.QuestTask("Cup Training", 1, "Cup Game", "Aim Training"),
			Quests.QuestTask("Push ups", 1, "Pushups", "Cup Training"),
			Quests.QuestTask("Boulder Split", 1, nil, "Push ups"),
			Quests.QuestTask("Defeat the Insect Trainee", 1, npcCode, "Boulder Split")
		}),
		Rewards = {
			Exp = 900,
			Wen = 405,
			Power = "Insect"
		},
		Requirements = {
			Level = 25
		},
		Category = "Combat",
		WenCostOnAccept = 3500,
		ItemCostOnAccept = {
			["Demon Horns"] = 15,
			["Beast Core"] = 3
		},
		CompletionNotify = {
			Npc = InsectTrainer.Name,
			Text = "My my, you really did it. Deadly, and never once looking like it. Welcome to the club."
		},
		TaskSpecs = {
			Meditate = v,
			["Aim Training"] = v,
			["Cup Training"] = v,
			["Push ups"] = v,
			["Boulder Split"] = v
		},
		Markers = {
			["Defeat the Insect Trainee"] = {
				Icon = "",
				Position = InsectTrainee.SendOver.Spawning.Locations[1] + vector.create(0, 3, 0)
			}
		}
	}
}