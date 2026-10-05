return {
	Lvl = 1,
	Cost = 20,
	Cooldown = 1,
	Damage = {
		Explosion = 18
	},
	Stun = {
		Explosion = 0.2
	},
	Knockback = {
		ExplosionDuration = 0.2,
		ExplosionVelocity = 100
	},
	Hitbox = {
		ExplosionRadius = 45
	},
	Projectile = {
		Speed = 300,
		Lifetime = 3,
		SpawnOffset = vector.create(0, 0, -5)
	},
	Timing = {
		ChargeUp = 0.1,
		ImpactDestroyDelay = 0.15
	}
}