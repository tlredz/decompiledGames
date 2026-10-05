local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://114509383251925",
	Marker = true,
	Appearance = script.Model,
	Animations = {
		idle = { "rbxassetid://10586618784" }
	},
	Spawns = { CFrame.new(-594, 1242.5, -1095, -1, 0, 0, 0, 1, 0, 0, 0, -1) },
	Shop = {
		["Fancy Katana"] = {
			Price = {
				Wen = 1500
			},
			Model = script.Shop["Fancy Katana"]
		},
		["Regular Katana"] = {
			Price = {
				Wen = 500
			},
			Model = script.Shop["Regular Katana"]
		}
	}
}