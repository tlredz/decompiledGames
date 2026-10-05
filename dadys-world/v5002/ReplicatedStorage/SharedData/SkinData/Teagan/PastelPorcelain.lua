local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Pastel Porcelain",
	TowerName = "Teagan",
	Description = "No description yet",
	Mastery = false,
	Cost = 1200,
	Requirement1 = { "Baskets", 1200 },
	Requirement2 = { "Coin", 1200 },
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W2,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Ability = "rbxassetid://93025637096259",
		Decode = "rbxassetid://95524828208663",
		Idle = "rbxassetid://83693657609282",
		Quirk = "rbxassetid://132632652116863",
		Run = "rbxassetid://90971105197429",
		Walk = "rbxassetid://101478135294663"
	},
	FaceTextures = {
		Normal = "rbxassetid://124316987943886",
		Blink = "rbxassetid://83459532181638",
		Hurt = "rbxassetid://129410689756384"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}