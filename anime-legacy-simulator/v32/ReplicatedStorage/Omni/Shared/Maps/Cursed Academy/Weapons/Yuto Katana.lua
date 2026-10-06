local createVector = vector.create
return {
	CombatSound = "Sword",
	Rarity = "Epic",
	MapName = script.Parent.Parent.Name,
	Icon = "rbxassetid://139262852421353",
	ComboTime = 0.65,
	Hits = {
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 600,
			Cooldown = 0.4,
			Delay = 0.23333333333333334,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 600,
			Cooldown = 0.35,
			Delay = 0.15,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 600,
			Cooldown = 0.4,
			Delay = 0.2,
			Offset = CFrame.new(0, 0, -3)
		},
		{
			Mode = "Block",
			Size = createVector(10, 1, 10),
			Damage = 600,
			Cooldown = 0.36666666666666664,
			Delay = 0.15,
			Offset = CFrame.new(0, 0, -3)
		}
	},
	HitVfx = {
		Default = {
			Name = "Hit",
			Offset = CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, -1.5707963267948966)
		}
	},
	Render = {
		Model = "Yuto Katana",
		Idle = "Idle",
		Attachments = {
			RightHand = "RightHand"
		}
	},
	Ultimate = {
		Enabled = true,
		Cooldown = 30,
		Renderer = "Yuto Katana",
		Animation = "Ultimate",
		FaceDirection = true,
		Sounds = {
			{
				Name = "Charge",
				Time = 0.8
			},
			{
				Name = "Beam",
				Time = 1.6833333333333333
			}
		},
		Phases = {
			{
				Name = "Preparing",
				Duration = 1.6833333333333333,
				Movement = {
					Mode = "Locked",
					LockRotation = true,
					BlockJump = true,
					BlockDash = true
				}
			},
			{
				Name = "Active",
				Duration = 1.4333333333333333,
				Damage = {
					Amount = 6000,
					Interval = 0.2,
					Immediate = true,
					Mode = "Block",
					Size = createVector(9.35149, 9.35149, 71.73457),
					Offsets = {
						CFrame.new(-3.29437, 4.72607, -35.005045),
						CFrame.new(-3.29884, 4.67822, -34.981635000000004),
						CFrame.new(-3.30775, 4.66064, -34.962995),
						CFrame.new(-3.30578, 4.63623, -34.963405),
						CFrame.new(-3.30767, 4.58691, -34.968455000000006),
						CFrame.new(-3.35348, 4.53564, -34.967975),
						CFrame.new(-3.41669, 4.50488, -34.961975),
						CFrame.new(-3.41421, 4.50586, -34.956805)
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
				Duration = 0.8166666666666667,
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