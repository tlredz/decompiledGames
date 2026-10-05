local createVector = vector.create
return {
	Lvl = 100,
	Cost = 30,
	Cooldown = 5,
	Damage = {
		Rush = 40.24999999999999,
		HiddenFinal = 4.199999999999999
	},
	Timing = {
		DashBaseDuration = 0.26666666666666666,
		HitLoopRate = 0.1,
		HiddenAimTime = 0.3,
		HiddenReleaseDelay = 0.1,
		EndLag = 0.15
	},
	Distance = {
		Max = 100,
		ClampMin = 10,
		ClampMax = 300
	},
	Hitbox = {
		Grab = createVector(25, 100, 25)
	},
	Grab = {
		VictimOffset = 6,
		UserOffset = 4,
		DestroyRadius = 35
	},
	Projectile = {
		Speed = 225,
		Lifetime = 1,
		Gravity = createVector(0, -300, 0)
	}
}