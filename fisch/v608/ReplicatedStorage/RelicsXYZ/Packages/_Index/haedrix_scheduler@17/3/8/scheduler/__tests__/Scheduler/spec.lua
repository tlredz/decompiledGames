local parent = script.Parent.Parent.Parent
local LuauPolyfill = require(parent.LuauPolyfill)
local error2 = LuauPolyfill.Error
local ReactGlobals = require(parent.ReactGlobals)
local JestGlobals = require(parent.Dev.JestGlobals)
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local jest = JestGlobals.jest
local v = nil
local v2 = nil
local unstable_runWithPriority = nil
local unstable_ImmediatePriority = nil
local unstable_UserBlockingPriority = nil
local unstable_NormalPriority = nil
local unstable_scheduleCallback = nil
local unstable_cancelCallback = nil
local unstable_wrapCallback = nil
local unstable_getCurrentPriorityLevel = nil
local unstable_shouldYield = nil

local function shift(list)
	local v3 = list[1]
	local v4 = #list - 1

	for i = 1, v4 do
		list[i] = list[i + 1]
	end

	list[v4 + 1] = nil
	return v3
end

beforeEach(function()
	jest.resetModules()
	local Shared = require(parent.Shared)
	v = Shared
	local unstable_mock = require(script.Parent.Parent.unstable_mock)
	v2 = unstable_mock
	unstable_runWithPriority = v2.unstable_runWithPriority
	unstable_ImmediatePriority = v2.unstable_ImmediatePriority
	unstable_UserBlockingPriority = v2.unstable_UserBlockingPriority
	unstable_NormalPriority = v2.unstable_NormalPriority
	unstable_scheduleCallback = v2.unstable_scheduleCallback
	unstable_cancelCallback = v2.unstable_cancelCallback
	unstable_wrapCallback = v2.unstable_wrapCallback
	unstable_getCurrentPriorityLevel = v2.unstable_getCurrentPriorityLevel
	unstable_shouldYield = v2.unstable_shouldYield
end)
it("flushes work incrementally", function()
	unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_yieldValue("A")
	end)
	unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_yieldValue("B")
	end)
	unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_yieldValue("C")
	end)
	unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_yieldValue("D")
	end)
	expect(v2).toFlushAndYieldThrough({ "A", "B" })
	expect(v2).toFlushAndYieldThrough({ "C" })
	expect(v2).toFlushAndYield({ "D" })
end)
it("cancels work", function()
	unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_yieldValue("A")
	end)
	local v3 = unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_yieldValue("B")
	end)
	unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_yieldValue("C")
	end)
	unstable_cancelCallback(v3)
	expect(v2).toFlushAndYield({ "A", "C" })
end)
it("executes the highest priority callbacks first", function()
	unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_yieldValue("A")
	end)
	unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_yieldValue("B")
	end)
	expect(v2).toFlushAndYieldThrough({ "A" })
	unstable_scheduleCallback(unstable_UserBlockingPriority, function()
		v2.unstable_yieldValue("C")
	end)
	unstable_scheduleCallback(unstable_UserBlockingPriority, function()
		v2.unstable_yieldValue("D")
	end)
	expect(v2).toFlushAndYield({ "C", "D", "B" })
end)
it("expires work", function()
	unstable_scheduleCallback(unstable_NormalPriority, function(p)
		v2.unstable_advanceTime(100)
		v2.unstable_yieldValue(string.format("A (did timeout: %s)", (tostring(p))))
	end)
	unstable_scheduleCallback(unstable_UserBlockingPriority, function(p)
		v2.unstable_advanceTime(100)
		v2.unstable_yieldValue(string.format("B (did timeout: %s)", (tostring(p))))
	end)
	unstable_scheduleCallback(unstable_UserBlockingPriority, function(p)
		v2.unstable_advanceTime(100)
		v2.unstable_yieldValue(string.format("C (did timeout: %s)", (tostring(p))))
	end)
	v2.unstable_advanceTime(249)
	expect(v2).toHaveYielded({})
	unstable_scheduleCallback(unstable_NormalPriority, function(p)
		v2.unstable_advanceTime(100)
		v2.unstable_yieldValue(string.format("D (did timeout: %s)", (tostring(p))))
	end)
	unstable_scheduleCallback(unstable_NormalPriority, function(p)
		v2.unstable_advanceTime(100)
		v2.unstable_yieldValue(string.format("E (did timeout: %s)", (tostring(p))))
	end)
	v2.unstable_advanceTime(1)
	expect(v2).toFlushExpired({ "B (did timeout: true)", "C (did timeout: true)" })
	v2.unstable_advanceTime(4600)
	expect(v2).toFlushExpired({ "A (did timeout: true)" })
	expect(v2).toFlushAndYield({ "D (did timeout: false)", "E (did timeout: true)" })
end)
it("has a default expiration of ~5 seconds", function()
	unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_yieldValue("A")
	end)
	v2.unstable_advanceTime(4999)
	expect(v2).toHaveYielded({})
	v2.unstable_advanceTime(1)
	expect(v2).toFlushExpired({ "A" })
