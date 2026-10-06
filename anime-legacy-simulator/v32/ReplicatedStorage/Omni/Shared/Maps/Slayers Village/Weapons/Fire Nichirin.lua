local createVector = vector.create
return {
	CombatSound = "Sword",
	Rarity = "Rare",
	MapName = script.Parent.Parent.Name,
	Icon = "rbxassetid://105225463488994",
	ComboTime = 0.65,
	Hits = {
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 160,
			Cooldown = 0.4166666666666667,
			Delay = 0.2833333333333333,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 160,
			Cooldown = 0.35,
			Delay = 0.16666666666666666,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 160,
			Cooldown = 0.5166666666666667,
			Delay = 0.25,
			Offset = CFrame.new(0, 0, -3)
		}
	},
	HitVfx = {
		Default = {
			Name = "Hit",
			Offset = CFrame.new(0, 0, -3)
		}
	},
	Render = {
		Model = "Fire Nichirin",
		Idle = "Idle",
		Attachments = {
			RightHand = "RightHand"
		}
	}
}