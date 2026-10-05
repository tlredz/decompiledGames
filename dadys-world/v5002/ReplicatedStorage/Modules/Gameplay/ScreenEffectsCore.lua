local ScreenEffectsCore = {
	DEFAULT = "On",
	LEVELS = { "On", "Light", "Off" }
}
local v = {
	On = {
		motion = 1,
		maxRoll = 1e999,
		grade = 1,
		blur = true,
		flicker = true,
		particles = 1,
		rumble = 1
	},
	Light = {
		motion = 0.35,
		maxRoll = 0.2617993877991494,
		grade = 0.5,
		blur = false,
		flicker = false,
		particles = 0.35,
		rumble = 0.35
	},
	Off = {
		motion = 0,
		maxRoll = 0,
		grade = 0,
		blur = false,
		flicker = false,
		particles = 0,
		rumble = 0
	}
}

function ScreenEffectsCore.resolve(value)
	if type(value) == "string" and v[value] then
		return value
	end

	return ScreenEffectsCore.DEFAULT
end

function ScreenEffectsCore.profile(p)
	return v[ScreenEffectsCore.resolve(p)]
end

function ScreenEffectsCore.isMotionOff(p)
	return p.motion <= 0
end

function ScreenEffectsCore.limitRoll(p, p2: number)
	return (math.clamp(p2 * p.motion, -p.maxRoll, p.maxRoll))
end

return ScreenEffectsCore