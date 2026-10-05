return {
	userAnimation = 103851623540403,
	victimAnimation = 138626859840633,
	sounds = {
		char = {
			{
				SoundId = "rbxassetid://84875056380734",
				Volume = 3.5
			}
		},
		hit = {
			{
				SoundId = "rbxassetid://75575049629114",
				Volume = 1.5
			}
		}
	},
	markers = {
		kick = {
			materialDependent = 1,
			normal = true,
			damage = 1
		},
		ezdown = {
			materialDependent = 1,
			normal = true,
			damage = 2
		},
		punch = {
			materialDependent = 1,
			normal = true,
			damage = 2
		},
		final = {
			materialDependent = 1,
			normal = true,
			damage = 5,
			final = {
				offset = -5,
				force = {
					sideways = 0,
					pushback = -65,
					up = vector.create(0, 15, 0)
				}
			}
		}
	}
}