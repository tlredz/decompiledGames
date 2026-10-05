local Config = {
	STARTUP_FREEZE_TIME = 0.33,
	WINDUP = 0.3,
	FLOWERS_LOCK_DURATION = 3
}
Config.SWEEP_AT = Config.WINDUP
Config.SWEEP_HITBOX_SIZE = vector.create(15, 10, 16)
Config.SWEEP_HITBOX_OFFSET = CFrame.new(0, 0, -2)
Config.MISS_RECOVERY = 0.7
Config.FLOWERS_DAMAGE = 18
Config.FLOWERS_STUN = 3
Config.RANKED_FLOWERS_STUN = 1.95
return Config