local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local IceveilGuardShiro = require(script.Parent.Parent.Parent.Parent.Parent.Npcs["Iceveil Settlement"]["Iceveil Guard Shiro"])
return {
	["Ill help you survive the winter(Lv 100)"] = {
		QuestInstance = Quests.Quest(
			"Supply the Settlement",
			{
				Quests.QuestTask("Cooked Bear Meat stocked", 9),
				Quests.QuestTask("Health Elixirs stocked", 25),
				Quests.QuestTask("Return to Shiro", 1)
			}
		),
		Rewards = {
			Exp = 12000,
			Wen = 6000,
			Ore = {
				Quantity = 1
			}
		},
		Requirements = {
			Level = 100
		},
		Category = "Dialogue",
		LogCompletion = true,
		TaskSpecs = {
			["Cooked Bear Meat stocked"] = {
				Type = "Deposit",
				RequiredItem = "Cooked Bear Meat",
				Position = createVector(-114.398, 1354.044, -2520.924)
			},
			["Health Elixirs stocked"] = {
				Type = "Deposit",
				RequiredItem = "Health Elixir",
				Position = createVector(-114.398, 1354.044, -2520.924)
			},
			["Return to Shiro"] = {
				Type = "Deliver",
				TargetNpc = IceveilGuardShiro.Name
			}
		},
		Markers = {
			["Health Elixirs stocked"] = {
				Icon = "",
				Position = createVector(-114.398, 1354.044, -2520.924)
			},
			["Return to Shiro"] = {
				Npc = IceveilGuardShiro.Name,
				After = { "Cooked Bear Meat stocked", "Health Elixirs stocked" }
			}
		}
	},
	["Ill fill the winter stores(Lv 105)"] = {
		QuestInstance = Quests.Quest("The Winter Catch", {
			Quests.QuestTask("Golden Fish stocked", 12),
			Quests.QuestTask("Clown Fish stocked", 12),
			Quests.QuestTask("Zebra Fish stocked", 12),
			Quests.QuestTask("Crustadon stocked", 2),
			Quests.QuestTask("Krathulon stocked", 2),
			Quests.QuestTask("Return to Shiro", 1)
		}),
		Rewards = {
			Exp = 2900,
			Wen = 3825
		},
		Requirements = {
			Level = 105
		},
		Category = "Fishing",
		TaskSpecs = {
			["Golden Fish stocked"] = {
				Type = "Deposit",
				RequiredItem = "Golden Fish",
				Position = createVector(-114.398, 1354.044, -2520.924)
			},
			["Clown Fish stocked"] = {
				Type = "Deposit",
				RequiredItem = "Clown Fish",
				Position = createVector(-114.398, 1354.044, -2520.924)
			},
			["Zebra Fish stocked"] = {
				Type = "Deposit",
				RequiredItem = "Zebra Fish",
				Position = createVector(-114.398, 1354.044, -2520.924)
			},
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
			["Return to Shiro"] = {
				Type = "Deliver",
				TargetNpc = IceveilGuardShiro.Name
			}
		},
		Markers = {
			["Krathulon stocked"] = {
				Icon = "",
				Position = createVector(-114.398, 1354.044, -2520.924)
			},
			["Return to Shiro"] = {
				Npc = IceveilGuardShiro.Name,
				After = {
					"Golden Fish stocked",
					"Clown Fish stocked",
					"Zebra Fish stocked",
					"Crustadon stocked",
					"Krathulon stocked"
				}
			}
		}
	}
}