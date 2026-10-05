local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local jest = JestGlobals.jest
local it = JestGlobals.it
local xit = JestGlobals.xit
local expect = JestGlobals.expect
local Shared = require(parent.Shared)
local console = Shared.console
local Promise = require(parent.Promise)
describe("DebugTracing", function()
	local v = nil
	local v2 = nil
	local v3 = nil
	beforeEach(function()
		jest.resetModules()
		local Shared2 = require(parent.Shared)
		local reactFeatureFlags = Shared2.ReactFeatureFlags
		reactFeatureFlags.enableDebugTracing = true
		reactFeatureFlags.enableSchedulingProfiler = true
		reactFeatureFlags.enableProfilerTimer = true
		reactFeatureFlags.replayFailedUnitOfWorkWithInvokeGuardedCallback = true
		reactFeatureFlags.enableSuspenseServerRenderer = true
		reactFeatureFlags.decoupleUpdatePriorityFromScheduler = true
		local React = require(parent.React)
		v = React
		local ReactTestRenderer = require(parent.Dev.ReactTestRenderer)
		v2 = ReactTestRenderer
		local Scheduler = require(parent.Scheduler)
		v3 = Scheduler
	end)
	it("should not log anything for sync render without suspends or state updates", function()
		expect(function()
			v2.create(v.createElement(v.unstable_DebugTracingMode, nil, v.createElement("div")))
		end).toLogDev({})
	end)
	it("should not log anything for concurrent render without suspends or state updates", function()
		expect(function()
			v2.create(v.createElement(v.unstable_DebugTracingMode, nil, v.createElement("div")), {
				unstable_isConcurrent = true
			})
		end).toLogDev({})
		expect(function()
			expect(v3).toFlushUntilNextPaint({})
		end).toLogDev({})
	end)
	xit("should log sync render with suspense", function()
		local v4 = Promise.delay(0):andThen(function()
			return true
		end)

		local function Example()
			error(v4)
		end

		expect(function()
			v2.create(v.createElement(v.unstable_DebugTracingMode, nil, v.createElement(v.Suspense, {
				fallback = {}
			}, v.createElement(Example))))
		end).toLogDev({ "* Example suspended" }, {
			withoutStack = true
		})
		expect(function()
			v4:await()
		end).toLogDev({ "* Example resolved" }, {
			withoutStack = true
		})
	end)
	it.skip("should log sync render with CPU suspense", function()
		local function Example()
			console.log("<Example/>")
			return nil
		end

		local function Wrapper(p)
			local children = p.children
			console.log("<Wrapper/>")
			return children
		end

		expect(function()
			v2.create(v.createElement(
				v.unstable_DebugTracingMode,
				nil,
				v.createElement(Wrapper, nil, v.createElement(v.Suspense, {
					fallback = {},
					unstable_expectedLoadTime = 1
				}, v.createElement(Example)))
			))
		end).toLogDev({ "<Wrapper/>" }, {
			withoutStack = true
		})
		expect(function()
			expect(v3).toFlushUntilNextPaint({})
		end).toLogDev({ "<Example/>" }, {
			withoutStack = true
		})
	end)
	xit("should log concurrent render with suspense", function()
		local v4 = Promise.delay(0):andThen(function()
			return true
		end)

		local function Example()
			error(v4)
		end

		expect(function()
			v2.create(v.createElement(v.unstable_DebugTracingMode, nil, v.createElement(v.Suspense, {
				fallback = {}
			}, v.createElement(Example))), {
				unstable_isConcurrent = true
			})
		end).toLogDev({})
		expect(function()
			expect(v3).toFlushUntilNextPaint({})
		end).toLogDev({ "* Example suspended" }, {
			withoutStack = true
		})
		expect(function()
			v4:await()
		end).toLogDev({ "* Example resolved" }, {
			withoutStack = true
		})
	end)
	xit("should log concurrent render with CPU suspense", function()
		local function Example()
			console.log("<Example/>")
			return nil
		end

		local function Wrapper(p)
			local children = p.children
			console.log("<Wrapper/>")
			return children
		end

		expect(function()
			v2.create(
				v.createElement(
					v.unstable_DebugTracingMode,
					nil,
					v.createElement(Wrapper, nil, v.createElement(v.Suspense, {
						fallback = {},
						unstable_expectedLoadTime = 1
					}, v.createElement(Example)))
				),
				{
					unstable_isConcurrent = true
				}
			)
		end).toLogDev({})
		expect(function()
			expect(v3).toFlushUntilNextPaint({})
		end).toLogDev({ "<Wrapper/>" }, {
			withoutStack = true
		})
		expect(function()
			expect(v3).toFlushUntilNextPaint({})
		end).toLogDev({ "<Example/>" }, {
			withoutStack = true
		})
	end)
	it("should log cascading class component updates", function()
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

		expect(function()
			v2.create(v.createElement(v.unstable_DebugTracingMode, nil, v.createElement(extended)), {
				unstable_isConcurrent = true
			})
		end).toLogDev({})
		expect(function()
			expect(v3).toFlushUntilNextPaint({})
		end).toLogDev({ "* Example updated state (0b0000000000000000000000000000001)" }, {
			withoutStack = true
		})
	end)
	it("should log render phase state updates for class component", function()
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

		expect(function()
			v2.create(v.createElement(v.unstable_DebugTracingMode, nil, v.createElement(extended)), {
				unstable_isConcurrent = true
			})
		end).toLogDev({})
		expect(function()
			expect(function()
				expect(v3).toFlushUntilNextPaint({})
			end).toErrorDev("Cannot update during an existing state transition")
		end).toLogDev({
			"* Example updated state (0b0000000000000000000001000000000)",
			"* Example updated state (0b0000000000000000000001000000000)"
		}, {
			withoutStack = true
		})
	end)
	it("should log cascading layout updates", function()
		local function Example()
			local state, setState = v.useState(false)
			v.useLayoutEffect(function()
				setState(true)
			end, {})
			return state
		end

		expect(function()
			v2.create(v.createElement(v.unstable_DebugTracingMode, nil, v.createElement(Example)), {
				unstable_isConcurrent = true
			})
		end).toLogDev({})
		expect(function()
			expect(v3).toFlushUntilNextPaint({})
		end).toLogDev({ "* Example updated state (0b0000000000000000000000000000001)" }, {
			withoutStack = true
		})
	end)
	it("should log cascading passive updates", function()
		local function Example()
			local state, setState = v.useState(false)
			v.useEffect(function()
				setState(true)
			end, {})
			return state
		end

		expect(function()
			v2.act(function()
				v2.create(v.createElement(v.unstable_DebugTracingMode, nil, v.createElement(Example)), {
					unstable_isConcurrent = true
				})
			end)
		end).toLogDev({ "* Example updated state (0b0000000000000000000010000000000)" }, {
			withoutStack = true
		})
	end)
	it("should log render phase updates", function()
		local function Example()
			local state, setState = v.useState(false)

			if not state then
				setState(true)
			end

			return state
		end

		expect(function()
			v2.act(function()
				v2.create(v.createElement(v.unstable_DebugTracingMode, nil, v.createElement(Example)), {
					unstable_isConcurrent = true
				})
			end)
		end).toLogDev({
			"* Example updated state (0b0000000000000000000001000000000)",
			"* Example updated state (0b0000000000000000000001000000000)"
		}, {
			withoutStack = true
		})
	end)
	xit("should log when user code logs", function()
		local function Example()
			console.log("Hello from user code")
			return nil
		end

		expect(function()
			v2.create(v.createElement(v.unstable_DebugTracingMode, nil, v.createElement(Example)), {
				unstable_isConcurrent = true
			})
		end).toLogDev({})
		expect(function()
			expect(v3).toFlushUntilNextPaint({})
		end).toLogDev({ "Hello from user code" })
	end)
	it("should not log anything outside of a unstable_DebugTracingMode subtree", function()
		local function ExampleThatCascades()
			local state, setState = v.useState(false)
			v.useLayoutEffect(function()
				setState(true)
			end, {})
			return state
		end

		local v4 = Promise.new(function()
			return {}
		end)

		local function ExampleThatSuspends()
			error(v4)
		end

		local function Example()
			return nil
		end

		expect(function()
			v2.create(v.createElement(
				v.Fragment,
				nil,
				v.createElement(ExampleThatCascades),
				v.createElement(v.Suspense, {
					fallback = {}
				}, nil, v.createElement(ExampleThatSuspends)),
				v.createElement(v.unstable_DebugTracingMode, nil, v.createElement(Example))
			))
		end).toLogDev({})
	end)
end)