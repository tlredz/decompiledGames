local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local it = JestGlobals.it
local jest = JestGlobals.jest
local unstable_scheduleCallback = nil
local unstable_ImmediatePriority = nil
local unstable_UserBlockingPriority = nil
local unstable_NormalPriority = nil
beforeEach(function()
	jest.resetModules()
	jest.useFakeTimers()
	local Scheduler = require(script.Parent.Parent.Scheduler)
	local scheduler = Scheduler()
	unstable_scheduleCallback = scheduler.unstable_scheduleCallback
	unstable_ImmediatePriority = scheduler.unstable_ImmediatePriority
	unstable_UserBlockingPriority = scheduler.unstable_UserBlockingPriority
	unstable_NormalPriority = scheduler.unstable_NormalPriority
end)
it("runAllTimers flushes all scheduled callbacks", function()
	local v = {}
	unstable_scheduleCallback(unstable_NormalPriority, function()
		table.insert(v, "A")
	end)
	unstable_scheduleCallback(unstable_NormalPriority, function()
		table.insert(v, "B")
	end)
	unstable_scheduleCallback(unstable_NormalPriority, function()
		table.insert(v, "C")
	end)
	expect(v).toEqual({})
	jest.runAllTimers()
	expect(v).toEqual({ "A", "B", "C" })
end)
it("executes callbacks in order of priority", function()
	local v = {}
	unstable_scheduleCallback(unstable_NormalPriority, function()
		table.insert(v, "A")
	end)
	unstable_scheduleCallback(unstable_NormalPriority, function()
		table.insert(v, "B")
	end)
	unstable_scheduleCallback(unstable_UserBlockingPriority, function()
		table.insert(v, "C")
	end)
	unstable_scheduleCallback(unstable_UserBlockingPriority, function()
		table.insert(v, "D")
	end)
	expect(v).toEqual({})
	jest.runAllTimers()
	expect(v).toEqual({
		"C",
		"D",
		"A",
		"B"
	})
end)
it("handles errors", function()
	local v = {}
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		table.insert(v, "A")
		error("Oops A")
	end)
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		table.insert(v, "B")
	end)
	unstable_scheduleCallback(unstable_ImmediatePriority, function()
		table.insert(v, "C")
		error("Oops C")
	end)
	expect(jest.runAllTimers).toThrow("Oops A")
	expect(v).toEqual({ "A" })
	v = {}
	expect(function()
		jest.runAllTimers()
	end).toThrow("Oops C")
	expect(v).toEqual({ "B", "C" })
end)