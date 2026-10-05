local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://129295080331555",
	Marker = true,
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://94305578565429" }
	},
	Spawns = { CFrame.new(
			-515.546509,
			1243.19995,
			-1251.23865,
			-0.463231921,
			-0.0000134432166,
			0.886237025,
			0,
			1,
			0.0000119138849,
			-0.886236489,
			0,
			-0.463232011
		) }
}