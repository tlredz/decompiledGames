local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Still Hip",
	TowerName = "Eggson",
	Description = "No description yet",
	Mastery = false,
	Cost = 1200,
	Requirement1 = { "Baskets", 1200 },
	Requirement2 = { "Coin", 1200 },
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W1,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Run = "rbxassetid://120314558467538",
		Walk = "rbxassetid://137163200131527",
		Idle = "rbxassetid://95954733211441",
		Quirk = "rbxassetid://77951741335181",
		Decode = "rbxassetid://119235955110495",
		Ability = "rbxassetid://131381713064685"
	},
	FaceTextures = {
		Normal = "rbxassetid://79843927276026",
		Blink = "rbxassetid://107260878865302",
		Hurt = "rbxassetid://104408273256752"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}