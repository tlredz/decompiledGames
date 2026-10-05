local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(-8578, -2259.17, 832), createVector(-8637, -2299.17, 754) },
			lookat = createVector(-8652.867, -2291.541, 743.571),
			duration = 9,
			force_fade_out = 7,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "pan",
			positions = { createVector(-8847.867, -2181.541, 1011.571), createVector(-8946.867, -2212.541, 884.571) },
			lookat = createVector(-8906.867, -2212.541, 730.571),
			duration = 7,
			force_fade_out = 5,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "orbit",
			center = createVector(-8811.867, -2345.541, 756.571),
			radius = 60,
			height_offset = 5,
			duration = 7,
			force_fade_out = 4,
			speed_scale = 0.6,
			orbit_angle = 0.6981317007977318,
			bank_tilt = 0.01,
			start_angle = 0.017453292519943295
		}
	},
	MUSIC_ID = "rbxassetid://139602446469690",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}