local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local ShrineMessengerAkio = require(script.Parent.Parent.Parent.Parent.Parent.Npcs["Iceveil Settlement"]["Shrine Messenger Akio"])
return {
	["Ill see you to Windy Peak(Lv 105)"] = {
		QuestInstance = Quests.Quest(
			"Escort Akio to Windy Peak",
			{ Quests.QuestTask("Fend off the ambushes", 6), Quests.QuestTask("Reach Windy Peak", 34) }
		),
		Rewards = {
			Exp = 2000,
			Wen = 900
		},
		Requirements = {
			Level = 105
		},
		Category = "Combat",
		Event = "Escort",
		NoSave = true
	},
	["Ill haul in the deep catch(Lv 125)"] = {
		QuestInstance = Quests.Quest("The Deep Catch", {
			Quests.QuestTask("Crustadon stocked", 5),
			Quests.QuestTask("Krathulon stocked", 5),
			Quests.QuestTask("Clown Fish stocked", 12),
			Quests.QuestTask("Return to Akio", 1)
		}),
		Rewards = {
			Exp = 4300,
			Wen = 3075
		},
		Requirements = {
			Level = 125
		},
		Category = "Fishing",
		TaskSpecs = {
			["Crustadon stocked"] = {
				Type = "Deposit",
				RequiredItem = "Crustadon",
				Position = createVector(-114.398, 1354.044, -2520.924)
			},
			["Krathulon stocked"] = {
				Type = "Deposit",
				RequiredItem = "Krathulon",
				Position = createVector(-114.398, 1354.044, -2520.924)
			},
			["Clown Fish stocked"] = {
				Type = "Deposit",
				RequiredItem = "Clown Fish",
				Position = createVector(-114.398, 1354.044, -2520.924)
			},
			["Return to Akio"] = {
				Type = "Deliver",
				TargetNpc = ShrineMessengerAkio.Name
			}
		},
		Markers = {
			["Krathulon stocked"] = {
				Icon = "",
				Position = createVector(-114.398, 1354.044, -2520.924)
			},
			["Return to Akio"] = {
				Npc = ShrineMessengerAkio.Name,
				After = { "Crustadon stocked", "Krathulon stocked", "Clown Fish stocked" }
			}
		}
	}
}