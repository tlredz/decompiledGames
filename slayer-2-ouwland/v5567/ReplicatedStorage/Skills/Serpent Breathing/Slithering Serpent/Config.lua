return {
	MOUSE_RANGE = 500,
	HOLD_SAFETY_DUR = 6,
	HOLD_FREEZE_AT = 0.3,
	DASH_SPEED = 175,
	DASH_DECAY_DUR = 1.15,
	DASH_WINDOW = 0.6,
	UNHOLD_NR_LINGER = 0.5,
	DASH_GOAL_OFFSET = CFrame.new(0, 0, -90),
	DASH_SCAN_TICKS = 9,
	DASH_SCAN_TICK = 0.06,
	DASH_HITBOX_OFFSET = CFrame.new(0, 0, -7),
	DASH_HITBOX_SIZE = vector.create(10, 10, 30),
	DASH_BLOCK_BREAK = 5,
	GRAB_LOCK_DUR = 3.65,
	GRAB_WALL_CLEARANCE = 7,
	GRAB_VICTIM_WELD_DUR = 3.55,
	GRAB_RELEASE_AT = 3.45,
	GRAB_FOV = 35,
	GRAB_DAMAGE_FRAMES = {
		{
			[0] = 12
		},
		{
			[1.26] = 8
		},
		{
			[0.34] = 8
		},
		{
			[0.216] = 8
		},
		{
			[0.3] = 8
		},
		{
			[0.233] = 14
		}
	},
	FINISH_STUN = 1.5,
	FINISH_RAGDOLL = 1.5,
	PVP = {
		RankedCooldown = 1.4
	}
}