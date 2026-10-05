local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(-2893, -304.6, -2198), createVector(-2800, -304.6, -2227) },
			lookat = createVector(-2739, -301.6, -2242),
			duration = 9,
			force_fade_out = 7,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "orbit",
			center = createVector(-2470, -272.6, -2398),
			radius = 60,
			height_offset = 5,
			duration = 8,
			force_fade_out = 5,
			speed_scale = 0.6,
			orbit_angle = 0.6981317007977318,
			bank_tilt = 0.01,
			start_angle = 0.017453292519943295
		},
		{
			type = "pan",
			positions = { createVector(-2602, -310.6, -2372), createVector(-2625, -310.6, -2446) },
			lookat = createVector(-2646, -302.6, -2483),
			duration = 7,
			force_fade_out = 5,
			speed_scale = 0.5,
			bank_tilt = 0.02
		}
	},
	MUSIC_ID = "rbxassetid://139713893739944",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}