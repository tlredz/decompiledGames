local module = require("./utils/intermediate")
local module2 = require("./utils/scheduler")
local module3 = require("./utils/signal")
require("./types")
local getValue = module.getValue
local recomputeValue = module.recomputeValue
local class = {}
class.__index = class

local function belowThreshold(value, p: number)
	if type(value) == "number" then
		return math.abs(value) <= p
	end

	local v = vector.abs(value)
	return math.max(v.x, v.y, v.z) <= p
end

local scheduler = module2("Spring", function(state, p, callback)
	if state.complete then
		callback(state)
		return getValue(state.position)
	end

	local position = state.position
	local velocity = state.velocity
	local goal = state.goal
	local restPosition = state.restPosition
	local restVelocity = state.restVelocity
	local dampingRatio = state.dampingRatio
	local v2 = state.frequency * 2 * 3.141592653589793
	local v3 = math.exp(-p * dampingRatio * v2)
	local complete = true
	local components = position.components
	local components2 = velocity.components
	local components3 = goal.components

	if dampingRatio == 1 then
		for k, component in components do
			local component2 = components2[k]
			local component3 = components3[k]
			local v5 = component - component3
			local v6 = (component2 * p + v5 * (v2 * p + 1)) * v3 + component3
			local v7 = (component2 - v2 * p * (v5 * v2 + component2)) * v3

			if complete then
				local v8 = v6 - component3

				if type(v8) == "number" then
					complete = math.abs(v8) <= restPosition
				else
					local v9 = vector.abs(v8)
					complete = math.max(v9.x, v9.y, v9.z) <= restPosition
				end

				if complete then
					if type(v7) == "number" then
						complete = math.abs(v7) <= restVelocity
					else
						local v9 = vector.abs(v7)
						complete = math.max(v9.x, v9.y, v9.z) <= restVelocity
					end
				end
			end

			components[k] = v6
			components2[k] = v7
		end
	elseif dampingRatio < 1 then
		local v5 = (1 - dampingRatio * dampingRatio) ^ 0.5
		local v6 = math.cos(v2 * v5 * p)
		local v7 = math.sin(v2 * v5 * p)
		local v8

		if v5 > 0.0001 then
			v8 = v7 / v5
		else
			local v9 = p * v2
			v8 = v9 + (v9 * v9 * (v5 * v5) * (v5 * v5) / 20 - v5 * v5) * (v9 * v9 * v9) / 6
		end

		local v9

		if v2 * v5 > 0.0001 then
			v9 = v7 / (v2 * v5)
		else
			local v10 = v2 * v5
			v9 = p + (p * p * (v10 * v10) * (v10 * v10) / 20 - v10 * v10) * (p * p * p) / 6
		end

		for k, component in components do
			local component2 = components2[k]
			local component3 = components3[k]
			local v10 = component - component3
			local v11 = (v10 * (v6 + dampingRatio * v8) + component2 * v9) * v3 + component3
			local v12 = (component2 * (v6 - v8 * dampingRatio) - v10 * (v8 * v2)) * v3

			if complete then
				local v13 = v11 - component3

				if type(v13) == "number" then
					complete = math.abs(v13) <= restPosition
				else
					local v14 = vector.abs(v13)
					complete = math.max(v14.x, v14.y, v14.z) <= restPosition
				end

				if complete then
					if type(v12) == "number" then
						complete = math.abs(v12) <= restVelocity
					else
						local v14 = vector.abs(v12)
						complete = math.max(v14.x, v14.y, v14.z) <= restVelocity
					end
				end
			end

			components[k] = v11
			components2[k] = v12
		end
	else
		local v5 = math.sqrt(dampingRatio * dampingRatio - 1)
		local v6 = -v2 * (dampingRatio - v5)
		local v7 = -v2 * (dampingRatio + v5)
		local v8 = math.exp(v6 * p)
		local v9 = math.exp(v7 * p)

		for k, component in components do
			local component2 = components2[k]
			local component3 = components3[k]
			local v10 = component - component3
			local v11 = (component2 - v10 * v6) / (2 * v2 * v5)
			local v12 = v8 * (v10 - v11)
			local v13 = v12 + v11 * v9 + component3
			local v14 = v12 * v6 + v11 * v9 * v7

			if complete then
				local v15 = v13 - component3

				if type(v15) == "number" then
					complete = math.abs(v15) <= restPosition
				else
					local v16 = vector.abs(v15)
					complete = math.max(v16.x, v16.y, v16.z) <= restPosition
				end

				if complete then
					if type(v14) == "number" then
						complete = math.abs(v14) <= restVelocity
					else
						local v16 = vector.abs(v14)
						complete = math.max(v16.x, v16.y, v16.z) <= restVelocity
					end
				end
			end

			components[k] = v13
			components2[k] = v14
		end
	end

	local v5

	if complete then
		v5 = getValue(goal)
	else
		v5 = recomputeValue(position)
	end

	velocity.dirty = true
	state.complete = complete
	state.fireChange(v5, p)

	if not complete then
		return v5
	end

	callback(state)
	module.assign(position, goal)
	module.zero(velocity)
	state.fireComplete(v5)
	return v5
end)

function class:scheduleUpdate()
	self.state.complete = false

	if self.state.started then
		scheduler.add(self.state)
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
	state.restPosition = data.precision or state.restPosition
	state.restVelocity = data.restVelocity or state.restPosition * 62.5

	if data.dampingRatio or data.frequency then
		state.dampingRatio = data.dampingRatio or state.dampingRatio
		state.frequency = data.frequency or state.frequency
	else
		local tension = data.tension or 170
		local friction = data.friction or 26
		local mass = data.mass or 1
		state.dampingRatio = friction / (2 * (mass * tension) ^ 0.5)
		state.frequency = (tension / mass) ^ 0.5 / 2 / 3.141592653589793
	end

	if data.velocity then
		self:setVelocity(data.velocity)
	end

	if data.impulse then
		self:impulse(data.impulse)
	end

	if data.position then
		self:setPosition(data.position)
	end
end

function class.getPosition(p)
	return module.getValue(p.state.position)
end

function class.getVelocity(p)
	return module.getValue(p.state.velocity)
end

function class.getGoal(p)
	return module.getValue(p.state.goal)
end

function class:setPosition(p)
	if module.setValue(self.state.position, p) then
		self:scheduleUpdate()
		self.state.fireChange(module.getValue(self.state.position), 0)
	end
end

function class:setVelocity(p)
	if module.setValue(self.state.velocity, p) then
		self:scheduleUpdate()
	end
end

function class:setGoal(p, p2)
	if p2 then
		self:configure(p2)
	end

	if module.setValue(self.state.goal, p) then
		self:scheduleUpdate()
	end
end

function class:impulse(p)
	module.addValue(self.state.velocity, p)
	self:scheduleUpdate()
end

function class.halt(p)
	module.zero(p.state.velocity)
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
	createSpring = function(p, options)
		local v2 = options or {}
		local position = module.create(v2.position or p)
		local onChange, fireChange = module3()
		local onComplete, fireComplete = module3()
		local self = setmetatable({
			state = {
				position = position,
				velocity = module.zero(module.copy(position)),
				goal = module.copy(position),
				dampingRatio = 1,
				frequency = 1,
				restPosition = 0.001,
				restVelocity = 0.0625,
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