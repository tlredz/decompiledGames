local createVector = vector.create
return {
	SEGMENTS = {
		{
			type = "pan",
			positions = { createVector(590, 88.514, 1604), createVector(590, 90.319, 1793) },
			lookat = createVector(590, 92.319, 1882),
			duration = 10,
			force_fade_out = 7,
			speed_scale = 0.5,
			bank_tilt = 0.02
		},
		{
			type = "pan",
			positions = { createVector(478, 92.319, 2124), createVector(683, 92.319, 2124) },
			lookat = createVector(589, 92.319, 2014),
			duration = 10,
			force_fade_out = 7,
			speed_scale = 0.5,
			bank_tilt = 0.02
		}
	},
	MUSIC_ID = "rbxassetid://127016457101029",
	MUSIC_VOLUME = 0.8,
	MUSIC_FADE_IN_TIME = 8,
	MUSIC_FADE_OUT_TIME = 4,
	INITIAL_FADE_IN_TIME = 8,
	FADE_DURATION = 2,
	FINAL_FADE_OUT_TIME = 2,
	FINAL_HOLD_TIME = 3,
	FINAL_FADE_IN_TIME = 3
}