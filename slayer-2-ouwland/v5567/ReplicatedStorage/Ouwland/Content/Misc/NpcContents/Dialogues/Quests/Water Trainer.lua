local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local npcs = ReplicatedStorage.Ouwland.Content.Misc.Npcs
local activeNpcs = ReplicatedStorage.Ouwland.Content.Misc.ActiveNpcs
local WaterTrainer = require(npcs["Water Trainer"])
local WaterTrainee = require(activeNpcs["Water Trainee"])
local npcCode = WaterTrainee.SendOver.Settings.NpcCode
local v = {
	CompletionNotify = {
		Npc = WaterTrainer.Name,
		Text = gameSettings.TrainerCompliments
	}
}
local underwaterRockSpot = gameSettings.UnderwaterRockSpots[game.PlaceId]
return {
	["Ill learn Water Breathing(Lv 25)"] = {
		OfferNpc = WaterTrainer.Name,
		QuestInstance = Quests.Quest("Water Breathing Training", {
			Quests.QuestTask("Parkour Dungeon", 1),
			Quests.QuestTask("Push ups", 1, "Pushups", "Parkour Dungeon"),
			Quests.QuestTask("Boulder Push", 1, nil, "Push ups"),
			Quests.QuestTask("Aim Training", 1, "Target Shooting", "Boulder Push"),
			Quests.QuestTask("Underwater Rocks", #underwaterRockSpot, nil, "Aim Training"),
			Quests.QuestTask("Defeat the Water Trainee", 1, npcCode, "Underwater Rocks")
		}),
		Rewards = {
			Exp = 900,
			Wen = 405,
			Power = "Water"
		},
		Requirements = {
			Level = 25
		},
		Category = "Combat",
		WenCostOnAccept = 5000,
		ItemCostOnAccept = {
			["Demon Horns"] = 30
		},
		CompletionNotify = {
			Npc = WaterTrainer.Name,
			Text = "You beat Sabito. Water finds its way through anything, and so did you."
		},
		TaskSpecs = {
			["Parkour Dungeon"] = {
				Type = "Dungeon",
				Dungeon = "Parkour Dungeon",
				Stage = "Complete",
				CompletionNotify = v.CompletionNotify
			},
			["Push ups"] = v,
			["Boulder Push"] = v,
			["Aim Training"] = v,
			["Underwater Rocks"] = {
				Type = "Pickup",
				Positions = underwaterRockSpot,
				CompletionNotify = v.CompletionNotify
			}
		},
		Markers = {
			["Defeat the Water Trainee"] = {
				Icon = "",
				Position = WaterTrainee.SendOver.Spawning.Locations[1] + vector.create(0, 3, 0)
			}
		}
	}
}