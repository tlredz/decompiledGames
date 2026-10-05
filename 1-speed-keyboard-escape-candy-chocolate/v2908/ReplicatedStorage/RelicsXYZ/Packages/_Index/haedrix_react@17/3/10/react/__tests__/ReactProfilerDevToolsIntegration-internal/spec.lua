local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local v = nil
local v2 = nil
local LuauPolyfill = require(parent.LuauPolyfill)
local set = LuauPolyfill.Set
local JestGlobals = require(parent.Dev.JestGlobals)
JestGlobals.describe("ReactProfiler DevTools integration", function()
	local expect = JestGlobals.expect
	local jest = JestGlobals.jest
	local it = JestGlobals.it
	local beforeEach = JestGlobals.beforeEach
	local afterEach = JestGlobals.afterEach
	local reactFeatureFlags = nil
	local v3 = nil
	local tracing = nil
	local v4 = nil
	local v5 = nil
	local __REACT_DEVTOOLS_GLOBAL_HOOK__ = nil
	beforeEach(function()
		v5 = {
			inject = function() end,
			onCommitFiberRoot = jest.fn(function(_, _) end),
			onCommitFiberUnmount = function() end,
			supportsFiber = true
		}
		__REACT_DEVTOOLS_GLOBAL_HOOK__ = ReactGlobals.__REACT_DEVTOOLS_GLOBAL_HOOK__
		ReactGlobals.__REACT_DEVTOOLS_GLOBAL_HOOK__ = v5
		jest.resetModules()
		local Shared = require(parent.Shared)
		reactFeatureFlags = Shared.ReactFeatureFlags
		reactFeatureFlags.enableProfilerTimer = true
		reactFeatureFlags.enableSchedulerTracing = true
		local Scheduler = require(parent.Dev.Scheduler)
		v2 = Scheduler
		tracing = v2.tracing
		local React = require(parent.React)
		v = React
		local ReactTestRenderer = require(parent.Dev.ReactTestRenderer)
		v3 = ReactTestRenderer
		v4 = v.Component:extend("AdvanceTime")
		v4.defaultProps = {
			byAmount = 10,
			shouldComponentUpdate = true
		}

		function v4.shouldComponentUpdate(_, p)
			return p.shouldComponentUpdate
		end

		function v4.render(p)
			v2.unstable_advanceTime(p.props.byAmount)
			return p.props.children or nil
		end
	end)
	afterEach(function()
		ReactGlobals.__REACT_DEVTOOLS_GLOBAL_HOOK__ = __REACT_DEVTOOLS_GLOBAL_HOOK__
	end)
	it("should auto-Profile all fibers if the DevTools hook is detected", function()
		local onRender = jest.fn(function() end)

		local function fn(p)
			local multiplier = p.multiplier
			v2.unstable_advanceTime(2)
			return v.createElement(v.Profiler, {
				id = "Profiler",
				onRender = onRender
			}, v.createElement(v4, {
				byAmount = 3 * multiplier,
				shouldComponentUpdate = true
			}), v.createElement(v4, {
				byAmount = 7 * multiplier,
				shouldComponentUpdate = false
			}))
		end

		local v7 = v3.create(v.createElement(fn, {
			multiplier = 1
		}))
		expect(v5.onCommitFiberRoot).toHaveBeenCalledTimes(1)
		expect(onRender).toHaveBeenCalledTimes(1)
		expect(onRender).toHaveBeenCalledWith("Profiler", "mount", 10, 10, 2, 12, set.new())
		onRender.mockClear()
		expect(v7.root:findByType(fn):_currentFiber().treeBaseDuration).toBe(12)
		v7.update(v.createElement(fn, {
			multiplier = 2
		}))
		expect(onRender).toHaveBeenCalledTimes(1)
		expect(onRender).toHaveBeenCalledWith("Profiler", "update", 6, 13, 14, 20, set.new())
		expect(v7.root:findByType(fn):_currentFiber().treeBaseDuration).toBe(15)
	end)
	it("should reset the fiber stack correctly after an error when profiling host roots", function()
		v2.unstable_advanceTime(20)
		local v6 = v3.create(v.createElement("div", nil, v.createElement(v4, {
			byAmount = 2
		})))
		v2.unstable_advanceTime(20)
		expect(function()
			v6.update(v.createElement("div", {
				ref = "this-will-cause-an-error"
			}, v.createElement(v4, {
				byAmount = 3
			})))
		end).toThrow()
		v2.unstable_advanceTime(20)
		v6.update(v.createElement("div", nil, v.createElement(v4, {
			byAmount = 7
		})))
		expect(v6.root:findByType("div"):_currentFiber().treeBaseDuration).toBe(7)
	end)
	it("should store traced interactions on the HostNode so DevTools can access them", function()
		local v6 = v3.create(v.createElement("div"))
		local return_ = v6.root:_currentFiber().return_
		expect(return_.stateNode.memoizedInteractions).toContainNoInteractions()
		v2.unstable_advanceTime(10)
		local unstable_now = v2.unstable_now()
		tracing.unstable_trace("some event", unstable_now, function()
			v6.update(v.createElement("div"))
		end)
		expect(return_.stateNode.memoizedInteractions).toMatchInteractions({
			{
				name = "some event",
				timestamp = unstable_now
			}
		})
	end)
	it("regression test: #17159", function()
		local function Text(p)
			local text = p.text
			v2.unstable_yieldValue(text)
			return text
		end

		local v6 = v3.create(nil, {
			unstable_isConcurrent = true
		})
		v6.update(v.createElement(Text, {
			text = "A"
		}))
		expect(v2).toFlushAndYield({ "A" })
		expect(v6).toMatchRenderedOutput("A")
		v2.unstable_advanceTime(10000)
		v6.update(v.createElement(Text, {
			text = "B"
		}))
		expect(v2).toFlushExpired({})
		expect(v2).toFlushAndYield({ "B" })
		expect(v6).toMatchRenderedOutput("B")
	end)
end)