return {
	userAnimation = 16310343179,
	victimAnimation = 16310419285,
	sounds = {
		char = {
			{
				SoundId = "rbxassetid://16310489770",
				Volume = 3
			}
		},
		hit = {
			{
				SoundId = "rbxassetid://16310489560",
				Volume = 3
			}
		}
	},
	markers = {
		hit1 = {
			materialDependent = 1,
			normal = true,
			waterparticle = false,
			damage = 1
		},
		hit2 = {
			materialDependent = 1,
			normal = true,
			waterparticle = false,
			damage = 1
		},
		hit3 = {
			materialDependent = 1,
			normal = true,
			waterparticle = false,
			damage = 1
		},
		hit4 = {
			materialDependent = 1,
			normal = true,
			waterparticle = false,
			damage = 2
		},
		hit5 = {
			materialDependent = 1,
			normal = true,
			waterparticle = true,
			damage = 4
		},
		hit6 = {
			final = {
				offset = -6,
				force = {
					sideways = 0,
					pushback = -45,
					up = vector.create(0, 25, 0)
				}
			},
			damage = 3
		}
	}
}