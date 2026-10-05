return {
	Name = "Little Helper",
	TowerName = "Toodles",
	Description = "No description yet",
	Mastery = false,
	Cost = 1200,
	Unlocks = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0),
	Requirement1 = { "Christmas2025Ornaments", 1200 },
	Requirement2 = { "Coin", 1200 },
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Run = "rbxassetid://128290384487143",
		Walk = "rbxassetid://90164001695243",
		Idle = "rbxassetid://77743652293964",
		Quirk = "rbxassetid://71463964970318",
		Ability = "rbxassetid://102009480535286",
		Decode = "rbxassetid://131645066354334"
	},
	FaceTextures = {
		Blink = "rbxassetid://97943895467699",
		Hurt = "rbxassetid://74304693065035",
		Normal = "rbxassetid://74045493222380"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(_) end
}