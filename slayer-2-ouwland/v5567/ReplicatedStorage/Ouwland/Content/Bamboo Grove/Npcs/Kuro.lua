local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://108495309747238",
	Marker = true,
	NightOnly = true,
	ModelAttributes = {
		NoDialogueTurn = true,
		NoDialogueAnim = true
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://83241418829766" }
	},
	Spawns = { CFrame.new(
			667.270996,
			1121.1991,
			-1100.75671,
			0.0672791451,
			0,
			0.997734189,
			0,
			1,
			0,
			-0.997734189,
			0,
			0.0672791451
		) },
	Shop = {
		["Health Regen Potion"] = {
			Price = {
				Wen = 600
			}
		},
		["Stamina Regen Potion"] = {
			Price = {
				Wen = 900
			}
		},
		["Urokodaki's Mask"] = {},
		["Stylish Boa"] = {},
		["Sun Eve Drape"] = {},
		["Peppermint Scarf"] = {},
		["Heart of Night Necklace"] = {},
		["Tidal Earrings"] = {},
		["Cherry Blossom Lantern"] = {},
		["Crown of the Brave"] = {},
		["Black Dragon Horns"] = {},
		["Solstice Necklace"] = {},
		["Black-Cord Necklace"] = {},
		["Ivory edge Cloak"] = {}
	}
}