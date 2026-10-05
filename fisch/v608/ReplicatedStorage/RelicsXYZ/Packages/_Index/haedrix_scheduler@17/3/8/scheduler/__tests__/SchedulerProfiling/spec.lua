local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local jest = JestGlobals.jest
local v = nil
local unstable_ImmediatePriority = nil
local unstable_UserBlockingPriority = nil
local unstable_NormalPriority = nil
local unstable_LowPriority = nil
local unstable_IdlePriority = nil
local unstable_scheduleCallback = nil
local unstable_cancelCallback = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function priorityLevelToString(p)
	if p == unstable_ImmediatePriority then
		return "Immediate"
	end

	if p == unstable_UserBlockingPriority then
		return "User-blocking"
	end

	if p == unstable_NormalPriority then
		return "Normal"
	end

	if p == unstable_LowPriority then
		return "Low"
	end

	if p == unstable_IdlePriority then
		return "Idle"
	end

	return nil
end

describe("Scheduler", function()
	it("profiling APIs are not available", function()
		local SchedulerFeatureFlags = require(script.Parent.Parent.SchedulerFeatureFlags)
		SchedulerFeatureFlags.enableProfiling = false
		local Scheduler = require(script.Parent.Parent.Scheduler)
		v = Scheduler()
		expect(v.unstable_Profiling).toBe(nil)
	end)
	beforeEach(function()
		jest.resetModules()
		jest.useFakeTimers()
		local SchedulerFeatureFlags = require(script.Parent.Parent.SchedulerFeatureFlags)
		SchedulerFeatureFlags.enableProfiling = true
		local unstable_mock = require(script.Parent.Parent.unstable_mock)
		v = unstable_mock
		unstable_ImmediatePriority = v.unstable_ImmediatePriority
		unstable_UserBlockingPriority = v.unstable_UserBlockingPriority
		unstable_NormalPriority = v.unstable_NormalPriority
		unstable_LowPriority = v.unstable_LowPriority
		unstable_IdlePriority = v.unstable_IdlePriority
		unstable_scheduleCallback = v.unstable_scheduleCallback
		unstable_cancelCallback = v.unstable_cancelCallback
	end)

	local function stopProfilingAndPrintFlamegraph()
		local v2 = v.unstable_Profiling.stopLoggingProfilingEvents()

		if v2 == nil then
			return "(empty profile)"
		end

		local v3 = { table.unpack(v2) }
		local v4 = 1
		local flag = true
		local v5 = {}
		local v6 = {}

		while v4 <= #v3 do
			local v7 = v3[v4][1]
			local v8 = v3[v4][2]

			if v7 == 0 then
				break
			end

			if v7 == 1 then
				local id = v3[v4][3]
				v5[id] = {
					id = id,
					priorityLevel = v3[v4][4],
					label = nil,
					start = v8,
					end_ = -1,
					exitStatus = nil,
					runs = {}
				}
				v4 += 1
			elseif v7 == 2 then
				if flag then
					error("Task cannot Complete outside the work loop.")
				end

				local v9 = v5[v3[v4][3]]

				if v9 == nil then
					error("Task does not exist.")
				end

				v9.end_ = v8
				v9.exitStatus = "completed"
				v4 += 1
			elseif v7 == 3 then
				if flag then
					error("Task cannot Error outside the work loop.")
				end

				local v9 = v5[v3[v4][3]]

				if v9 == nil then
					error("Task does not exist.")
				end

				v9.end_ = v8
				v9.exitStatus = "errored"
				v4 += 1
			elseif v7 == 4 then
				local v9 = v5[v3[v4][3]]

				if v9 == nil then
					error("Task does not exist.")
				end

				v9.end_ = v8
				v9.exitStatus = "canceled"
				v4 += 1
			elseif v7 == 5 or v7 == 6 then
				if flag then
					error("Task cannot Run or Yield outside the work loop.")
				end

				local v9 = v5[v3[v4][3]]

				if v9 == nil then
					error("Task does not exist.")
				end

				table.insert(v9.runs, v8)
				v4 += 1
			elseif v7 == 7 then
				if flag then
					error("Scheduler cannot Suspend outside the work loop.")
				end

				table.insert(v6, v8)
				v4 += 1
				flag = true
			elseif v7 == 8 then
				if not flag then
					error("Scheduler cannot Resume inside the work loop.")
				end

				table.insert(v6, v8)
				v4 += 1
				flag = false
			else
				error("Unknown instruction type: " + v7)
			end
		end

		local v7 = ""
		local v8 = true

		for _, v10 in v6 do
			for _ = 1, v10 / 50000 - string.len(v7) do
				v7 ..= v8 and "X" or "_"
			end

			v8 = not v8
		end

		local v10 = "" .. "!!! Main thread              " .. "│" .. v7 .. "\n"
		local v11 = {}

		for _, v12 in v5 do
			table.insert(v11, v12)
		end

		table.sort(v11, function(a, b)
			return b.priorityLevel > a.priorityLevel
		end)

		for _, v12 in v11 do
			local _ = v12.label == nil
			local v13 = string.format("Task %d [%s]", v12.id, priorityLevelToString(v12.priorityLevel))

			for _ = 1, 30 - string.len(v13) - 1 do
				v13 ..= " "
			end

			local v14 = ""

			for _ = 1, v12.start / 50000 do
				v14 ..= " "
			end

			local v15 = false

			for _, run in v12.runs do
				for _ = 1, run / 50000 - string.len(v14) do
					v14 ..= v15 and "X" or "_"
				end

				v15 = not v15
			end

			for _ = 1, v12.end_ / 50000 - string.len(v14) do
				v14 ..= v15 and "X" or "_"
			end

			if v12.exitStatus ~= "completed" then
				v14 ..= "O " .. (v12.exitStatus or "")
			end

			v10 ..= v13 .. "│" .. v14 .. "\n"
		end

		return "\n" .. v10
	end

	it("creates a basic flamegraph", function()
		v.unstable_Profiling.startLoggingProfilingEvents()
		v.unstable_advanceTime(100)
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v.unstable_advanceTime(300)
			v.unstable_yieldValue("Yield 1")
			unstable_scheduleCallback(unstable_UserBlockingPriority, function()
				v.unstable_yieldValue("Yield 2")
				v.unstable_advanceTime(300)
			end, {
				label = "Bar"
			})
			v.unstable_advanceTime(100)
			v.unstable_yieldValue("Yield 3")
			return function()
				v.unstable_yieldValue("Yield 4")
				v.unstable_advanceTime(300)
			end
		end, {
			label = "Foo"
		})
		expect(v).toFlushAndYieldThrough({ "Yield 1", "Yield 3" })
		v.unstable_advanceTime(100)
		expect(v).toFlushAndYield({ "Yield 2", "Yield 4" })
		expect((stopProfilingAndPrintFlamegraph())).toEqual([[

!!! Main thread              │XX________XX____________
Task 2 [User-blocking]       │        ____XXXXXX
Task 1 [Normal]              │  XXXXXXXX________XXXXXX
]])
	end)
	it("marks when a Task is canceled", function()
		v.unstable_Profiling.startLoggingProfilingEvents()
		local v2 = unstable_scheduleCallback(unstable_NormalPriority, function()
			v.unstable_yieldValue("Yield 1")
			v.unstable_advanceTime(300)
			v.unstable_yieldValue("Yield 2")
			return function()
				v.unstable_yieldValue("Continuation")
				v.unstable_advanceTime(200)
			end
		end)
		expect(v).toFlushAndYieldThrough({ "Yield 1", "Yield 2" })
		v.unstable_advanceTime(100)
		unstable_cancelCallback(v2)
		v.unstable_advanceTime(1000)
		expect(v).toFlushWithoutYielding()
		expect((stopProfilingAndPrintFlamegraph())).toEqual([[

!!! Main thread              │______XXXXXXXXXXXXXXXXXXXXXX
Task 1 [Normal]              │XXXXXX__O canceled
]])
	end)
	it("marks when a task errors", function()
		v.unstable_Profiling.startLoggingProfilingEvents()
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v.unstable_advanceTime(300)
			error("Oops")
		end)
		expect(v).toFlushAndThrow("Oops")
		v.unstable_advanceTime(100)
		v.unstable_advanceTime(1000)
		expect(v).toFlushWithoutYielding()
		expect((stopProfilingAndPrintFlamegraph())).toEqual([[

!!! Main thread              │______XXXXXXXXXXXXXXXXXXXXXX
Task 1 [Normal]              │XXXXXXO errored
]])
	end)
	it("marks when multiple tasks are canceled", function()
		v.unstable_Profiling.startLoggingProfilingEvents()
		local v2 = unstable_scheduleCallback(unstable_NormalPriority, function()
			v.unstable_yieldValue("Yield 1")
			v.unstable_advanceTime(300)
			v.unstable_yieldValue("Yield 2")
			return function()
				v.unstable_yieldValue("Continuation")
				v.unstable_advanceTime(200)
			end
		end)
		local v3 = unstable_scheduleCallback(unstable_NormalPriority, function()
			v.unstable_yieldValue("Yield 3")
			v.unstable_advanceTime(300)
			v.unstable_yieldValue("Yield 4")
			return function()
				v.unstable_yieldValue("Continuation")
				v.unstable_advanceTime(200)
			end
		end)
		expect(v).toFlushAndYieldThrough({ "Yield 1", "Yield 2" })
		v.unstable_advanceTime(100)
		unstable_cancelCallback(v2)
		unstable_cancelCallback(v3)
		v.unstable_advanceTime(1000)
		expect(v).toFlushWithoutYielding()
		expect((stopProfilingAndPrintFlamegraph())).toEqual([[

!!! Main thread              │______XXXXXXXXXXXXXXXXXXXXXX
Task 1 [Normal]              │XXXXXX__O canceled
Task 2 [Normal]              │________O canceled
]])
	end)
	it("handles cancelling a task_ that already finished", function()
		v.unstable_Profiling.startLoggingProfilingEvents()
		local v2 = unstable_scheduleCallback(unstable_NormalPriority, function()
			v.unstable_yieldValue("A")
			v.unstable_advanceTime(1000)
		end)
		expect(v).toFlushAndYield({ "A" })
		unstable_cancelCallback(v2)
		expect((stopProfilingAndPrintFlamegraph())).toEqual([[

!!! Main thread              │____________________
Task 1 [Normal]              │XXXXXXXXXXXXXXXXXXXX
]])
	end)
	it("handles cancelling a task multiple times", function()
		v.unstable_Profiling.startLoggingProfilingEvents()
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v.unstable_yieldValue("A")
			v.unstable_advanceTime(1000)
		end, {
			label = "A"
		})
		v.unstable_advanceTime(200)
		local v2 = unstable_scheduleCallback(unstable_NormalPriority, function()
			v.unstable_yieldValue("B")
			v.unstable_advanceTime(1000)
		end, {
			label = "B"
		})
		v.unstable_advanceTime(400)
		unstable_cancelCallback(v2)
		unstable_cancelCallback(v2)
		unstable_cancelCallback(v2)
		expect(v).toFlushAndYield({ "A" })
		expect((stopProfilingAndPrintFlamegraph())).toEqual([[

!!! Main thread              │XXXXXXXXXXXX____________________
Task 1 [Normal]              │____________XXXXXXXXXXXXXXXXXXXX
Task 2 [Normal]              │    ________O canceled
]])
	end)
	it("handles delayed tasks", function()
		v.unstable_Profiling.startLoggingProfilingEvents()
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v.unstable_advanceTime(1000)
			v.unstable_yieldValue("A")
		end, {
			delay = 1000
		})
		expect(v).toFlushWithoutYielding()
		v.unstable_advanceTime(1000)
		expect(v).toFlushAndYield({ "A" })
		expect((stopProfilingAndPrintFlamegraph())).toEqual([[

!!! Main thread              │XXXXXXXXXXXXXXXXXXXX____________________
Task 1 [Normal]              │                    XXXXXXXXXXXXXXXXXXXX
]])
	end)
	it("handles cancelling a delayed Task", function()
		v.unstable_Profiling.startLoggingProfilingEvents()
		local v2 = unstable_scheduleCallback(unstable_NormalPriority, function()
			return v.unstable_yieldValue("A")
		end, {
			delay = 1000
		})
		unstable_cancelCallback(v2)
		expect(v).toFlushWithoutYielding()
		expect((stopProfilingAndPrintFlamegraph())).toEqual([[

!!! Main thread              │
]])
	end)
	it("automatically stops profiling and warns if event log gets too big", function()
		v.unstable_Profiling.startLoggingProfilingEvents()
		local v2 = 1
		expect(function()
			while v2 < 41000 do
				v2 += 1
				local v3 = unstable_scheduleCallback(unstable_NormalPriority, function()
					return {}
				end)
				unstable_cancelCallback(v3)
				expect(v).toFlushAndYield({})
			end
		end).toErrorDev("Event log exceeded maximum size", {
			withoutStack = true
		})
		expect((stopProfilingAndPrintFlamegraph())).toEqual("(empty profile)")
		v.unstable_Profiling.startLoggingProfilingEvents()
		unstable_scheduleCallback(unstable_NormalPriority, function()
			v.unstable_advanceTime(1000)
		end)
		expect(v).toFlushAndYield({})
		expect((stopProfilingAndPrintFlamegraph())).toEqual([[

!!! Main thread              │____________________
Task 41000 [Normal]          │XXXXXXXXXXXXXXXXXXXX
]])
	end)
end)