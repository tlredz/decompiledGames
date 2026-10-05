local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	["Ill restock the infirmary(Lv 70)"] = {
		QuestInstance = Quests.Quest("Restock the Infirmary", {
			Quests.QuestTask("Health Elixirs stocked", 10),
			Quests.QuestTask("Health Regen Elixirs stocked", 10),
			Quests.QuestTask("Stamina Regen Elixirs stocked", 10),
			Quests.QuestTask("Return to Shiori", 1)
		}),
		Rewards = {
			Exp = 7200,
			Wen = 810,
			Ore = {
				Quantity = 1
			}
		},
		Requirements = {
			Level = 70
		},
		Category = "Dialogue",
		LogCompletion = true,
		TaskSpecs = {
			["Health Elixirs stocked"] = {
				Type = "Deposit",
				RequiredItem = "Health Elixir",
				Position = createVector(-1848.23, 315.086, -119.539)
			},
			["Health Regen Elixirs stocked"] = {
				Type = "Deposit",
				RequiredItem = "Health Regen Elixir",
				Position = createVector(-1848.23, 315.086, -119.539)
			},
			["Stamina Regen Elixirs stocked"] = {
				Type = "Deposit",
				RequiredItem = "Stamina Regen Elixir",
				Position = createVector(-1848.23, 315.086, -119.539)
			},
			["Return to Shiori"] = {
				Type = "Deliver",
				TargetNpc = "Shiori"
			}
		},
		Markers = {
			["Stamina Regen Elixirs stocked"] = {
				Icon = "",
				Position = createVector(-1848.23, 315.086, -119.539)
			},
			["Return to Shiori"] = {
				Npc = "Shiori",
				After = { "Health Elixirs stocked", "Health Regen Elixirs stocked", "Stamina Regen Elixirs stocked" }
			}
		}
	},
	["Ill stock the reserves(Lv 75)"] = {
		QuestInstance = Quests.Quest("The Full Pantry", {
			Quests.QuestTask("Golden Fish crated", 9),
			Quests.QuestTask("Clown Fish crated", 9),
			Quests.QuestTask("Zebra Fish crated", 9),
			Quests.QuestTask("Return to Shiori", 1)
		}),
		Rewards = {
			Exp = 2900,
			Wen = 2250
		},
		Requirements = {
			Level = 75
		},
		Category = "Fishing",
		TaskSpecs = {
			["Golden Fish crated"] = {
				Type = "Deposit",
				RequiredItem = "Golden Fish",
				Position = createVector(-1848.23, 315.086, -119.539)
			},
			["Clown Fish crated"] = {
				Type = "Deposit",
				RequiredItem = "Clown Fish",
				Position = createVector(-1848.23, 315.086, -119.539)
			},
			["Zebra Fish crated"] = {
				Type = "Deposit",
				RequiredItem = "Zebra Fish",
				Position = createVector(-1848.23, 315.086, -119.539)
			},
			["Return to Shiori"] = {
				Type = "Deliver",
				TargetNpc = "Shiori"
			}
		},
		Markers = {
			["Zebra Fish crated"] = {
				Icon = "",
				Position = createVector(-1848.23, 315.086, -119.539)
			},
			["Return to Shiori"] = {
				Npc = "Shiori",
				After = { "Golden Fish crated", "Clown Fish crated", "Zebra Fish crated" }
			}
		}
	}
}