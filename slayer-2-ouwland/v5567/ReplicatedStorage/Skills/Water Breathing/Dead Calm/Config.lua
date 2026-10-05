local Config = {
	STARTUP_DUR = 0.7,
	CUTSCENE_LENGTH = 8.3,
	CUTSCENE_FOV = 50,
	MULTI_SLASH_AT = 4.7,
	WAVE_AT = 6.2,
	VICTIM_CORRECT_DUR = 6.1,
	CATCH_HITBOX_SIZE = vector.create(50, 10, 50)
}
Config.CATCH_HITBOX_OFFSET = CFrame.new(0, Config.CATCH_HITBOX_SIZE.Y / 2 - 3, 0)
Config.BLOCK_BREAK = 5
Config.MULTI_SLASH_COUNT = 10
Config.MULTI_SLASH_DUR = 1.5
Config.SLASH_DAMAGE = 2.2
Config.WAVE_DAMAGE = 35
Config.WAVE_STUN = 2.5
Config.WAVE_RAGDOLL = 2.5
Config.PVP = {
	RankedCooldown = 1.4
}
return Config