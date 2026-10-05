return {
	userAnimation = 125518819402716,
	victimAnimation = 71936994705401,
	sounds = {
		char = {
			{
				SoundId = "rbxassetid://113641266793862",
				Volume = 2,
				TimePosition = 0
			}
		},
		hit = {
			{
				SoundId = "rbxassetid://90466896156784",
				Volume = 2
			}
		}
	},
	markers = {
		hit1 = {
			materialDependent = 3.5,
			normal = true,
			damage = 1
		},
		hit2 = {
			normal = true,
			damage = 5
		},
		hit3 = {
			final = {
				offset = 3,
				force = {
					pushback = -250,
					up = vector.create(0, 75, 0)
				}
			},
			damage = 35
		}
	}
}