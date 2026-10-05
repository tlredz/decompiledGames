local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(-8701.867, -3447.541, 844.571), createVector(-8784.867, -3482.541, 758.571) },
			lookat = createVector(-8807.867, -3493.541, 742.571),
			duration = 8,
			force_fade_out = 6.5,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "pan",
			positions = { createVector(-8974.867, -3493.541, 551.571), createVector(-9004.867, -3493.541, 711.571) },
			lookat = createVector(-9087.867, -3493.541, 711.571),
			duration = 7,
			force_fade_out = 5,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "orbit",
			center = createVector(-8827.867, -3529.541, 725.571),
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
	MUSIC_ID = "rbxassetid://139585545177642",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}