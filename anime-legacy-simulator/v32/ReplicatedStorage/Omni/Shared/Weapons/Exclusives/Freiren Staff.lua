return {
	Tradeable = true,
	TradeValue = 5000,
	Rarity = "Exclusive",
	Icon = "rbxassetid://108996101650198",
	Hits = {
		{
			Range = 7.5,
			Damage = 150,
			Cooldown = 0.31666666666666665,
			Delay = 0.26666666666666666,
			Offset = CFrame.new(0, 0, -5)
		},
		{
			Range = 7.5,
			Damage = 150,
			Cooldown = 0.4666666666666667,
			Delay = 0.4,
			Offset = CFrame.new(0, 0, -5)
		}
	},
	ComboTime = 0.65,
	HitVfx = {
		Default = {
			Name = "Hit",
			Offset = CFrame.new(0, 0, -5)
		}
	},
	Render = {
		Model = "Freiren Staff",
		Idle = "Idle",
		Attachments = {
			RightHand = "RightHand"
		}
	},
	Ultimate = {
		Enabled = true,
		Cooldown = 30,
		Renderer = "Freiren Staff",
		Animation = "Ultimate",
		FaceDirection = true,
		Sounds = {
			{
				Name = "Charge",
				Time = 0
			},
			{
				Name = "Launch",
				Time = 1.0833333333333333
			},
			{
				Name = "Vortex",
				Time = 1.4333333333333333
			},
			{
				Name = "Explosion",
				Time = 1.8833333333333333
			}
		},
		Visual = {
			SpawnAt = 0.6666666666666666,
			Part = "LeftHand",
			Offset = CFrame.new(0, -0.5, 0),
			InitialScale = 0.18,
			MaximumScale = 3
		},
		Phases = {
			{
				Name = "Preparing",
				Duration = 1.0833333333333333,
				Movement = {
					Mode = "Slowed",
					SpeedMultiplier = 0.5,
					BlockDash = true
				}
			},
			{
				Name = "Launching",
				Duration = 0.35,
				Speed = 28.57142857142857,
				OriginPart = "LeftHand",
				OriginOffset = CFrame.new(0, -0.5, 0),
				Damage = {
					Amount = 2850,
					Interval = 0.08,
					Radius = 0.6,
					EndRadius = 10
				},
				Movement = {
					Mode = "Locked",
					LockRotation = true,
					BlockJump = true,
					BlockDash = true
				}
			},
			{
				Name = "Active",
				Duration = 0.45,
				Speed = 28.57142857142857,
				Damage = {
					Amount = 3100,
					Interval = 0.08,
					Radius = 10
				}
			},
			{
				Name = "Ending",
				Duration = 0.25,
				Speed = 28.57142857142857,
				Damage = {
					Amount = 3100,
					Interval = 0.08,
					Radius = 10,
					EndRadius = 0
				}
			}
		}
	}
}