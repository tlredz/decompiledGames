local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local npcs = ReplicatedStorage.Ouwland.Content.Misc.Npcs
local activeNpcs = ReplicatedStorage.Ouwland.Content.Misc.ActiveNpcs
local SoryuExpertKazuma = require(npcs["Soryu Expert Kazuma"])
local SoryuTrainee = require(activeNpcs["Soryu Trainee"])
local npcCode = SoryuTrainee.SendOver.Settings.NpcCode
return {
	["Ill learn the Soryu Style(Lv 62)"] = {
		OfferNpc = SoryuExpertKazuma.Name,
		QuestInstance = Quests.Quest("The Soryu Trial", {
			Quests.QuestTask("Common Fish", 20),
			Quests.QuestTask("Soryu Scroll", 1),
			Quests.QuestTask("Land 8,000 fist M1 damage", 8000, "FistM1Damage"),
			Quests.QuestTask("Defeat the Soryu Trainee", 1, npcCode)
		}),
		Rewards = {
			Exp = 2232,
			Wen = 1004,
			Power = {
				Name = "Soryu",
				GrantNotify = {
					Npc = SoryuExpertKazuma.Name,
					Text = "Soryu is yours now. Do not make me regret it."
				}
			}
		},
		Requirements = {
			Race = { "Demon", "Hybrid" },
			Level = 62
		},
		Category = "Combat",
		WenCostOnAccept = 8000,
		ItemCostOnAccept = {
			["Demon Horns"] = 12
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
				TargetNpc = SoryuExpertKazuma.Name,
				Hint = "Only fish handed to Kazuma count. Bring the catch back."
			},
			["Soryu Scroll"] = {
				Type = "Pickup",
				Positions = { vector.create(-663.656, 745.75, 114.442) },
				Hint = "In the flooded cave under Kazuma's feet"
			},
			["Defeat the Soryu Trainee"] = {
				Hint = "In the cave the waterfall hides"
			}
		}
	}
}