end)
it("continues working on same task after yielding", function()
	unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_advanceTime(100)
		v2.unstable_yieldValue("A")
	end)
	unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_advanceTime(100)
		v2.unstable_yieldValue("B")
	end)
	local v3 = false
	local v4 = {
		{ "C1", 100 },
		{ "C2", 100 },
		{ "C3", 100 }
	}
	local C

	C = function()
		while #v4 > 0 do
			local v5 = v4
			local v6 = v5[1]
			local v7 = #v5 - 1

			for i = 1, v7 do
				v5[i] = v5[i + 1]
			end

			v5[v7 + 1] = nil
			local v8, v9 = unpack(v6)
			v2.unstable_advanceTime(v9)
			v2.unstable_yieldValue(v8)

			if not unstable_shouldYield() then
				continue
			end

			v3 = true
			return C
		end

		return nil
	end

	unstable_scheduleCallback(unstable_NormalPriority, C)
	unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_advanceTime(100)
		v2.unstable_yieldValue("D")
	end)
	unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_advanceTime(100)
		v2.unstable_yieldValue("E")
	end)
	expect(v3).toBe(false)
	expect(v2).toFlushAndYieldThrough({ "A", "B", "C1" })
	expect(v3).toBe(true)
	expect(v2).toFlushAndYield({
		"C2",
		"C3",
		"D",
		"E"
	})
