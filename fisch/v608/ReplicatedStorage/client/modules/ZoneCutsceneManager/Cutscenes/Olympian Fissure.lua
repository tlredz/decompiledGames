local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(-8824.001, -4225.137, -134), createVector(-8822.001, -4213.137, -315) },
			lookat = createVector(-8818.001, -4207.137, -385),
			duration = 7,
			force_fade_out = 5,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "pan",
			positions = { createVector(-8855.001, -4221.137, -308), createVector(-8731.001, -4209.137, -296) },
			lookat = createVector(-8817.001, -4216.137, -436),
			duration = 7,
			force_fade_out = 5,
			speed_scale = 0.5,
			bank_tilt = 0.02
		}
	},
	MUSIC_ID = "rbxassetid://119960833611824",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}