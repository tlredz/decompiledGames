local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local npcs = ReplicatedStorage.Ouwland.Content.Misc.Npcs
local activeNpcs = ReplicatedStorage.Ouwland.Content.Misc.ActiveNpcs
local TaiChiExpertRenjiro = require(npcs["Tai Chi Expert Renjiro"])
local TaiChiTrainee = require(activeNpcs["Tai Chi Trainee"])
local npcCode = TaiChiTrainee.SendOver.Settings.NpcCode
return {
	["Ill learn the Tai Chi Style(Lv 65)"] = {
		OfferNpc = TaiChiExpertRenjiro.Name,
		QuestInstance = Quests.Quest("The Tai Chi Trial", {
			Quests.QuestTask("Common Fish", 20),
			Quests.QuestTask("Tai Chi Scroll", 1),
			Quests.QuestTask("Land 8,000 fist M1 damage", 8000, "FistM1Damage"),
			Quests.QuestTask("Defeat the Tai Chi Trainee", 1, npcCode)
		}),
		Rewards = {
			Exp = 2340,
			Wen = 1053,
			Power = {
				Name = "Tai Chi",
				GrantNotify = {
					Npc = TaiChiExpertRenjiro.Name,
					Text = "Tai Chi is yours. Softness first, the rest follows."
				}
			}
		},
		Requirements = {
			Race = { "Slayer", "Hybrid" },
			Level = 65
		},
		Category = "Combat",
		WenCostOnAccept = 9000,
		ItemCostOnAccept = {
			["Beast Core"] = 5
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
				TargetNpc = TaiChiExpertRenjiro.Name,
				Hint = "Only fish handed to Renjiro count. Bring the catch back."
			},
			["Tai Chi Scroll"] = {
				Type = "Pickup",
				Positions = { vector.create(1989.166, 534.405, -645.663) },
				Hint = "Deep in the water below Renjiro"
			},
			["Defeat the Tai Chi Trainee"] = {
				Hint = "In a hidden cave beneath the Stone Hashira's retirement home"
			}
		}
	}
}