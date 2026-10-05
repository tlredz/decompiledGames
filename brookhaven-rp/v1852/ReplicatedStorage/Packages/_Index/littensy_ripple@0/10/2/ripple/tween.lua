local module = require("./easing")
local module2 = require("./utils/interpolate")
local module3 = require("./utils/merge")
local module4 = require("./utils/scheduler")
local module5 = require("./utils/signal")
require("./types")
local class = {}
class.__index = class

-- equivalent calls inferred from this helper; original call sites unknown
local function getAlpha(repeats: number, repeats2: number, reverses: boolean)
	local v = repeats2 < 0 and 1e999 or repeats2

	if not (v > 1 and repeats >= 1) then
		return repeats
	end

	if reverses then
		return (math.abs((repeats - 1) % 2 - 1))
	end

	if repeats < v then
		return repeats % 1
	end

	return 1
end

local scheduler = module4("Tween", function(state, p, callback)
	if state.complete then
		callback(state)
		return state.position
	end

	state.elapsed += p
	local repeats = math.clamp(state.elapsed / state.duration, 0, state.repeats)

	if repeats ~= repeats then
		repeats = state.repeats
	end

	local alpha = getAlpha(repeats, state.repeats, state.reverses) -- equivalent call inferred; original call site unknown

	if alpha > 0 and alpha < 1 then
		alpha = state.easingFunction(alpha)
	end

	local position = module2(state.from, state.goal, alpha)
	state.position = position
	state.fireChange(position, p)

	if repeats == state.repeats then
		callback(state)
		state.complete = true
		state.fireComplete(position)
	end

	return position
end)

function class:resumeFromCurrentPosition()
	local state = self.state
	state.complete = false
	state.elapsed = 0
	state.from = state.position

	if state.started then
		scheduler.add(state)
	end
end

function class:start()
	self.state.started = true

	if not self.state.complete then
		scheduler.add(self.state)
	end
end

function class:stop()
	self.state.started = false
	scheduler.remove(self.state)
end

function class.idle(p)
	return p.state.complete
end

function class.step(p, p2: number)
	return scheduler.update(p.state, p2)
end

function class:configure(data)
	local state = self.state
	state.easingFunction = module[data.easing] or state.easingFunction
	state.duration = data.duration or state.duration
	state.repeats = data.repeats or state.repeats
	state.reverses = data.reverses or state.reverses

	if data.position then
		self:setPosition(data.position)
	end

	if not state.complete and state.elapsed ~= 0 then
		self:resumeFromCurrentPosition()
	end
end

function class.getPosition(p)
	return p.state.position
end

function class.getFrom(p)
	return p.state.from
end

function class.getGoal(p)
	return p.state.goal
end

function class:setPosition(position)
	if type(position) == "table" then
		position = module3(self.state.position, position)
	end

	if self.state.position ~= position then
		self.state.position = position
		self:resumeFromCurrentPosition()
		self.state.fireChange(position, 0)
	end
end

function class:setGoal(goal, p)
	if p then
		self:configure(p)
	end

	if type(goal) == "table" then
		goal = module3(self.state.goal, goal)
	end

	if self.state.goal ~= goal then
		self.state.goal = goal
		self:resumeFromCurrentPosition()
	end
end

function class.onChange(p, callback)
	return p.state.onChange(callback)
end

function class.onComplete(p, callback)
	return p.state.onComplete(callback)
end

function class:destroy()
	self:stop()
end

return {
	scheduler = scheduler,
	createTween = function(p, options)
		local v2 = options or {}
		local position = v2.position or p
		local onChange, fireChange = module5()
		local onComplete, fireComplete = module5()
		local self = setmetatable({
			state = {
				position = position,
				from = position,
				goal = position,
				easingFunction = module.linear,
				duration = 1,
				repeats = 1,
				reverses = false,
				elapsed = 0,
				started = false,
				complete = true,
				onChange = onChange,
				fireChange = fireChange,
				onComplete = onComplete,
				fireComplete = fireComplete
			}
		}, class)
		self:configure(v2)

		if v2.start then
			self:start()
		end

		return self
	end
}