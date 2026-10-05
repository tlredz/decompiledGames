local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Wilted Daisies",
	TowerName = "Shrimpo",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W3,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Decode = "rbxassetid://82115028837237",
		Idle = "rbxassetid://104855983361844",
		Quirk = "rbxassetid://118596195257950",
		Run = "rbxassetid://118408617438325",
		Walk = "rbxassetid://83797003369894"
	},
	FaceTextures = {
		Normal = "rbxassetid://76434637519785",
		Blink = "rbxassetid://76896409373948",
		Hurt = "rbxassetid://138242547005242"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}