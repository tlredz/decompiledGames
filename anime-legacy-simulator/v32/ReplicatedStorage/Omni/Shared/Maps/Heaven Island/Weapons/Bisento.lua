return {
	CombatSound = "Sword",
	Rarity = "Rare",
	MapName = script.Parent.Parent.Name,
	Icon = "rbxassetid://96101027238394",
	ComboTime = 0.65,
	Hits = {
		{
			Range = 10,
			Damage = 50,
			Cooldown = 0.4666666666666667,
			Delay = 0.3,
			Offset = CFrame.new(0, 0, -5)
		},
		{
			Range = 10,
			Damage = 50,
			Cooldown = 0.38333333333333336,
			Delay = 0.21666666666666667,
			Offset = CFrame.new(0, 0, -5)
		},
		{
			Range = 10,
			Damage = 50,
			Cooldown = 0.38333333333333336,
			Delay = 0.21666666666666667,
			Offset = CFrame.new(0, 0, -5)
		}
	},
	HitVfx = {
		Default = {
			Name = "Hit",
			Offset = CFrame.new(0, 0, -5)
		}
	},
	Render = {
		Model = "Bisento",
		Idle = "Idle",
		Walk = "Walk",
		Run = "Run",
		Attachments = {
			RightHand = "RightHand"
		}
	}
}