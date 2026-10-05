local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(-1975.623, -12330.895, 366.055), createVector(-1696.669, -12282.145, 87.101) },
			lookat = createVector(-2040.5, -12307.645, 430.932),
			duration = 7,
			force_fade_out = 5,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "orbit",
			center = createVector(-1669.976, -12307.645, 63.944),
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
	MUSIC_ID = "rbxassetid://126053828520104",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}