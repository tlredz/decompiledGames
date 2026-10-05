local createVector = vector.create
local module = require("../easing")
local module2 = require("../../../../tests/test")
local module3 = require("../tween")
local createTween = module3.createTween
local scheduler = module3.scheduler
module2("should have expected api", function()
	local tween = createTween(0)
	assert(type(tween.setPosition) == "function", "missing setPosition")
	assert(type(tween.setGoal) == "function", "missing setGoal")
	assert(type(tween.getPosition) == "function", "missing getPosition")
	assert(type(tween.getFrom) == "function", "missing getFrom")
	assert(type(tween.getGoal) == "function", "missing getGoal")
	assert(type(tween.onChange) == "function", "missing onChange")
	assert(type(tween.onComplete) == "function", "missing onComplete")
	assert(type(tween.step) == "function", "missing step")
	assert(type(tween.idle) == "function", "missing idle")
	assert(type(tween.configure) == "function", "missing configure")
	assert(type(tween.start) == "function", "missing start")
	assert(type(tween.stop) == "function", "missing stop")
	assert(type(tween.destroy) == "function", "missing destroy")
end)
module2("should get properties", function()
	local tween = createTween(createVector(1, 1, 1))
	assert(tween:getPosition() == createVector(1, 1, 1), "invalid position")
	assert(tween:getFrom() == createVector(1, 1, 1), "invalid from")
	assert(tween:getGoal() == createVector(1, 1, 1), "invalid target")
	assert(tween:idle(), "invalid complete")
end)
module2("should update properties", function()
	local tween = createTween(createVector(0, 0, 0))
	tween:setPosition(createVector(1, 1, 1))
	tween:setGoal(createVector(1, 1, 1))
	assert(tween:getPosition() == createVector(1, 1, 1), "invalid position")
	assert(tween:getFrom() == tween:getPosition(), "invalid from")
	assert(tween:getGoal() == createVector(1, 1, 1), "invalid target")
	assert(not tween:idle(), "invalid complete")
end)
module2("should handle tables", function()
	local tween = createTween({ 0, 0, 0 })
	local position = tween:getPosition()
	local goal = tween:getGoal()
	tween:setPosition({ 0, 0, 0 })
	tween:setGoal({ 0, 0, 0 })
	assert(tween:getPosition() == position, "unnecessary position copy")
	assert(tween:getGoal() == goal, "unnecessary goal copy")
	tween:setPosition({
		[1] = 1,
		[3] = 1
	})
	tween:setGoal({
		[1] = 1,
		[3] = 1
	})
	assert(table.concat(tween:getPosition()) == "101", "did not merge position")
	assert(table.concat(tween:getGoal()) == "101", "did not merge goal")
end)
module2("should complete if duration passes", function()
	local v = nil
	local tween = createTween(createVector(1, 1, 1), {
		duration = 1
	})
	tween:onComplete(function(p)
		v = p
	end)
	tween:setPosition(createVector(0, 0, 0))
	tween:step(0.5)
	assert(not tween:idle(), "invalid complete")
	assert(not v, "invalid result")
	assert(tween:getPosition() == createVector(0.5, 0.5, 0.5), "invalid position")
	assert(tween:getFrom() == createVector(0, 0, 0), "invalid from")
	tween:step(0.5)
	assert(tween:idle(), "invalid complete")
	assert(v == createVector(1, 1, 1), "invalid result")
	assert(tween:getPosition() == createVector(1, 1, 1), "invalid position")
	assert(tween:getFrom() == createVector(0, 0, 0), "invalid from")
end)
module2("should start from new position", function()
	local v = nil
	local tween = createTween(createVector(1, 1, 1), {
		duration = 1
	})
	tween:onComplete(function(p)
		v = p
	end)

	for _ = 1, 2 do
		tween:setPosition(createVector(0, 0, 0))
		tween:step(0.5)
		assert(not tween:idle(), "invalid complete")
		assert(not v, "invalid result")
		assert(tween:getPosition() == createVector(0.5, 0.5, 0.5), "invalid position")
		assert(tween:getFrom() == createVector(0, 0, 0), "invalid from")
	end

	tween:step(0.5)
	assert(tween:idle(), "invalid complete")
	assert(v == createVector(1, 1, 1), "invalid result")
	assert(tween:getPosition() == createVector(1, 1, 1), "invalid position")
	assert(tween:getFrom() == createVector(0, 0, 0), "invalid from")
end)
module2("should connect while active", function()
	local v = {}

	for i = 1, 10 do
		v[i] = createTween(createVector(0, 0, 0), {
			start = true,
			duration = 1
		})
	end

	assert(#scheduler.states == 0, "start with 0 connections")

	for _ = 1, 2 do
		for _, v2 in v do
			v2:setGoal(v2:getGoal() + createVector(1, 1, 1))
		end

		assert(#scheduler.states == #v, "connect on update")
		scheduler.step(0.5)
		assert(#scheduler.states == #v, "stay connected on partial step")
		scheduler.step(0.5)
		assert(#scheduler.states == 0, "disconnect on complete")
	end
end)
module2("should repeat", function()
	local v = nil
	local tween = createTween(createVector(1, 1, 1), {
		duration = 1
	})
	tween:onComplete(function(p)
		v = p
	end)

	for k, v2 in {
		[3] = {
			0.5,
			0,
			0.5,
			0,
			0.5,
			1
		},
		[4] = {
			0.5,
			0,
			0.5,
			0,
			0.5,
			0,
			0.5,
			1
		}
	} do
		tween:configure({
			position = createVector(0, 0, 0),
			repeats = k
		})

		for i = 1, k * 2 do
			tween:step(0.5)
			assert(
				tween:getPosition() == createVector(1, 1, 1) * v2[i],
				(`{k} expected {v2[i]}, got {tween:getPosition()}`)
			)
		end

		assert(tween:idle(), "did not complete")
		assert(v == createVector(1, 1, 1) * v2[#v2], (`{k} expected {v2[#v2]}, got {v}`))
	end
end)
module2("should repeat in reverse", function()
	local v = nil
	local tween = createTween(createVector(1, 1, 1), {
		duration = 1
	})
	tween:onComplete(function(p)
		v = p
	end)

	for k, v2 in {
		[3] = {
			0.5,
			1,
			0.5,
			0,
			0.5,
			1
		},
		[4] = {
			0.5,
			1,
			0.5,
			0,
			0.5,
			1,
			0.5,
			0
		}
	} do
		tween:configure({
			position = createVector(0, 0, 0),
			repeats = k,
			reverses = true
		})

		for i = 1, k * 2 do
			tween:step(0.5)
			assert(
				tween:getPosition() == createVector(1, 1, 1) * v2[i],
				(`{k} expected {v2[i]}, got {tween:getPosition()}`)
			)
		end

		assert(tween:idle(), "did not complete")
		assert(v == createVector(1, 1, 1) * v2[#v2], (`{k} expected {v2[#v2]}, got {v}`))
	end
end)
module2("should wake after update on complete", function()
	local count = 0
	local count2 = 0
	local tween = createTween(0, {
		duration = 1
	})
	tween:setGoal(1)
	tween:onChange(function()
		count += 1
	end)
	tween:onComplete(function()
		count2 += 1

		if tween:getGoal() ~= 0 then
			tween:setGoal(0)
			assert(not tween:idle(), "did not uncomplete")
		end
	end)
	tween:step(0.5)
	assert(count == 1, "did not step")
	assert(count2 == 0, "completed early")
	tween:step(0.5)
	assert(count == 2, "did not step")
	assert(count2 == 1, "did not complete")
	tween:step(0.5)
	assert(count == 3, "did not step")
	assert(count2 == 1, "completed early")
	tween:step(0.5)
	assert(count == 4, "did not step")
	assert(count2 == 2, "did not finally complete")
	assert(tween:idle(), "did not complete")
	tween:step(0.5)
	assert(count == 4, "stepped after complete")
	assert(count2 == 2, "completed after complete")
end)
module2("should have correct start and end", function()
	local tween = createTween(1)

	for k in pairs(module) do
		tween:configure({
			position = 0,
			easing = k
		})
		local v = tween:step(0)
		local v2 = tween:step(1)
		assert(v == 0, (`{k}(0) should be 0, got {v}`))
		assert(v2 == 1, (`{k}(1) should be 1, got {v2}`))
	end
end)
module2("should fire change with full state", function()
	local v = {}
	local tween = createTween({ 0, 0, 0 })
	tween:onChange(function(p)
		v = p
	end)
	tween:setPosition({ 1, 1, 1 })
	assert(table.concat(v) == "111", "did not fire change with position")
	tween:setPosition({
		[1] = 2,
		[3] = 2
	})
	assert(table.concat(v) == "212", "did not fire change with position merge")
end)
module2("should not be nan when step and duration are zero", function()
	local tween = createTween(0, {
		duration = 0
	})
	tween:setGoal(1)
	tween:step(0)
	assert(tween:getPosition() == tween:getPosition(), "position is nan on zero step")
end)
return {}