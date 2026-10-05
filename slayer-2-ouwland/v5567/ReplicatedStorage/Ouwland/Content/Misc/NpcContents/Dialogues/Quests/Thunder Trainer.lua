local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local npcs = ReplicatedStorage.Ouwland.Content.Misc.Npcs
local activeNpcs = ReplicatedStorage.Ouwland.Content.Misc.ActiveNpcs
local ThunderTrainer = require(npcs["Thunder Trainer"])
local ThunderTrainee = require(activeNpcs["Thunder Trainee"])
local npcCode = ThunderTrainee.SendOver.Settings.NpcCode
local v = {
	CompletionNotify = {
		Npc = ThunderTrainer.Name,
		Text = gameSettings.TrainerCompliments
	}
}
return {
	["Ill learn Thunder Breathing(Lv 25)"] = {
		OfferNpc = ThunderTrainer.Name,
		QuestInstance = Quests.Quest("Thunder Breathing Training", {
			Quests.QuestTask("Meditate", 1, "Meditation"),
			Quests.QuestTask("Cup Training", 1, "Cup Game", "Meditate"),
			Quests.QuestTask("Push ups", 1, "Pushups", "Cup Training"),
			Quests.QuestTask("Aim Training", 1, "Target Shooting", "Push ups"),
			Quests.QuestTask("Boulder Split", 1, nil, "Aim Training"),
			Quests.QuestTask("Defeat the Thunder Trainee", 1, npcCode, "Boulder Split")
		}),
		Rewards = {
			Exp = 900,
			Wen = 405,
			Power = "Thunder"
		},
		Requirements = {
			Level = 25
		},
		Category = "Combat",
		WenCostOnAccept = 7000,
		ItemCostOnAccept = {
			["Demon Horns"] = 10
		},
		CompletionNotify = {
			Npc = ThunderTrainer.Name,
			Text = "Y-YOU DID IT?! One clean strike, no hesitation."
		},
		TaskSpecs = {
			Meditate = v,
			["Cup Training"] = v,
			["Push ups"] = v,
			["Aim Training"] = v,
			["Boulder Split"] = v
		},
		Markers = {
			["Defeat the Thunder Trainee"] = {
				Icon = "",
				Position = ThunderTrainee.SendOver.Spawning.Locations[1] + vector.create(0, 3, 0)
			}
		}
	}
}