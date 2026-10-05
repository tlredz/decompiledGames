return {
	userAnimation = 18903642853,
	victimAnimation = 18903644685,
	sounds = {
		char = {
			{
				SoundId = "rbxassetid://18846960753",
				Volume = 10
			}
		},
		hit = {
			{
				SoundId = "rbxassetid://18846960425",
				Volume = 10
			}
		},
		wall = {}
	},
	markers = {
		hit1 = {
			materialDependent = 3.5,
			normal = true,
			damage = 12.5
		},
		hit2 = {
			materialDependent = 0,
			normal = true,
			damage = 12.5
		},
		hit3 = {
			materialDependent = 0,
			final = {
				offset = -6,
				force = {
					sideways = 0,
					pushback = 0
				}
			},
			damage = 30
		}
	}
}