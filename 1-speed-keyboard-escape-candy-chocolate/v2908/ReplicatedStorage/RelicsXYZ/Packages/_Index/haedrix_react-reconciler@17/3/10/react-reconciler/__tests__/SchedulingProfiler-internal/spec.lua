local parent = script.Parent.Parent.Parent
local Shared = require(parent.Shared)
local reactVersion = Shared.ReactVersion
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local afterEach = JestGlobals.afterEach
local it = JestGlobals.it
local xit = JestGlobals.xit
local jest = JestGlobals.jest
local describe = JestGlobals.describe
local LuauPolyfill = require(parent.LuauPolyfill)
local array = LuauPolyfill.Array
local error2 = LuauPolyfill.Error
local Promise = require(parent.Promise)
describe("SchedulingProfiler", function()
	local v = nil
	local v2 = nil
	local v3 = nil
	local v4 = nil
	local v5 = nil

	local function createUserTimingPolyfill()
		return {
			mark = function(p)
				table.insert(v5, p)
			end
		}
	end

	beforeEach(function()
		jest.resetModules()
		_G.performance = {
			mark = function(p)
				table.insert(v5, p)
			end
		}
		v5 = {}
		local Shared2 = require(parent.Shared)
		local reactFeatureFlags = Shared2.ReactFeatureFlags
		reactFeatureFlags.enableSchedulingProfiler = true
		reactFeatureFlags.enableProfilerTimer = true
		reactFeatureFlags.replayFailedUnitOfWorkWithInvokeGuardedCallback = true
		reactFeatureFlags.enableSuspenseServerRenderer = true
		reactFeatureFlags.decoupleUpdatePriorityFromScheduler = true
		reactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode = false
		reactFeatureFlags.enableDebugTracing = false
		reactFeatureFlags.warnAboutDeprecatedLifecycles = true
		reactFeatureFlags.enableProfilerCommitHooks = false
		reactFeatureFlags.enableBlocksAPI = false
		reactFeatureFlags.enableLazyElements = false
		reactFeatureFlags.enableSchedulerDebugging = false
		reactFeatureFlags.enableFundamentalAPI = false
		reactFeatureFlags.enableScopeAPI = false
		reactFeatureFlags.enableCreateEventHandleAPI = false
		reactFeatureFlags.warnAboutUnmockedScheduler = false
		reactFeatureFlags.enableSuspenseCallback = false
		reactFeatureFlags.warnAboutDefaultPropsOnFunctionComponents = false
		reactFeatureFlags.warnAboutStringRefs = false
		reactFeatureFlags.disableLegacyContext = false
		reactFeatureFlags.disableModulePatternComponents = false
		reactFeatureFlags.warnUnstableRenderSubtreeIntoContainer = false
		reactFeatureFlags.warnAboutSpreadingKeyToJSX = false
		reactFeatureFlags.enableComponentStackLocations = true
		reactFeatureFlags.skipUnmountedBoundaries = false
		reactFeatureFlags.enableNewReconciler = false
		reactFeatureFlags.deferRenderPhaseUpdateToNextBatch = true
		reactFeatureFlags.enableEagerRootListeners = true
		reactFeatureFlags.enableDoubleInvokingEffects = false
		local React = require(parent.React)
		v = React
		local ReactTestRenderer = require(parent.Dev.ReactTestRenderer)
		v2 = ReactTestRenderer
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v3 = ReactNoopRenderer
		local Scheduler = require(parent.Scheduler)
		v4 = Scheduler
	end)
	afterEach(function()
		_G.performance = nil
	end)
	xit("should not mark if enableSchedulingProfiler is false", function()
		v2.create(v.createElement("div"))
		expect(v5).toEqual({})
	end)
	it("should log React version on initialization", function()
		expect(v5).toEqual({ "--react-init-" .. tostring(reactVersion) })
	end)
	it("should mark sync render without suspends or state updates", function()
		v2.create(v.createElement("div"))
		expect(v5).toEqual({
			"--react-init-" .. tostring(reactVersion),
			"--schedule-render-1",
			"--render-start-1",
			"--render-stop",
			"--commit-start-1",
			"--layout-effects-start-1",
			"--layout-effects-stop",
			"--commit-stop"
		})
	end)
	it("should mark concurrent render without suspends or state updates", function()
		v2.create(v.createElement("div"), {
			unstable_isConcurrent = true
		})
		expect(v5).toEqual({ "--react-init-" .. tostring(reactVersion), "--schedule-render-512" })
		array.splice(v5, 1)
		expect(v4).toFlushUntilNextPaint({})
		expect(v5).toEqual({
			"--render-start-512",
			"--render-stop",
			"--commit-start-512",
			"--layout-effects-start-512",
			"--layout-effects-stop",
			"--commit-stop"
		})
	end)
	it("should mark render yields", function()
		local function Bar()
			v4.unstable_yieldValue("Bar")
			return nil
		end

		local function Foo()
			v4.unstable_yieldValue("Foo")
			return v.createElement(Bar)
		end

		v3.render(v.createElement(Foo))
		expect(v3.flushNextYield()).toEqual({ "Foo" })
		expect(v5).toEqual({
			"--react-init-" .. tostring(reactVersion),
			"--schedule-render-512",
			"--render-start-512",
			"--render-yield"
		})
	end)
	it("should mark sync render with suspense that resolves", function()
		local v6 = Promise.delay(0):andThen(function()
			return true
		end)

		local function Example()
			error(v6)
		end

		v2.create(v.createElement(v.Suspense, {
			fallback = {}
		}, v.createElement(Example)))
		expect(v5).toEqual({
			"--react-init-" .. tostring(reactVersion),
			"--schedule-render-1",
			"--render-start-1",
			"--suspense-suspend-0-Example",
			"--render-stop",
			"--commit-start-1",
			"--layout-effects-start-1",
			"--layout-effects-stop",
			"--commit-stop"
		})
		array.splice(v5, 1)
		v6:await()
		expect(v5).toEqual({ "--suspense-resolved-0-Example" })
	end)
	it("should mark sync render with suspense that rejects", function()
		local v6 = Promise.delay(0):andThen(function()
			error(error2.new("error"))
		end)

		local function Example()
			error(v6)
		end

		v2.create(v.createElement(v.Suspense, {
			fallback = {}
		}, v.createElement(Example)))
		expect(v5).toEqual({
			"--react-init-" .. tostring(reactVersion),
			"--schedule-render-1",
			"--render-start-1",
			"--suspense-suspend-0-Example",
			"--render-stop",
			"--commit-start-1",
			"--layout-effects-start-1",
			"--layout-effects-stop",
			"--commit-stop"
		})
		array.splice(v5, 1)
		expect(function()
			v6:expect()
		end).toThrow()
		expect(v5).toEqual({ "--suspense-rejected-0-Example" })
	end)
	it("should mark concurrent render with suspense that resolves", function()
		local v6 = Promise.delay(0):andThen(function()
			return true
		end)

		local function Example()
			error(v6)
		end

		v2.create(v.createElement(v.Suspense, {
			fallback = {}
		}, v.createElement(Example)), {
			unstable_isConcurrent = true
		})
		expect(v5).toEqual({ "--react-init-" .. tostring(reactVersion), "--schedule-render-512" })
		array.splice(v5, 1)
		expect(v4).toFlushUntilNextPaint({})
		expect(v5).toEqual({
			"--render-start-512",
			"--suspense-suspend-0-Example",
			"--render-stop",
			"--commit-start-512",
			"--layout-effects-start-512",
			"--layout-effects-stop",
			"--commit-stop"
		})
		array.splice(v5, 1)
		v6:expect()
		expect(v5).toEqual({ "--suspense-resolved-0-Example" })
	end)
	it("should mark concurrent render with suspense that rejects", function()
		local v6 = Promise.delay(0):andThen(function()
			error(error2.new("error"))
		end)

		local function Example()
			error(v6)
		end

		v2.create(v.createElement(v.Suspense, {
			fallback = {}
		}, v.createElement(Example)), {
			unstable_isConcurrent = true
		})
		expect(v5).toEqual({ "--react-init-" .. tostring(reactVersion), "--schedule-render-512" })
		array.splice(v5, 1)
		expect(v4).toFlushUntilNextPaint({})
		expect(v5).toEqual({
			"--render-start-512",
			"--suspense-suspend-0-Example",
			"--render-stop",
			"--commit-start-512",
			"--layout-effects-start-512",
			"--layout-effects-stop",
			"--commit-stop"
		})
		array.splice(v5, 1)
		expect(function()
			v6:expect()
		end).toThrow()
		expect(v5).toEqual({ "--suspense-rejected-0-Example" })
	end)
	it("should mark cascading class component state updates", function()
		local extended = v.Component:extend("Example")

		function extended:init()
			self.state = {
				didMount = false
			}
		end

		function extended.componentDidMount(object)
			object:setState({
				didMount = true
			})
		end

		function extended.render(_)
			return nil
		end

		v2.create(v.createElement(extended), {
			unstable_isConcurrent = true
		})
		expect(v5).toEqual({ "--react-init-" .. tostring(reactVersion), "--schedule-render-512" })
		array.splice(v5, 1)
		expect(v4).toFlushUntilNextPaint({})
		expect(v5).toEqual({
			"--render-start-512",
			"--render-stop",
			"--commit-start-512",
			"--layout-effects-start-512",
			"--schedule-state-update-1-Example",
			"--layout-effects-stop",
			"--render-start-1",
			"--render-stop",
			"--commit-start-1",
			"--commit-stop",
			"--commit-stop"
		})
	end)
	it("should mark cascading class component force updates", function()
		local extended = v.Component:extend("Example")

		function extended.componentDidMount(object)
			object:forceUpdate()
		end

		function extended.render(_)
			return nil
		end

		v2.create(v.createElement(extended), {
			unstable_isConcurrent = true
		})
		expect(v5).toEqual({ "--react-init-" .. tostring(reactVersion), "--schedule-render-512" })
		array.splice(v5, 1)
		expect(v4).toFlushUntilNextPaint({})
		expect(v5).toEqual({
			"--render-start-512",
			"--render-stop",
			"--commit-start-512",
			"--layout-effects-start-512",
			"--schedule-forced-update-1-Example",
			"--layout-effects-stop",
			"--render-start-1",
			"--render-stop",
			"--commit-start-1",
			"--commit-stop",
			"--commit-stop"
		})
	end)
	it("should mark render phase state updates for class component", function()
		local extended = v.Component:extend("Example")

		function extended:init()
			self.state = {
				didRender = false
			}
		end

		function extended.render(object)
			if object.state.didRender == false then
				object:setState({
					didRender = true
				})
			end

			return nil
		end

		v2.create(v.createElement(extended), {
			unstable_isConcurrent = true
		})
		expect(v5).toEqual({ "--react-init-" .. tostring(reactVersion), "--schedule-render-512" })
		array.splice(v5, 1)
		expect(function()
			expect(v4).toFlushUntilNextPaint({})
		end).toErrorDev("Cannot update during an existing state transition")
		expect(v5).toContain("--schedule-state-update-1024-Example")
	end)
	it("should mark render phase force updates for class component", function()
		local extended = v.Component:extend("Example")

		function extended:init()
			self.state = {
				didRender = false
			}
		end

		function extended.render(object)
			if object.state.didRender == false then
				object:forceUpdate(function()
					object:setState({
						didRender = true
					})
				end)
			end

			return nil
		end

		v2.create(v.createElement(extended), {
			unstable_isConcurrent = true
		})
		expect(v5).toEqual({ "--react-init-" .. tostring(reactVersion), "--schedule-render-512" })
		array.splice(v5, 1)
		expect(function()
			expect(v4).toFlushUntilNextPaint({})
		end).toErrorDev("Cannot update during an existing state transition")
		expect(v5).toContain("--schedule-forced-update-1024-Example")
	end)
	it("should mark cascading layout updates", function()
		local function Example()
			local state, setState = v.useState(false)
			v.useLayoutEffect(function()
				setState(true)
			end, {})
			return state
		end

		v2.create(v.createElement(Example), {
			unstable_isConcurrent = true
		})
		expect(v5).toEqual({ "--react-init-" .. tostring(reactVersion), "--schedule-render-512" })
		array.splice(v5, 1)
		expect(v4).toFlushUntilNextPaint({})
		expect(v5).toEqual({
			"--render-start-512",
			"--render-stop",
			"--commit-start-512",
			"--layout-effects-start-512",
			"--schedule-state-update-1-Example",
			"--layout-effects-stop",
			"--render-start-1",
			"--render-stop",
			"--commit-start-1",
			"--commit-stop",
			"--commit-stop"
		})
	end)
	it("should mark cascading passive updates", function()
		local function Example()
			local state, setState = v.useState(false)
			v.useEffect(function()
				setState(true)
			end, {})
			return state
		end

		v2.unstable_concurrentAct(function()
			v2.create(v.createElement(Example), {
				unstable_isConcurrent = true
			})
		end)
		expect(v5).toEqual({
			"--react-init-" .. tostring(reactVersion),
			"--schedule-render-512",
			"--render-start-512",
			"--render-stop",
			"--commit-start-512",
			"--layout-effects-start-512",
			"--layout-effects-stop",
			"--commit-stop",
			"--passive-effects-start-512",
			"--schedule-state-update-1024-Example",
			"--passive-effects-stop",
			"--render-start-1024",
			"--render-stop",
			"--commit-start-1024",
			"--commit-stop"
		})
	end)
	it("should mark render phase updates", function()
		local function Example()
			local state, setState = v.useState(false)

			if not state then
				setState(true)
			end

			return state
		end

		v2.unstable_concurrentAct(function()
			v2.create(v.createElement(Example), {
				unstable_isConcurrent = true
			})
		end)
		expect(v5).toContain("--schedule-state-update-1024-Example")
	end)
end)