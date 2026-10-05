return {
	Lvl = 300,
	Cost = 40,
	Cooldown = 9,
	Damage = {
		BeamTick = 2.55
	},
	Stun = {
		InitialBlast = 2
	},
	Heal = {
		Amount = 8,
		LevelDivisor = 100
	},
	Hitbox = {
		Radius = 72.25,
		HeightFloorPadding = 7.5
	},
	Knockback = {
		InitialBlastDuration = 1,
		InitialBlastVelocity = vector.create(0, 30, 0)
	},
	Ray = {
		GroundDistance = 40
	},
	Soul = {
		MinTimeUntilReaches = 1.8,
		MaxTimeUntilReaches = 2.4
	},
	Timing = {
		ChargeUpFor = 0.7,
		LastsFor = 5,
		TickRate = 5,
		EndLag = 0.4
	}
}