local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local Niko = require(script.Parent.Parent.Parent.Parent.Npcs.Niko)
return {
	["Ill deliver the supply box(Lv 70)"] = {
		QuestInstance = Quests.Quest(
			"Deliver Niko's Supply Box",
			{
				Quests.QuestTask("Deliver to Shiori", 1),
				Quests.QuestTask("Report back to Niko", 1, nil, "Deliver to Shiori")
			}
		),
		Rewards = {
			Exp = 420,
			Wen = 189
		},
		Requirements = {
			Level = 70
		},
		AcceptCooldown = 40,
		Category = "Dialogue",
		NoSave = true,
		OfferNpc = Niko.Name,
		GrantItemOnAccept = "Supply Box",
		TaskSpecs = {
			["Deliver to Shiori"] = {
				Type = "Deliver",
				RequiredItem = "Supply Box",
				Count = 1,
				TargetNpc = "Shiori"
			},
			["Report back to Niko"] = {
				Type = "Deliver",
				TargetNpc = Niko.Name
			}
		},
		Markers = {
			["Deliver to Shiori"] = {
				Npc = "Shiori"
			},
			["Report back to Niko"] = {
				Npc = Niko.Name,
				After = { "Deliver to Shiori" }
			}
		}
	}
}