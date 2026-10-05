local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(-8696.867, -3098.541, 544.571), createVector(-8914.867, -3165.541, 631.571) },
			lookat = createVector(-8960.867, -3165.541, 679.571),
			duration = 9,
			force_fade_out = 7,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "pan",
			positions = { createVector(-8981.867, -3165.541, 884.571), createVector(-8828.867, -3165.541, 898.571) },
			lookat = createVector(-8876.867, -3167.541, 949.571),
			duration = 6.5,
			force_fade_out = 4.5,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "orbit",
			center = createVector(-8822.867, -3178.541, 741.571),
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
	MUSIC_ID = "rbxassetid://140695633562281",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}