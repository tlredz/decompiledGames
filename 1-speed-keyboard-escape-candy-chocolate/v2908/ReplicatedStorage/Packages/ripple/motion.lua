local module = require("./utils/scheduler")
local module2 = require("./utils/signal")
local module3 = require("./spring")
local module4 = require("./tween")
require("./types")
local class = {}
class.__index = class
local scheduler = module("Motion", function(state, p, callback)
	if state.complete then
		callback(state)
		return state.current:getPosition()
	end

	local v2 = state.current:step(p)

	if state.current:idle() then
		callback(state)
		state.complete = true
		state.fireComplete(v2)
	end

	return v2
end)

local function omitStartOption(p)
	if p == nil or p.start ~= true then
		return p
	end

	local clone = table.clone(p)
	clone.start = nil
	return clone
end

function class:scheduleUpdate()
	self.state.complete = false

	if self.state.started then
		scheduler.add(self.state)
	end
end

function class:prepareSpring()
	local state = self.state

	if state.current ~= state.spring then
		state.spring:setPosition(state.tween:getPosition())
		state.current = state.spring
	end
end

function class:prepareTween()
	local state = self.state

	if state.current ~= state.tween then
		state.tween:setPosition(state.spring:getPosition())
		state.spring:halt()
		state.current = state.tween
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

function class:idle()
	return self.state.complete
end

function class:step(p2: number)
	return scheduler.update(self.state, p2)
end

function class:configure(p)
	if p.spring then
		self.state.spring:configure(p.spring)
	end

	if p.tween then
		self.state.tween:configure(p.tween)
	end

	if not self.state.current:idle() then
		self:scheduleUpdate()
	end
end

function class:getPosition()
	return self.state.current:getPosition()
end

function class:getVelocity()
	return self.state.spring:getVelocity()
end

function class:getGoal()
	return self.state.current:getGoal()
end

function class:setPosition(p)
	self.state.current:setPosition(p)

	if not self.state.current:idle() then
		self:scheduleUpdate()
	end
end

function class:setVelocity(p)
	if self.state.current == self.state.spring then
		self.state.spring:setVelocity(p)

		if not self.state.current:idle() then
			self:scheduleUpdate()
		end
	end
end

function class:setGoal(p, p2)
	if p2 then
		if p2.spring then
			return self:spring(p, p2.spring)
		end

		if p2.tween then
			return self:tween(p, p2.tween)
		end
	end

	self.state.current:setGoal(p)

	if not self.state.current:idle() then
		self:scheduleUpdate()
	end
end

function class:spring(p, p2)
	self:prepareSpring()
	self.state.spring:setGoal(p, p2)

	if not self.state.spring:idle() then
		self:scheduleUpdate()
	end
end

function class:tween(p, p2)
	self:prepareTween()
	self.state.tween:setGoal(p, p2)

	if not self.state.tween:idle() then
		self:scheduleUpdate()
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
	createMotion = function(p, options)
		local v2 = options or {}
		local createSpring = module3.createSpring
		local spring = v2.spring

		if spring ~= nil and spring.start == true then
			spring = table.clone(spring)
			spring.start = nil
		end

		local spring2 = createSpring(p, spring)
		local createTween = module4.createTween
		local tween = v2.tween

		if tween ~= nil and tween.start == true then
			tween = table.clone(tween)
			tween.start = nil
		end

		local tween2 = createTween(p, tween)
		local current

		if v2.tween then
			current = tween2
		else
			current = spring2
		end

		local onChange, v5 = module2()
		local onComplete, fireComplete = module2()
		local state = {
			spring = spring2,
			tween = tween2,
			current = current,
			started = false,
			complete = true,
			onChange = onChange,
			onComplete = onComplete,
			fireComplete = fireComplete
		}
		local self = setmetatable({
			state = state
		}, class)

		if v2.start then
			self:start()
		end

		spring2:onChange(function(p2, p3: number)
			if state.current == spring2 then
				v5(p2, p3)
			end
		end)
		tween2:onChange(function(p2, p3: number)
			if state.current == tween2 then
				v5(p2, p3)
			end
		end)
		return self
	end
}