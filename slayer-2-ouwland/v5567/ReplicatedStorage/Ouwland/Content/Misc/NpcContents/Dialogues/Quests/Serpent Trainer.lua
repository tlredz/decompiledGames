local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local npcs = ReplicatedStorage.Ouwland.Content.Misc.Npcs
local activeNpcs = ReplicatedStorage.Ouwland.Content.Misc.ActiveNpcs
local SerpentTrainer = require(npcs["Serpent Trainer"])
local SerpentTrainee = require(activeNpcs["Serpent Trainee"])
local npcCode = SerpentTrainee.SendOver.Settings.NpcCode
local v = {
	CompletionNotify = {
		Npc = SerpentTrainer.Name,
		Text = gameSettings.TrainerCompliments
	}
}
return {
	["Ill learn Serpent Breathing(Lv 25)"] = {
		OfferNpc = SerpentTrainer.Name,
		QuestInstance = Quests.Quest("Serpent Breathing Training", {
			Quests.QuestTask("Meditate", 1, "Meditation"),
			Quests.QuestTask("Push ups", 1, "Pushups", "Meditate"),
			Quests.QuestTask("Boulder Split", 1, nil, "Push ups"),
			Quests.QuestTask("Boulder Push", 1, nil, "Boulder Split"),
			Quests.QuestTask("Aim Training", 1, "Target Shooting", "Boulder Push"),
			Quests.QuestTask("Defeat the Serpent Trainee", 1, npcCode, "Aim Training")
		}),
		Rewards = {
			Exp = 900,
			Wen = 405,
			Power = "Serpent"
		},
		Requirements = {
			Level = 25
		},
		Category = "Combat",
		WenCostOnAccept = 1000,
		ItemCostOnAccept = {
			["Demon Horns"] = 20,
			["Beast Core"] = 5
		},
		CompletionNotify = {
			Npc = SerpentTrainer.Name,
			Text = "You struck without hesitation, and without wasting a single movement. You have earned my respect."
		},
		TaskSpecs = {
			Meditate = v,
			["Push ups"] = v,
			["Boulder Split"] = v,
			["Boulder Push"] = v,
			["Aim Training"] = v
		},
		Markers = {
			["Defeat the Serpent Trainee"] = {
				Icon = "",
				Position = SerpentTrainee.SendOver.Spawning.Locations[1] + vector.create(0, 3, 0)
			}
		}
	}
}