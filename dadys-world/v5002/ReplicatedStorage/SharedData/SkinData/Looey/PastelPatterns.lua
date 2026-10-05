local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Pastel Patterns",
	TowerName = "Looey",
	Description = "No description yet",
	Mastery = false,
	Cost = 1200,
	Requirement1 = { "Baskets", 1200 },
	Requirement2 = { "Coin", 1200 },
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W4,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Decode = "rbxassetid://79768637071341",
		Idle = "rbxassetid://114164950432130",
		Quirk = "rbxassetid://124926738745442",
		Run = "rbxassetid://120607857048035",
		Walk = "rbxassetid://139763653288896"
	},
	FaceTextures = {
		Normal = "rbxassetid://80218447607082",
		Blink = "rbxassetid://135175365947513",
		Hurt = "rbxassetid://88154440046272"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}