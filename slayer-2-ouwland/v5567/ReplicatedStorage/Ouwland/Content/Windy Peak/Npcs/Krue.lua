local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://135239677564444",
	Marker = true,
	Appearance = script.Model,
	Animations = {
		idle = { "rbxassetid://10586618784" }
	},
	Spawns = { CFrame.new(
			-425.491821,
			1243.50012,
			-952.493408,
			-1.00000107,
			2.91038305e-9,
			1.49011612e-8,
			-2.91038305e-9,
			0.999999881,
			-2.79396772e-9,
			1.49011612e-8,
			2.79396772e-9,
			-1.00000024
		) }
}