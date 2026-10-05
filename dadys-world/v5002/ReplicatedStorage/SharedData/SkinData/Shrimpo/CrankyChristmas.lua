local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Cranky Christmas",
	TowerName = "Shrimpo",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W3,
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Run = "rbxassetid://125764908139950",
		Walk = "rbxassetid://127433467890235",
		Idle = "rbxassetid://108456395740581",
		Quirk = "rbxassetid://123236564367823",
		Decode = "rbxassetid://116781714010144"
	},
	FaceTextures = {
		Blink = "rbxassetid://133020084478236",
		Hurt = "rbxassetid://77612948006555",
		Normal = "rbxassetid://116805854007228"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}