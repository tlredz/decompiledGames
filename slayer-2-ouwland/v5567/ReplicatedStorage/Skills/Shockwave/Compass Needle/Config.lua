local Config = {
	BUFF_DURATION = 5,
	WINDUP = 0.3
}
Config.SWEEP_AT = Config.WINDUP
Config.SWEEP_HITBOX_SIZE = vector.create(20, 12, 22)
Config.SWEEP_HITBOX_OFFSET = CFrame.new(0, 0, -5)
Config.BUFF_STATE_VALUE = "CompassNeedleBuff"
Config.BUFF_SKILL_NAME = "Annihilation Type"
Config.BUFF_VALUE_NAME = "CompassNeedleSurge"
Config.BUFF_MOVEMENT_FACTOR = 0.15
Config.BUFF_DAMAGE_FACTOR = 0.15
Config.COUNTER_DAMAGE = 18
Config.COUNTER_STUN_DURATION = 1
Config.COUNTER_LOCK_DURATION = 0.5
Config.COUNTER_TELEPORT_AT = 0.3
Config.COUNTER_CASTER_LOCK = 0.35
Config.COUNTER_ANIM_LENGTH = 1.25
Config.PVP = {
	RankedCooldown = 1.2307692307692308
}
return Config