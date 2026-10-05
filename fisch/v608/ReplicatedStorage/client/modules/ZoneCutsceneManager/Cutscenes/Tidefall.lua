local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(3073, -943.85, 874), createVector(3099, -1010.85, 831) },
			lookat = createVector(3122, -895.85, 864),
			duration = 8,
			force_fade_out = 5,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "pan",
			positions = { createVector(3099, -1078.85, 813), createVector(3226, -1078.85, 688) },
			lookat = createVector(3315, -1052.85, 657),
			duration = 10,
			force_fade_out = 7,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "orbit",
			center = createVector(3854, -1033.85, 847),
			radius = 60,
			height_offset = 5,
			duration = 8,
			force_fade_out = 5,
			speed_scale = 0.6,
			orbit_angle = 0.6981317007977318,
			bank_tilt = 0.01,
			start_angle = 0.017453292519943295
		}
	},
	MUSIC_ID = "rbxassetid://114866558291713",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}