local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Spring Quilt",
	TowerName = "Squirm",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W1,
	Easter = true,
	HolidaySkin = true,
	GeneratorOffset = {
		Y = 0,
		Z = 1.16
	},
	OverwriteAnimations = {
		Run = "rbxassetid://96691901753873",
		Walk = "rbxassetid://115649459486775",
		Idle = "rbxassetid://105609509684314",
		Quirk = "rbxassetid://121370693536610",
		Decode = "rbxassetid://129616785848225",
		Ability_End = "rbxassetid://72299385000677",
		Ability_Loop = "rbxassetid://84015650323713",
		Ability_Start = "rbxassetid://112567518383017",
		Munch = "rbxassetid://104675324730316"
	},
	FaceTextures = {
		Normal = "rbxassetid://84030455317736",
		Blink = "rbxassetid://128576485006588",
		Hurt = "rbxassetid://93931028618201"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}