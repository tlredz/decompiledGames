local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Funny Bunny",
	TowerName = "Looey",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W2,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Walk = "rbxassetid://128622526279717",
		Idle = "rbxassetid://101567511246609",
		Decode = "rbxassetid://77531724990678",
		Run = "rbxassetid://99708231658418",
		Quirk = "rbxassetid://81982842713118"
	},
	FaceTextures = {
		Normal = "rbxassetid://81891135280795",
		Blink = "rbxassetid://83140898205539",
		Hurt = "rbxassetid://132478395155231"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}