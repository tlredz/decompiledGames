local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local jest = JestGlobals.jest
local LuauPolyfill = require(parent.LuauPolyfill)
local set = LuauPolyfill.Set
describe("TracingSubscriptions", function()
	local tracing = nil
	local reactFeatureFlags = nil
	local v = nil
	local onInteractionScheduledWorkCompleted = nil
	local onInteractionTraced = nil
	local onWorkCanceled = nil
	local onWorkScheduled = nil
	local onWorkStarted = nil
	local onWorkStopped = nil
	local flag = nil
	local flag2 = nil
	local flag3 = nil
	local flag4 = nil
	local flag5 = nil
	local flag6 = nil
	local v8 = nil
	local v9 = nil
	local v10 = {
		id = 0,
		name = "first",
		timestamp = 0
	}
	local v11 = {
		id = 1,
		name = "second",
		timestamp = 0
	}

	local function loadModules(p)
		local enableSchedulerTracing = p.enableSchedulerTracing
		local v12 = p.autoSubscribe == nil or p.autoSubscribe
		jest.resetModules()
		jest.useFakeTimers()
		v = 0
		local Shared = require(parent.Shared)
		reactFeatureFlags = Shared.ReactFeatureFlags
		reactFeatureFlags.enableSchedulerTracing = enableSchedulerTracing
		local Scheduler = require(parent.Scheduler)
		tracing = Scheduler.tracing
		flag = false
		flag2 = false
		flag3 = false
		flag4 = false
		flag5 = false
		flag6 = false
		onInteractionScheduledWorkCompleted = jest.fn(function()
			if flag then
				error("Expected error onInteractionScheduledWorkCompleted")
			end
		end)
		onInteractionTraced = jest.fn(function()
			if flag2 then
				error("Expected error onInteractionTraced")
			end
		end)
		onWorkCanceled = jest.fn(function()
			if flag3 then
				error("Expected error onWorkCanceled")
			end
		end)
		onWorkScheduled = jest.fn(function()
			if flag4 then
				error("Expected error onWorkScheduled")
			end
		end)
		onWorkStarted = jest.fn(function()
			if flag5 then
				error("Expected error onWorkStarted")
			end
		end)
		onWorkStopped = jest.fn(function()
			if flag6 then
				error("Expected error onWorkStopped")
			end
		end)
		v8 = {
			onInteractionScheduledWorkCompleted = onInteractionScheduledWorkCompleted,
			onInteractionTraced = onInteractionTraced,
			onWorkCanceled = onWorkCanceled,
			onWorkScheduled = onWorkScheduled,
			onWorkStarted = onWorkStarted,
			onWorkStopped = onWorkStopped
		}
		v9 = {
			onInteractionScheduledWorkCompleted = jest.fn(),
			onInteractionTraced = jest.fn(),
			onWorkCanceled = jest.fn(),
			onWorkScheduled = jest.fn(),
			onWorkStarted = jest.fn(),
			onWorkStopped = jest.fn()
		}

		if v12 then
			tracing.unstable_subscribe(v8)
			tracing.unstable_subscribe(v9)
		end
	end

	describe("enabled", function()
		beforeEach(function()
			return loadModules({
				enableSchedulerTracing = true
			})
		end)
		it("should lazily subscribe to tracing and unsubscribe again if there are no external subscribers", function()
			loadModules({
				enableSchedulerTracing = true,
				autoSubscribe = false
			})
			expect(tracing.__subscriberRef.current).toBe(nil)
			tracing.unstable_subscribe(v8)
			expect(tracing.__subscriberRef.current).toBeDefined()
			tracing.unstable_subscribe(v9)
			expect(tracing.__subscriberRef.current).toBeDefined()
			tracing.unstable_unsubscribe(v9)
			expect(tracing.__subscriberRef.current).toBeDefined()
			tracing.unstable_unsubscribe(v8)
			expect(tracing.__subscriberRef.current).toBe(nil)
		end)
		describe("error handling", function()
			it("should cover onInteractionTraced/onWorkStarted within", function()
				tracing.unstable_trace(v10.name, v, function()
					local v12 = jest.fn()
					flag2 = true
					expect(function()
						return tracing.unstable_trace(v11.name, v, v12, 123)
					end).toThrow("Expected error onInteractionTraced")
					flag2 = false
					expect(v12).toHaveBeenCalledTimes(1)
					flag5 = true
					expect(function()
						return tracing.unstable_trace(v11.name, v, v12, 123)
					end).toThrow("Expected error onWorkStarted")
					expect(v12).toHaveBeenCalledTimes(2)
					expect(tracing.unstable_getCurrent()).toMatchInteractions({ v10 })
					expect(v9.onInteractionTraced).toHaveBeenCalledTimes(3)
					expect(v9.onWorkStarted).toHaveBeenCalledTimes(3)
				end)
			end)
			it("should cover onWorkStopped within trace", function()
				tracing.unstable_trace(v10.name, v, function()
					local v12 = nil
					local v13 = jest.fn(function()
						v12 = tracing.unstable_getCurrent()._array[2]
					end)
					flag6 = true
					expect(function()
						return tracing.unstable_trace(v11.name, v, v13)
					end).toThrow("Expected error onWorkStopped")
					flag6 = false
					expect(tracing.unstable_getCurrent()).toMatchInteractions({ v10 })
					expect(v12.__count).toBe(0)
					expect(v9.onWorkStopped).toHaveBeenCalledTimes(1)
				end)
			end)
			it("should cover onInteractionScheduledWorkCompleted within trace", function()
				tracing.unstable_trace(v10.name, v, function()
					local v12 = jest.fn()
					flag = true
					expect(function()
						return tracing.unstable_trace(v11.name, v, v12)
					end).toThrow("Expected error onInteractionScheduledWorkCompleted")
					flag = false
					expect(tracing.unstable_getCurrent()).toMatchInteractions({ v10 })
					expect(v9.onInteractionScheduledWorkCompleted).toHaveBeenCalledTimes(1)
				end)
			end)
			it("should cover the callback within trace", function()
				expect(onWorkStarted).never.toHaveBeenCalled()
				expect(onWorkStopped).never.toHaveBeenCalled()
				expect(function()
					tracing.unstable_trace(v10.name, v, function()
						error("Expected error callback")
					end)
				end).toThrow("Expected error callback")
				expect(onWorkStarted).toHaveBeenCalledTimes(1)
				expect(onWorkStopped).toHaveBeenCalledTimes(1)
			end)
			it("should cover onWorkScheduled within wrap", function()
				tracing.unstable_trace(v10.name, v, function()
					local v12 = tracing.unstable_getCurrent()._array[1]
					local __count = v12.__count
					flag4 = true
					expect(function()
						return tracing.unstable_wrap(function() end)
					end).toThrow("Expected error onWorkScheduled")
					expect(v12.__count).toBe(__count)
					expect(v9.onWorkScheduled).toHaveBeenCalledTimes(1)
				end)
			end)
			it("should cover onWorkStarted within wrap", function()
				local v12 = jest.fn()
				local v13 = nil
				local v14 = nil
				tracing.unstable_trace(v10.name, v, function()
					v13 = tracing.unstable_getCurrent()._array[1]
					v14 = tracing.unstable_wrap(v12)
				end)
				expect(v13.__count).toBe(1)
				flag5 = true
				expect(function()
					v14()
				end).toThrow("Expected error onWorkStarted")
				expect(v12).toHaveBeenCalledTimes(1)
				expect(v13.__count).toBe(0)
				expect(v9.onWorkStarted).toHaveBeenCalledTimes(2)
			end)
			it("should cover onWorkStopped within wrap", function()
				tracing.unstable_trace(v10.name, v, function()
					local v12 = tracing.unstable_getCurrent()._array[1]
					expect(v12.__count).toBe(1)
					local v13 = nil
					local v14 = nil
					tracing.unstable_trace(v11.name, v, function()
						v14 = tracing.unstable_getCurrent()._array[2]
						expect(v12.__count).toBe(1)
						expect(v14.__count).toBe(1)
						v13 = tracing.unstable_wrap(jest.fn())
						expect(v12.__count).toBe(2)
						expect(v14.__count).toBe(2)
					end)
					expect(v12.__count).toBe(2)
					expect(v14.__count).toBe(1)
					flag6 = true
					expect(function()
						v13()
					end).toThrow("Expected error onWorkStopped")
					flag6 = false
					expect(tracing.unstable_getCurrent()).toMatchInteractions({ v12 })
					expect(v12.__count).toBe(1)
					expect(v14.__count).toBe(0)
					expect(v9.onWorkStopped).toHaveBeenCalledTimes(2)
				end)
			end)
			it("should cover the callback within wrap", function()
				expect(onWorkStarted).never.toHaveBeenCalled()
				expect(onWorkStopped).never.toHaveBeenCalled()
				local v12 = nil
				local v13 = nil
				tracing.unstable_trace(v10.name, v, function()
					v13 = tracing.unstable_getCurrent()._array[1]
					v12 = tracing.unstable_wrap(function()
						error("Expected error wrap")
					end)
				end)
				expect(onWorkStarted).toHaveBeenCalledTimes(1)
				expect(onWorkStopped).toHaveBeenCalledTimes(1)
				expect(function()
					v12()
				end).toThrow("Expected error wrap")
				expect(onWorkStarted).toHaveBeenCalledTimes(2)
				expect(onWorkStopped).toHaveBeenCalledTimes(2)
				expect(onWorkStopped).toHaveBeenLastNotifiedOfWork({ v13 })
			end)
			it("should cover onWorkCanceled within wrap", function()
				local v12 = nil
				local v13 = nil
				tracing.unstable_trace(v10.name, v, function()
					v12 = tracing.unstable_getCurrent()._array[1]
					v13 = tracing.unstable_wrap(jest.fn())
				end)
				expect(v12.__count).toBe(1)
				flag3 = true
				expect(function()
					v13.cancel()
				end).toThrow("Expected error onWorkCanceled")
				expect(onWorkCanceled).toHaveBeenCalledTimes(1)
				expect(v12.__count).toBe(0)
				expect(onInteractionScheduledWorkCompleted).toHaveBeenLastNotifiedOfInteraction(v10)
				expect(v9.onWorkCanceled).toHaveBeenCalledTimes(1)
			end)
		end)
		it("calls lifecycle methods for trace", function()
			expect(onInteractionTraced).never.toHaveBeenCalled()
			expect(onInteractionScheduledWorkCompleted).never.toHaveBeenCalled()
			tracing.unstable_trace(v10.name, v, function()
				expect(onInteractionTraced).toHaveBeenCalledTimes(1)
				expect(onInteractionTraced).toHaveBeenLastNotifiedOfInteraction(v10)
				expect(onInteractionScheduledWorkCompleted).never.toHaveBeenCalled()
				expect(onWorkStarted).toHaveBeenCalledTimes(1)
				expect(onWorkStarted).toHaveBeenLastNotifiedOfWork(set.new({ v10 }), 123)
				expect(onWorkStopped).never.toHaveBeenCalled()
				tracing.unstable_trace(v11.name, v, function()
					expect(onInteractionTraced).toHaveBeenCalledTimes(2)
					expect(onInteractionTraced).toHaveBeenLastNotifiedOfInteraction(v11)
					expect(onInteractionScheduledWorkCompleted).never.toHaveBeenCalled()
					expect(onWorkStarted).toHaveBeenCalledTimes(2)
					expect(onWorkStarted).toHaveBeenLastNotifiedOfWork(set.new({ v10, v11 }), 123)
					expect(onWorkStopped).never.toHaveBeenCalled()
				end, 123)
				expect(onInteractionScheduledWorkCompleted).toHaveBeenCalledTimes(1)
				expect(onInteractionScheduledWorkCompleted).toHaveBeenLastNotifiedOfInteraction(v11)
				expect(onWorkStopped).toHaveBeenCalledTimes(1)
				expect(onWorkStopped).toHaveBeenLastNotifiedOfWork(set.new({ v10, v11 }), 123)
			end, 123)
			expect(onInteractionScheduledWorkCompleted).toHaveBeenCalledTimes(2)
			expect(onInteractionScheduledWorkCompleted).toHaveBeenLastNotifiedOfInteraction(v10)
			expect(onWorkScheduled).never.toHaveBeenCalled()
			expect(onWorkCanceled).never.toHaveBeenCalled()
			expect(onWorkStarted).toHaveBeenCalledTimes(2)
			expect(onWorkStopped).toHaveBeenCalledTimes(2)
			expect(onWorkStopped).toHaveBeenLastNotifiedOfWork(set.new({ v10 }), 123)
		end)
		it("calls lifecycle methods for wrap", function()
			local v12 = jest.fn()
			local v13 = nil
			tracing.unstable_trace(v10.name, v, function()
				expect(onInteractionTraced).toHaveBeenCalledTimes(1)
				expect(onInteractionTraced).toHaveBeenLastNotifiedOfInteraction(v10)
				tracing.unstable_trace(v11.name, v, function()
					expect(onInteractionTraced).toHaveBeenCalledTimes(2)
					expect(onInteractionTraced).toHaveBeenLastNotifiedOfInteraction(v11)
					v13 = tracing.unstable_wrap(v12, 123)
					expect(onWorkScheduled).toHaveBeenCalledTimes(1)
					expect(onWorkScheduled).toHaveBeenLastNotifiedOfWork(set.new({ v10, v11 }), 123)
				end)
			end)
			expect(onInteractionTraced).toHaveBeenCalledTimes(2)
			expect(onInteractionScheduledWorkCompleted).never.toHaveBeenCalled()
			v13()
			expect(v12).toHaveBeenCalled()
			expect(onWorkScheduled).toHaveBeenCalledTimes(1)
			expect(onWorkCanceled).never.toHaveBeenCalled()
			expect(onWorkStarted).toHaveBeenCalledTimes(3)
			expect(onWorkStarted).toHaveBeenLastNotifiedOfWork(set.new({ v10, v11 }), 123)
			expect(onWorkStopped).toHaveBeenCalledTimes(3)
			expect(onWorkStopped).toHaveBeenLastNotifiedOfWork(set.new({ v10, v11 }), 123)
			expect(onInteractionScheduledWorkCompleted.mock.calls[1][1]).toMatchInteraction(v10)
			expect(onInteractionScheduledWorkCompleted.mock.calls[2][1]).toMatchInteraction(v11)
		end)
		it("should call the correct interaction subscriber methods when a wrapped callback is canceled", function()
			local v12 = jest.fn()
			local v13 = jest.fn()
			local v14 = nil
			local v15 = nil
			tracing.unstable_trace(v10.name, v, function()
				v14 = tracing.unstable_wrap(v12, 123)
				tracing.unstable_trace(v11.name, v, function()
					v15 = tracing.unstable_wrap(v13, 123)
				end)
			end)
			expect(onInteractionTraced).toHaveBeenCalledTimes(2)
			expect(onInteractionScheduledWorkCompleted).never.toHaveBeenCalled()
			expect(onWorkCanceled).never.toHaveBeenCalled()
			expect(onWorkStarted).toHaveBeenCalledTimes(2)
			expect(onWorkStopped).toHaveBeenCalledTimes(2)
			v15:cancel()
			expect(onInteractionScheduledWorkCompleted).toHaveBeenCalledTimes(1)
			expect(onInteractionScheduledWorkCompleted).toHaveBeenLastNotifiedOfInteraction(v11)
			expect(onWorkCanceled).toHaveBeenCalledTimes(1)
			expect(onWorkCanceled).toHaveBeenLastNotifiedOfWork(set.new({ v10, v11 }), 123)
			v14:cancel()
			expect(onInteractionScheduledWorkCompleted).toHaveBeenCalledTimes(2)
			expect(onInteractionScheduledWorkCompleted).toHaveBeenLastNotifiedOfInteraction(v10)
			expect(onWorkCanceled).toHaveBeenCalledTimes(2)
			expect(onWorkCanceled).toHaveBeenLastNotifiedOfWork(set.new({ v10 }), 123)
			expect(v12).never.toHaveBeenCalled()
			expect(v13).never.toHaveBeenCalled()
		end)
		it(
			"should not end an interaction twice if wrap is used to schedule follow up work within another wrap",
			function()
				local v12 = nil
				local v13 = nil
				local v14 = jest.fn()
				local v15 = jest.fn(function()
					v13 = tracing.unstable_wrap(v14, 123)
				end)
				tracing.unstable_trace(v10.name, v, function()
					v12 = tracing.unstable_wrap(v15, 123)
				end)
				expect(onInteractionTraced).toHaveBeenCalledTimes(1)
				expect(onInteractionScheduledWorkCompleted).never.toHaveBeenCalled()
				v12()
				expect(onInteractionTraced).toHaveBeenCalledTimes(1)
				expect(onInteractionScheduledWorkCompleted).never.toHaveBeenCalled()
				v13()
				expect(onInteractionTraced).toHaveBeenCalledTimes(1)
				expect(onInteractionScheduledWorkCompleted).toHaveBeenCalledTimes(1)
				expect(onInteractionScheduledWorkCompleted).toHaveBeenLastNotifiedOfInteraction(v10)
			end
		)
		it("should not decrement the interaction count twice if a wrapped function is run twice", function()
			local v12 = jest.fn()
			local v13 = jest.fn()
			local v14 = nil
			local v15 = nil
			tracing.unstable_trace(v10.name, v, function()
				v14 = tracing.unstable_wrap(v12, 123)
				v15 = tracing.unstable_wrap(v13, 123)
			end)
			expect(onInteractionTraced).toHaveBeenCalledTimes(1)
			expect(onInteractionScheduledWorkCompleted).never.toHaveBeenCalled()
			v14()
			expect(v12).toHaveBeenCalledTimes(1)
			expect(onInteractionTraced).toHaveBeenCalledTimes(1)
			expect(onInteractionScheduledWorkCompleted).never.toHaveBeenCalled()
			v14()
			expect(v12).toHaveBeenCalledTimes(2)
			expect(onInteractionTraced).toHaveBeenCalledTimes(1)
			expect(onInteractionScheduledWorkCompleted).never.toHaveBeenCalled()
			v15()
			expect(onInteractionTraced).toHaveBeenCalledTimes(1)
			expect(onInteractionScheduledWorkCompleted).toHaveBeenCalledTimes(1)
			expect(onInteractionScheduledWorkCompleted).toHaveBeenLastNotifiedOfInteraction(v10)
		end)
		it("should unsubscribe", function()
			tracing.unstable_unsubscribe(v8)
			tracing.unstable_trace(v10.name, v, function() end)
			expect(onInteractionTraced).never.toHaveBeenCalled()
		end)
	end)
	describe("disabled", function()
		beforeEach(function()
			return loadModules({
				enableSchedulerTracing = false
			})
		end)
		it("TODO - we need at least one test for JestRoblox not to throw", function() end)
	end)
end)