end)
it("continuation callbacks inherit the expiration of the previous callback", function()
	local v3 = {
		{ "A", 125 },
		{ "B", 124 },
		{ "C", 100 },
		{ "D", 100 }
	}
	local work

	work = function()
		while #v3 > 0 do
			local v4 = v3
			local v5 = v4[1]
			local v6 = #v4 - 1

			for i = 1, v6 do
				v4[i] = v4[i + 1]
			end

			v4[v6 + 1] = nil
			local v7, v8 = unpack(v5)
			v2.unstable_advanceTime(v8)
			v2.unstable_yieldValue(v7)

			if unstable_shouldYield() then
				return work
			end
		end

		return nil
	end

	unstable_scheduleCallback(unstable_UserBlockingPriority, work)
	expect(v2).toFlushAndYieldThrough({ "A", "B" })
	v2.unstable_advanceTime(1)
	expect(v2).toFlushExpired({ "C", "D" })
end)
it("continuations are interrupted by higher priority work", function()
	local v3 = {
		{ "A", 100 },
		{ "B", 100 },
		{ "C", 100 },
		{ "D", 100 }
	}
	local work

	work = function()
		while #v3 > 0 do
			local v4 = v3
			local v5 = v4[1]
			local v6 = #v4 - 1

			for i = 1, v6 do
				v4[i] = v4[i + 1]
			end

			v4[v6 + 1] = nil
			local v7, v8 = unpack(v5)
			v2.unstable_advanceTime(v8)
			v2.unstable_yieldValue(v7)

			if #v3 > 0 and unstable_shouldYield() then
				return work
			end
		end

		return nil
	end

	unstable_scheduleCallback(unstable_NormalPriority, work)
	expect(v2).toFlushAndYieldThrough({ "A" })
	unstable_scheduleCallback(unstable_UserBlockingPriority, function()
		v2.unstable_advanceTime(100)
		v2.unstable_yieldValue("High pri")
	end)
	expect(v2).toFlushAndYield({
		"High pri",
		"B",
		"C",
		"D"
	})
end)
it("continuations do not block higher priority work scheduled inside an executing callback", function()
	local v3 = {
		{ "A", 100 },
		{ "B", 100 },
		{ "C", 100 },
		{ "D", 100 }
	}
	local work

	work = function()
		while #v3 > 0 do
			local v4 = v3
			local v5 = v4[1]
			local v6 = #v4 - 1

			for i = 1, v6 do
				v4[i] = v4[i + 1]
			end

			v4[v6 + 1] = nil
			local v7, v8 = unpack(v5)
			v2.unstable_advanceTime(v8)
			v2.unstable_yieldValue(v7)

			if v7 == "B" then
				v2.unstable_yieldValue("Schedule high pri")
				unstable_scheduleCallback(unstable_UserBlockingPriority, function()
					v2.unstable_advanceTime(100)
					v2.unstable_yieldValue("High pri")
				end)
			end

			if #v3 > 0 then
				return work
			end
		end

		return nil
	end

	unstable_scheduleCallback(unstable_NormalPriority, work)
	expect(v2).toFlushAndYield({
		"A",
		"B",
		"Schedule high pri",
		"High pri",
		"C",
		"D"
	})
end)
it("cancelling a continuation", function()
	local v3 = unstable_scheduleCallback(unstable_NormalPriority, function()
		v2.unstable_yieldValue("Yield")
		return function()
			v2.unstable_yieldValue("Continuation")
		end
	end)
	expect(v2).toFlushAndYieldThrough({ "Yield" })
	unstable_cancelCallback(v3)
	expect(v2).toFlushWithoutYielding()
end)
it("top-level immediate callbacks fire in a subsequent task", function()
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		v2.unstable_yieldValue("A")
	end)
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		v2.unstable_yieldValue("B")
	end)
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		v2.unstable_yieldValue("C")
	end)
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		v2.unstable_yieldValue("D")
	end)
	expect(v2).toHaveYielded({})
	expect(v2).toFlushExpired({
		"A",
		"B",
		"C",
		"D"
	})
end)
it("nested immediate callbacks are added to the queue of immediate callbacks", function()
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		v2.unstable_yieldValue("A")
	end)
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		v2.unstable_yieldValue("B")
		unstable_scheduleCallback(unstable_ImmediatePriority, function()
			v2.unstable_yieldValue("C")
		end)
	end)
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		v2.unstable_yieldValue("D")
	end)
	expect(v2).toHaveYielded({})
	expect(v2).toFlushExpired({
		"A",
		"B",
		"D",
		"C"
	})
end)
it("wrapped callbacks have same signature as original callback", function()
	local v3 = unstable_wrapCallback(function(...)
		return {
			args = { ... }
		}
	end)("a", "b")
	expect(#v3.args).toBe(2)
	expect(v3.args).toEqual({ "a", "b" })
end)
it("wrapped callbacks inherit the current priority", function()
	local v3 = unstable_runWithPriority(unstable_NormalPriority, function()
		return unstable_wrapCallback(function()
			v2.unstable_yieldValue(unstable_getCurrentPriorityLevel())
		end)
	end)
	local v4 = unstable_runWithPriority(unstable_UserBlockingPriority, function()
		return unstable_wrapCallback(function()
			v2.unstable_yieldValue(unstable_getCurrentPriorityLevel())
		end)
	end)
	v3()
	expect(v2).toHaveYielded({ unstable_NormalPriority })
	v4()
	expect(v2).toHaveYielded({ unstable_UserBlockingPriority })
end)
it("wrapped callbacks inherit the current priority even when nested", function()
	local v3 = nil
	local v4 = nil
	unstable_runWithPriority(unstable_NormalPriority, function()
		v3 = unstable_wrapCallback(function()
			v2.unstable_yieldValue(unstable_getCurrentPriorityLevel())
		end)
		v4 = unstable_runWithPriority(unstable_UserBlockingPriority, function()
			return unstable_wrapCallback(function()
				v2.unstable_yieldValue(unstable_getCurrentPriorityLevel())
			end)
		end)
	end)
	v3()
	expect(v2).toHaveYielded({ unstable_NormalPriority })
	v4()
	expect(v2).toHaveYielded({ unstable_UserBlockingPriority })
end)
it("immediate callbacks fire even if there's an error", function()
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		v2.unstable_yieldValue("A")
		error("Oops A")
	end)
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		v2.unstable_yieldValue("B")
	end)
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		v2.unstable_yieldValue("C")
		error(error2.new("Oops C"))
	end)
	expect(function()
		expect(v2).toFlushExpired()
	end).toThrow("Oops A")
	expect(v2).toHaveYielded({ "A" })
	expect(function()
		expect(v2).toFlushExpired()
	end).toThrow("Oops C")
	expect(v2).toHaveYielded({ "B", "C" })
