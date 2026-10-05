local createVector = vector.create
local module = require("../easing")
local module2 = require("../motion")
local module3 = require("../../../../tests/test")
local createMotion = module2.createMotion
local scheduler = module2.scheduler
module3("should have expected api", function()
	local motion = createMotion(0)
	assert(type(motion.setPosition) == "function", "missing setPosition")
	assert(type(motion.setVelocity) == "function", "missing setVelocity")
	assert(type(motion.setGoal) == "function", "missing setGoal")
	assert(type(motion.getPosition) == "function", "missing getPosition")
	assert(type(motion.getVelocity) == "function", "missing getVelocity")
	assert(type(motion.getGoal) == "function", "missing getGoal")
	assert(type(motion.onChange) == "function", "missing onChange")
	assert(type(motion.onComplete) == "function", "missing onComplete")
	assert(type(motion.step) == "function", "missing step")
	assert(type(motion.spring) == "function", "missing spring")
	assert(type(motion.tween) == "function", "missing tween")
	assert(type(motion.idle) == "function", "missing idle")
	assert(type(motion.configure) == "function", "missing configure")
	assert(type(motion.start) == "function", "missing start")
	assert(type(motion.stop) == "function", "missing stop")
	assert(type(motion.destroy) == "function", "missing destroy")
end)
module3("should swap from spring to tween", function()
	local count = 0
	local motion = createMotion(createVector(1, 1, 1))
	motion:onComplete(function()
		count += 1
	end)
	motion:spring(createVector(0, 0, 0), {
		precision = 0.1
	})
	motion:step(0.1)
	assert(count == 0, "motion should be incomplete")
	assert(motion:getPosition() ~= createVector(1, 1, 1), "position should change")
	assert(motion:getVelocity() ~= createVector(0, 0, 0), "velocity should not be zero")
	motion:step(0.9)
	assert(count == 1, "motion should be complete")
	assert(motion:getPosition() == createVector(0, 0, 0), "position should finish")
	assert(motion:getVelocity() == createVector(0, 0, 0), "velocity should be zero after completion")
	motion:tween(createVector(1, 1, 1), {
		duration = 1
	})
	motion:step(0.5)
	assert(count == 1, "motion should be incomplete")
	assert(motion:getPosition() == createVector(0.5, 0.5, 0.5), "position should be halfway to goal")
	assert(motion:getVelocity() == createVector(0, 0, 0), "velocity should be zero during tween")
	motion:step(0.5)
	assert(count == 2, "motion should be complete")
	assert(motion:getPosition() == createVector(1, 1, 1), "position should finish at goal")
	assert(motion:getVelocity() == createVector(0, 0, 0), "velocity should be zero after completion")
end)
module3("should swap from tween to spring", function()
	local count = 0
	local motion = createMotion(createVector(0, 0, 0))
	motion:onComplete(function()
		count += 1
	end)
	motion:tween(createVector(1, 1, 1), {
		duration = 1
	})
	motion:step(0.5)
	assert(count == 0, "motion should be incomplete")
	assert(motion:getPosition() == createVector(0.5, 0.5, 0.5), "position should be halfway to goal")
	assert(motion:getVelocity() == createVector(0, 0, 0), "velocity should be zero during tween")
	motion:step(0.5)
	assert(count == 1, "motion should be complete")
	assert(motion:getPosition() == createVector(1, 1, 1), "position should finish at goal")
	assert(motion:getVelocity() == createVector(0, 0, 0), "velocity should be zero after completion")
	motion:spring(createVector(0, 0, 0), {
		precision = 0.1
	})
	motion:step(0.1)
	assert(count == 1, "motion should be incomplete")
	assert(motion:getPosition() ~= createVector(1, 1, 1), "position should change")
	assert(motion:getVelocity() ~= createVector(0, 0, 0), "velocity should not be zero")
	motion:step(0.9)
	assert(count == 2, "motion should be complete")
	assert(motion:getPosition() == createVector(0, 0, 0), "position should finish")
	assert(motion:getVelocity() == createVector(0, 0, 0), "velocity should be zero after completion")
end)
module3.describe("spring", function()
	module3("should get properties", function()
		local motion = createMotion(createVector(1, 1, 1))
		assert(motion:getPosition() == createVector(1, 1, 1), "invalid position")
		assert(motion:getVelocity() == createVector(0, 0, 0), "invalid velocity")
		assert(motion:getGoal() == createVector(1, 1, 1), "invalid target")
		assert(motion:idle(), "invalid complete")
	end)
	module3("should update properties", function()
		local motion = createMotion(createVector(0, 0, 0))
		motion:setPosition(createVector(1, 1, 1))
		motion:setVelocity(createVector(1, 1, 1))
		motion:setGoal(createVector(1, 1, 1))
		assert(motion:getPosition() == createVector(1, 1, 1), "invalid position")
		assert(motion:getVelocity() == createVector(1, 1, 1), "invalid velocity")
		assert(motion:getGoal() == createVector(1, 1, 1), "invalid target")
		assert(not motion:idle(), "invalid complete")
	end)
	module3("should handle tables", function()
		local motion = createMotion({ 0, 0, 0 })
		local position = motion:getPosition()
		local velocity = motion:getVelocity()
		motion:setPosition({ 0, 0, 0 })
		motion:setVelocity({ 0, 0, 0 })
		assert(motion:getPosition() == position, "unnecessary position copy")
		assert(motion:getVelocity() == velocity, "unnecessary velocity copy")
		motion:setPosition({
			[1] = 1,
			[3] = 1
		})
		motion:setVelocity({
			[1] = 1,
			[3] = 1
		})
		assert(table.concat(motion:getPosition()) == "101", "did not merge position")
		assert(table.concat(motion:getVelocity()) == "101", "did not merge velocity")
	end)
	module3("should complete if goal is in reach", function()
		local v = nil
		local motion = createMotion(createVector(1, 1, 1), {
			spring = {
				precision = 0.5,
				restVelocity = 0.5
			}
		})
		motion:onComplete(function(p)
			v = p
		end)
		motion:setPosition(createVector(0, 0, 0))
		motion:step(0)
		assert(not motion:idle(), "invalid complete")
		assert(not v, "invalid result")
		assert(motion:getPosition() == createVector(0, 0, 0), "invalid position")
		assert(motion:getVelocity() == createVector(0, 0, 0), "invalid velocity")
		motion:setPosition(createVector(0.5, 0.5, 0.5))
		motion:setVelocity(createVector(0.5, 0.5, 0.5))
		motion:step(0)
		assert(motion:idle(), "invalid complete")
		assert(v == createVector(1, 1, 1), "invalid result")
		assert(motion:getPosition() == createVector(1, 1, 1), "invalid position")
		assert(motion:getVelocity() == createVector(0, 0, 0), "invalid velocity")
	end)
	module3("should connect while active", function()
		local v = {}

		for i = 1, 10 do
			v[i] = createMotion(createVector(0, 0, 0), {
				start = true,
				spring = {
					precision = 0.1
				}
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
	module3("should wake after update on complete", function()
		local v = false
		local count = 0
		local motion = createMotion(0, {
			spring = {
				precision = 0.1
			}
		})
		motion:setGoal(1)
		motion:onChange(function()
			v = true
		end)
		motion:onComplete(function()
			count += 1

			if motion:getGoal() ~= 0 then
				motion:setGoal(0)
				assert(not motion:idle(), "did not uncomplete")
			end
		end)
		motion:step(1)
		assert(v, "did not step")
		assert(count == 1, "did not complete")
		assert(not motion:idle(), "did not uncomplete")
		v = false
		motion:step(0.2)
		assert(v, "did not step")
		assert(count == 1, "completed for wrong goal")
		v = false
		motion:step(0.2)
		assert(v, "did not step")
		assert(count == 2, "did not finally complete")
		assert(motion:idle(), "did not complete")
		v = false
		motion:step(1)
		assert(not v, "stepped after complete")
		assert(count == 2, "completed after completion")
	end)
	module3("should fire change with full state", function()
		local v = {}
		local motion = createMotion({ 0, 0, 0 })
		motion:onChange(function(p)
			v = p
		end)
		motion:setPosition({ 1, 1, 1 })
		assert(table.concat(v) == "111", "did not fire change with position")
		motion:setPosition({
			[1] = 2,
			[3] = 2
		})
		assert(table.concat(v) == "212", "did not fire change with position merge")
	end)
end)
module3.describe("tween", function()
	module3("should get properties", function()
		local motion = createMotion(createVector(1, 1, 1), {
			tween = {}
		})
		assert(motion:getPosition() == createVector(1, 1, 1), "invalid position")
		assert(motion:getGoal() == createVector(1, 1, 1), "invalid target")
		assert(motion:idle(), "invalid complete")
	end)
	module3("should update properties", function()
		local motion = createMotion(createVector(0, 0, 0), {
			tween = {}
		})
		motion:setPosition(createVector(1, 1, 1))
		motion:setGoal(createVector(1, 1, 1))
		assert(motion:getPosition() == createVector(1, 1, 1), "invalid position")
		assert(motion:getGoal() == createVector(1, 1, 1), "invalid target")
		assert(not motion:idle(), "invalid complete")
	end)
	module3("should handle tables", function()
		local motion = createMotion({ 0, 0, 0 }, {
			tween = {}
		})
		local position = motion:getPosition()
		local goal = motion:getGoal()
		motion:setPosition({ 0, 0, 0 })
		motion:setGoal({ 0, 0, 0 })
		assert(motion:getPosition() == position, "unnecessary position copy")
		assert(motion:getGoal() == goal, "unnecessary goal copy")
		motion:setPosition({
			[1] = 1,
			[3] = 1
		})
		motion:setGoal({
			[1] = 1,
			[3] = 1
		})
		assert(table.concat(motion:getPosition()) == "101", "did not merge position")
		assert(table.concat(motion:getGoal()) == "101", "did not merge goal")
	end)
	module3("should complete if duration passes", function()
		local v = nil
		local motion = createMotion(createVector(1, 1, 1), {
			tween = {
				duration = 1
			}
		})
		motion:onComplete(function(p)
			v = p
		end)
		motion:setPosition(createVector(0, 0, 0))
		motion:step(0.5)
		assert(not motion:idle(), "invalid complete")
		assert(not v, "invalid result")
		assert(motion:getPosition() == createVector(0.5, 0.5, 0.5), "invalid position")
		motion:step(0.5)
		assert(motion:idle(), "invalid complete")
		assert(v == createVector(1, 1, 1), "invalid result")
		assert(motion:getPosition() == createVector(1, 1, 1), "invalid position")
	end)
	module3("should start from new position", function()
		local v = nil
		local motion = createMotion(createVector(1, 1, 1), {
			tween = {
				duration = 1
			}
		})
		motion:onComplete(function(p)
			v = p
		end)

		for _ = 1, 2 do
			motion:setPosition(createVector(0, 0, 0))
			motion:step(0.5)
			assert(not motion:idle(), "invalid complete")
			assert(not v, "invalid result")
			assert(motion:getPosition() == createVector(0.5, 0.5, 0.5), "invalid position")
		end

		motion:step(0.5)
		assert(motion:idle(), "invalid complete")
		assert(v == createVector(1, 1, 1), "invalid result")
		assert(motion:getPosition() == createVector(1, 1, 1), "invalid position")
	end)
	module3("should connect while active", function()
		local v = {}

		for i = 1, 10 do
			v[i] = createMotion(createVector(0, 0, 0), {
				start = true,
				tween = {
					duration = 1
				}
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
	module3("should repeat", function()
		local v = nil
		local motion = createMotion(createVector(1, 1, 1), {
			tween = {
				duration = 1
			}
		})
		motion:onComplete(function(p)
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
			motion:configure({
				tween = {
					position = createVector(0, 0, 0),
					repeats = k
				}
			})

			for i = 1, k * 2 do
				motion:step(0.5)
				assert(
					motion:getPosition() == createVector(1, 1, 1) * v2[i],
					(`{k} expected {v2[i]}, got {motion:getPosition()}`)
				)
			end

			assert(motion:idle(), "did not complete")
			assert(v == createVector(1, 1, 1) * v2[#v2], (`{k} expected {v2[#v2]}, got {v}`))
		end
	end)
	module3("should repeat in reverse", function()
		local v = nil
		local motion = createMotion(createVector(1, 1, 1), {
			tween = {
				duration = 1
			}
		})
		motion:onComplete(function(p)
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
			motion:configure({
				tween = {
					position = createVector(0, 0, 0),
					repeats = k,
					reverses = true
				}
			})

			for i = 1, k * 2 do
				motion:step(0.5)
				assert(
					motion:getPosition() == createVector(1, 1, 1) * v2[i],
					(`{k} expected {v2[i]}, got {motion:getPosition()}`)
				)
			end

			assert(motion:idle(), "did not complete")
			assert(v == createVector(1, 1, 1) * v2[#v2], (`{k} expected {v2[#v2]}, got {v}`))
		end
	end)
	module3("should wake after update on complete", function()
		local count = 0
		local count2 = 0
		local motion = createMotion(0, {
			tween = {
				duration = 1
			}
		})
		motion:setGoal(1)
		motion:onChange(function()
			count += 1
		end)
		motion:onComplete(function()
			count2 += 1

			if motion:getGoal() ~= 0 then
				motion:setGoal(0)
				assert(not motion:idle(), "did not uncomplete")
			end
		end)
		motion:step(0.5)
		assert(count == 1, "did not step")
		assert(count2 == 0, "completed early")
		motion:step(0.5)
		assert(count == 2, "did not step")
		assert(count2 == 1, "did not complete")
		motion:step(0.5)
		assert(count == 3, "did not step")
		assert(count2 == 1, "completed early")
		motion:step(0.5)
		assert(count == 4, "did not step")
		assert(count2 == 2, "did not finally complete")
		assert(motion:idle(), "did not complete")
		motion:step(0.5)
		assert(count == 4, "stepped after complete")
		assert(count2 == 2, "completed after complete")
	end)
	module3("should have correct start and end", function()
		local motion = createMotion(1, {
			tween = {}
		})

		for k in pairs(module) do
			motion:configure({
				tween = {
					position = 0,
					easing = k
				}
			})
			local v = motion:step(0)
			local v2 = motion:step(1)
			assert(v == 0, (`{k}(0) should be 0, got {v}`))
			assert(v2 == 1, (`{k}(1) should be 1, got {v2}`))
		end
	end)
	module3("should fire change with full state", function()
		local v = {}
		local motion = createMotion({ 0, 0, 0 }, {
			tween = {}
		})
		motion:onChange(function(p)
			v = p
		end)
		motion:setPosition({ 1, 1, 1 })
		assert(table.concat(v) == "111", "did not fire change with position")
		motion:setPosition({
			[1] = 2,
			[3] = 2
		})
		assert(table.concat(v) == "212", "did not fire change with position merge")
	end)
end)
return {}