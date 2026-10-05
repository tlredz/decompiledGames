local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local npcs = ReplicatedStorage.Ouwland.Content.Misc.Npcs
local activeNpcs = ReplicatedStorage.Ouwland.Content.Misc.ActiveNpcs
local SoundTrainer = require(npcs["Sound Trainer"])
local SoundTrainee = require(activeNpcs["Sound Trainee"])
local npcCode = SoundTrainee.SendOver.Settings.NpcCode
local v = {
	CompletionNotify = {
		Npc = SoundTrainer.Name,
		Text = gameSettings.TrainerCompliments
	}
}
local underwaterRockSpot = gameSettings.UnderwaterRockSpots[game.PlaceId]
return {
	["Ill learn Sound Breathing(Lv 25)"] = {
		OfferNpc = SoundTrainer.Name,
		QuestInstance = Quests.Quest("Sound Breathing Training", {
			Quests.QuestTask("Push ups", 1, "Pushups"),
			Quests.QuestTask("Barbell squats", 1, "Squat", "Push ups"),
			Quests.QuestTask("Boulder Split", 1, nil, "Barbell squats"),
			Quests.QuestTask("Cup Training", 1, "Cup Game", "Boulder Split"),
			Quests.QuestTask("Underwater Rocks", #underwaterRockSpot, nil, "Cup Training"),
			Quests.QuestTask("Defeat the Sound Trainee", 1, npcCode, "Underwater Rocks")
		}),
		Rewards = {
			Exp = 900,
			Wen = 405,
			Power = "Sound"
		},
		Requirements = {
			Level = 25
		},
		Category = "Combat",
		WenCostOnAccept = 4000,
		ItemCostOnAccept = {
			["Demon Horns"] = 10,
			["Beast Core"] = 3
		},
		CompletionNotify = {
			Npc = SoundTrainer.Name,
			Text = "MAGNIFICENT! An explosive finish! Flashy is non negotiable from here on out."
		},
		TaskSpecs = {
			["Push ups"] = v,
			["Barbell squats"] = v,
			["Boulder Split"] = v,
			["Cup Training"] = v,
			["Underwater Rocks"] = {
				Type = "Pickup",
				Positions = underwaterRockSpot,
				CompletionNotify = v.CompletionNotify
			}
		},
		Markers = {
			["Defeat the Sound Trainee"] = {
				Icon = "",
				Position = SoundTrainee.SendOver.Spawning.Locations[1] + vector.create(0, 3, 0)
			}
		}
	}
}