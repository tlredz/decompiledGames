local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "orbit",
			center = createVector(-6673.201, 210.621, -18143.59),
			radius = 80,
			height_offset = 25,
			duration = 10,
			force_fade_out = 8,
			speed_scale = 0.6,
			orbit_angle = 2.2689280275926285,
			bank_tilt = 0.05,
			start_angle = 1.7453292519943295
		},
		{
			type = "pan",
			positions = {
				createVector(-6875, 141.803, -18026.992),
				createVector(-7008.234, 157.643, -18018.002),
				createVector(-7091.615, 195.596, -17987.938)
			},
			lookat = createVector(-7228.986, 233.787, -17881.064),
			duration = 10,
			force_fade_out = 7,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "orbit",
			center = createVector(-7053.314, 151.831, -17913.023),
			radius = 60,
			height_offset = 5,
			duration = 8,
			force_fade_out = 5,
			speed_scale = 0.6,
			orbit_angle = 0.6981317007977318,
			bank_tilt = 0.01,
			start_angle = 4.71238898038469
		}
	},
	MUSIC_ID = "rbxassetid://115532981056415",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}