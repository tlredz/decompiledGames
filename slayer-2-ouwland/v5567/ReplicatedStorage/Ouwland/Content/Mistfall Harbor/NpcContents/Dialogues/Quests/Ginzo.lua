local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
return {
	["Ill find the jewelry box(Lv 45)"] = {
		QuestInstance = Quests.Quest(
			"Retrieve Ginzo's Jewelry Box",
			{ Quests.QuestTask("Jewelry Box found", 1), Quests.QuestTask("Return to Ginzo", 1) }
		),
		Rewards = {
			Exp = 2700,
			Wen = 240
		},
		Requirements = {
			Level = 45
		},
		Category = "Dialogue",
		LogCompletion = true,
		TaskSpecs = {
			["Jewelry Box found"] = {
				Type = "Pickup",
				MaxDistance = 25,
				GrantItem = "Jewelry Box",
				Positions = { createVector(1869.092, 687.835, -734.628) },
				CompletionNotify = {
					Npc = "Ginzo",
					Text = "Careful with that."
				}
			},
			["Return to Ginzo"] = {
				Type = "Deliver",
				RequiredItem = "Jewelry Box",
				TargetNpc = "Ginzo"
			}
		},
		Markers = {
			["Jewelry Box found"] = {
				Icon = "rbxassetid://127721943897846",
				Position = createVector(1869.092, 687.835, -734.628)
			},
			["Return to Ginzo"] = {
				Npc = "Ginzo",
				After = { "Jewelry Box found" }
			}
		}
	}
}