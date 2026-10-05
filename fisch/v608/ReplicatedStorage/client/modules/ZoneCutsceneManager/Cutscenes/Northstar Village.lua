local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(-7610.001, 239.452, -17671), createVector(-7670.457, 324.452, -17760.045) },
			lookat = createVector(-7764.653, 299.452, -17716.307),
			duration = 10,
			force_fade_out = 7,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "pan",
			positions = { createVector(-7729.505, 176.452, -17622.725), createVector(-7828.524, 176.452, -17654.414) },
			lookat = createVector(-7822.036, 176.452, -17617.154),
			duration = 10,
			force_fade_out = 7,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "orbit",
			center = createVector(-8018.735, 199.385, -17827.441),
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
	MUSIC_ID = "rbxassetid://94585725633809",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}