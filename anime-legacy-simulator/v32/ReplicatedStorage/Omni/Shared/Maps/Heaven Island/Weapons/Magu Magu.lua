return {
	Rarity = "Rare",
	MapName = script.Parent.Parent.Name,
	Icon = "rbxassetid://114819284677483",
	ComboTime = 0.65,
	Hits = {
		{
			Range = 7.5,
			Damage = 95,
			Cooldown = 0.38333333333333336,
			Delay = 0.15,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Range = 7.5,
			Damage = 95,
			Cooldown = 0.38333333333333336,
			Delay = 0.15,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Range = 7.5,
			Damage = 95,
			Cooldown = 0.38333333333333336,
			Delay = 0.11666666666666667,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Range = 7.5,
			Damage = 95,
			Cooldown = 0.38333333333333336,
			Delay = 0.15,
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
		Model = "Magu Magu",
		Idle = "Idle",
		ModelEffects = true,
		Attachments = {
			RightUpperArm = "RightUpperArm",
			RightLowerArm = "RightLowerArm",
			LeftUpperArm = "LeftUpperArm",
			LeftLowerArm = "LeftLowerArm"
		}
	}
}