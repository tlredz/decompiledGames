local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = "Rika",
	Icon = "rbxassetid://115554429036192",
	Marker = true,
	Appearance = script.Model,
	Animations = {
		idle = { "rbxassetid://140392055724592" }
	},
	Spawns = { CFrame.new(
			-496.450104,
			1248.9071,
			-1177.20642,
			-0.0000117509608,
			-0.0494209379,
			0.998778105,
			0.0141670359,
			0.998677731,
			0.0494161285,
			-0.999899566,
			0.0141503057,
			0.000688412634
		) },
	SpawnOffset = CFrame.Angles(0, 0.6283185307179586, 0) * CFrame.new(0, -1.7, -0.65),
	Shop = {
		["Health Regen Potion"] = {
			Price = {
				Wen = 600
			},
			Model = script.Shop["Health Regen Potion"],
			SuccessDialogue = "Rika_PurchaseSuccess",
			FailDialogue = "Rika_PurchaseFail"
		},
		["Stamina Regen Potion"] = {
			Price = {
				Wen = 900
			},
			Model = script.Shop["Stamina Regen Potion"],
			SuccessDialogue = "Rika_PurchaseSuccess",
			FailDialogue = "Rika_PurchaseFail"
		}
	}
}