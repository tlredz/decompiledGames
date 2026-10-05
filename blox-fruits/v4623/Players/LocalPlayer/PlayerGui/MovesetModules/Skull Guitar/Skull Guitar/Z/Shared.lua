local createVector = vector.create
return {
	Lvl = 150,
	Cost = 20,
	Cooldown = 7,
	Damage = {
		BeamTick = 1.6500000000000001
	},
	Stun = {
		BeamTick = 0.4
	},
	Knockback = {
		DragPower = 1,
		Velocity = 100,
		Duration = 0.4
	},
	Beam = {
		Length = 1000,
		DissipateAfter = 2,
		ExtendsForTime = 1,
		Diameter = 24,
		RadiusPadding = 4,
		TickRate = 10,
		NearOriginOffset = createVector(0, 10, 0),
		FarOriginOffset = createVector(0, 8, -36.7)
	},
	Timing = {
		EndLag = 0.25
	}
}