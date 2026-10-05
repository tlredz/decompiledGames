local createVector = vector.create
local Config = {
	MOUSE_RANGE = 100,
	DASH_SPEED = 100,
	DASH_RAMP_IN = 0.1,
	DASH_DURATION = 0.9,
	DASH_ANIM_FADE = 0.2,
	STARTUP = 0.3
}
Config.MAX_DASH_DURATION = Config.STARTUP + Config.DASH_DURATION
Config.FRONT_STOP_OFFSET = CFrame.new(0, 0, -7)
Config.FRONT_STOP_SIZE = createVector(10, 10, 15)
Config.SLAM_AT = 1.23
Config.GRAB_TOTAL = 2.12
Config.GRAB_HITBOX_SIZE = createVector(15, 7, 16)
Config.GRAB_HITBOX_OFFSET = CFrame.new(0, 0, -7)
Config.GRAB_VICTIM_OFFSET = CFrame.new()
Config.GRAB_WALL_CLEARANCE = 7
Config.GRAB_DAMAGE = 6
Config.SLAM_DAMAGE = 20
Config.SLAM_STUN = 1.6
Config.SLAM_KNOCKDOWN = 20
Config.GRAB_BLOCK_BREAK = 2
Config.SLAM_BLOCK_BREAK = 5
return Config