end)
it("multiple immediate callbacks can throw and there will be an error for each one", function()
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		error("First error")
	end)
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		error("Second error")
	end)
	expect(function()
		v2.unstable_flushAll()
	end).toThrow("First error")
	expect(function()
		v2.unstable_flushAll()
	end).toThrow("Second error")
end)
it("exposes the current priority level", function()
	v2.unstable_yieldValue(unstable_getCurrentPriorityLevel())
	unstable_runWithPriority(unstable_ImmediatePriority, function()
		v2.unstable_yieldValue(unstable_getCurrentPriorityLevel())
		unstable_runWithPriority(unstable_NormalPriority, function()
			v2.unstable_yieldValue(unstable_getCurrentPriorityLevel())
			unstable_runWithPriority(unstable_UserBlockingPriority, function()
				v2.unstable_yieldValue(unstable_getCurrentPriorityLevel())
			end)
		end)
		v2.unstable_yieldValue(unstable_getCurrentPriorityLevel())
	end)
	expect(v2).toHaveYielded({
		unstable_NormalPriority,
		unstable_ImmediatePriority,
		unstable_NormalPriority,
		unstable_UserBlockingPriority,
		unstable_ImmediatePriority
	})
end)
describe("delayed tasks", function()
	it("schedules a delayed task", function()
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v2.unstable_yieldValue("A")
		end, {
			delay = 1000
		})
		expect(v2).toFlushAndYield({})
		v2.unstable_advanceTime(999)
		expect(v2).toFlushAndYield({})
		v2.unstable_advanceTime(1)
		expect(v2).toFlushAndYield({ "A" })
	end)
	it("schedules multiple delayed tasks", function()
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v2.unstable_yieldValue("C")
		end, {
			delay = 300
		})
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v2.unstable_yieldValue("B")
		end, {
			delay = 200
		})
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v2.unstable_yieldValue("D")
		end, {
			delay = 400
		})
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v2.unstable_yieldValue("A")
		end, {
			delay = 100
		})
		expect(v2).toFlushAndYield({})
		v2.unstable_advanceTime(200)
		expect(v2).toFlushAndYieldThrough({ "A" })
		expect(v2).toFlushAndYield({ "B" })
		v2.unstable_advanceTime(200)
		expect(v2).toFlushAndYield({ "C", "D" })
	end)
	it("interleaves normal tasks and delayed tasks", function()
		unstable_scheduleCallback(unstable_UserBlockingPriority, function()
			v2.unstable_yieldValue("Timer 2")
		end, {
			delay = 300
		})
		unstable_scheduleCallback(unstable_UserBlockingPriority, function()
			v2.unstable_yieldValue("Timer 1")
		end, {
			delay = 100
		})
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v2.unstable_yieldValue("A")
			v2.unstable_advanceTime(100)
		end)
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v2.unstable_yieldValue("B")
			v2.unstable_advanceTime(100)
		end)
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v2.unstable_yieldValue("C")
			v2.unstable_advanceTime(100)
		end)
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v2.unstable_yieldValue("D")
			v2.unstable_advanceTime(100)
		end)
		expect(v2).toFlushAndYield({
			"A",
			"Timer 1",
			"B",
			"C",
			"Timer 2",
			"D"
		})
	end)
	it("interleaves delayed tasks with time-sliced tasks", function()
		unstable_scheduleCallback(unstable_UserBlockingPriority, function()
			v2.unstable_yieldValue("Timer 2")
		end, {
			delay = 300
		})
		unstable_scheduleCallback(unstable_UserBlockingPriority, function()
			v2.unstable_yieldValue("Timer 1")
		end, {
			delay = 100
		})
		local v3 = {
			{ "A", 100 },
			{ "B", 100 },
			{ "C", 100 },
			{ "D", 100 }
		}
		local work

		work = function()
			while #v3 > 0 do
				local v4 = v3
				local v5 = v4[1]
				local v6 = #v4 - 1

				for i = 1, v6 do
					v4[i] = v4[i + 1]
				end

				v4[v6 + 1] = nil
				local v7, v8 = unpack(v5)
				v2.unstable_advanceTime(v8)
				v2.unstable_yieldValue(v7)

				if #v3 > 0 then
					return work
				end
			end

			return nil
		end

		unstable_scheduleCallback(unstable_NormalPriority, work)
		expect(v2).toFlushAndYield({
			"A",
			"Timer 1",
			"B",
			"C",
			"Timer 2",
			"D"
		})
	end)
	it("cancels a delayed task", function()
		local v3 = {
			delay = 100
		}
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v2.unstable_yieldValue("A")
		end, v3)
		local v4 = unstable_scheduleCallback(unstable_NormalPriority, function()
			v2.unstable_yieldValue("B")
		end, v3)
		local v5 = unstable_scheduleCallback(unstable_NormalPriority, function()
			v2.unstable_yieldValue("C")
		end, v3)
		expect(v2).toFlushAndYield({})
		unstable_cancelCallback(v4)
		v2.unstable_advanceTime(500)
		unstable_cancelCallback(v5)
		expect(v2).toFlushAndYield({ "A" })
	end)
	it("gracefully handles scheduled tasks that are not a function", function()
		unstable_scheduleCallback(unstable_ImmediatePriority)
		expect(v2).toFlushWithoutYielding()
		unstable_scheduleCallback(unstable_ImmediatePriority, {})
		expect(v2).toFlushWithoutYielding()
		unstable_scheduleCallback(unstable_ImmediatePriority, 42)
		expect(v2).toFlushWithoutYielding()
	end)
	it("delayed tasks stringify their error", function()
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v2.unstable_yieldValue("A")
			error(error2.new("Oops A"))
		end, {
			delay = 100
		})
		v2.unstable_advanceTime(100)
		expect(v2).toFlushAndThrow("Oops A")
	end)
