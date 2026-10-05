local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Confident Caroler",
	TowerName = "Poppy",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W3,
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Run = "rbxassetid://130457582828761",
		Walk = "rbxassetid://74238306639300",
		Idle = "rbxassetid://87088569337275",
		Quirk = "rbxassetid://80243115371349",
		Decode = "rbxassetid://120859968917492"
	},
	FaceTextures = {
		Blink = "rbxassetid://77450485950246",
		Hurt = "rbxassetid://130273693130453",
		Normal = "rbxassetid://99007653673022"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}