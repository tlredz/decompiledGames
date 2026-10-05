local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local npcs = ReplicatedStorage.Ouwland.Content.Misc.Npcs
local activeNpcs = ReplicatedStorage.Ouwland.Content.Misc.ActiveNpcs
local StoneTrainer = require(npcs["Stone Trainer"])
local StoneTrainee = require(activeNpcs["Stone Trainee"])
local npcCode = StoneTrainee.SendOver.Settings.NpcCode
local v = {
	CompletionNotify = {
		Npc = StoneTrainer.Name,
		Text = gameSettings.TrainerCompliments
	}
}
return {
	["Ill learn Stone Breathing(Lv 25)"] = {
		OfferNpc = StoneTrainer.Name,
		QuestInstance = Quests.Quest("Stone Breathing Training", {
			Quests.QuestTask("Meditate", 1, "Meditation"),
			Quests.QuestTask("Push ups", 1, "Pushups", "Meditate"),
			Quests.QuestTask("Boulder Push", 1, nil, "Push ups"),
			Quests.QuestTask("Boulder Split", 1, nil, "Boulder Push"),
			Quests.QuestTask("Parkour Dungeon", 1, nil, "Boulder Split"),
			Quests.QuestTask("Defeat the Stone Trainee", 1, npcCode, "Parkour Dungeon")
		}),
		Rewards = {
			Exp = 900,
			Wen = 405,
			Power = "Stone"
		},
		Requirements = {
			Level = 25,
			Items = { "Axe and Mace", "Seismic Axe and Mace", "Nightfall Axe and Mace" }
		},
		Category = "Combat",
		WenCostOnAccept = 4000,
		ItemCostOnAccept = {
			["Beast Core"] = 4
		},
		CompletionNotify = {
			Npc = StoneTrainer.Name,
			Text = "You stood against my student and did not waver. That stillness is the true weight of Stone Breathing."
		},
		TaskSpecs = {
			Meditate = v,
			["Push ups"] = v,
			["Boulder Push"] = v,
			["Boulder Split"] = v,
			["Parkour Dungeon"] = {
				Type = "Dungeon",
				Dungeon = "Parkour Dungeon",
				Stage = "Complete",
				CompletionNotify = v.CompletionNotify
			}
		},
		Markers = {
			["Defeat the Stone Trainee"] = {
				Icon = "",
				Position = StoneTrainee.SendOver.Spawning.Locations[1] + vector.create(0, 3, 0)
			}
		}
	}
}