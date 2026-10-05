local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Marching Band",
	TowerName = "Looey",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W4,
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Walk = "rbxassetid://127893398434624",
		Idle = "rbxassetid://114611492297974",
		Decode = "rbxassetid://79768637071341",
		Run = "rbxassetid://137265454348919",
		Quirk = "rbxassetid://97957113035522"
	},
	FaceTextures = {
		Normal = "rbxassetid://121553330488377",
		Blink = "rbxassetid://106810053253119",
		Hurt = "rbxassetid://113191501959170"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}