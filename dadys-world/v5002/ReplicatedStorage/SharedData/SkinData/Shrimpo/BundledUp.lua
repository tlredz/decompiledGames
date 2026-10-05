local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Bundled Up",
	TowerName = "Shrimpo",
	Description = "No description yet",
	Mastery = false,
	Cost = 1200,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W4,
	Requirement1 = { "Christmas2025Ornaments", 1200 },
	Requirement2 = { "Coin", 1200 },
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Walk = "rbxassetid://91906792798349",
		Run = "rbxassetid://102890501150858",
		Quirk = "rbxassetid://127119934505084",
		Idle = "rbxassetid://131428148427073",
		Decode = "rbxassetid://123752826161425"
	},
	FaceTextures = {
		Blink = "rbxassetid://86286742644229",
		Hurt = "rbxassetid://118351716176197",
		Normal = "rbxassetid://72525026837353"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}