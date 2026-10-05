return {
	userAnimation = 16023456135,
	victimAnimation = 16023171958,
	grabWeapon = true,
	sounds = {
		char = {
			{
				SoundId = "rbxassetid://16023181836",
				Volume = 2
			}
		},
		hit = {
			{
				SoundId = "rbxassetid://16023181747",
				Volume = 3
			}
		}
	},
	markers = {
		hit1 = {
			normal = true,
			damage = 1,
			slash = true
		},
		hit2 = {
			materialDependent = 1.5,
			normal = true,
			damage = 4
		},
		hit3 = {
			explosion = true,
			normal = true,
			materialDependent = 2,
			damage = 4
		},
		hit4 = {
			final = {
				offset = -5.5,
				force = {
					sideways = -52.5,
					pushback = 0,
					up = vector.create(0, 6, 0)
				}
			},
			damage = 2
		}
	}
}