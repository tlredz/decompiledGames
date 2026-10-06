local createVector = vector.create
return {
	CombatSound = "Sword",
	Rarity = "Epic",
	MapName = script.Parent.Parent.Name,
	Icon = "rbxassetid://74835836403391",
	ComboTime = 0.65,
	Hits = {
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 100,
			Cooldown = 0.4,
			Delay = 0.23333333333333334,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 100,
			Cooldown = 0.35,
			Delay = 0.15,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 100,
			Cooldown = 0.4,
			Delay = 0.2,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 200,
			Cooldown = 0.36666666666666664,
			Delay = 0.15,
			Offset = CFrame.new(0, 0, -3)
		}
	},
	HitVfx = {
		Default = {
			Name = "Hit",
			Offset = CFrame.new(0, 0, -3) * CFrame.Angles(0, -1.5707963267948966, -1.5707963267948966)
		}
	},
	Render = {
		Model = "Yoru",
		Idle = "Idle",
		Attachments = {
			RightHand = "RightHand"
		}
	},
	Ultimate = {
		Enabled = true,
		Cooldown = 30,
		Renderer = "Yoru",
		Animation = "Ultimate",
		FaceDirection = true,
		Sounds = {
			{
				Name = "Charge",
				Time = 0
			},
			{
				Name = "Slash",
				Time = 0.6,
				Count = 6,
				Interval = 0.1,
				Variants = 2
			},
			{
				Name = "Finish",
				Time = 1.1166666666666667
			}
		},
		Phases = {
			{
				Name = "Preparing",
				Duration = 0.6,
				Movement = {
					Mode = "Locked",
					LockRotation = true,
					BlockJump = true,
					BlockDash = true
				}
			},
			{
				Name = "Active",
				Duration = 0.5166666666666667,
				Damage = {
					Amount = 1500,
					Interval = 0.1,
					Immediate = true,
					Mode = "Ball",
					Radius = 12.5,
					Offsets = {
						CFrame.new(0.24837, -1.45865, -23.03611),
						CFrame.new(0.365, -1.86086, -24.60672),
						CFrame.new(0.42942, -1.88847, -24.71308),
						CFrame.new(0.45231, -1.89966, -24.71647),
						CFrame.new(0.42919, -1.89238, -24.68846),
						CFrame.new(0.42624, -1.89139, -24.68478)
					}
				},
				Movement = {
					Mode = "Locked",
					LockRotation = true,
					BlockJump = true,
					BlockDash = true
				}
			},
			{
				Name = "Ending",
				Duration = 0.8833333333333333,
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