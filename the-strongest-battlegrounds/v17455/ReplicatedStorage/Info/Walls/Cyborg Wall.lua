return {
	userAnimation = 15943915877,
	victimAnimation = 15943926967,
	sounds = {
		char = {
			{
				SoundId = "rbxassetid://15943937672",
				Volume = 1.5
			}
		},
		hit = {
			{
				SoundId = "rbxassetid://15943937560",
				Volume = 2
			}
		}
	},
	markers = {
		hit1 = {
			materialDependent = 1,
			normal = true,
			damage = 1
		},
		hit2 = {
			materialDependent = 2,
			normal = true,
			damage = 4
		},
		hit3 = {
			materialDependent = 1,
			normal = true,
			damage = 1
		},
		hit4 = {
			final = {
				offset = 0.5,
				force = {
					sideways = -52.5,
					pushback = 0,
					up = vector.create(0, 6, 0)
				}
			},
			damage = 6
		}
	}
}