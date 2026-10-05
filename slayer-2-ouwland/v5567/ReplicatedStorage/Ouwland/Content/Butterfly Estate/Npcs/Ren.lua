local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local shop = script:FindFirstChild("Shop")
return {
	Type = Menum.npcType.Idle,
	Name = script.Name,
	Icon = "rbxassetid://71765581781968",
	Marker = true,
	Requirements = {
		Level = 75
	},
	Shop = {
		["Small Gourd"] = {
			Model = shop and shop:FindFirstChild("Small Gourd"),
			RequiresSide = "Slayer",
			SuccessDialogue = "Ren_GourdSuccess",
			FailDialogue = "Ren_GourdFail"
		},
		["Medium Gourd"] = {
			Model = shop and shop:FindFirstChild("Medium Gourd"),
			RequiresSide = "Slayer",
			SuccessDialogue = "Ren_GourdSuccess",
			FailDialogue = "Ren_GourdFail"
		},
		["Large Gourd"] = {
			Model = shop and shop:FindFirstChild("Large Gourd"),
			RequiresSide = "Slayer",
			SuccessDialogue = "Ren_GourdSuccess",
			FailDialogue = "Ren_GourdFail"
		}
	},
	Appearance = script:FindFirstChild("Model"),
	WaitBeforeChangingDirection = {
		Min = 8,
		Max = 14
	},
	Spawns = {
		createVector(-1795, 311.8, -85),
		createVector(-1849.1, 311.8, -91.3),
		createVector(-1887.3, 311.8, -82.7),
		createVector(-1834.9, 311.8, -23.7),
		createVector(-1834.9, 311.8, 75.4),
		createVector(-1688.3, 286.8, 75.4),
		createVector(-1609.3, 286.8, 10.2),
		createVector(-1609.3, 311.8, -80.9),
		createVector(-1643.2, 311.8, -125.1),
		createVector(-1707.6, 311.8, -125.1)
	}
}