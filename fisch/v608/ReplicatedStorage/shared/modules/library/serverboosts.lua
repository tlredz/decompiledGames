return {
	Activated = {
		{
			"Xp",
			2,
			DateTime.fromUniversalTime(2026, 6, 20, 16),
			DateTime.fromUniversalTime(2026, 7, 20, 16)
		},
		{
			"C$",
			1.1,
			DateTime.fromUniversalTime(2025, 3, 4, 15),
			DateTime.fromUniversalTime(2026, 1, 18, 8)
		},
		{
			"Lucky",
			2,
			DateTime.fromUniversalTime(2026, 3, 17, 12),
			DateTime.fromUniversalTime(2026, 8, 16, 23)
		}
	},
	List = {
		Xp = {
			Name = "",
			Description = "> 100% XP Boost",
			Icon = script:WaitForChild("xp"),
			OutlineColor = Color3.fromRGB(0, 157, 255)
		},
		["C$"] = {
			Name = "",
			Description = "> 10% C$ Boost",
			Icon = script:WaitForChild("c$"),
			OutlineColor = Color3.fromRGB(255, 233, 110)
		},
		Lucky = {
			Name = "",
			Description = "> 2× Luck Boost",
			Icon = script:WaitForChild("lucky"),
			OutlineColor = Color3.fromRGB(122, 255, 112)
		}
	}
}