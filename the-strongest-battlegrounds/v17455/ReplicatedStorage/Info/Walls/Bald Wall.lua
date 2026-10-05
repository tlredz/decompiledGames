return {
	userAnimation = 15955393872,
	victimAnimation = 15955422503,
	sounds = {
		char = {
			{
				SoundId = "rbxassetid://15955357446",
				Volume = 2,
				TimePosition = 0.167
			},
			{
				SoundId = "rbxassetid://15955559676",
				Volume = 2,
				TimePosition = 0.2
			}
		},
		wall = {
			{
				SoundId = "rbxassetid://15955357060",
				Volume = 2,
				TimePosition = 0.167
			}
		}
	},
	markers = {
		hit1 = {
			materialDependent = 3.5,
			normal = true,
			damage = 6
		},
		hit2 = {
			materialDependent = 3.5,
			final = {
				offset = -6,
				force = {
					sideways = 0,
					pushback = -45,
					up = vector.create(0, 25, 0)
				}
			},
			damage = 6
		}
	}
}