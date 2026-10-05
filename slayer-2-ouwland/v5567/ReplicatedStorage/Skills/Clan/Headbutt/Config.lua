local Config = {
	WINDUP_SPEED = 1.4
}
Config.HIT_AT = 0.7 / Config.WINDUP_SPEED
Config.LOCK = Config.HIT_AT + 0.9
Config.SWING_SFX_AT = 0
Config.HITBOX_OFFSET = CFrame.new(0, 0, -4)
Config.HITBOX_SIZE = vector.create(8, 8, 8)
Config.BLOCK_BREAK = 5
Config.DAMAGE = 24
Config.IMPACT_STUN = 3
Config.KNOCKBACK = 6
Config.KNOCKBACK_DURATION = 0.15
return Config