local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
local CivilianSettings = require(script.Parent.Parent:WaitForChild("NpcShared"):WaitForChild("CivilianSettings"))
return {
	Type = Menum.npcType.Idle,
	Name = "Estate Worker Niko",
	Icon = "rbxassetid://84465224432837",
	Marker = true,
	Requirements = {
		Level = 70
	},
	Appearance = script:FindFirstChild("Model"),
	WalkSpeed = 16,
	Spawns = CivilianSettings.Points
}