end)
describe("yield catching", function()
	if ReactGlobals.__DEV__ then
		describe("when enabled", function()
			beforeEach(function()
				v.ReactFeatureFlags.catchYieldingInDEV = true
			end)
			it("throws if a callback yields", function()
				unstable_scheduleCallback(unstable_NormalPriority, function()
					task.wait()
				end)
				expect(function()
					expect(v2).toFlushWithoutYielding()
				end).toThrow("Yielding is not allowed inside components or hooks.")
			end)
			it("throws if a continuation yields", function()
				unstable_scheduleCallback(unstable_NormalPriority, function()
					v2.unstable_yieldValue("A")
					return function()
						task.wait()
					end
				end)
				expect(v2).toFlushAndYieldThrough({ "A" })
				expect(function()
					expect(v2).toFlushWithoutYielding()
				end).toThrow("Yielding is not allowed inside components or hooks.")
			end)
		end)
	end

	describe("when disabled", function()
		beforeEach(function()
			v.ReactFeatureFlags.catchYieldingInDEV = false
		end)
		it("does not throw if a callback yields", function()
			unstable_scheduleCallback(unstable_NormalPriority, function()
				task.wait()
				v2.unstable_yieldValue("A")
			end)
			expect(v2).toFlushAndYield({ "A" })
		end)
		it("does not throw if a continuation yields", function()
			unstable_scheduleCallback(unstable_NormalPriority, function()
				v2.unstable_yieldValue("A")
				return function()
					task.wait()
					v2.unstable_yieldValue("B")
				end
			end)
			expect(v2).toFlushAndYieldThrough({ "A" })
			expect(v2).toFlushAndYield({ "B" })
		end)
	end)
end)