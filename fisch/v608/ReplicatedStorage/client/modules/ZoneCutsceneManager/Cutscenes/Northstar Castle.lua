local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(-7512.245, 171.452, -17645.01), createVector(-7540.441, 184.388, -17651.014) },
			lookat = createVector(-7594.764, 187.186, -17662.582),
			duration = 10,
			force_fade_out = 7,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "pan",
			positions = { createVector(-7463.097, 204.452, -17717.361), createVector(-7553.022, 254.452, -17839.207) },
			lookat = createVector(-7616.133, 216.186, -17795.268),
			duration = 9,
			force_fade_out = 6,
			speed_scale = 0.5,
			bank_tilt = 0.02
		}
	},
	MUSIC_ID = "rbxassetid://95249165621211",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}