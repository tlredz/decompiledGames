local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local npcs = ReplicatedStorage.Ouwland.Content.Misc.Npcs
local activeNpcs = ReplicatedStorage.Ouwland.Content.Misc.ActiveNpcs
local FlameTrainer = require(npcs["Flame Trainer"])
local FlameTrainee = require(activeNpcs["Flame Trainee"])
local npcCode = FlameTrainee.SendOver.Settings.NpcCode
local v = {
	CompletionNotify = {
		Npc = FlameTrainer.Name,
		Text = gameSettings.TrainerCompliments
	}
}
return {
	["Ill learn Flame Breathing(Lv 25)"] = {
		OfferNpc = FlameTrainer.Name,
		QuestInstance = Quests.Quest("Flame Breathing Training", {
			Quests.QuestTask("Meditate", 1, "Meditation"),
			Quests.QuestTask("Push ups", 1, "Pushups", "Meditate"),
			Quests.QuestTask("Boulder Split", 1, nil, "Push ups"),
			Quests.QuestTask("Aim Training", 1, "Target Shooting", "Boulder Split"),
			Quests.QuestTask("Cup Training", 1, "Cup Game", "Aim Training"),
			Quests.QuestTask("Defeat the Flame Trainee", 1, npcCode, "Cup Training")
		}),
		Rewards = {
			Exp = 900,
			Wen = 405,
			Power = "Flame"
		},
		Requirements = {
			Level = 25
		},
		Category = "Combat",
		WenCostOnAccept = 6000,
		ItemCostOnAccept = {
			["Demon Horns"] = 10
		},
		CompletionNotify = {
			Npc = FlameTrainer.Name,
			Text = "Magnificent! That is the heart of Flame Breathing."
		},
		TaskSpecs = {
			Meditate = v,
			["Push ups"] = v,
			["Boulder Split"] = v,
			["Aim Training"] = v,
			["Cup Training"] = v
		},
		Markers = {
			["Defeat the Flame Trainee"] = {
				Icon = "",
				Position = FlameTrainee.SendOver.Spawning.Locations[1] + vector.create(0, 3, 0)
			}
		}
	}
}