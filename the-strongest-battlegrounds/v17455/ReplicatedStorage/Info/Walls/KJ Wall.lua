return {
	userAnimation = 18447913645,
	victimAnimation = 18447915110,
	sounds = {
		char = {
			{
				SoundId = "rbxassetid://18443048724",
				Volume = 10
			}
		},
		hit = {
			{
				SoundId = "rbxassetid://18443049348",
				Volume = 10
			}
		}
	},
	markers = {
		hit1 = {
			materialDependent = 2,
			normal = true,
			damage = 6
		},
		hit2 = {
			normal = true,
			damage = 6
		},
		hit3 = {
			final = {
				offset = -6,
				force = {
					sideways = -120,
					pushback = 0,
					up = vector.create(0, 25, 0)
				}
			},
			damage = 10
		}
	}
}