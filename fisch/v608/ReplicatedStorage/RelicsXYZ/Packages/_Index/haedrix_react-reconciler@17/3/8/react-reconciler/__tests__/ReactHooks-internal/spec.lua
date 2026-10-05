local v = nil
local reactFeatureFlags = nil
local v2 = nil
local v3 = nil
local unstable_concurrentAct = nil
local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local jest = JestGlobals.jest
local it = JestGlobals.it
local xit = JestGlobals.xit
local describe = JestGlobals.describe
describe("ReactHooks", function()
	local Promise = require(parent.Promise)
	local LuauPolyfill = require(parent.LuauPolyfill)
	local array = LuauPolyfill.Array
	local error2 = LuauPolyfill.Error
	beforeEach(function()
		jest.resetModules()
		local Shared = require(parent.Shared)
		reactFeatureFlags = Shared.ReactFeatureFlags
		local React = require(parent.React)
		v = React
		local ReactTestRenderer = require(parent.Dev.ReactTestRenderer)
		v2 = ReactTestRenderer
		local Scheduler = require(parent.Scheduler)
		v3 = Scheduler
		unstable_concurrentAct = v2.unstable_concurrentAct
	end)

	if ReactGlobals.__DEV__ then
		it("useDebugValue throws when used in a class component", function()
			local extended = v.Component:extend("Example")

			function extended.render(_)
				v.useDebugValue("abc")
				return nil
			end

			expect(function()
				v2.create(v.createElement(extended))
			end).toThrow([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
		end)
	end

	it("bails out in the render phase if all of the state is the same", function()
		local useState = v.useState
		local useLayoutEffect = v.useLayoutEffect

		local function Child(p)
			local text = p.text
			v3.unstable_yieldValue("Child: " .. tostring(text))
			return text
		end

		local v4 = nil
		local v5 = nil

		local function Parent()
			local state, setState = useState(0)
			v4 = setState
			local state2, setState2 = useState(0)
			v5 = setState2
			local text = string.format("%s, %s", tostring(state), (tostring(state2)))
			v3.unstable_yieldValue(string.format("Parent: %s", text))
			useLayoutEffect(function()
				v3.unstable_yieldValue(string.format("Effect: %s", text))
			end)
			return v.createElement(Child, {
				text = text
			})
		end

		local v6 = v2.create(nil, {
			unstable_isConcurrent = true
		})
		v6.update(v.createElement(Parent))
		expect(v3).toFlushAndYield({ "Parent: 0, 0", "Child: 0, 0", "Effect: 0, 0" })
		expect(v6).toMatchRenderedOutput("0, 0")
		unstable_concurrentAct(function()
			v4(1)
			v5(1)
		end)
		expect(v3).toHaveYielded({ "Parent: 1, 1", "Child: 1, 1", "Effect: 1, 1" })
		unstable_concurrentAct(function()
			return v4(1)
		end)
		expect(v3).toHaveYielded({ "Parent: 1, 1" })
		unstable_concurrentAct(function()
			v4(1)
			v5(2)
		end)
		expect(v3).toHaveYielded({ "Parent: 1, 2", "Child: 1, 2", "Effect: 1, 2" })
		unstable_concurrentAct(function()
			v4(9)
			v5(3)
			v4(4)
			v5(7)
			v4(1)
			v5(2)
		end)
		expect(v3).toHaveYielded({ "Parent: 1, 2" })
		unstable_concurrentAct(function()
			v4(-0)
			v5((0 / 0))
		end)
		expect(v3).toHaveYielded({ "Parent: -0, nan", "Child: -0, nan", "Effect: -0, nan" })
		unstable_concurrentAct(function()
			v4(-0)
			v5((0 / 0))
			v5(1e999)
			v5((0 / 0))
		end)
		expect(v3).toHaveYielded({ "Parent: -0, nan" })
		unstable_concurrentAct(function()
			v4(0)
		end)
		expect(v3).toHaveYielded({ "Parent: 0, nan", "Child: 0, nan", "Effect: 0, nan" })
	end)
	it("bails out in render phase if all the state is the same and props bail out with memo", function()
		local useState = v.useState
		local memo = v.memo

		local function Child(p)
			local text = p.text
			v3.unstable_yieldValue("Child: " .. tostring(text))
			return text
		end

		local v4 = nil
		local v5 = nil

		local function Parent(p)
			local theme = p.theme
			local state, setState = useState(0)
			v4 = setState
			local state2, setState2 = useState(0)
			v5 = setState2
			local text = string.format("%s, %s (%s)", tostring(state), tostring(state2), theme)
			v3.unstable_yieldValue(string.format("Parent: %s", text))
			return v.createElement(Child, {
				text = text
			})
		end

		local v6 = memo(Parent)
		local v7 = v2.create(nil, {
			unstable_isConcurrent = true
		})
		v7.update(v.createElement(v6, {
			theme = "light"
		}))
		expect(v3).toFlushAndYield({ "Parent: 0, 0 (light)", "Child: 0, 0 (light)" })
		expect(v7).toMatchRenderedOutput("0, 0 (light)")
		unstable_concurrentAct(function()
			v4(1)
			v5(1)
		end)
		expect(v3).toHaveYielded({ "Parent: 1, 1 (light)", "Child: 1, 1 (light)" })
		unstable_concurrentAct(function()
			return v4(1)
		end)
		expect(v3).toHaveYielded({ "Parent: 1, 1 (light)" })
		unstable_concurrentAct(function()
			v4(1)
			v5(2)
		end)
		expect(v3).toHaveYielded({ "Parent: 1, 2 (light)", "Child: 1, 2 (light)" })
		unstable_concurrentAct(function()
			v4(1)
			v5(2)
			v7.update(v.createElement(v6, {
				theme = "dark"
			}))
		end)
		expect(v3).toHaveYielded({ "Parent: 1, 2 (dark)", "Child: 1, 2 (dark)" })
		unstable_concurrentAct(function()
			v4(1)
			v5(2)
			v7.update(v.createElement(v6, {
				theme = "dark"
			}))
		end)
		expect(v3).toHaveYielded({ "Parent: 1, 2 (dark)" })
	end)
	it("warns about setState second argument", function()
		local useState = v.useState
		local v4 = nil

		local function Counter()
			local state, setState = useState(0)
			v4 = setState
			v3.unstable_yieldValue(string.format("Count: %s", (tostring(state))))
			return state
		end

		local v5 = v2.create(nil, {
			unstable_isConcurrent = true
		})
		v5.update(v.createElement(Counter))
		expect(v3).toFlushAndYield({ "Count: 0" })
		expect(v5).toMatchRenderedOutput("0")
		expect(function()
			unstable_concurrentAct(function()
				return v4(1, function()
					error(error2.new("Expected to ignore the callback."))
				end)
			end)
		end).toErrorDev("State updates from the useState() and useReducer() Hooks don't support the second callback argument. To execute a side effect after rendering, declare it in the component body with useEffect().", {
			withoutStack = true
		})
		expect(v3).toHaveYielded({ "Count: 1" })
		expect(v5).toMatchRenderedOutput("1")
	end)
	it("warns about dispatch second argument", function()
		local useReducer = v.useReducer
		local v4 = nil

		local function Counter()
			local v5, v6 = useReducer(function(_, p)
				return p
			end, 0)
			v4 = v6
			v3.unstable_yieldValue(string.format("Count: %s", v5))
			return v5
		end

		local v5 = v2.create(nil, {
			unstable_isConcurrent = true
		})
		v5.update(v.createElement(Counter))
		expect(v3).toFlushAndYield({ "Count: 0" })
		expect(v5).toMatchRenderedOutput("0")
		expect(function()
			unstable_concurrentAct(function()
				return v4(1, function()
					error(error2.new("Expected to ignore the callback."))
				end)
			end)
		end).toErrorDev("State updates from the useState() and useReducer() Hooks don't support the second callback argument. To execute a side effect after rendering, declare it in the component body with useEffect().", {
			withoutStack = true
		})
		expect(v3).toHaveYielded({ "Count: 1" })
		expect(v5).toMatchRenderedOutput("1")
	end)
	it("never bails out if context has changed", function()
		local useState = v.useState
		local useLayoutEffect = v.useLayoutEffect
		local useContext = v.useContext
		local context = v.createContext("light")
		local v4 = nil

		local function ThemeProvider(p)
			local children = p.children
			local state, setState = useState("light")
			v3.unstable_yieldValue("Theme: " .. tostring(state))
			v4 = setState
			return v.createElement(context.Provider, {
				value = state
			}, children)
		end

		local function Child(p)
			local text = p.text
			v3.unstable_yieldValue("Child: " .. tostring(text))
			return text
		end

		local v5 = nil

		local function Parent()
			local state, setState = useState(0)
			v5 = setState
			local v6 = useContext(context)
			local text = string.format("%d (%s)", state, v6)
			v3.unstable_yieldValue(string.format("Parent: %s", text))
			useLayoutEffect(function()
				v3.unstable_yieldValue(string.format("Effect: %s", text))
			end)
			return v.createElement(Child, {
				text = text
			})
		end

		local v6 = v2.create(nil, {
			unstable_isConcurrent = true
		})
		unstable_concurrentAct(function()
			v6.update(v.createElement(ThemeProvider, nil, v.createElement(Parent)))
		end)
		expect(v3).toHaveYielded({
			"Theme: light",
			"Parent: 0 (light)",
			"Child: 0 (light)",
			"Effect: 0 (light)"
		})
		expect(v6).toMatchRenderedOutput("0 (light)")
		v4("light")
		expect(v3).toFlushAndYield({})
		expect(v6).toMatchRenderedOutput("0 (light)")
		unstable_concurrentAct(function()
			return v5(1)
		end)
		expect(v3).toHaveYielded({ "Parent: 1 (light)", "Child: 1 (light)", "Effect: 1 (light)" })
		expect(v6).toMatchRenderedOutput("1 (light)")
		unstable_concurrentAct(function()
			return v5(1)
		end)
		expect(v3).toHaveYielded({ "Parent: 1 (light)" })
		expect(v6).toMatchRenderedOutput("1 (light)")
		unstable_concurrentAct(function()
			v5(1)
			v4("dark")
		end)
		expect(v3).toHaveYielded({
			"Theme: dark",
			"Parent: 1 (dark)",
			"Child: 1 (dark)",
			"Effect: 1 (dark)"
		})
		expect(v6).toMatchRenderedOutput("1 (dark)")
	end)
	it("can bail out without calling render phase (as an optimization) if queue is known to be empty", function()
		local useState = v.useState
		local useLayoutEffect = v.useLayoutEffect

		local function Child(p)
			local text = p.text
			v3.unstable_yieldValue("Child: " .. tostring(text))
			return text
		end

		local v4 = nil

		local function Parent()
			local state, setState = useState(0)
			v4 = setState
			v3.unstable_yieldValue("Parent: " .. tostring(state))
			useLayoutEffect(function()
				v3.unstable_yieldValue("Effect: " .. tostring(state))
			end)
			return v.createElement(Child, {
				text = state
			})
		end

		local v5 = v2.create(nil, {
			unstable_isConcurrent = true
		})
		v5.update(v.createElement(Parent))
		expect(v3).toFlushAndYield({ "Parent: 0", "Child: 0", "Effect: 0" })
		expect(v5).toMatchRenderedOutput("0")
		unstable_concurrentAct(function()
			return v4(1)
		end)
		expect(v3).toHaveYielded({ "Parent: 1", "Child: 1", "Effect: 1" })
		expect(v5).toMatchRenderedOutput("1")
		unstable_concurrentAct(function()
			return v4(1)
		end)
		expect(v3).toHaveYielded({ "Parent: 1" })
		expect(v5).toMatchRenderedOutput("1")
		unstable_concurrentAct(function()
			return v4(1)
		end)
		expect(v3).toFlushAndYield({})
		expect(v5).toMatchRenderedOutput("1")
		unstable_concurrentAct(function()
			return v4(2)
		end)
		expect(v3).toHaveYielded({ "Parent: 2", "Child: 2", "Effect: 2" })
		expect(v5).toMatchRenderedOutput("2")
		unstable_concurrentAct(function()
			v4(0)
		end)
		expect(v3).toHaveYielded({ "Parent: 0", "Child: 0", "Effect: 0" })
		expect(v5).toMatchRenderedOutput("0")
		unstable_concurrentAct(function()
			v4(0)
		end)
		expect(v3).toHaveYielded({ "Parent: 0" })
		expect(v5).toMatchRenderedOutput("0")
		unstable_concurrentAct(function()
			v4(0)
		end)
		expect(v3).toFlushAndYield({})
		expect(v5).toMatchRenderedOutput("0")
		unstable_concurrentAct(function()
			v4(-0)
		end)
		expect(v3).toHaveYielded({ "Parent: -0", "Child: -0", "Effect: -0" })
		expect(v5).toMatchRenderedOutput("-0")
	end)
	it("bails out multiple times in a row without entering render phase", function()
		local useState = v.useState

		local function Child(p)
			local text = p.text
			v3.unstable_yieldValue("Child: " .. tostring(text))
			return text
		end

		local v4 = nil

		local function Parent()
			local state, setState = useState(0)
			v4 = setState
			v3.unstable_yieldValue("Parent: " .. tostring(state))
			return v.createElement(Child, {
				text = state
			})
		end

		local v5 = v2.create(nil, {
			unstable_isConcurrent = true
		})
		v5.update(v.createElement(Parent))
		expect(v3).toFlushAndYield({ "Parent: 0", "Child: 0" })
		expect(v5).toMatchRenderedOutput("0")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update(p)
			v4(function(p2)
				v3.unstable_yieldValue(string.format("Compute state (%s -> %s)", tostring(p2), (tostring(p))))
				return p
			end)
		end

		v2.unstable_batchedUpdates(function()
			update(0) -- equivalent call inferred; original call site unknown
			update(0) -- equivalent call inferred; original call site unknown
			update(0) -- equivalent call inferred; original call site unknown
			update(1) -- equivalent call inferred; original call site unknown
			update(2) -- equivalent call inferred; original call site unknown
			update(3) -- equivalent call inferred; original call site unknown
		end)
		expect(v3).toHaveYielded({
			"Compute state (0 -> 0)",
			"Compute state (0 -> 0)",
			"Compute state (0 -> 0)",
			"Compute state (0 -> 1)"
		})
		expect(v3).toFlushAndYield({
			"Compute state (1 -> 2)",
			"Compute state (2 -> 3)",
			"Parent: 3",
			"Child: 3"
		})
		expect(v5).toMatchRenderedOutput("3")
	end)
	it("can rebase on top of a previously skipped update", function()
		local useState = v.useState

		local function Child(p)
			local text = p.text
			v3.unstable_yieldValue("Child: " .. tostring(text))
			return text
		end

		local v4 = nil

		local function Parent()
			local state, setState = useState(1)
			v4 = setState
			v3.unstable_yieldValue("Parent: " .. tostring(state))
			return v.createElement(Child, {
				text = state
			})
		end

		local v5 = v2.create(nil, {
			unstable_isConcurrent = true
		})
		v5.update(v.createElement(Parent))
		expect(v3).toFlushAndYield({ "Parent: 1", "Child: 1" })
		expect(v5).toMatchRenderedOutput("1")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update(fn)
			v4(function(p)
				local v6 = fn(p)
				v3.unstable_yieldValue(string.format("Compute state (%s -> %s)", tostring(p), (tostring(v6))))
				return v6
			end)
		end

		v2.unstable_batchedUpdates(function()
			return update(function(p)
				return p * 100
			end)
		end)
		expect(v3).toHaveYielded({ "Compute state (1 -> 100)" })
		v5.unstable_flushSync(function()
			local function fn(p)
				return p + 5
			end

			update(fn) -- equivalent call inferred; original call site unknown
		end)
		expect(v3).toHaveYielded({ "Compute state (1 -> 6)", "Parent: 6", "Child: 6" })
		expect(v5).toMatchRenderedOutput("6")
		expect(v3).toFlushAndYield({ "Compute state (100 -> 105)", "Parent: 105", "Child: 105" })
		expect(v5).toMatchRenderedOutput("105")
	end)
	xit("warns about variable number of dependencies", function()
		local useLayoutEffect = v.useLayoutEffect

		local function App(p)
			useLayoutEffect(function()
				v3.unstable_yieldValue("Did commit: " .. tostring(array.join(p.dependencies, ", ")))
			end, p.dependencies)
			return p.dependencies
		end

		local v4 = v2.create(v.createElement(App, {
			dependencies = { "A" }
		}))
		expect(v3).toHaveYielded({ "Did commit: A" })
		expect(function()
			v4.update(v.createElement(App, {
				dependencies = { "A", "B" }
			}))
		end).toErrorDev({ [[
Warning: The final argument passed to useLayoutEffect changed size between renders. The order and size of this array must remain constant.

Previous: ["A"]
Incoming: ["A", "B"]
]] })
	end)
	it("warns if switching from dependencies to no dependencies", function()
		local useMemo = v.useMemo

		local function App(p)
			local text = p.text
			local hasDeps = p.hasDeps
			return (useMemo(function()
				v3.unstable_yieldValue("Compute")
				return string.upper(text)
			end, not hasDeps and { text } or nil))
		end

		local v4 = v2.create(nil)
		v4.update(v.createElement(App, {
			text = "Hello",
			hasDeps = true
		}))
		expect(v3).toHaveYielded({ "Compute" })
		expect(v4).toMatchRenderedOutput("HELLO")
		expect(function()
			v4.update(v.createElement(App, {
				text = "Hello",
				hasDeps = false
			}))
		end).toErrorDev({ "Warning: useMemo received a final argument during this render, but not during the previous render. Even though the final argument is optional, its type cannot change between renders." })
	end)
	it("warns if deps is not an array", function()
		local useEffect = v.useEffect
		local useLayoutEffect = v.useLayoutEffect
		local useMemo = v.useMemo
		local useCallback = v.useCallback

		local function App(p)
			useEffect(function() end, p.deps)
			useLayoutEffect(function() end, p.deps)
			useMemo(function()
				return nil
			end, p.deps)
			useCallback(function() end, p.deps)
			return nil
		end

		expect(function()
			unstable_concurrentAct(function()
				v2.create(v.createElement(App, {
					deps = "hello"
				}))
			end)
		end).toErrorDev({
			"Warning: useEffect received a final argument that is not an array (instead, received `string`). When specified, the final argument must be an array.",
			"Warning: useLayoutEffect received a final argument that is not an array (instead, received `string`). When specified, the final argument must be an array.",
			"Warning: useMemo received a final argument that is not an array (instead, received `string`). When specified, the final argument must be an array.",
			"Warning: useCallback received a final argument that is not an array (instead, received `string`). When specified, the final argument must be an array."
		})
		expect(function()
			unstable_concurrentAct(function()
				v2.create(v.createElement(App, {
					deps = 100500
				}))
			end)
		end).toErrorDev({
			"Warning: useEffect received a final argument that is not an array (instead, received `number`). When specified, the final argument must be an array.",
			"Warning: useLayoutEffect received a final argument that is not an array (instead, received `number`). When specified, the final argument must be an array.",
			"Warning: useMemo received a final argument that is not an array (instead, received `number`). When specified, the final argument must be an array.",
			"Warning: useCallback received a final argument that is not an array (instead, received `number`). When specified, the final argument must be an array."
		})
		expect(function()
			unstable_concurrentAct(function()
				v2.create(v.createElement(App, {
					deps = {
						notempty = true
					}
				}))
			end)
		end).toErrorDev({
			"Warning: useEffect received a final argument that is not an array (instead, received `table`). When specified, the final argument must be an array.",
			"Warning: useLayoutEffect received a final argument that is not an array (instead, received `table`). When specified, the final argument must be an array.",
			"Warning: useMemo received a final argument that is not an array (instead, received `table`). When specified, the final argument must be an array.",
			"Warning: useCallback received a final argument that is not an array (instead, received `table`). When specified, the final argument must be an array."
		})
		unstable_concurrentAct(function()
			v2.create(v.createElement(App, {
				deps = {}
			}))
			v2.create(v.createElement(App, {
				deps = nil
			}))
			v2.create(v.createElement(App, {
				deps = nil
			}))
		end)
	end)
	it("does not warn for sparse dep arrays", function()
		local useEffect = v.useEffect
		local useLayoutEffect = v.useLayoutEffect
		local useMemo = v.useMemo
		local useCallback = v.useCallback

		local function App(p)
			useEffect(function() end, p.deps)
			useLayoutEffect(function() end, p.deps)
			useMemo(function()
				return nil
			end, p.deps)
			useCallback(function() end, p.deps)
			return nil
		end

		expect(function()
			unstable_concurrentAct(function()
				v2.create(v.createElement(App, {
					deps = { nil, "world", "!" }
				}))
			end)
		end).toErrorDev({})
		expect(function()
			unstable_concurrentAct(function()
				v2.create(v.createElement(App, {
					deps = { "hello", "world", "!" }
				}))
			end)
		end).toErrorDev({})
		expect(function()
			unstable_concurrentAct(function()
				v2.create(v.createElement(App, {
					deps = { "hello", nil, "!" }
				}))
			end)
		end).toErrorDev({})
	end)
	xit("warns if deps is not an array for useImperativeHandle", function()
		local useImperativeHandle = v.useImperativeHandle
		local forwardRef = v.forwardRef(function(p, p2)
			useImperativeHandle(p2, function()
				return nil
			end, p.deps)
			return nil
		end)
		expect(function()
			v2.create(v.createElement(forwardRef, {
				deps = "hello"
			}))
		end).toErrorDev({ "Warning: useImperativeHandle received a final argument that is not an array (instead, received `string`). When specified, the final argument must be an array." }, {
			withoutStack = true
		})
		v2.create(v.createElement(forwardRef, {
			deps = {}
		}))
		v2.create(v.createElement(forwardRef, {
			deps = nil
		}))
		v2.create(v.createElement(forwardRef, {
			deps = nil
		}))
	end)
	it("does not forget render phase useState updates inside an effect", function()
		local useState = v.useState
		local useEffect = v.useEffect

		local function Counter()
			local state, setState = useState(0)

			if state == 0 then
				setState(function(p)
					return p + 1
				end)
				setState(function(p)
					return p + 1
				end)
			end

			useEffect(function()
				setState(function(p)
					return p + 1
				end)
				setState(function(p)
					return p + 1
				end)
			end, {})
			return state
		end

		local v4 = v2.create(nil)
		unstable_concurrentAct(function()
			v4.update(v.createElement(Counter))
		end)
		expect(v4).toMatchRenderedOutput("4")
	end)
	it("does not forget render phase useReducer updates inside an effect with hoisted reducer", function()
		local useReducer = v.useReducer
		local useEffect = v.useEffect

		local function reducer(p: number, _: nil)
			return p + 1
		end

		local function Counter()
			local v4, v5 = useReducer(reducer, 0)

			if v4 == 0 then
				v5()
				v5()
			end

			useEffect(function()
				v5()
				v5()
			end, {})
			return v4
		end

		local v4 = v2.create(nil)
		unstable_concurrentAct(function()
			v4.update(v.createElement(Counter))
		end)
		expect(v4).toMatchRenderedOutput("4")
	end)
	it("does not forget render phase useReducer updates inside an effect with inline reducer", function()
		local useReducer = v.useReducer
		local useEffect = v.useEffect

		local function Counter()
			local v4, v5 = useReducer(function(p: number, _: nil)
				return p + 1
			end, 0)

			if v4 == 0 then
				v5()
				v5()
			end

			useEffect(function()
				v5()
				v5()
			end, {})
			return v4
		end

		local v4 = v2.create(nil)
		unstable_concurrentAct(function()
			v4.update(v.createElement(Counter))
		end)
		expect(v4).toMatchRenderedOutput("4")
	end)
	it("warns for bad useImperativeHandle first arg", function()
		local useImperativeHandle = v.useImperativeHandle

		local function App()
			useImperativeHandle({
				focus = function(_) end
			})
			return nil
		end

		expect(function()
			expect(function()
				v2.create(v.createElement(App))
			end).toThrow("attempt to call a nil value")
		end).toErrorDev({
			"Expected useImperativeHandle() first argument to either be a ref callback or React.createRef() object. Instead received: an object with keys {focus}.",
			"Warning: Expected useImperativeHandle() second argument to be a function that creates a handle. Instead received: nil."
		})
	end)
	it("warns for bad useImperativeHandle second arg", function()
		local useImperativeHandle = v.useImperativeHandle
		local forwardRef = v.forwardRef(function(_, p)
			useImperativeHandle(p, {
				focus = function(_) end
			})
			return nil
		end)
		expect(function()
			v2.create(v.createElement(forwardRef))
		end).toErrorDev({ "Expected useImperativeHandle() second argument to be a function that creates a handle. Instead received: table." })
	end)
	it("throws when calling hooks inside .memo's compare function", function()
		local useState = v.useState

		local function App()
			useState(0)
			return nil
		end

		local memo = v.memo(App, function()
			useState(0)
			return false
		end)
		local v4 = v2.create(v.createElement(memo))
		expect(function()
			return v4.update(v.createElement(memo))
		end).toThrow([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
		expect(function()
			return v4.update(v.createElement(memo))
		end).never.toThrow([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
		expect(function()
			return v4.update(v.createElement(memo))
		end).toThrow([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end)
	it("warns when calling hooks inside useMemo", function()
		local useMemo = v.useMemo
		local useState = v.useState

		local function App()
			useMemo(function()
				useState(0)
				return nil
			end)
			return nil
		end

		expect(function()
			return v2.create(v.createElement(App))
		end).toErrorDev("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks.")
	end)
	it("warns when reading context inside useMemo", function()
		local useMemo = v.useMemo
		local createContext = v.createContext
		local reactCurrentDispatcher = v.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher
		local context = createContext("light")

		local function App()
			return useMemo(function()
				assert(reactCurrentDispatcher.current ~= nil, "current dispatcher is nil!")
				return reactCurrentDispatcher.current.readContext(context)
			end, {})
		end

		expect(function()
			return v2.create(v.createElement(App))
		end).toErrorDev("Context can only be read while React is rendering")
	end)
	it("warns when reading context inside useMemo after reading outside it", function()
		local useMemo = v.useMemo
		local createContext = v.createContext
		local reactCurrentDispatcher = v.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher
		local context = createContext("light")
		local v4 = nil
		local v5 = nil

		local function App()
			assert(reactCurrentDispatcher.current ~= nil, "current dispatcher is nil!")
			v4 = reactCurrentDispatcher.current.readContext(context)
			useMemo(function()
				return nil
			end)
			v5 = reactCurrentDispatcher.current.readContext(context)
			return useMemo(function()
				return reactCurrentDispatcher.current.readContext(context)
			end, {})
		end

		expect(function()
			return v2.create(v.createElement(App))
		end).toErrorDev("Context can only be read while React is rendering")
		expect(v4).toBe("light")
		expect(v5).toBe("light")
	end)
	xit("throws when reading context inside useEffect", function()
		local useEffect = v.useEffect
		local createContext = v.createContext
		local reactCurrentDispatcher = v.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher
		local context = createContext("light")

		local function App()
			useEffect(function()
				assert(reactCurrentDispatcher.current ~= nil, "current dispatcher is nil!")
				reactCurrentDispatcher.current.readContext(context)
			end)
			return nil
		end

		expect(function()
			unstable_concurrentAct(function()
				v2.create(v.createElement(App))
			end)
		end).toThrow("Context can only be read while React is rendering")
	end)
	it("throws when reading context inside useLayoutEffect", function()
		local useLayoutEffect = v.useLayoutEffect
		local createContext = v.createContext
		local reactCurrentDispatcher = v.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher
		local context = createContext("light")

		local function App()
			useLayoutEffect(function()
				assert(reactCurrentDispatcher.current ~= nil, "current dispatcher is nil!")
				reactCurrentDispatcher.current.readContext(context)
			end)
			return nil
		end

		expect(function()
			return v2.create(v.createElement(App))
		end).toThrow("Context can only be read while React is rendering")
	end)
	it("warns when reading context inside useReducer", function()
		local useReducer = v.useReducer
		local createContext = v.createContext
		local reactCurrentDispatcher = v.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher
		local context = createContext("light")

		local function App()
			local v4, v5 = useReducer(function(_, p)
				assert(reactCurrentDispatcher.current ~= nil, "current dispatcher is nil!")
				reactCurrentDispatcher.current.readContext(context)
				return p
			end, 0)

			if v4 == 0 then
				v5(1)
			end

			return nil
		end

		expect(function()
			return v2.create(v.createElement(App))
		end).toErrorDev({ "Context can only be read while React is rendering" })
	end)
	it("warns when reading context inside eager useReducer", function()
		local useState = v.useState
		local context = v.createContext("light")
		local reactCurrentDispatcher = v.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher
		local v4 = nil

		local function Fn()
			local _, setState = useState(nil)
			v4 = setState
			return nil
		end

		local extended = v.Component:extend("Cls")

		function extended.render(_)
			v4(function()
				assert(reactCurrentDispatcher.current ~= nil, "current dispatcher is nil!")
				return reactCurrentDispatcher.current.readContext(context)
			end)
			return nil
		end

		expect(function()
			return v2.create(v.createElement(v.Fragment, nil, v.createElement(Fn), v.createElement(extended)))
		end).toErrorDev({
			"Context can only be read while React is rendering",
			"Cannot update a component (`Fn`) while rendering a different component (`Cls`)."
		})
	end)
	it("warns when calling hooks inside useReducer", function()
		local useReducer = v.useReducer
		local useState = v.useState
		local useRef = v.useRef

		local function App()
			local v4, v5 = useReducer(function(p: number, _)
				useRef(0)
				return p + 1
			end, 0)

			if v4 == 0 then
				v5("foo")
			end

			useState(0)
			return v4
		end

		expect(function()
			expect(function()
				v2.create(v.createElement(App))
			end).toThrow("Rendered more hooks than during the previous render.")
		end).toErrorDev({
			"Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks",
			"Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks",
			[[
Warning: React has detected a change in the order of Hooks called by App. This will lead to bugs and errors if not fixed. For more information, read the Rules of Hooks: https://reactjs.org/link/rules-of-hooks

   Previous render            Next render
   ------------------------------------------------------
1. useReducer                 useReducer
2. useState                   useRef
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

]]
		})
	end)
	it("warns when calling hooks inside useState's initialize function", function()
		local useState = v.useState
		local useRef = v.useRef

		local function App()
			useState(function()
				useRef(0)
				return 0
			end)
			return nil
		end

		expect(function()
			return v2.create(v.createElement(App))
		end).toErrorDev("Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks.")
	end)
	it("resets warning internal state when interrupted by an error", function()
		local reactCurrentDispatcher = v.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher
		local context = v.createContext("light")

		local function App()
			v.useMemo(function()
				assert(reactCurrentDispatcher.current ~= nil, "current dispatcher is nil!")
				reactCurrentDispatcher.current.readContext(context)
				v.useRef(0)
				error(error2.new("No."))
			end, {})
		end

		local extended = v.Component:extend("Boundary")

		function extended.init(object)
			object:setState({})
		end

		function extended.getDerivedStateFromError(_)
			return {
				err = true
			}
		end

		function extended.render(p)
			if p.state.err then
				return "Oops"
			end

			return p.props.children
		end

		expect(function()
			v2.create(v.createElement(extended, nil, v.createElement(App)))
		end).toErrorDev({
			"Context can only be read while React is rendering",
			"Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks",
			"Context can only be read while React is rendering",
			"Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks"
		})

		local function Valid()
			v.useState(0)
			v.useMemo(function()
				return nil
			end)
			v.useReducer(function()
				return nil
			end, 0)
			v.useEffect(function() end)
			v.useLayoutEffect(function() end)
			v.useCallback(function() end)
			v.useRef(0)
			v.useImperativeHandle(function()
				return nil
			end, function()
				return nil
			end)

			if ReactGlobals.__DEV__ then
				v.useDebugValue(0)
			end

			return nil
		end

		unstable_concurrentAct(function()
			v2.create(v.createElement(Valid))
		end)
		expect(function()
			v2.create(v.createElement(extended, nil, v.createElement(App)))
		end).toErrorDev({
			"Context can only be read while React is rendering",
			"Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks",
			"Context can only be read while React is rendering",
			"Do not call Hooks inside useEffect(...), useMemo(...), or other built-in Hooks"
		})
	end)
	it("double-invokes components with Hooks in Strict Mode", function()
		reactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode = true
		local useState = v.useState
		local strictMode = v.StrictMode
		local count = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function NoHooks()
			count += 1
			return v.createElement("div")
		end

		local function HasHooks()
			useState(0)
			return NoHooks()
		end

		local forwardRef = v.forwardRef(function(_, _)
			count += 1
			return v.createElement("div")
		end)
		local forwardRef2 = v.forwardRef(function(_, _)
			useState(0)
			return NoHooks()
		end)
		local memo = v.memo(function(_)
			count += 1
			return v.createElement("div")
		end)
		local memo2 = v.memo(function(_)
			useState(0)
			return NoHooks()
		end)

		local function Factory()
			return {
				state = {},
				render = function(_)
					count += 1
					return v.createElement("div")
				end
			}
		end

		local v4 = v2.create(nil)
		count = 0
		v4.update(v.createElement(NoHooks))
		expect(count).toBe(1)
		count = 0
		v4.update(v.createElement(NoHooks))
		expect(count).toBe(1)
		count = 0
		v4.update(v.createElement(strictMode, nil, v.createElement(NoHooks)))
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		count = 0
		v4.update(v.createElement(strictMode, nil, v.createElement(NoHooks)))
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		count = 0
		v4.update(v.createElement(forwardRef))
		expect(count).toBe(1)
		count = 0
		v4.update(v.createElement(forwardRef))
		expect(count).toBe(1)
		count = 0
		v4.update(v.createElement(strictMode, nil, v.createElement(forwardRef)))
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		count = 0
		v4.update(v.createElement(strictMode, nil, v.createElement(forwardRef)))
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		count = 0
		v4.update(v.createElement(memo, {
			arg = 1
		}))
		expect(count).toBe(1)
		count = 0
		v4.update(v.createElement(memo, {
			arg = 2
		}))
		expect(count).toBe(1)
		count = 0
		v4.update(v.createElement(strictMode, nil, v.createElement(memo, {
			arg = 1
		})))
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		count = 0
		v4.update(v.createElement(strictMode, nil, v.createElement(memo, {
			arg = 2
		})))
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)

		if not reactFeatureFlags.disableModulePatternComponents then
			count = 0
			expect(function()
				return v4.update(v.createElement(Factory))
			end).toErrorDev("Warning: The <Factory /> component appears to be a function component that returns a class instance. Change Factory to a class that extends React.Component instead. ")
			expect(count).toBe(1)
			count = 0
			v4.update(v.createElement(Factory))
			expect(count).toBe(1)
			count = 0
			v4.update(v.createElement(strictMode, nil, v.createElement(Factory)))
			expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
			count = 0
			v4.update(v.createElement(strictMode, nil, v.createElement(Factory)))
			expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		end

		count = 0
		v4.update(v.createElement(HasHooks))
		expect(count).toBe(1)
		count = 0
		v4.update(v.createElement(HasHooks))
		expect(count).toBe(1)
		count = 0
		v4.update(v.createElement(strictMode, nil, v.createElement(HasHooks)))
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		count = 0
		v4.update(v.createElement(strictMode, nil, v.createElement(HasHooks)))
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		count = 0
		v4.update(v.createElement(forwardRef2))
		expect(count).toBe(1)
		count = 0
		v4.update(v.createElement(forwardRef2))
		expect(count).toBe(1)
		count = 0
		v4.update(v.createElement(strictMode, nil, v.createElement(forwardRef2)))
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		count = 0
		v4.update(v.createElement(strictMode, nil, v.createElement(forwardRef2)))
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		count = 0
		v4.update(v.createElement(memo2, {
			arg = 1
		}))
		expect(count).toBe(1)
		count = 0
		v4.update(v.createElement(memo2, {
			arg = 2
		}))
		expect(count).toBe(1)
		count = 0
		v4.update(v.createElement(strictMode, nil, v.createElement(memo2, {
			arg = 1
		})))
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		count = 0
		v4.update(v.createElement(strictMode, nil, v.createElement(memo2, {
			arg = 2
		})))
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		reactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode = false
	end)
	it("double-invokes useMemo in DEV StrictMode despite []", function()
		reactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode = true
		local useMemo = v.useMemo
		local strictMode = v.StrictMode
		local count = 0

		local function BadUseMemo()
			useMemo(function()
				count += 1
				return nil
			end, {})
			return v.createElement("div")
		end

		count = 0
		v2.create(v.createElement(strictMode, nil, v.createElement(BadUseMemo)))
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		reactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode = false
	end)
	describe("hook ordering", function()
		local function useCallbackHelper()
			return v.useCallback(function() end, {})
		end

		local function useContextHelper()
			return v.useContext(v.createContext(0))
		end

		local function useDebugValueHelper()
			v.useDebugValue("abc")
		end

		local function useEffectHelper()
			v.useEffect(function()
				return function() end
			end, {})
		end

		local function useImperativeHandleHelper()
			v.useImperativeHandle({
				current = 0
			}, function()
				return 0
			end, {})
		end

		local function useLayoutEffectHelper()
			v.useLayoutEffect(function()
				return function() end
			end, {})
		end

		local function useMemoHelper()
			return v.useMemo(function()
				return 123
			end, {})
		end

		local function useReducerHelper()
			return v.useReducer(function(_, p)
				return p
			end, 0)
		end

		local function useRefHelper()
			return v.useRef(nil)
		end

		local function useStateHelper()
			return v.useState(0)
		end

		local v4 = {
			useCallbackHelper,
			useContextHelper,
			useDebugValueHelper,
			useEffectHelper,
			useLayoutEffectHelper,
			useMemoHelper,
			useReducerHelper,
			useRefHelper,
			useStateHelper
		}
		local v5 = {
			useCallbackHelper,
			useEffectHelper,
			useImperativeHandleHelper,
			useLayoutEffectHelper,
			useMemoHelper,
			useReducerHelper,
			useRefHelper,
			useStateHelper
		}
		local _ = ReactGlobals.__EXPERIMENTAL__

		local function formatHookNamesToMatchErrorMessage(value, p)
			return string.format("use%s%s%s", value, string.rep(" ", 24 - string.len(value)), (function()
				if p then
					return string.format("use%s", p)
				end

				return ""
			end)())
		end

		array.forEach(v4, function(callback, p: number)
			local v6

			if p > 0 then
				v6 = v4[p]
			else
				v6 = v4[#v4]
			end

			local v7 = debug.info(callback, "n"):gsub("use", ""):gsub("Helper", "")
			local v8 = debug.info(v6, "n"):gsub("use", ""):gsub("Helper", "")
			xit(("warns on using differently ordered hooks (%s, %s) on subsequent renders"):format(v7, v8), function()
				local function App(p2)
					if p2.update then
						v6()
						callback()
					else
						callback()
						v6()
					end

					v.useRef(nil)
					return nil
				end

				local v9 = nil
				unstable_concurrentAct(function()
					v9 = v2.create(v.createElement(App, {
						update = false
					}))
				end)
				expect(function()
					xpcall(function()
						unstable_concurrentAct(function()
							v9.update(v.createElement(App, {
								update = true
							}))
						end)
					end, function(_) end)
				end).toErrorDev({ "Warning: React has detected a change in the order of Hooks called by App. " .. "This will lead to bugs and errors if not fixed. For more information, " .. [[
read the Rules of Hooks: https://reactjs.org/link/rules-of-hooks

]] .. "   Previous render            Next render\n" .. "   ------------------------------------------------------\n" .. string.format(
						"1. %s\n",
						formatHookNamesToMatchErrorMessage(v7, v8)
					) .. [[
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    in App (at **)]] })
				xpcall(function()
					unstable_concurrentAct(function()
						v9.update(v.createElement(App, {
							update = false
						}))
					end)
				end, function(_) end)
			end)
			it(string.format("warns when more hooks (%s, %s) are used during update than mount", v7, v8), function()
				local function App(p2)
					if p2.update then
						callback()
						v6()
					else
						callback()
					end

					return nil
				end

				local v9 = nil
				unstable_concurrentAct(function()
					v9 = v2.create(v.createElement(App, {
						update = false
					}))
				end)
				expect(function()
					xpcall(function()
						unstable_concurrentAct(function()
							v9.update(v.createElement(App, {
								update = true
							}))
						end)
					end, function(_) end)
				end).toErrorDev({ "Warning: React has detected a change in the order of Hooks called by App. " .. "This will lead to bugs and errors if not fixed. For more information, " .. [[
read the Rules of Hooks: https://reactjs.org/link/rules-of-hooks

]] .. "   Previous render            Next render\n" .. "   ------------------------------------------------------\n" .. string.format(
						"1. %s\n",
						formatHookNamesToMatchErrorMessage(v7, v7)
					) .. ("2. undefined                  use%s\n"):format(v8) .. [[
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    in App (at **)]] })
			end)
		end)
		array.forEach(v5, function(callback, p: number)
			local v6

			if p > 0 then
				v6 = v5[p]
			else
				v6 = v5[#v5]
			end

			local v7 = debug.info(callback, "n"):gsub("use", ""):gsub("Helper", "")
			local v8 = debug.info(v6, "n"):gsub("use", ""):gsub("Helper", "")
			xit(string.format("warns when fewer hooks (%s, %s) are used during update than mount", v7, v8), function()
				local function App(p2)
					if p2.update then
						callback()
					else
						callback()
						v6()
					end

					return nil
				end

				local v9 = nil
				unstable_concurrentAct(function()
					v9 = v2.create(v.createElement(App, {
						update = false
					}))
				end)
				expect(function()
					unstable_concurrentAct(function()
						v9.update(v.createElement(App, {
							update = true
						}))
					end)
				end).toThrow("Rendered fewer hooks than expected.")
			end)
		end)
		xit(
			"warns on using differently ordered hooks (useImperativeHandleHelper, useMemoHelper) on subsequent renders",
			function()
				local function App(p)
					if p.update then
						v.useMemo(function()
							return 123
						end, {})
						useImperativeHandleHelper()
					else
						useImperativeHandleHelper()
						v.useMemo(function()
							return 123
						end, {})
					end

					v.useRef(nil)
					return nil
				end

				local v6 = v2.create(v.createElement(App, {
					update = false
				}))
				expect(function()
					xpcall(function()
						v6.update(v.createElement(App, {
							update = true
						}))
					end, function(_) end)
				end).toErrorDev({ "Warning: React has detected a change in the order of Hooks called by App. " .. "This will lead to bugs and errors if not fixed. For more information, " .. [[
read the Rules of Hooks: https://reactjs.org/link/rules-of-hooks

]] .. "   Previous render            Next render\n" .. "   ------------------------------------------------------\n" .. string.format(
						"1. %s\n",
						formatHookNamesToMatchErrorMessage("ImperativeHandle", "Memo")
					) .. [[
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    in App (at **)]] })
				v6.update(v.createElement(App, {
					update = false
				}))
			end
		)
		it("detects a bad hook order even if the component throws", function()
			local useState = v.useState
			local useReducer = v.useReducer

			local function useCustomHook()
				useState(0)
			end

			local function App(p)
				if p.update then
					useState(0)
					useReducer(function(_, p2)
						return p2
					end, 0)
					error(error2.new("custom error"))
				else
					useReducer(function(_, p2)
						return p2
					end, 0)
					useState(0)
				end

				return nil
			end

			local v6 = v2.create(v.createElement(App, {
				update = false
			}))
			expect(function()
				expect(function()
					return v6.update(v.createElement(App, {
						update = true
					}))
				end).toThrow("custom error")
			end).toErrorDev({ [[
Warning: React has detected a change in the order of Hooks called by App. This will lead to bugs and errors if not fixed. For more information, read the Rules of Hooks: https://reactjs.org/link/rules-of-hooks

   Previous render            Next render
   ------------------------------------------------------
1. useReducer                 useState
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

]] })
		end)
	end)
	it("does not swallow original error when updating another component in render phase", function()
		local useState = v.useState
		local v4 = nil

		local function A()
			local _, setState = useState(0)
			v4 = setState
			return nil
		end

		local function B()
			v4(function()
				error(error2.new("Hello"))
			end)
			return nil
		end

		expect(function()
			unstable_concurrentAct(function()
				v2.unstable_batchedUpdates(function()
					v2.create(v.createElement(v.Fragment, nil, v.createElement(A), v.createElement(B)))
					expect(function()
						v3.unstable_flushAll()
					end).toThrow("Hello")
				end)
			end)
		end).toErrorDev("Warning: Cannot update a component (`A`) while rendering a different component (`B`).")
	end)
	it("does not fire a false positive warning when previous effect unmounts the component", function()
		local B
		local C
		local useState = v.useState
		local useEffect = v.useEffect
		local fn

		local function A()
			local state, setState = useState(true)

			local function hideMe()
				setState(false)
			end

			if state then
				return (v.createElement(B, {
					hideMe = hideMe
				}))
			end

			return nil
		end

		B = function(p)
			return v.createElement(C, p)
		end

		C = function(p)
			local hideMe = p.hideMe
			local _, setState = useState("")
			useEffect(function()
				local v4 = false

				fn = function()
					if not v4 then
						setState("hello")
					end
				end

				return function()
					v4 = true
					hideMe()
				end
			end)
			return nil
		end

		unstable_concurrentAct(function()
			v2.create(v.createElement(A))
		end)
		expect(function()
			fn()
			fn()
		end).toErrorDev({
			"An update to C inside a test was not wrapped in act",
			"An update to C inside a test was not wrapped in act"
		})
	end)
	it("does not fire a false positive warning when suspending memo", function()
		local suspense = v.Suspense
		local useState = v.useState
		local v4 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function trySuspend()
			if not v4 then
				error(Promise.delay(0):andThen(function(callback)
					v4 = true
					callback()
				end))
			end
		end

		local function Child()
			useState(0)
			trySuspend() -- equivalent call inferred; original call site unknown
			return "hello"
		end

		local memo = v.memo(Child)
		local v5 = v2.create(v.createElement(suspense, {
			fallback = "loading"
		}, v.createElement(memo)))
		expect(v5).toMatchRenderedOutput("loading")
		Promise.delay(0):await()
		v3.unstable_flushAll()
		expect(v5).toMatchRenderedOutput("hello")
	end)
	it("does not fire a false positive warning when suspending forwardRef", function()
		local suspense = v.Suspense
		local useState = v.useState
		local v4 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function trySuspend()
			if not v4 then
				error(Promise.delay(0):andThen(function(callback)
					v4 = true
					callback()
				end))
			end
		end

		local function render(_, _)
			useState(0)
			trySuspend() -- equivalent call inferred; original call site unknown
			return "hello"
		end

		local forwardRef = v.forwardRef(render)
		local v5 = v2.create(v.createElement(suspense, {
			fallback = "loading"
		}, v.createElement(forwardRef)))
		expect(v5).toMatchRenderedOutput("loading")
		Promise.delay(0):await()
		v3.unstable_flushAll()
		expect(v5).toMatchRenderedOutput("hello")
	end)
	it("does not fire a false positive warning when suspending memo(forwardRef)", function()
		local suspense = v.Suspense
		local useState = v.useState
		local v4 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function trySuspend()
			if not v4 then
				error(Promise.delay(0):andThen(function(callback)
					v4 = true
					callback()
				end))
			end
		end

		local function render(_, _)
			useState(0)
			trySuspend() -- equivalent call inferred; original call site unknown
			return "hello"
		end

		local memo = v.memo(v.forwardRef(render))
		local v5 = v2.create(v.createElement(suspense, {
			fallback = "loading"
		}, v.createElement(memo)))
		expect(v5).toMatchRenderedOutput("loading")
		Promise.delay(0):await()
		v3.unstable_flushAll()
		expect(v5).toMatchRenderedOutput("hello")
	end)
	it("resets hooks when an error is thrown in the middle of a list of hooks", function()
		local useEffect = v.useEffect
		local useState = v.useState

		local function Wrapper(p)
			return p.children
		end

		local extended = v.Component:extend("ErrorBoundary")

		function extended.init(object)
			object:setState({})
		end

		function extended.getDerivedStateFromError()
			return {
				hasError = true
			}
		end

		function extended.render(p)
			return v.createElement(Wrapper, nil, p.state.hasError and "Error!" or p.props.children)
		end

		local v4 = nil

		local function Thrower()
			local state, setState = useState(false)
			v4 = setState

			if state then
				error(error2.new("Throw!"))
			end

			useEffect(function() end, {})
			return "Throw!"
		end

		local v5 = nil
		unstable_concurrentAct(function()
			v5 = v2.create(v.createElement(extended, nil, v.createElement(Thrower)))
		end)
		expect(v5).toMatchRenderedOutput("Throw!")
		unstable_concurrentAct(function()
			return v4(true)
		end)
		expect(v5).toMatchRenderedOutput("Error!")
	end)
end)