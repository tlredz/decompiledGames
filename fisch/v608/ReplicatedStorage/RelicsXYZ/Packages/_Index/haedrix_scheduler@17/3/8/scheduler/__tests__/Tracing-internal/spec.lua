local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local jest = JestGlobals.jest
local LuauPolyfill = require(parent.LuauPolyfill)
local set = LuauPolyfill.Set
describe("Tracing", function()
	local tracing = nil
	local reactFeatureFlags = nil
	local advanceTimersByTime = nil
	local time = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function loadModules(p)
		local enableSchedulerTracing = p.enableSchedulerTracing
		jest.resetModules()
		jest.useFakeTimers()
		time = os.time
		advanceTimersByTime = jest.advanceTimersByTime
		local Shared = require(parent.Shared)
		reactFeatureFlags = Shared.ReactFeatureFlags
		reactFeatureFlags.enableSchedulerTracing = enableSchedulerTracing
		local Scheduler = require(parent.Scheduler)
		tracing = Scheduler.tracing
	end

	describe("enableSchedulerTracing enabled", function()
		beforeEach(function()
			loadModules({
				enableSchedulerTracing = true
			}) -- equivalent call inferred; original call site unknown
		end)
		it("should return the value of a traced function", function()
			expect(tracing.unstable_trace("arbitrary", time(), function()
				return 123
			end)).toBe(123)
		end)
		it("should return the value of a clear function", function()
			expect(tracing.unstable_clear(function()
				return 123
			end)).toBe(123)
		end)
		it("should return the value of a wrapped function", function()
			local v = nil
			tracing.unstable_trace("arbitrary", time(), function()
				v = tracing.unstable_wrap(function()
					return 123
				end)
			end)
			jest.runAllTimers()
			expect(v()).toBe(123)
		end)
		it("should pass arguments through to a wrapped function", function()
			local v = nil
			local v2 = false
			tracing.unstable_trace("arbitrary", time(), function()
				v = tracing.unstable_wrap(function(p, p2)
					expect(p).toBe("foo")
					expect(p2).toBe("bar")
					v2 = true
				end)
			end)
			v("foo", "bar")
			jest.runAllTimers()
			expect(v2).toBe(true)
		end)
		it("should return an empty set when outside of a traced event", function()
			expect(tracing.unstable_getCurrent()).toContainNoInteractions()
		end)
		it("should report the traced interaction from within the trace callback", function()
			local v = false
			advanceTimersByTime(100)
			tracing.unstable_trace("some event", time(), function()
				expect((tracing.unstable_getCurrent())).toMatchInteractions({
					{
						name = "some event",
						timestamp = 100
					}
				})
				v = true
			end)
			expect(v).toBe(true)
		end)
		it("should report the traced interaction from within wrapped callbacks", function()
			local v = false
			local v2 = nil

			local function indirection()
				expect((tracing.unstable_getCurrent())).toMatchInteractions({
					{
						name = "some event",
						timestamp = 100
					}
				})
				v = true
			end

			advanceTimersByTime(100)
			tracing.unstable_trace("some event", time(), function()
				v2 = tracing.unstable_wrap(indirection)
			end)
			advanceTimersByTime(50)
			v2()
			expect(v).toBe(true)
		end)
		it("should clear the interaction stack for traced callbacks", function()
			local v = false
			tracing.unstable_trace("outer event", time(), function()
				expect(tracing.unstable_getCurrent()).toMatchInteractions({
					{
						name = "outer event"
					}
				})
				tracing.unstable_clear(function()
					expect(tracing.unstable_getCurrent()).toMatchInteractions({})
					tracing.unstable_trace("inner event", time(), function()
						expect(tracing.unstable_getCurrent()).toMatchInteractions({
							{
								name = "inner event"
							}
						})
						v = true
					end)
				end)
				expect(tracing.unstable_getCurrent()).toMatchInteractions({
					{
						name = "outer event"
					}
				})
			end)
			expect(v).toBe(true)
		end)
		it("should clear the interaction stack for wrapped callbacks", function()
			local v = false
			local v2 = nil
			local v3 = jest.fn(function()
				expect(tracing.unstable_getCurrent()).toMatchInteractions({
					{
						name = "outer event"
					}
				})
				tracing.unstable_clear(function()
					expect(tracing.unstable_getCurrent()).toMatchInteractions({})
					tracing.unstable_trace("inner event", time(), function()
						expect(tracing.unstable_getCurrent()).toMatchInteractions({
							{
								name = "inner event"
							}
						})
						v = true
					end)
				end)
				expect(tracing.unstable_getCurrent()).toMatchInteractions({
					{
						name = "outer event"
					}
				})
			end)
			tracing.unstable_trace("outer event", time(), function()
				v2 = tracing.unstable_wrap(v3)
			end)
			v2()
			expect(v).toBe(true)
		end)
		it("should support nested traced events", function()
			local v = false
			advanceTimersByTime(100)
			local v2 = false
			local v3 = false

			local function innerIndirection()
				expect((tracing.unstable_getCurrent())).toMatchInteractions({
					{
						name = "outer event",
						timestamp = 100
					},
					{
						name = "inner event",
						timestamp = 150
					}
				})
				v2 = true
			end

			local function outerIndirection()
				expect((tracing.unstable_getCurrent())).toMatchInteractions({
					{
						name = "outer event",
						timestamp = 100
					}
				})
				v3 = true
			end

			tracing.unstable_trace("outer event", time(), function()
				local unstable_getCurrent = tracing.unstable_getCurrent()
				expect(unstable_getCurrent).toMatchInteractions({
					{
						name = "outer event",
						timestamp = 100
					}
				})
				advanceTimersByTime(50)
				local unstable_wrap = tracing.unstable_wrap(outerIndirection)
				local v4 = nil
				local v5 = false
				tracing.unstable_trace("inner event", time(), function()
					unstable_getCurrent = tracing.unstable_getCurrent()
					expect(unstable_getCurrent).toMatchInteractions({
						{
							name = "outer event",
							timestamp = 100
						},
						{
							name = "inner event",
							timestamp = 150
						}
					})
					unstable_wrap()
					expect(v3).toBe(true)
					v4 = tracing.unstable_wrap(innerIndirection)
					v5 = true
				end)
				expect(v5).toBe(true)
				unstable_getCurrent = tracing.unstable_getCurrent()
				expect(unstable_getCurrent).toMatchInteractions({
					{
						name = "outer event",
						timestamp = 100
					}
				})
				v4()
				expect(v2).toBe(true)
				v = true
			end)
			expect(v).toBe(true)
		end)
		describe("error handling", function()
			it("should reset state appropriately when an error occurs in a trace callback", function()
				local v = false
				advanceTimersByTime(100)
				tracing.unstable_trace("outer event", time(), function()
					expect(function()
						tracing.unstable_trace("inner event", time(), function()
							error("intentional")
						end)
					end).toThrow()
					expect(tracing.unstable_getCurrent()).toMatchInteractions({
						{
							name = "outer event",
							timestamp = 100
						}
					})
					v = true
				end)
				expect(v).toBe(true)
			end)
			it("should reset state appropriately when an error occurs in a wrapped callback", function()
				local v = false
				advanceTimersByTime(100)
				tracing.unstable_trace("outer event", time(), function()
					local v2 = nil
					tracing.unstable_trace("inner event", time(), function()
						v2 = tracing.unstable_wrap(function()
							error("intentional")
						end)
					end)
					expect(function()
						v2()
					end).toThrow()
					expect(tracing.unstable_getCurrent()).toMatchInteractions({
						{
							name = "outer event",
							timestamp = 100
						}
					})
					v = true
				end)
				expect(v).toBe(true)
			end)
		end)
		describe("advanced integration", function()
			it("should return a unique threadID per request", function()
				expect(tracing.unstable_getThreadID()).never.toBe(tracing.unstable_getThreadID())
			end)
			it("should expose the current set of interactions to be externally manipulated", function()
				tracing.unstable_trace("outer event", time(), function()
					expect(tracing.__interactionsRef.current).toBe(tracing.unstable_getCurrent())
					tracing.__interactionsRef.current = set.new({
						{
							name = "override event"
						}
					})
					expect(tracing.unstable_getCurrent()).toMatchInteractions({
						{
							name = "override event"
						}
					})
				end)
			end)
			it("should expose a subscriber ref to be externally manipulated", function()
				tracing.unstable_trace("outer event", time(), function()
					expect(tracing.__subscriberRef).toEqual({
						current = nil
					})
				end)
			end)
		end)
	end)
	describe("enableSchedulerTracing disabled", function()
		beforeEach(function()
			loadModules({
				enableSchedulerTracing = false
			}) -- equivalent call inferred; original call site unknown
		end)
		it("should return the value of a traced function", function()
			expect(tracing.unstable_trace("arbitrary", time(), function()
				return 123
			end)).toBe(123)
		end)
		it("should return the value of a wrapped function", function()
			local v = nil
			tracing.unstable_trace("arbitrary", time(), function()
				v = tracing.unstable_wrap(function()
					return 123
				end)
			end)
			expect(v()).toBe(123)
		end)
		it("should return nil for traced interactions", function()
			expect(tracing.unstable_getCurrent()).toBe(nil)
		end)
		it("should execute traced callbacks", function()
			local v = false
			tracing.unstable_trace("some event", time(), function()
				expect(tracing.unstable_getCurrent()).toBe(nil)
				v = true
			end)
			expect(v).toBe(true)
		end)
		it("should return the value of a clear function", function()
			expect(tracing.unstable_clear(function()
				return 123
			end)).toBe(123)
		end)
		it("should execute wrapped callbacks", function()
			local v = false
			tracing.unstable_wrap(function()
				expect(tracing.unstable_getCurrent()).toBe(nil)
				v = true
			end)()
			expect(v).toBe(true)
		end)
		describe("advanced integration", function()
			it("should not create unnecessary objects", function()
				expect(tracing.__interactionsRef).toBe(nil)
			end)
		end)
	end)
end)