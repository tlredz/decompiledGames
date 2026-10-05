local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local npcs = ReplicatedStorage.Ouwland.Content.Misc.Npcs
local activeNpcs = ReplicatedStorage.Ouwland.Content.Misc.ActiveNpcs
local HarvesterofSoulsZurinyz = require(npcs["Harvester of Souls Zurinyz"])
local ReaperTrainee = require(activeNpcs["Reaper Trainee"])
local npcCode = ReaperTrainee.SendOver.Settings.NpcCode
return {
	["Ill learn the Reaping Blades Style(Lv 100)"] = {
		OfferNpc = HarvesterofSoulsZurinyz.Name,
		QuestInstance = Quests.Quest("The Reaper's Trial", {
			Quests.QuestTask("Common Fish", 20),
			Quests.QuestTask("Reaper Scroll", 1),
			Quests.QuestTask("Land 12,000 fist M1 damage", 12000, "FistM1Damage"),
			Quests.QuestTask("Defeat the Reaper Trainee", 1, npcCode)
		}),
		Rewards = {
			Exp = 3600,
			Wen = 1620,
			Power = {
				Name = "Reaping Blades",
				GrantNotify = {
					Npc = HarvesterofSoulsZurinyz.Name,
					Text = "The Reaping Blades are yours. Reap cleanly."
				}
			}
		},
		Requirements = {
			Race = { "Demon", "Hybrid" },
			Level = 100
		},
		Category = "Combat",
		WenCostOnAccept = 15000,
		ItemCostOnAccept = {
			["Demon Horns"] = 20
		},
		TaskSpecs = {
			["Common Fish"] = {
				Type = "DeliverAny",
				RequiredItems = {
					"OuwFish",
					"Sea Horse",
					"Coral",
					"OuwFwesh"
				},
				TargetNpc = HarvesterofSoulsZurinyz.Name,
				Hint = "Only fish handed to Zurinyz count. Bring the catch back."
			},
			["Reaper Scroll"] = {
				Type = "Pickup",
				Positions = { vector.create(594.094, 974.151, -589.813) },
				Hint = "In the lake beneath the falls, on the road to the bamboo sanctuary"
			},
			["Defeat the Reaper Trainee"] = {
				Hint = "A cave where small blue caps grow on the rock and snow"
			}
		}
	}
}