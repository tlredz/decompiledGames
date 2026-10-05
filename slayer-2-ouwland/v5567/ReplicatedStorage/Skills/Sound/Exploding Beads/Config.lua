local createVector = vector.create
local Config = {
	MOUSE_RANGE = 500,
	DETECT_OFFSET = CFrame.new(0, 0, -6),
	DETECT_SIZE = createVector(15, 10, 16),
	BRANCH_SIGNAL_TIMEOUT = 1,
	CLOSE_PLACE_DURATION = 0.65,
	CLOSE_DASH_DURATION = 0.7
}
Config.CLOSE_TOTAL_DURATION = Config.CLOSE_PLACE_DURATION + Config.CLOSE_DASH_DURATION
Config.DASH_BACK_DISTANCE = 25
Config.CLOSE_BOMB_OFFSET = CFrame.new(0, 0, -3)
Config.CLOSE_PLACE_AT = 0.35
Config.CLOSE_DETONATE_DELAY = 0.75
Config.CLOSE_HITBOX_OFFSET = CFrame.new(0, 7, -3)
Config.CLOSE_HITBOX_SIZE = createVector(25, 19, 25)
Config.LIFT_HITBOX_SIZE = Config.CLOSE_HITBOX_SIZE
Config.LIFT_KNOCKBACK = 1
Config.LIFT_DURATION = 1.5
Config.LIFT_STUN = 1.5
Config.LIFT_BLOCK_BREAK = Config.CLOSE_BLOCK_BREAK
Config.CLOSE_DAMAGE = 30
Config.CLOSE_STUN = 1.5
Config.CLOSE_RAGDOLL = 1.5
Config.CLOSE_KNOCKBACK = 35
Config.CLOSE_KNOCKUP = 35
Config.CLOSE_KNOCKBACK_DURATION = 0.15
Config.CLOSE_BLOCK_BREAK = 3
Config.FAR_LOCK_DURATION = 1.0499999999999998
Config.FAR_THROW_AT = 0.25
Config.FAR_DETECT_OFFSET = CFrame.new(0, 0, -13.5)
Config.FAR_DETECT_SIZE = createVector(20, 15, 35)
Config.FAR_TOTAL_BEADS = 20
Config.FAR_TARGET_BEADS_MIN = 3
Config.FAR_TARGET_BEADS_MAX = 5
Config.BEAD_SIDE_SPREAD = 3
Config.BEAD_HEIGHT_SPREAD = 1
Config.BEAD_RANGE_MIN = 1
Config.BEAD_RANGE_MAX = 51
Config.FAR_DETONATE_WINDOW = 5
Config.BEAD_HITBOX_SIZE = createVector(16, 16, 16)
Config.FAR_FIRE_RATE = 2.142857142857143
Config.BEAD_TRAVEL_TIME = 0.4 / Config.FAR_FIRE_RATE
Config.BEAD_STAGGER_UNIT = 0.02 / Config.FAR_FIRE_RATE
Config.BEAD_THROW_ORIGIN = CFrame.new(0, 1, -2.5)
Config.BEAD_TRIGGER_SIZE = createVector(2, 2, 2)
Config.BEAD_DAMAGE = 3.5
Config.BEAD_STUN = 0.5
Config.BEAD_BLOCK_BREAK = 0.15

function Config.DetonationOrder(p: number, p2: number?)
	local result = {}

	if p2 ~= nil and p2 >= 1 and p2 <= p then
		table.insert(result, p2)
	end

	for i = 1, p do
		if i ~= p2 then
			table.insert(result, i)
		end
	end

	return result
end

return Config