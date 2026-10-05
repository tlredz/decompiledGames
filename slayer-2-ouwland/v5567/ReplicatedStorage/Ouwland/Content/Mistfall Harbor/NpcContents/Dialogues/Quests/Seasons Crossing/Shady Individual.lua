local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local Rooyi = require(script.Parent.Parent.Parent.Parent.Parent.Npcs["Seasons Crossing"].Rooyi)
local MizunotoSettings = require(script.Parent.Parent.Parent.Parent.Parent.NpcShared.MizunotoSettings)
local position = Rooyi.Spawns[1].Position + vector.create(0, 3, 0)
return {
	["Ill eliminate the Mizunoto(Lv 62)"] = {
		OfferNpc = Rooyi.Name,
		QuestInstance = Quests.Quest(
			"Five Broken Blades",
			{ Quests.QuestTask("Broken Nichirin Katanas", 5), Quests.QuestTask("Return to the Shady Individual", 1) }
		),
		Rewards = {
			Exp = 1050,
			Wen = 473
		},
		Requirements = {
			Race = { "Demon", "Hybrid" },
			Level = 62
		},
		Category = "Combat",
		Markers = {
			["Broken Nichirin Katanas"] = {
				Icon = "",
				Position = MizunotoSettings.Center
			},
			["Return to the Shady Individual"] = {
				Icon = Rooyi.Icon,
				Position = position,
				After = { "Broken Nichirin Katanas" }
			}
		},
		TaskSpecs = {
			["Broken Nichirin Katanas"] = {
				Type = "Collect",
				RequiredItem = "Broken Nichirin Katana",
				Hint = "Not every Mizunoto falls with their blade intact."
			},
			["Return to the Shady Individual"] = {
				Type = "Deliver",
				RequiredItem = "Broken Nichirin Katana",
				Count = 5,
				TargetNpc = Rooyi.Name
			}
		}
	}
}