return {
	Rarity = "Epic",
	MapName = script.Parent.Parent.Name,
	Icon = "rbxassetid://112962508970098",
	ComboTime = 0.65,
	Hits = {
		{
			Range = 7.5,
			Damage = 175,
			Cooldown = 0.38333333333333336,
			Delay = 0.15,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Range = 7.5,
			Damage = 175,
			Cooldown = 0.38333333333333336,
			Delay = 0.15,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Range = 7.5,
			Damage = 175,
			Cooldown = 0.38333333333333336,
			Delay = 0.11666666666666667,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Range = 7.5,
			Damage = 175,
			Cooldown = 0.38333333333333336,
			Delay = 0.15,
			Offset = CFrame.new(0, 0, -3)
		}
	},
	HitVfx = {
		Default = {
			Name = "Hit",
			Offset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 1.5707963267948966, 0)
		}
	},
	Render = {
		Idle = "Idle"
	},
	Ultimate = {
		Enabled = true,
		Cooldown = 30,
		Renderer = "Gomu Gomu",
		Animation = "Ultimate",
		FaceDirection = true,
		Sounds = {
			{
				Name = "Aura",
				Time = 0.18333333333333332
			},
			{
				Name = "Punch",
				Time = 0.35,
				Count = 10,
				Interval = 0.1922222222222222,
				Variants = 2
			}
		},
		Phases = {
			{
				Name = "Preparing",
				Duration = 0.35,
				Movement = {
					Mode = "Locked",
					LockRotation = true,
					BlockJump = true,
					BlockDash = true
				}
			},
			{
				Name = "Active",
				Duration = 1.7333333333333334,
				Damage = {
					Amount = 1475,
					Interval = 0.1922222222222222,
					Immediate = true,
					Mode = "Block",
					Size = vector.create(8.56049, 5.8905, 14.22505),
					Offset = CFrame.new(0.03174, 0.0083, -12.89063)
				},
				Movement = {
					Mode = "Locked",
					LockRotation = true,
					BlockJump = true,
					BlockDash = true
				}
			}
		}
	}
}