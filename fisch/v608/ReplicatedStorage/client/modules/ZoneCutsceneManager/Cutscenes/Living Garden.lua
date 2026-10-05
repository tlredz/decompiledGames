local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(-2686, -311.6, -2784), createVector(-2521, -302.6, -2852) },
			lookat = createVector(-2488, -295.6, -2867),
			duration = 9,
			force_fade_out = 7,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "pan",
			positions = { createVector(-2418, -295.6, -2867), createVector(-2476, -310.6, -2989) },
			lookat = createVector(-2492, -301.6, -3060),
			duration = 7,
			force_fade_out = 5,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "orbit",
			center = createVector(-2369, -310.6, -2740),
			radius = 60,
			height_offset = 5,
			duration = 6,
			force_fade_out = 4,
			speed_scale = 0.6,
			orbit_angle = 0.6981317007977318,
			bank_tilt = 0.01,
			start_angle = 2.356194490192345
		}
	},
	MUSIC_ID = "rbxassetid://100122204817969",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}