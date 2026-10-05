local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(-8788.867, -4180.541, 614.571), createVector(-8765.867, -4196.541, 467.571) },
			lookat = createVector(-8850.867, -4196.541, 448.571),
			duration = 8,
			force_fade_out = 6.5,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "pan",
			positions = { createVector(-8679.867, -4168.541, 503.571), createVector(-8661.867, -4180.541, 319.571) },
			lookat = createVector(-8571.867, -4199.541, 392.571),
			duration = 6.8,
			force_fade_out = 4.7,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "pan",
			positions = { createVector(-8888.867, -4184.541, 215.571), createVector(-8770.867, -4184.541, 215.571) },
			lookat = createVector(-8832.867, -4184.541, 104.571),
			duration = 8,
			force_fade_out = 6,
			speed_scale = 0.5,
			bank_tilt = 0.02
		}
	},
	MUSIC_ID = "rbxassetid://139212002086473",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}