local Config = {
	PROJECTILE_SIZE = vector.create(3, 3, 3),
	PROJECTILE_SPAWN_OFFSET = CFrame.new(0.98583984375, -0.09681105613708496, -5.2540283203125) * CFrame.fromEulerAnglesYXZ(
		0.001424319576472044,
		0.012316026724874973,
		-1.6016160249710083
	),
	PROJECTILE_SPEED = 40,
	PROJECTILE_RANGE = 120
}
Config.PROJECTILE_LIFETIME = Config.PROJECTILE_RANGE / Config.PROJECTILE_SPEED
Config.AIM_RANGE = 40
Config.CANCEL_WINDOW = 2
Config.CUTSCENE_DUR = 6.3
Config.CASTER_LOCK_DUR = 6.4
Config.VICTIM_VALUES_DUR = 3.26
Config.VICTIM_LOCK_OFFSET = CFrame.new(0, 0, -5)
Config.BLOCK_BREAK = 5
Config.EFFECT_INTERVALS = {
	1.9,
	1.99,
	2.17,
	2.39,
	2.49,
	3.04,
	3.2
}
Config.DAMAGE_INTERVALS = {
	{
		Time = 2.06,
		Damage = 10
	},
	{
		Time = 2.38,
		Damage = 10
	},
	{
		Time = 3.04,
		Damage = 10
	},
	{
		Time = 3.04,
		Damage = 10
	},
	{
		Time = 6.15,
		Damage = 17,
		Final = true
	}
}
Config.FINAL_STUN = 2
Config.FINAL_RAGDOLL = 2
Config.PVP = {
	RankedCooldown = 1.4
}
return Config