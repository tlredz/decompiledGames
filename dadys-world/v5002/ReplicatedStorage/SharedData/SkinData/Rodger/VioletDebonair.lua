local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Violet Debonair",
	TowerName = "Rodger",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W5,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Ability = "rbxassetid://91214158723001",
		Decode = "rbxassetid://96274777168731",
		Idle = "rbxassetid://116632192663655",
		Quirk = "rbxassetid://133972153975384",
		Run = "rbxassetid://72255967621198",
		Walk = "rbxassetid://125823000111969"
	},
	FaceTextures = {
		Normal = "rbxassetid://127059249684000",
		Blink = "rbxassetid://96234258193269",
		Hurt = "rbxassetid://79192641097034"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}