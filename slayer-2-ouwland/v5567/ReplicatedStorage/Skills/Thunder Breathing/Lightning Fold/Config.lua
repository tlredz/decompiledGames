local Config = {
	RADIUS = 35,
	STARTUP_DUR = 0.25
}
Config.ZIGZAG_OFFSETS = { CFrame.new(15, 10, 15), CFrame.new(-15, 20, -15), CFrame.new(0, 40, -Config.RADIUS * 0.5) }
Config.ZIGZAG_DUR = 0.085
Config.CAST_DUR = 0.85
Config.SLAM_HITBOX_SIZE = vector.create(30, 30, 30)
Config.SLAM_DAMAGE = 27.5
Config.SLAM_STUN = 1
Config.SLAM_RAGDOLL = 1
Config.SLAM_BLOCK_BREAK = 3
Config.SLAM_KNOCKBACK = 35
Config.SLAM_KNOCKUP = 25
Config.SLAM_KNOCKBACK_DUR = 0.2
Config.PVP = {
	Base = 0.8
}
return Config