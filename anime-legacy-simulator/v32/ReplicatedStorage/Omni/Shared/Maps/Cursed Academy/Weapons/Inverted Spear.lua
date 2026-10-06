local createVector = vector.create
return {
	CombatSound = "Sword",
	Rarity = "Rare",
	MapName = script.Parent.Parent.Name,
	Icon = "rbxassetid://126331036358122",
	ComboTime = 0.65,
	Hits = {
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 525,
			Cooldown = 0.25,
			Delay = 0.16666666666666666,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 525,
			Cooldown = 0.2,
			Delay = 0.1,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 525,
			Cooldown = 0.5333333333333333,
			Delay = 0.23333333333333334,
			Offset = CFrame.new(0, 0, -3)
		}
	},
	HitVfx = {
		Default = {
			Name = "Hit",
			Offset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, -1.5707963267948966)
		}
	},
	Render = {
		Model = "Inverted Spear",
		Idle = "Idle",
		Attachments = {
			RightHand = "RightHand"
		}
	}
}