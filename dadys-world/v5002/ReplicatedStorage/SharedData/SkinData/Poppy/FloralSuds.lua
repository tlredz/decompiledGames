local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Floral Suds",
	TowerName = "Poppy",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W5,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Run = "rbxassetid://130457582828761",
		Walk = "rbxassetid://74238306639300",
		Idle = "rbxassetid://111736258311834",
		Quirk = "rbxassetid://80243115371349",
		Decode = "rbxassetid://120859968917492"
	},
	FaceTextures = {
		Normal = "rbxassetid://120960953320145",
		Blink = "rbxassetid://105351310471542",
		Hurt = "rbxassetid://102139523462330"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}