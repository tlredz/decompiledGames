local parent = script.Parent.Parent.Parent
local LuauPolyfill = require(parent.LuauPolyfill)
local object = LuauPolyfill.Object
local Shared = require(parent.Shared)
local reactFeatureFlags = Shared.ReactFeatureFlags
local v = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local xit = JestGlobals.xit
local jest = JestGlobals.jest
describe("ReactIncrementalUpdates", function()
	local function gate(fn)
		return fn(reactFeatureFlags)
	end

	beforeEach(function()
		jest.resetModules()
		local React = require(parent.React)
		v = React
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Scheduler)
		v3 = Scheduler
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function span(prop)
		return {
			type = "span",
			children = {},
			prop = prop,
			hidden = false
		}
	end

	it("applies updates in order of priority", function()
		local state = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {}
		end

		function extended.componentDidMount(object2)
			v3.unstable_yieldValue("commit")
			v2.deferredUpdates(function()
				object2:setState({
					b = "b"
				})
				object2:setState({
					c = "c"
				})
			end)
			object2:setState({
				a = "a"
			})
		end

		function extended.render(p)
			state = p.state
			return v.createElement("div")
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushAndYieldThrough({ "commit" })
		expect(state).toEqual({
			a = "a"
		})
		expect(v3).toFlushWithoutYielding()
		expect(state).toEqual({
			a = "a",
			b = "b",
			c = "c"
		})
	end)
	it("applies updates with equal priority in insertion order", function()
		local state = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {}
		end

		function extended.componentDidMount(object2)
			object2:setState({
				a = "a"
			})
			object2:setState({
				b = "b"
			})
			object2:setState({
				c = "c"
			})
		end

		function extended.render(p)
			state = p.state
			return v.createElement("div")
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushWithoutYielding()
		expect(state).toEqual({
			a = "a",
			b = "b",
			c = "c"
		})
	end)
	it("only drops updates with equal or lesser priority when replaceState is called", function()
		local v4 = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {}
		end

		function extended.componentDidMount(_)
			v3.unstable_yieldValue("componentDidMount")
		end

		function extended.componentDidUpdate(_)
			v3.unstable_yieldValue("componentDidUpdate")
		end

		function extended.render(p)
			v3.unstable_yieldValue("render")
			v4 = p
			return v.createElement("div")
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushAndYield({ "render", "componentDidMount" })
		v2.flushSync(function()
			v2.deferredUpdates(function()
				v4:setState({
					x = "x"
				})
				v4:setState({
					y = "y"
				})
			end)
			v4:setState({
				a = "a"
			})
			v4:setState({
				b = "b"
			})
			v2.deferredUpdates(function()
				v4.__updater.enqueueReplaceState(v4, {
					c = "c"
				})
				v4:setState({
					d = "d"
				})
			end)
		end)
		expect(v4.state).toEqual({
			a = "a",
			b = "b"
		})
		expect(v3).toHaveYielded({ "render", "componentDidUpdate" })
		expect(v3).toFlushAndYield({ "render", "componentDidUpdate" })
		expect(v4.state).toEqual({
			c = "c",
			d = "d"
		})
	end)
	it("can abort an update, schedule additional updates, and resume", function()
		local v4 = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {}
		end

		function extended.render(p)
			v4 = p
			local keys = object.keys(p.state)
			table.sort(keys)
			return v.createElement("span", {
				prop = table.concat(keys, "")
			})
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushWithoutYielding()

		local function createUpdate(p)
			return function()
				v3.unstable_yieldValue(p)
				return {
					[p] = p
				}
			end
		end

		local v5 = "a"
		v4:setState(function()
			v3.unstable_yieldValue(v5)
			return {
				[v5] = v5
			}
		end)
		local v6 = "b"
		v4:setState(function()
			v3.unstable_yieldValue(v6)
			return {
				[v6] = v6
			}
		end)
		local v7 = "c"
		v4:setState(function()
			v3.unstable_yieldValue(v7)
			return {
				[v7] = v7
			}
		end)
		expect(v3).toFlushAndYieldThrough({ "a", "b", "c" })
		expect(v2.getChildren()).toEqual({ span("") })
		local v8 = "d"
		v4:setState(function()
			v3.unstable_yieldValue(v8)
			return {
				[v8] = v8
			}
		end)
		v2.flushSync(function()
			local v9 = "e"
			v4:setState(function()
				v3.unstable_yieldValue(v9)
				return {
					[v9] = v9
				}
			end)
			local v10 = "f"
			v4:setState(function()
				v3.unstable_yieldValue(v10)
				return {
					[v10] = v10
				}
			end)
		end)
		local v9 = "g"
		v4:setState(function()
			v3.unstable_yieldValue(v9)
			return {
				[v9] = v9
			}
		end)
		expect(v3).toHaveYielded({ "e", "f" })
		expect(v2.getChildren()).toEqual({ span("ef") })
		expect(v3).toFlushAndYield({
			"a",
			"b",
			"c",
			"d",
			"e",
			"f",
			"g"
		})
		expect(v2.getChildren()).toEqual({ span("abcdefg") })
	end)
	it("can abort an update, schedule a replaceState, and resume", function()
		local v4 = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {}
		end

		function extended.render(p)
			v4 = p
			local keys = object.keys(p.state)
			table.sort(keys)
			return v.createElement("span", {
				prop = table.concat(keys, "")
			})
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushWithoutYielding()

		local function createUpdate(p)
			return function()
				v3.unstable_yieldValue(p)
				return {
					[p] = p
				}
			end
		end

		local v5 = "a"
		v4:setState(function()
			v3.unstable_yieldValue(v5)
			return {
				[v5] = v5
			}
		end)
		local v6 = "b"
		v4:setState(function()
			v3.unstable_yieldValue(v6)
			return {
				[v6] = v6
			}
		end)
		local v7 = "c"
		v4:setState(function()
			v3.unstable_yieldValue(v7)
			return {
				[v7] = v7
			}
		end)
		expect(v3).toFlushAndYieldThrough({ "a", "b", "c" })
		expect(v2.getChildren()).toEqual({ span("") })
		local v8 = "d"
		v4:setState(function()
			v3.unstable_yieldValue(v8)
			return {
				[v8] = v8
			}
		end)
		v2.flushSync(function()
			local v9 = "e"
			v4:setState(function()
				v3.unstable_yieldValue(v9)
				return {
					[v9] = v9
				}
			end)
			local v10 = "f"
			v4.__updater.enqueueReplaceState(v4, function()
				v3.unstable_yieldValue(v10)
				return {
					[v10] = v10
				}
			end)
		end)
		local v9 = "g"
		v4:setState(function()
			v3.unstable_yieldValue(v9)
			return {
				[v9] = v9
			}
		end)
		expect(v3).toHaveYielded({ "e", "f" })
		expect(v2.getChildren()).toEqual({ span("f") })
		expect(v3).toFlushAndYield({
			"a",
			"b",
			"c",
			"d",
			"e",
			"f",
			"g"
		})
		expect(v2.getChildren()).toEqual({ span("fg") })
	end)
	it("can abort an update, schedule a replaceState, and resume many times", function()
		local v4 = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {}
		end

		function extended.render(p)
			v4 = p
			local keys = object.keys(p.state)
			table.sort(keys)
			return v.createElement("span", {
				prop = table.concat(keys, "")
			})
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushWithoutYielding()

		local function createUpdate(p)
			return function()
				v3.unstable_yieldValue(p)
				return {
					[p] = p
				}
			end
		end

		for _ = 1, 500 do
			local v6 = "a"
			v4:setState(function()
				v3.unstable_yieldValue(v6)
				return {
					[v6] = v6
				}
			end)
			local v8 = "b"
			v4:setState(function()
				v3.unstable_yieldValue(v8)
				return {
					[v8] = v8
				}
			end)
			local v10 = "c"
			v4:setState(function()
				v3.unstable_yieldValue(v10)
				return {
					[v10] = v10
				}
			end)
		end

		expect(v2.getChildren()).toEqual({ span("") })
		local v5 = "d"
		v4:setState(function()
			v3.unstable_yieldValue(v5)
			return {
				[v5] = v5
			}
		end)
		v2.flushSync(function()
			local v6 = "e"
			v4:setState(function()
				v3.unstable_yieldValue(v6)
				return {
					[v6] = v6
				}
			end)
			local v7 = "f"
			v4.__updater.enqueueReplaceState(v4, function()
				v3.unstable_yieldValue(v7)
				return {
					[v7] = v7
				}
			end)
		end)
		local v6 = "g"
		v4:setState(function()
			v3.unstable_yieldValue(v6)
			return {
				[v6] = v6
			}
		end)
		expect(v3).toHaveYielded({ "e", "f" })
		expect(v2.getChildren()).toEqual({ span("f") })
		v2.flushSync(function()
			local v7 = "g"
			v4:setState(function()
				v3.unstable_yieldValue(v7)
				return {
					[v7] = v7
				}
			end)
		end)
		expect(v2.getChildren()).toEqual({ span("fg") })
	end)
	it("passes accumulation of previous updates to replaceState updater function", function()
		local v4 = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {}
		end

		function extended.render(p)
			v4 = p
			return v.createElement("span")
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushWithoutYielding()
		v4:setState({
			a = "a"
		})
		v4:setState({
			b = "b"
		})
		v4.__updater.enqueueReplaceState(v4, function(previousState)
			return {
				previousState = previousState
			}
		end)
		expect(v3).toFlushWithoutYielding()
		expect(v4.state.previousState).toEqual({
			a = "a",
			b = "b"
		})
	end)
	it("does not call callbacks that are scheduled by another callback until a later commit", function()
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {}
		end

		function extended.componentDidMount(object2)
			v3.unstable_yieldValue("did mount")
			object2:setState({
				a = "a"
			}, function()
				v3.unstable_yieldValue("callback a")
				object2:setState({
					b = "b"
				}, function()
					v3.unstable_yieldValue("callback b")
				end)
			end)
		end

		function extended.render(_)
			v3.unstable_yieldValue("render")
			return v.createElement("div")
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushAndYield({
			"render",
			"did mount",
			"render",
			"callback a",
			"render",
			"callback b"
		})
	end)
	it("gives setState during reconciliation the same priority as whatever level is currently reconciling", function()
		local v4 = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {}
		end

		function extended.UNSAFE_componentWillReceiveProps(object2)
			v3.unstable_yieldValue("componentWillReceiveProps")
			object2:setState({
				b = "b"
			})
		end

		function extended.render(p)
			v3.unstable_yieldValue("render")
			v4 = p
			return v.createElement("div")
		end

		v2.render(v.createElement(extended))
		expect(function()
			return expect(v3).toFlushAndYield({ "render" })
		end).toErrorDev("Using UNSAFE_componentWillReceiveProps in strict mode is not recommended", {
			withoutStack = true
		})
		v2.flushSync(function()
			v4:setState({
				a = "a"
			})
			v2.render(v.createElement(extended))
			return "test"
		end)
		expect(v4.state).toEqual({
			a = "a",
			b = "b"
		})
		expect(v3).toHaveYielded({ "componentWillReceiveProps", "render" })
	end)
	it("updates triggered from inside a class setState updater", function()
		local v4 = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {}
		end

		function extended.render(p)
			v3.unstable_yieldValue("render")
			v4 = p
			return v.createElement("div")
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushAndYield({ "render" })
		v4:setState(function()
			v3.unstable_yieldValue("setState updater")
			v4:setState({
				b = "b"
			})
			return {
				a = "a"
			}
		end)
		expect(function()
			return expect(v3).toFlushAndYield(gate(function(p)
				if p.deferRenderPhaseUpdateToNextBatch then
					return { "setState updater", "render", "render" }
				end

				return { "setState updater", "render" }
			end))
		end).toErrorDev("An update (setState, replaceState, or forceUpdate) was scheduled from inside an update function. Update functions should be pure, with zero side-effects. Consider using componentDidUpdate or a callback.")
		expect(v4.state).toEqual({
			a = "a",
			b = "b"
		})
		v4:setState(function()
			v4:setState({
				a = "a"
			})
			return {
				b = "b"
			}
		end)
		expect(v3).toFlushAndYield(gate(function(p)
			if p.deferRenderPhaseUpdateToNextBatch then
				return { "render", "render" }
			end

			return { "render" }
		end))
	end)
	it("getDerivedStateFromProps should update base state of updateQueue (based on product bug)", function()
		local v4 = nil
		local v5 = nil
		local extended = v.Component:extend("Bar")

		function extended.render(p)
			v5 = p
			return nil
		end

		local extended2 = v.Component:extend("Foo")

		function extended2:init()
			self.state = {
				value = "initial state"
			}
		end

		function extended2.getDerivedStateFromProps(_)
			return {
				value = "derived state"
			}
		end

		function extended2.render(p)
			v4 = p
			return v.createElement(v.Fragment, nil, v.createElement("span", {
				prop = p.state.value
			}), v.createElement(extended))
		end

		v2.flushSync(function()
			v2.render(v.createElement(extended2))
		end)
		expect(v2.getChildren()).toEqual({ span("derived state") })
		v2.flushSync(function()
			v2.render(v.createElement(extended2))
			v4:setState({
				value = "update state"
			}, function() end)
		end)
		expect(v2.getChildren()).toEqual({ span("derived state") })
		v2.flushSync(function()
			v5:setState({})
		end)
		expect(v2.getChildren()).toEqual({ span("derived state") })
	end)
	it("regression: does not expire soon due to layout effects in the last batch", function()
		local useState = v.useState
		local useLayoutEffect = v.useLayoutEffect
		local v4 = nil

		local function App()
			local state, setState = useState(0)
			v4 = setState
			v3.unstable_yieldValue("Render: " .. state)
			useLayoutEffect(function()
				v4(function(p)
					return p + 1
				end)
				v3.unstable_yieldValue("Commit: " .. state)
			end, {})
			return nil
		end

		v2.act(function()
			v2.render(v.createElement(App))
			expect(v3).toFlushExpired({})
			expect(v3).toFlushAndYield({ "Render: 0", "Commit: 0", "Render: 1" })
			v3.unstable_advanceTime(10000)
			v4(2)
			expect(v3).toFlushExpired({})
		end)
	end)
	it("regression: does not expire soon due to previous flushSync", function()
		local function Text(p)
			local text = p.text
			v3.unstable_yieldValue(text)
			return text
		end

		v2.flushSync(function()
			v2.render(v.createElement(Text, {
				text = "A"
			}))
		end)
		expect(v3).toHaveYielded({ "A" })
		v3.unstable_advanceTime(10000)
		v2.render(v.createElement(Text, {
			text = "B"
		}))
		expect(v3).toFlushExpired({})
	end)
	it("regression: does not expire soon due to previous expired work", function()
		local function Text(p)
			local text = p.text
			v3.unstable_yieldValue(text)
			return text
		end

		v2.render(v.createElement(Text, {
			text = "A"
		}))
		v3.unstable_advanceTime(10000)
		expect(v3).toFlushExpired({ "A" })
		v3.unstable_advanceTime(10000)
		v2.render(v.createElement(Text, {
			text = "B"
		}))
		expect(v3).toFlushExpired({})
	end)
	it("when rebasing, does not exclude updates that were already committed, regardless of priority", function()
		local useState = v.useState
		local useLayoutEffect = v.useLayoutEffect
		local fn

		local function App()
			local state, setState = useState("")

			fn = function(p)
				return setState(function(p2)
					return p2 .. p
				end)
			end

			useLayoutEffect(function()
				v3.unstable_yieldValue("Committed: " .. state)

				if state == "B" then
					v2.unstable_runWithPriority(10, function()
						return v3.unstable_runWithPriority(v3.unstable_UserBlockingPriority, function()
							fn("C")
						end)
					end)
					setState(function(p)
						return p .. "D"
					end)
				end
			end, { state })
			return state
		end

		local root = v2.createRoot()
		v2.act(function()
			root.render(v.createElement(App))
		end)
		expect(v3).toHaveYielded({ "Committed: " })
		expect(root).toMatchRenderedOutput("")
		v2.act(function()
			fn("A")
			v2.unstable_runWithPriority(10, function()
				return v3.unstable_runWithPriority(v3.unstable_UserBlockingPriority, function()
					fn("B")
				end)
			end)
		end)
		expect(v3).toHaveYielded({
			"Committed: B",
			"Committed: BD",
			"Committed: BCD",
			"Committed: ABCD"
		})
		expect(root).toMatchRenderedOutput("ABCD")
	end)
	xit(
		"when rebasing, does not exclude updates that were already committed, regardless of priority (classes)",
		function()
			local v4 = nil
			local extended = v.Component:extend("App")

			function extended:init()
				self.state = {
					log = ""
				}
			end

			function extended:pushToLog(p)
				self:setState(function(p2)
					return {
						log = p2.state.log .. p
					}
				end)
			end

			function extended:componentDidUpdate()
				v3.unstable_yieldValue("Committed: " .. self.state.log)

				if self.state.log == "B" then
					v2.unstable_runWithPriority(10, function()
						v3.unstable_runWithPriority(v3.unstable_UserBlockingPriority, function()
							self:pushToLog("C")
						end)
					end)
					self:pushToLog("D")
				end
			end

			function extended.render(p)
				v4 = p
				return p.state.log
			end

			local root = v2.createRoot()
			local element = v.createElement(extended)
			v2.act(function()
				root.render(element)
			end)
			expect(v3).toHaveYielded({})
			expect(root).toMatchRenderedOutput("")
			v2.act(function()
				v4:pushToLog("A")
				v2.unstable_runWithPriority(10, function()
					v3.unstable_runWithPriority(v3.unstable_UserBlockingPriority, function()
						v4:pushToLog("B")
					end)
				end)
			end)
			expect(v3).toHaveYielded({
				"Committed: B",
				"Committed: BD",
				"Committed: BCD",
				"Committed: ABCD"
			})
			expect(root).toMatchRenderedOutput("ABCD")
		end
	)
	it("base state of update queue is initialized to its fiber's memoized state", function()
		local v4 = nil
		local extended = v.Component:extend("App")

		function extended:init()
			self.state = {
				prevProp = "A",
				count = 0
			}
		end

		function extended.getDerivedStateFromProps(p, p2)
			if p.prop == p2.prevProp then
				return nil
			end

			return {
				prevProp = p.prop,
				count = p2.count + 100
			}
		end

		function extended.render(p)
			v4 = p
			return p.state.count
		end

		local root = v2.createRoot()
		v2.act(function()
			root.render(v.createElement(extended, {
				prop = "A"
			}))
		end)
		expect(root).toMatchRenderedOutput("0")
		v2.act(function()
			root.render(v.createElement(extended, {
				prop = "B"
			}))
		end)
		expect(root).toMatchRenderedOutput("100")
		v2.act(function()
			root.render(v.createElement(extended, {
				prop = "A"
			}))
			v4:setState(function(p)
				return {
					count = p.count + 1
				}
			end)
		end)
		expect(root).toMatchRenderedOutput("201")
	end)
end)