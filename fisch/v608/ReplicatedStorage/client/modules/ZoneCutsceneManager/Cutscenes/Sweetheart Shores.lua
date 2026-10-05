local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(20412, 154.403, -17594.002), createVector(20456.355, 143.811, -17733.686) },
			lookat = createVector(20485.014, 146.403, -17772.002),
			duration = 7,
			force_fade_out = 4,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "orbit",
			center = createVector(20670.355, 161.811, -17695.686),
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
			positions = { createVector(20532.355, 235.811, -17855.686), createVector(20636.355, 217.811, -17929.686) },
			lookat = createVector(20664.355, 213.811, -18001.686),
			duration = 6,
			force_fade_out = 4,
			speed_scale = 0.5,
			bank_tilt = 0.02
		}
	},
	MUSIC_ID = "rbxassetid://102205491599069",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}