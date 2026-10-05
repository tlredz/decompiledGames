local Config = {
	TAP_WINDOW = 0.3,
	TAP_BEATS = {
		{
			at = 0.15,
			state = "Initial"
		},
		{
			at = 0.4,
			state = "Roar"
		}
	}
}
Config.TAP_HIT_AT = Config.TAP_BEATS[2].at
Config.TAP_END_AT = 1.15
Config.TAP_RADIUS = 25
Config.TAP_FIELD_DURATION = 1
Config.BLOCK_BREAK = 2
Config.KNOCKBACK = 28
Config.KNOCKBACK_DURATION = 0.3
Config.STUN = 2
Config.LEAVE_STUN = 2
Config.DEBUFF_VALUE = "Fear"
Config.DEBUFF_DURATION = 5
Config.HOLD_WINDUP_SPEED = 2.5

local function compress(p: number)
	if p <= Config.TAP_WINDOW then
		return p
	end

	return Config.TAP_WINDOW + (p - Config.TAP_WINDOW) / Config.HOLD_WINDUP_SPEED
end

Config.HOLD_BEATS = {}

for k, v in {
	{
		at = 0.4,
		state = "HoldCharge"
	},
	{
		at = 1.25,
		state = "Kick"
	},
	{
		at = 1.4,
		state = "Out"
	},
	{
		at = 1.7,
		state = "Lines"
	}
} do
	local HOLD_BEATS = Config.HOLD_BEATS
	local at = v.at

	if not (at <= Config.TAP_WINDOW) then
		at = Config.TAP_WINDOW + (at - Config.TAP_WINDOW) / Config.HOLD_WINDUP_SPEED
	end

	HOLD_BEATS[k] = {
		at = at,
		state = v.state
	}
end

Config.FIELD_OPEN_AT = Config.HOLD_BEATS[#Config.HOLD_BEATS].at
Config.FIELD_RADIUS = 55
Config.FIELD_HEIGHT = 20
Config.MAX_FIELD_DURATION = 2
return Config