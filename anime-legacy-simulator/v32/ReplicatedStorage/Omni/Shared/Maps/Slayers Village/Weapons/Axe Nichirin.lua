local createVector = vector.create
return {
	CombatSound = "Sword",
	Rarity = "Epic",
	MapName = script.Parent.Parent.Name,
	Icon = "rbxassetid://79131621764973",
	ComboTime = 0.65,
	Hits = {
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 650,
			Cooldown = 0.6166666666666667,
			Delay = 0.43333333333333335,
			Offset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, -1.5707963267948966)
		},
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 650,
			Cooldown = 0.6666666666666666,
			Delay = 0.48333333333333334,
			Offset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, -0.4363323129985824)
		},
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 650,
			Cooldown = 0.5333333333333333,
			Delay = 0.3333333333333333,
			Offset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 1.9198621771937625)
		}
	},
	HitVfx = {
		{
			Name = "Hit",
			Offset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, -1.5707963267948966)
		},
		{
			Name = "Hit",
			Offset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, -0.4363323129985824)
		},
		{
			Name = "Hit",
			Offset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 0, 1.9198621771937625)
		}
	},
	Render = {
		Model = "Axe Nichinin",
		Idle = "Idle",
		Walk = "Walk",
		Run = "Run",
		ModelAnimations = true,
		Attachments = {
			HumanoidRootPart = "HumanoidRootPart"
		}
	},
	Ultimate = {
		Enabled = true,
		Cooldown = 30,
		Renderer = "Axe Nichirin",
		Animation = "Ultimate",
		FaceDirection = true,
		Sounds = {
			{
				Name = "Jump",
				Time = 0.2833333333333333
			},
			{
				Name = "Smash",
				Time = 1.4
			}
		},
		Phases = {
			{
				Name = "Preparing",
				Duration = 1.4,
				Movement = {
					Mode = "Locked",
					LockRotation = true,
					BlockJump = true,
					BlockDash = true
				}
			},
			{
				Name = "Active",
				Duration = 0.1,
				Damage = {
					Amount = 32500,
					Interval = 0.2,
					Immediate = true,
					Mode = "Ball",
					Radius = 12,
					Offset = CFrame.new(0, 0, -8.16)
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
				Duration = 0.15
			}
		}
	}
}