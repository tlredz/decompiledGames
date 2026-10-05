return {
	userAnimation = 16311141574,
	victimAnimation = 16310732064,
	sounds = {
		char = {
			{
				SoundId = "rbxassetid://16310741248",
				Volume = 3
			}
		},
		hit = {
			{
				SoundId = "rbxassetid://16310741455",
				Volume = 3
			}
		}
	},
	markers = {
		hit1 = {
			normal = true,
			damage = 3,
			materialDependent = 2
		},
		hit2 = {
			final = {
				offset = -6,
				force = {
					sideways = 0,
					pushback = -45,
					up = vector.create(0, 25, 0)
				}
			},
			materialDependent = 2,
			damage = 9
		}
	}
}