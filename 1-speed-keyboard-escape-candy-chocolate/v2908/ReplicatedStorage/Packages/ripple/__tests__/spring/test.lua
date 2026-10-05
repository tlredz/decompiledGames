local createVector = vector.create
local module = require("../spring")
local module2 = require("../../../../tests/test")
local createSpring = module.createSpring
local scheduler = module.scheduler
module2("should have expected api", function()
	local spring = createSpring(0)
	assert(type(spring.setPosition) == "function", "missing setPosition")
	assert(type(spring.setVelocity) == "function", "missing setVelocity")
	assert(type(spring.setGoal) == "function", "missing setGoal")
	assert(type(spring.getPosition) == "function", "missing getPosition")
	assert(type(spring.getVelocity) == "function", "missing getVelocity")
	assert(type(spring.getGoal) == "function", "missing getGoal")
	assert(type(spring.onChange) == "function", "missing onChange")
	assert(type(spring.onComplete) == "function", "missing onComplete")
	assert(type(spring.step) == "function", "missing step")
	assert(type(spring.impulse) == "function", "missing impulse")
	assert(type(spring.halt) == "function", "missing halt")
	assert(type(spring.idle) == "function", "missing idle")
	assert(type(spring.configure) == "function", "missing configure")
	assert(type(spring.start) == "function", "missing start")
	assert(type(spring.stop) == "function", "missing stop")
	assert(type(spring.destroy) == "function", "missing destroy")
end)
module2("should get properties", function()
	local spring = createSpring(createVector(1, 1, 1))
	assert(spring:getPosition() == createVector(1, 1, 1), "invalid position")
	assert(spring:getVelocity() == createVector(0, 0, 0), "invalid velocity")
	assert(spring:getGoal() == createVector(1, 1, 1), "invalid target")
	assert(spring:idle(), "invalid complete")
end)
module2("should update properties", function()
	local spring = createSpring(createVector(0, 0, 0))
	spring:setPosition(createVector(1, 1, 1))
	spring:setVelocity(createVector(1, 1, 1))
	spring:setGoal(createVector(1, 1, 1))
	assert(spring:getPosition() == createVector(1, 1, 1), "invalid position")
	assert(spring:getVelocity() == createVector(1, 1, 1), "invalid velocity")
	assert(spring:getGoal() == createVector(1, 1, 1), "invalid target")
	assert(not spring:idle(), "invalid complete")
end)
module2("should handle tables", function()
	local spring = createSpring({ 0, 0, 0 })
	local position = spring:getPosition()
	local velocity = spring:getVelocity()
	spring:setPosition({ 0, 0, 0 })
	spring:setVelocity({ 0, 0, 0 })
	assert(spring:getPosition() == position, "unnecessary position copy")
	assert(spring:getVelocity() == velocity, "unnecessary velocity copy")
	spring:setPosition({
		[1] = 1,
		[3] = 1
	})
	spring:setVelocity({
		[1] = 1,
		[3] = 1
	})
	assert(table.concat(spring:getPosition()) == "101", "did not merge position")
	assert(table.concat(spring:getVelocity()) == "101", "did not merge velocity")
end)
module2("should complete if goal is in reach", function()
	local v = nil
	local spring = createSpring(createVector(1, 1, 1), {
		precision = 0.5,
		restVelocity = 0.5
	})
	spring:onComplete(function(p)
		v = p
	end)
	spring:setPosition(createVector(0, 0, 0))
	spring:step(0)
	assert(not spring:idle(), "invalid complete")
	assert(not v, "invalid result")
	assert(spring:getPosition() == createVector(0, 0, 0), "invalid position")
	assert(spring:getVelocity() == createVector(0, 0, 0), "invalid velocity")
	spring:setPosition(createVector(0.5, 0.5, 0.5))
	spring:setVelocity(createVector(0.5, 0.5, 0.5))
	spring:step(0)
	assert(spring:idle(), "invalid complete")
	assert(v == createVector(1, 1, 1), "invalid result")
	assert(spring:getPosition() == createVector(1, 1, 1), "invalid position")
	assert(spring:getVelocity() == createVector(0, 0, 0), "invalid velocity")
end)
module2("should connect while active", function()
	local v = {}

	for i = 1, 10 do
		v[i] = createSpring(createVector(0, 0, 0), {
			start = true,
			precision = 0.1
		})
	end

	assert(#scheduler.states == 0, "start with 0 connections")

	for _ = 1, 2 do
		for _, v2 in v do
			v2:setGoal(v2:getGoal() + createVector(1, 1, 1))
		end

		assert(#scheduler.states == #v, "connect on update")
		scheduler.step(0.2)
		assert(#scheduler.states == #v, "stay connected on partial step")
		scheduler.step(0.5)
		assert(#scheduler.states == 0, "disconnect on complete")
	end
end)
module2("should wake after update on complete", function()
	local v = false
	local count = 0
	local spring = createSpring(0, {
		precision = 0.1
	})
	spring:setGoal(1)
	spring:onChange(function()
		v = true
	end)
	spring:onComplete(function()
		count += 1

		if spring:getGoal() ~= 0 then
			spring:setGoal(0)
			assert(not spring:idle(), "did not uncomplete")
		end
	end)
	spring:step(1)
	assert(v, "did not step")
	assert(count == 1, "did not complete")
	assert(not spring:idle(), "did not uncomplete")
	v = false
	spring:step(0.2)
	assert(v, "did not step")
	assert(count == 1, "completed for wrong goal")
	v = false
	spring:step(0.2)
	assert(v, "did not step")
	assert(count == 2, "did not finally complete")
	assert(spring:idle(), "did not complete")
	v = false
	spring:step(1)
	assert(not v, "stepped after complete")
	assert(count == 2, "completed after completion")
end)
module2("should fire change with full state", function()
	local v = {}
	local spring = createSpring({ 0, 0, 0 })
	spring:onChange(function(p)
		v = p
	end)
	spring:setPosition({ 1, 1, 1 })
	assert(table.concat(v) == "111", "did not fire change with position")
	spring:setPosition({
		[1] = 2,
		[3] = 2
	})
	assert(table.concat(v) == "212", "did not fire change with position merge")
end)
module2("should update velocity intermediate", function()
	local spring = createSpring(0)
	spring:setVelocity(10)
	spring:step(0.1)
	spring:setVelocity(10)
	assert(spring:getVelocity() == 10, "velocity intermediate not updated")
end)
return {}