local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Luna Moth",
	TowerName = "Flyte",
	Cost = 600,
	Easter = true,
	HolidaySkin = true,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W1,
	OverwriteAnimations = {
		Run = "rbxassetid://98768698423249",
		Walk = "rbxassetid://132121208809384",
		Idle = "rbxassetid://71907669576411",
		Quirk = "rbxassetid://73037781965316",
		Decode = "rbxassetid://89435437515784",
		Ability = "rbxassetid://88091931881960"
	},
	FaceTextures = {
		Normal = "rbxassetid://134491474882147",
		Blink = "rbxassetid://104141864212524",
		Hurt = "rbxassetid://93877698720818"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}