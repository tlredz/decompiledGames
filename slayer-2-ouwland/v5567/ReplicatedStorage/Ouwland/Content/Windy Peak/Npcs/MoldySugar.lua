local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://122180820704282",
	Marker = true,
	Appearance = script:FindFirstChild("Model"),
	ModelAttributes = {
		NoDialogueTurn = true,
		NoDialogueAnim = true
	},
	Animations = {
		idle = { "rbxassetid://84011318400421" }
	},
	Spawns = { CFrame.new(
			-701.752869,
			1243.34021,
			-982.68335,
			0.317818224,
			0.0498984009,
			-0.946837604,
			0,
			0.998614132,
			0.0526284277,
			0.948151648,
			-0.0167302601,
			0.317377627
		) }
}