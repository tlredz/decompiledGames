return {
	userAnimation = 15997042291,
	victimAnimation = 15997027501,
	grabWeapon = true,
	sounds = {
		char = {
			{
				SoundId = "rbxassetid://15997645271",
				Volume = 2
			}
		},
		hit = {
			{
				SoundId = "rbxassetid://15997641783",
				Volume = 3
			}
		}
	},
	markers = {
		hit1 = {
			normal = true,
			damage = 2,
			slash = true
		},
		hit2 = {
			materialDependent = 1.5,
			normal = true,
			damage = 1
		},
		hit3 = {
			materialDependent = 1,
			normal = true,
			damage = 2
		},
		hit4 = {
			final = {
				offset = -6,
				force = {
					sideways = 52.5,
					pushback = 0,
					up = vector.create(0, 6, 0)
				}
			},
			slash = true,
			damage = 7
		}
	}
}