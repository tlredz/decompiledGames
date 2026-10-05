local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Egg Thief",
	TowerName = "Gigi",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W4,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Ability = "rbxassetid://92455041576210",
		Decode = "rbxassetid://98963387488985",
		Idle = "rbxassetid://125686660526683",
		Quirk = "rbxassetid://97537374452563",
		Run = "rbxassetid://109941595226660",
		Walk = "rbxassetid://88140844483455"
	},
	FaceTextures = {
		Normal = "rbxassetid://112259921057639",
		Blink = "rbxassetid://123572543961950",
		Hurt = "rbxassetid://99253419766432"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}