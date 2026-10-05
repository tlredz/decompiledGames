return {
	Name = "List Maker",
	TowerName = "Rodger",
	Description = "No description yet",
	Mastery = false,
	Cost = 1200,
	Unlocks = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0),
	Requirement1 = { "Christmas2025Ornaments", 1200 },
	Requirement2 = { "Coin", 1200 },
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Walk = "rbxassetid://114964947075190",
		Run = "rbxassetid://111438983325709",
		Quirk = "rbxassetid://128585471059690",
		Idle = "rbxassetid://71040279993115",
		Ability = "rbxassetid://72515061072906",
		Decode = "rbxassetid://120849076580449"
	},
	FaceTextures = {
		Blink = "rbxassetid://96234258193269",
		Hurt = "rbxassetid://79192641097034",
		Normal = "rbxassetid://127059249684000"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}