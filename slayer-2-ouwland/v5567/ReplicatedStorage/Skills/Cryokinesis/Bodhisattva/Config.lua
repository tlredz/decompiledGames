local createVector = vector.create
local Config = {
	ANIMATION_DURATION = 3.55,
	UPDRAFT_TIME = 0.6,
	IMPACT_TIME_1 = 2.1,
	IMPACT_TIME_2 = 3.395,
	UPDRAFT_HITBOX_SIZE = createVector(30, 20, 30)
}
Config.UPDRAFT_ZONE_SIZE = Config.UPDRAFT_HITBOX_SIZE * 1.4
Config.UPDRAFT_ZONE_FORWARD = 8
Config.UPDRAFT_DAMAGE = 15
Config.UPDRAFT_KNOCKBACK = 1
Config.IMPACT_HITBOX_SIZE = createVector(24, 24, 58)
Config.FIRST_IMPACT_DAMAGE = 15
Config.SECOND_IMPACT_DAMAGE = 25
Config.IMPACT_RAGDOLL = 1.75
Config.BLOCK_DAMAGE = 3
Config.PVE_BLOCK_BREAK = 5
Config.PVP = {
	RankedCooldown = 1.4
}
return Config