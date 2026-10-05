local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local v = CFrame.new(-91.65, 1353.38, -2705.573) * CFrame.Angles(0, -2.356194490192345, 0)
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://74539284258900",
	Marker = true,
	Appearance = script:FindFirstChild("Model"),
	Spawns = { v },
	RequiresQuestDone = "Ill help you survive the winter(Lv 100)",
	Shop = {
		Shovel = {
			Price = {
				Wen = 1000
			},
			Model = script.Shop.Shovel,
			SuccessDialogue = "Lynx_PurchaseSuccess",
			FailDialogue = "Lynx_PurchaseFail"
		}
	},
	RotatingShop = {
		Name = "Lynx",
		Seed = 9137,
		TimedEvent = "TailorRestock",
		SlotCount = 4,
		MannequinTemplateName = "outfit_stand",
		RefreshEffect = "ElaraClothingSwitch",
		SuccessDialogue = "Lynx_PurchaseSuccess",
		FailDialogue = "Lynx_PurchaseFail",
		CountdownAt = vector.create(-105.95, 1362.199, -2687.034),
		Slots = {
			CFrame.new(-65.347, 1351.117, -2730.372, 0.707, 0, -0.707, 0, 1, 0, 0.707, 0, 0.707),
			CFrame.new(-65.785, 1351.112, -2690.863, -0.707, 0, -0.707, 0, 1, 0, 0.707, 0, -0.707),
			CFrame.new(-69.94, 1351.147, -2686.726, -0.707, 0, -0.707, 0, 1, 0, 0.707, 0, -0.707),
			CFrame.new(-74.443, 1351.147, -2682.229, -0.707, 0, -0.707, 0, 1, 0, 0.707, 0, -0.707),
			CFrame.new(-61.497, 1351.117, -2695.161, -0.707, 0, -0.707, 0, 1, 0, 0.707, 0, -0.707),
			CFrame.new(-52.611, 1351.117, -2717.636, 0.707, 0, -0.707, 0, 1, 0, 0.707, 0, 0.707),
			CFrame.new(-57.039, 1351.117, -2699.619, -0.707, 0, -0.707, 0, 1, 0, 0.707, 0, -0.707),
			CFrame.new(-60.895, 1351.117, -2725.92, 0.707, 0, -0.707, 0, 1, 0, 0.707, 0, 0.707),
			CFrame.new(-48.159, 1351.117, -2713.184, 0.707, 0, -0.707, 0, 1, 0, 0.707, 0, 0.707)
		},
		Pool = {
			"Yukiume Fur Coat",
			"Wisteria Greatcoat",
			"Indigo Frost Coat",
			"Yamamichi Kimono",
			"Frostgrey Traveler's Coat",
			"Matsuba Haori",
			"Frostsilk Topper",
			"Conductor's Cap",
			"Sakura Felt Hat",
			"Ichimatsu Erimaki",
			"Raimon Erimaki",
			"Sakura Erimaki",
			"Murasaki Erimaki"
		}
	}
}