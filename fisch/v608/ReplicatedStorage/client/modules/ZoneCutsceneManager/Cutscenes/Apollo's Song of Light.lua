local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(-8800.867, -2795.541, 779.571), createVector(-8837.867, -2860.541, 662.571) },
			lookat = createVector(-8831.867, -2860.541, 574.571),
			duration = 9,
			force_fade_out = 7,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "pan",
			positions = { createVector(-8747.867, -2889.541, 620.571), createVector(-8716.867, -2889.541, 793.571) },
			lookat = createVector(-8693.867, -2889.541, 848.571),
			duration = 7,
			force_fade_out = 5,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "orbit",
			center = createVector(-8825.867, -2892.541, 734.571),
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
	MUSIC_ID = "rbxassetid://109734326403108",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}