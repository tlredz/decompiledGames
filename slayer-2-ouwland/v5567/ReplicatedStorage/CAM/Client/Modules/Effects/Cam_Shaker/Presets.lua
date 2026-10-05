local createVector = vector.create
return {
	punch_shake = {
		FadeInTime = 0,
		Frequency = 0.082,
		Amplitude = 0.12,
		SustainTime = 0.145,
		FadeOutTime = 0.15,
		RotationInfluence = createVector(0.1, 0.1, 0.1),
		PositionInfluence = createVector(0.4, 0.4, 0.4)
	},
	dream_swing_shake = {
		FadeInTime = 0.05,
		Frequency = 0.16,
		Amplitude = 0.3,
		SustainTime = 0.18,
		FadeOutTime = 0.35,
		RotationInfluence = createVector(0.12, 0.12, 0.12),
		PositionInfluence = createVector(0.55, 0.55, 0.55)
	},
	dream_final_shake = {
		FadeInTime = 0.05,
		Frequency = 0.18,
		Amplitude = 0.45,
		SustainTime = 0.2,
		FadeOutTime = 0.45,
		RotationInfluence = createVector(0.14, 0.14, 0.14),
		PositionInfluence = createVector(0.6, 0.6, 0.6)
	},
	tinyshake_preset = {
		FadeInTime = 0,
		Frequency = 0.07,
		Amplitude = 0.25,
		SustainTime = 0.05,
		FadeOutTime = 0.2,
		RotationInfluence = createVector(0.1, 0.1, 0.1),
		PositionInfluence = createVector(0.5, 0.5, 0.5)
	},
	tinyshake_less_aggresive_preset = {
		FadeInTime = 0,
		Frequency = 0.15,
		Amplitude = 0.25,
		SustainTime = 0.1,
		FadeOutTime = 0.3,
		RotationInfluence = createVector(0.1, 0.1, 0.1),
		PositionInfluence = createVector(0.5, 0.5, 0.5)
	},
	medium_shake_preset = {
		FadeInTime = 0,
		Frequency = 0.1,
		Amplitude = 0.6,
		SustainTime = 0.14,
		FadeOutTime = 0.5,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(3.5, 3.5, 3.5)
	},
	medium_shake_longer_preset = {
		FadeInTime = 0,
		Frequency = 0.135,
		Amplitude = 0.35,
		SustainTime = 0.9,
		FadeOutTime = 0.75,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(3.5, 3.5, 3.5)
	},
	Medium_tiny_shake_preset = {
		FadeInTime = 0,
		Frequency = 0.135,
		Amplitude = 0.4,
		SustainTime = 0.14,
		FadeOutTime = 0.5,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(3.5, 3.5, 3.5)
	},
	Medium_tiny_shake_preset2 = {
		FadeInTime = 0,
		Frequency = 0.17,
		Amplitude = 0.3,
		SustainTime = 0.14,
		FadeOutTime = 0.5,
		RotationInfluence = createVector(0.15, 0.15, 0.15),
		PositionInfluence = createVector(1, 1, 1)
	},
	activate_shakelessaggresive = {
		FadeInTime = 0,
		Frequency = 0.22,
		Amplitude = 0.1,
		SustainTime = 0.2,
		FadeOutTime = 0.4,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(0.5, 0.5, 0.5)
	},
	activate_shake = {
		FadeInTime = 0,
		Frequency = 0.2,
		Amplitude = 0.25,
		SustainTime = 0.1,
		FadeOutTime = 0.5,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(1, 1, 1)
	}
}