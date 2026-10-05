local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Quiet Caroler",
	TowerName = "Boxten",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W3,
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Run = "rbxassetid://127127779830772",
		Walk = "rbxassetid://125154018702398",
		Idle = "rbxassetid://88222746185839",
		Decode = "rbxassetid://74084458477451",
		Quirk = "rbxassetid://132810007083092"
	},
	FaceTextures = {
		Blink = "rbxassetid://97900582993333",
		Hurt = "rbxassetid://127841881929329",
		Normal = "rbxassetid://96552737329373"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}