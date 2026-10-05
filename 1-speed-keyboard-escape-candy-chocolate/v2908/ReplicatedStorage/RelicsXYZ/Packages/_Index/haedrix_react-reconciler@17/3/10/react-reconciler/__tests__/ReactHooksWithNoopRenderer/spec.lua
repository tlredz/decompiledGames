local parent = script.Parent.Parent.Parent
local v = nil
local v2 = nil
local LuauPolyfill = require(parent.LuauPolyfill)
local clearTimeout = LuauPolyfill.clearTimeout
local setTimeout = LuauPolyfill.setTimeout
local array = LuauPolyfill.Array
local v3 = nil
local v4 = nil
local suspense = nil
local useState = nil
local useReducer = nil
local useEffect = nil
local useLayoutEffect = nil
local useCallback = nil
local useMemo = nil
local useRef = nil
local useBinding = nil
local useImperativeHandle = nil
local forwardRef = nil
local memo = nil
local act = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local it = JestGlobals.it
local xit = JestGlobals.xit
beforeEach(function()
	jest.resetModules()
	jest.useFakeTimers()
	local Promise = require(parent.Promise)
	v2 = Promise
	local LuauPolyfill2 = require(parent.LuauPolyfill)
	LuauPolyfill = LuauPolyfill2
	clearTimeout = LuauPolyfill.clearTimeout
	setTimeout = LuauPolyfill.setTimeout
	local React = require(parent.React)
	v = React
	local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
	v3 = ReactNoopRenderer
	local Scheduler = require(parent.Scheduler)
	v4 = Scheduler
	useState = v.useState
	useReducer = v.useReducer
	useEffect = v.useEffect
	useLayoutEffect = v.useLayoutEffect
	useCallback = v.useCallback
	useMemo = v.useMemo
	useRef = v.useRef
	useBinding = v.useBinding
	useImperativeHandle = v.useImperativeHandle
	forwardRef = v.forwardRef
	memo = v.memo
	suspense = v.Suspense
	act = v3.act
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function span(prop)
	return {
		type = "span",
		hidden = false,
		children = {},
		prop = prop
	}
end

local function Text(p)
	v4.unstable_yieldValue(p.text)
	return v.createElement("span", {
		prop = p.text
	})
end

it("resumes after an interruption", function()
	local function Counter(p, p2)
		local state, setState = useState(0)
		useImperativeHandle(p2, function()
			return {
				updateCount = setState
			}
		end)
		return v.createElement(Text, {
			text = tostring(p.label) .. ": " .. state
		})
	end

	local v5 = forwardRef(Counter)
	local ref = v.createRef()
	v3.render(v.createElement(v5, {
		label = "Count",
		ref = ref
	}))
	expect(v4).toFlushAndYield({ "Count: 0" })
	expect(v3.getChildren()).toEqual({ span("Count: 0") })
	v3.batchedUpdates(function()
		ref.current.updateCount(1)
		ref.current.updateCount(function(p: number)
			return p + 10
		end)
	end)
	expect(v4).toFlushAndYieldThrough({ "Count: 11" })
	expect(v3.getChildren()).toEqual({ span("Count: 0") })
	v3.flushSync(function()
		v3.render(v.createElement(v5, {
			label = "Total"
		}))
	end)
	expect(v4).toHaveYielded({ "Total: 0" })
	expect(v4).toFlushAndYield({ "Total: 11" })
	expect(v3.getChildren()).toEqual({ span("Total: 11") })
end)
it("throws inside class components", function()
	local extended = v.Component:extend("BadCounter")

	function extended.render(p)
		local v5 = useState(0)
		return v.createElement(Text, {
			text = p.props.label + ": " .. v5
		})
	end

	v3.render(v.createElement(extended))
	expect(v4).toFlushAndThrow([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])

	local function GoodCounter(p, _)
		local text = useState(p.initialCount)
		return v.createElement(Text, {
			text = text
		})
	end

	v3.render(v.createElement(GoodCounter, {
		initialCount = 10
	}))
	expect(v4).toFlushAndYield({ 10 })
end)
it("throws when called outside the render phase", function()
	expect(function()
		expect(function()
			useState(0)
		end).toThrow("attempt to index nil with 'useState'")
	end).toErrorDev([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]], {
		withoutStack = true
	})
end)
describe("useState", function()
	it("simple mount and update", function()
		local function Counter(_, p)
			local state, setState = useState(0)
			useImperativeHandle(p, function()
				return {
					updateCount = setState
				}
			end)
			return v.createElement(Text, {
				text = "Count: " .. state
			})
		end

		local v5 = forwardRef(Counter)
		local ref = v.createRef()
		v3.render(v.createElement(v5, {
			ref = ref
		}))
		expect(v4).toFlushAndYield({ "Count: 0" })
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
		act(function()
			return ref.current.updateCount(1)
		end)
		expect(v4).toHaveYielded({ "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Count: 1") })
		act(function()
			return ref.current.updateCount(function(p: number)
				return p + 10
			end)
		end)
		expect(v4).toHaveYielded({ "Count: 11" })
		expect(v3.getChildren()).toEqual({ span("Count: 11") })
	end)
	it("lazy state initializer", function()
		local function Counter(p, p2)
			local state, setState = useState(function()
				v4.unstable_yieldValue("getInitialState")
				return p.initialState
			end)
			useImperativeHandle(p2, function()
				return {
					updateCount = setState
				}
			end)
			return v.createElement(Text, {
				text = "Count: " .. state
			})
		end

		local v5 = forwardRef(Counter)
		local ref = v.createRef()
		v3.render(v.createElement(v5, {
			initialState = "42",
			ref = ref
		}))
		expect(v4).toFlushAndYield({ "getInitialState", "Count: 42" })
		expect(v3.getChildren()).toEqual({ span("Count: 42") })
		act(function()
			return ref.current.updateCount(7)
		end)
		expect(v4).toHaveYielded({ "Count: 7" })
		expect(v3.getChildren()).toEqual({ span("Count: 7") })
	end)
	it("multiple states", function()
		local function Counter(_, p)
			local state, setState = useState(0)
			local state2, setState2 = useState("Count")
			useImperativeHandle(p, function()
				return {
					updateCount = setState,
					updateLabel = setState2
				}
			end)
			return v.createElement(Text, {
				text = state2 .. ": " .. state
			})
		end

		local v5 = forwardRef(Counter)
		local ref = v.createRef()
		v3.render(v.createElement(v5, {
			ref = ref
		}))
		expect(v4).toFlushAndYield({ "Count: 0" })
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
		act(function()
			return ref.current.updateCount(7)
		end)
		expect(v4).toHaveYielded({ "Count: 7" })
		act(function()
			return ref.current.updateLabel("Total")
		end)
		expect(v4).toHaveYielded({ "Total: 7" })
	end)
	it("returns the same updater function every time", function()
		local v5 = nil

		local function Counter()
			local state, setState = useState(0)
			v5 = setState
			return v.createElement(Text, {
				text = "Count: " .. state
			})
		end

		v3.render(v.createElement(Counter))
		expect(v4).toFlushAndYield({ "Count: 0" })
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
		local v6 = v5
		act(function()
			return v6(1)
		end)
		expect(v4).toHaveYielded({ "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Count: 1") })
		local v7 = v5
		act(function()
			return v6(function(p)
				return p + 10
			end)
		end)
		expect(v4).toHaveYielded({ "Count: 11" })
		expect(v3.getChildren()).toEqual({ span("Count: 11") })
		expect(v6).toEqual(v7)
	end)
	it("does not warn on set after unmount", function()
		local state = nil
		local setState = nil

		local function Counter(_, _)
			state, setState = useState(0)
			return nil
		end

		v3.render(v.createElement(Counter))
		expect(v4).toFlushWithoutYielding()
		v3.render(nil)
		expect(v4).toFlushWithoutYielding()
		act(function()
			setState(1)
		end)
	end)
	it("works with memo", function()
		local state = nil
		local setState = nil

		local function Counter()
			state, setState = useState(0)
			return v.createElement(Text, {
				text = "Count: " .. state
			})
		end

		local v5 = memo(Counter)
		v3.render(v.createElement(v5))
		expect(v4).toFlushAndYield({ "Count: 0" })
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
		v3.render(v.createElement(v5))
		expect(v4).toFlushAndYield({})
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
		act(function()
			return setState(1)
		end)
		expect(v4).toHaveYielded({ "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Count: 1") })
	end)
end)
describe("updates during the render phase", function()
	it("restarts the render function and applies the new updates on top", function()
		local function ScrollView(p)
			local row = p.row
			local state, setState = useState(false)
			local state2, setState2 = useState(nil)

			if state2 ~= row then
				setState(state2 ~= nil and state2 < row)
				setState2(row)
			end

			return v.createElement(Text, {
				text = string.format("Scrolling down: %s", (tostring(state)))
			})
		end

		v3.render(v.createElement(ScrollView, {
			row = 1
		}))
		expect(v4).toFlushAndYield({ "Scrolling down: false" })
		expect(v3.getChildren()).toEqual({ span("Scrolling down: false") })
		v3.render(v.createElement(ScrollView, {
			row = 5
		}))
		expect(v4).toFlushAndYield({ "Scrolling down: true" })
		expect(v3.getChildren()).toEqual({ span("Scrolling down: true") })
		v3.render(v.createElement(ScrollView, {
			row = 5
		}))
		expect(v4).toFlushAndYield({ "Scrolling down: true" })
		expect(v3.getChildren()).toEqual({ span("Scrolling down: true") })
		v3.render(v.createElement(ScrollView, {
			row = 10
		}))
		expect(v4).toFlushAndYield({ "Scrolling down: true" })
		expect(v3.getChildren()).toEqual({ span("Scrolling down: true") })
		v3.render(v.createElement(ScrollView, {
			row = 2
		}))
		expect(v4).toFlushAndYield({ "Scrolling down: false" })
		expect(v3.getChildren()).toEqual({ span("Scrolling down: false") })
		v3.render(v.createElement(ScrollView, {
			row = 2
		}))
		expect(v4).toFlushAndYield({ "Scrolling down: false" })
		expect(v3.getChildren()).toEqual({ span("Scrolling down: false") })
	end)
	it("keeps restarting until there are no more new updates", function()
		local function Counter()
			local state, setState = useState(0)

			if state < 3 then
				setState(state + 1)
			end

			v4.unstable_yieldValue("Render: " .. state)
			return v.createElement(Text, {
				text = state
			})
		end

		v3.render(v.createElement(Counter))
		expect(v4).toFlushAndYield({
			"Render: 0",
			"Render: 1",
			"Render: 2",
			"Render: 3",
			3
		})
		expect(v3.getChildren()).toEqual({ span(3) })
	end)
	it("updates multiple times within same render function", function()
		local function Counter()
			local state, setState = useState(0)

			if state < 12 then
				setState(function(p)
					return p + 1
				end)
				setState(function(p)
					return p + 1
				end)
				setState(function(p)
					return p + 1
				end)
			end

			v4.unstable_yieldValue("Render: " .. state)
			return v.createElement(Text, {
				text = state
			})
		end

		v3.render(v.createElement(Counter))
		expect(v4).toFlushAndYield({
			"Render: 0",
			"Render: 3",
			"Render: 6",
			"Render: 9",
			"Render: 12",
			12
		})
		expect(v3.getChildren()).toEqual({ span(12) })
	end)
	it("throws after too many iterations", function()
		local function Counter()
			local state, setState = useState(0)
			setState(state + 1)
			v4.unstable_yieldValue("Render: " .. state)
			return v.createElement(Text, {
				text = state
			})
		end

		v3.render(v.createElement(Counter))
		expect(v4).toFlushAndThrow("Too many re-renders. React limits the number of renders to prevent an infinite loop.")
	end)
	it("works with useReducer", function()
		local function reducer(count: number, p)
			if p == "increment" then
				count += 1
			end

			return count
		end

		local function Counter(_)
			local text, v6 = useReducer(reducer, 0)

			if text < 3 then
				v6("increment")
			end

			v4.unstable_yieldValue("Render: " .. text)
			return v.createElement(Text, {
				text = text
			})
		end

		v3.render(v.createElement(Counter))
		expect(v4).toFlushAndYield({
			"Render: 0",
			"Render: 1",
			"Render: 2",
			"Render: 3",
			3
		})
		expect(v3.getChildren()).toEqual({ span(3) })
	end)
	it("uses reducer passed at time of render, not time of dispatch", function()
		local function reducerA(p: number, p2)
			if p2 == "increment" then
				return p + 1
			end

			if p2 == "reset" then
			end

			return 0
		end

		local function reducerB(p: number, p2)
			if p2 == "increment" then
				return p + 10
			end

			if p2 == "reset" then
			end

			return 0
		end

		local function Counter(_, p)
			local state, setState = useState(function()
				return reducerA
			end)
			local text, dispatch = useReducer(state, 0)
			useImperativeHandle(p, function()
				return {
					dispatch = dispatch
				}
			end)

			if text < 20 then
				dispatch("increment")

				if state == reducerA then
					setState(function()
						return reducerB
					end)
				else
					setState(function()
						return reducerA
					end)
				end
			end

			v4.unstable_yieldValue("Render: " .. text)
			return v.createElement(Text, {
				text = text
			})
		end

		local v5 = forwardRef(Counter)
		local ref = v.createRef()
		v3.render(v.createElement(v5, {
			ref = ref
		}))
		expect(v4).toFlushAndYield({
			"Render: 0",
			"Render: 10",
			"Render: 11",
			"Render: 21",
			21
		})
		expect(v3.getChildren()).toEqual({ span(21) })
		v3.act(function()
			ref.current.dispatch("reset")
		end)
		v3.render(v.createElement(v5, {
			ref = ref
		}))
		expect(v4).toHaveYielded({
			"Render: 0",
			"Render: 1",
			"Render: 11",
			"Render: 12",
			"Render: 22",
			22
		})
		expect(v3.getChildren()).toEqual({ span(22) })
	end)
	it("discards render phase updates if something suspends", function()
		local v5 = {
			andThen = function() end
		}
		local Bar

		local function Foo(p)
			local signal = p.signal
			return v.createElement(suspense, {
				fallback = "Loading..."
			}, v.createElement(Bar, {
				signal = signal
			}))
		end

		Bar = function(p)
			local signal = p.signal
			local state, setState = useState(0)
			local state2, setState2 = useState(true)

			if state2 ~= signal then
				setState(function(p2)
					return p2 + 1
				end)
				setState2(signal)

				if state == 0 then
					v4.unstable_yieldValue("Suspend!")
					error(v5)
				end
			end

			return v.createElement(Text, {
				text = state
			})
		end

		local root = v3.createRoot()
		root.render(v.createElement(Foo, {
			signal = true
		}))
		expect(v4).toFlushAndYield({ 0 })
		expect(root).toMatchRenderedOutput(v.createElement("span", {
			prop = 0
		}))
		root.render(v.createElement(Foo, {
			signal = false
		}))
		expect(v4).toFlushAndYield({ "Suspend!" })
		expect(root).toMatchRenderedOutput(v.createElement("span", {
			prop = 0
		}))
		root.render(v.createElement(Foo, {
			signal = false
		}))
		expect(v4).toFlushAndYield({ "Suspend!" })
	end)
	it("discards render phase updates if something suspends, but not other updates in the same component", function()
		local v5 = {
			andThen = function() end
		}
		local Bar

		local function Foo(p)
			local signal = p.signal
			return v.createElement(suspense, {
				fallback = "Loading..."
			}, v.createElement(Bar, {
				signal = signal
			}))
		end

		local v6 = nil

		Bar = function(p)
			local signal = p.signal
			local state, setState = useState(0)

			if state == 1 then
				v4.unstable_yieldValue("Suspend!")
				error(v5)
			end

			local state2, setState2 = useState(true)

			if state2 ~= signal then
				setState(function(p2)
					return p2 + 1
				end)
				setState2(signal)
			end

			local state3, setState3 = useState("A")
			v6 = setState3
			return v.createElement(Text, {
				text = state3 .. ":" .. tostring(state)
			})
		end

		local root = v3.createRoot()
		root.render(v.createElement(Foo, {
			signal = true
		}))
		expect(v4).toFlushAndYield({ "A:0" })
		expect(root).toMatchRenderedOutput(v.createElement("span", {
			prop = "A:0"
		}))
		v3.act(function()
			root.render(v.createElement(Foo, {
				signal = false
			}))
			v6("B")
			expect(v4).toFlushAndYield({ "Suspend!" })
			expect(root).toMatchRenderedOutput(v.createElement("span", {
				prop = "A:0"
			}))
			root.render(v.createElement(Foo, {
				signal = false
			}))
			expect(v4).toFlushAndYield({ "Suspend!" })
			root.render(v.createElement(Foo, {
				signal = true
			}))
			expect(v4).toFlushAndYield({ "B:0" })
			expect(root).toMatchRenderedOutput(v.createElement("span", {
				prop = "B:0"
			}))
			return v2.resolve()
		end)
	end)
	it("regression: render phase updates cause lower pri work to be dropped", function()
		local v5 = nil

		local function ScrollView()
			local state, setState = useState(10)
			v5 = setState
			local state2, setState2 = useState("Up")
			local state3, setState3 = useState(nil)

			if state3 ~= state then
				setState2((state3 == nil or not (state3 < state)) and "Up" or "Down")
				setState3(state)
			end

			return v.createElement(Text, {
				text = state2
			})
		end

		local root = v3.createRoot()
		act(function()
			root.render(v.createElement(ScrollView, {
				row = 10
			}))
		end)
		expect(v4).toHaveYielded({ "Up" })
		expect(root).toMatchRenderedOutput(v.createElement("span", {
			prop = "Up"
		}))
		act(function()
			v3.discreteUpdates(function()
				v5(5)
			end)
			v5(20)
		end)
		expect(v4).toHaveYielded({ "Up", "Down" })
		expect(root).toMatchRenderedOutput(v.createElement("span", {
			prop = "Down"
		}))
	end)
end)
describe("useReducer", function()
	it("simple mount and update", function()
		local function reducer_(p: number, p2)
			if p2 == "INCREMENT" then
				return p + 1
			elseif p2 == "DECREMENT" then
				return p - 1
			end

			return p
		end

		local function Counter(_, p)
			local v5, dispatch = useReducer(reducer_, 0)
			useImperativeHandle(p, function()
				return {
					dispatch = dispatch
				}
			end)
			return v.createElement(Text, {
				text = "Count: " .. v5
			})
		end

		local v5 = forwardRef(Counter)
		local ref = v.createRef()
		v3.render(v.createElement(v5, {
			ref = ref
		}))
		expect(v4).toFlushAndYield({ "Count: 0" })
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
		act(function()
			return ref.current.dispatch("INCREMENT")
		end)
		expect(v4).toHaveYielded({ "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Count: 1") })
		act(function()
			ref.current.dispatch("DECREMENT")
			ref.current.dispatch("DECREMENT")
			ref.current.dispatch("DECREMENT")
		end)
		expect(v4).toHaveYielded({ "Count: -2" })
		expect(v3.getChildren()).toEqual({ span("Count: -2") })
	end)
	it("lazy init", function()
		local function reducer_(p: number, p2)
			if p2 == "INCREMENT" then
				return p + 1
			elseif p2 == "DECREMENT" then
				return p - 1
			end

			return p
		end

		local function Counter(p, p2)
			local v5, dispatch = useReducer(reducer_, p, function(p3)
				v4.unstable_yieldValue("Init")
				return p3.initialCount
			end)
			useImperativeHandle(p2, function()
				return {
					dispatch = dispatch
				}
			end)
			return v.createElement(Text, {
				text = "Count: " .. v5
			})
		end

		local v5 = forwardRef(Counter)
		local ref = v.createRef()
		v3.render(v.createElement(v5, {
			initialCount = 10,
			ref = ref
		}))
		expect(v4).toFlushAndYield({ "Init", "Count: 10" })
		expect(v3.getChildren()).toEqual({ span("Count: 10") })
		act(function()
			return ref.current.dispatch("INCREMENT")
		end)
		expect(v4).toHaveYielded({ "Count: 11" })
		expect(v3.getChildren()).toEqual({ span("Count: 11") })
		act(function()
			ref.current.dispatch("DECREMENT")
			ref.current.dispatch("DECREMENT")
			ref.current.dispatch("DECREMENT")
		end)
		expect(v4).toHaveYielded({ "Count: 8" })
		expect(v3.getChildren()).toEqual({ span("Count: 8") })
	end)
	it("handles dispatches with mixed priorities", function()
		local function reducer_(p: number, p2)
			if p2 == "INCREMENT" then
				return p + 1
			end

			return p
		end

		local function Counter(_, p)
			local v5, dispatch = useReducer(reducer_, 0)
			useImperativeHandle(p, function()
				return {
					dispatch = dispatch
				}
			end)
			return v.createElement(Text, {
				text = "Count: " .. v5
			})
		end

		local v5 = forwardRef(Counter)
		local ref = v.createRef()
		v3.render(v.createElement(v5, {
			ref = ref
		}))
		expect(v4).toFlushAndYield({ "Count: 0" })
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
		v3.batchedUpdates(function()
			ref.current.dispatch("INCREMENT")
			ref.current.dispatch("INCREMENT")
			ref.current.dispatch("INCREMENT")
		end)
		v3.flushSync(function()
			ref.current.dispatch("INCREMENT")
		end)
		expect(v4).toHaveYielded({ "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Count: 1") })
		expect(v4).toFlushAndYield({ "Count: 4" })
		expect(v3.getChildren()).toEqual({ span("Count: 4") })
	end)
end)
describe("useEffect", function()
	it("simple mount and update", function()
		local function Counter(p)
			useEffect(function()
				v4.unstable_yieldValue(string.format("Passive effect [%d]", p.count))
			end)
			return v.createElement(Text, {
				text = "Count: " .. p.count
			})
		end

		act(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 0") })
			expect(v4).toFlushAndYield({ "Passive effect [0]" })
		end)
		act(function()
			v3.render(v.createElement(Counter, {
				count = 1
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 1", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 1") })
			expect(v4).toFlushAndYield({ "Passive effect [1]" })
		end)
	end)
	it("flushes passive effects even with sibling deletions", function()
		local function LayoutEffect(_)
			useLayoutEffect(function()
				v4.unstable_yieldValue("Layout effect")
			end)
			return v.createElement(Text, {
				text = "Layout"
			})
		end

		local function PassiveEffect(_)
			useEffect(function()
				v4.unstable_yieldValue("Passive effect")
			end, {})
			return v.createElement(Text, {
				text = "Passive"
			})
		end

		local element = v.createElement(PassiveEffect, {
			key = "p"
		})
		act(function()
			v3.render({ v.createElement(LayoutEffect, {
					key = "l"
				}), element })
			expect(v4).toFlushAndYieldThrough({ "Layout", "Passive", "Layout effect" })
			expect(v3.getChildren()).toEqual({ span("Layout"), span("Passive") })
			v3.render({ element })
			expect(v4).toFlushAndYield({ "Passive effect" })
			expect(v3.getChildren()).toEqual({ span("Passive") })
		end)
		expect(v4).toHaveYielded({})
	end)
	it("flushes passive effects even if siblings schedule an update", function()
		local function PassiveEffect(_)
			useEffect(function()
				v4.unstable_yieldValue("Passive effect")
			end)
			return v.createElement(Text, {
				text = "Passive"
			})
		end

		local function LayoutEffect(_)
			local state, setState = useState(0)
			useLayoutEffect(function()
				if state == 0 then
					setState(1)
				end

				v4.unstable_yieldValue("Layout effect " .. state)
			end)
			return v.createElement(Text, {
				text = "Layout"
			})
		end

		v3.render({ v.createElement(PassiveEffect, {
				key = "p"
			}), v.createElement(LayoutEffect, {
				key = "l"
			}) })
		act(function()
			expect(v4).toFlushAndYield({
				"Passive",
				"Layout",
				"Layout effect 0",
				"Passive effect",
				"Layout",
				"Layout effect 1"
			})
		end)
		expect(v3.getChildren()).toEqual({ span("Passive"), span("Layout") })
	end)
	it("flushes passive effects even if siblings schedule a new root", function()
		local function PassiveEffect(_)
			useEffect(function()
				v4.unstable_yieldValue("Passive effect")
			end, {})
			return v.createElement(Text, {
				text = "Passive"
			})
		end

		local function LayoutEffect(_)
			useLayoutEffect(function()
				v4.unstable_yieldValue("Layout effect")
				v3.renderToRootWithID(v.createElement(Text, {
					text = "New Root"
				}), "root2")
			end)
			return v.createElement(Text, {
				text = "Layout"
			})
		end

		act(function()
			v3.render({ v.createElement(PassiveEffect, {
					key = "p"
				}), v.createElement(LayoutEffect, {
					key = "l"
				}) })
			expect(v4).toFlushAndYield({
				"Passive",
				"Layout",
				"Layout effect",
				"Passive effect",
				"New Root"
			})
			expect(v3.getChildren()).toEqual({ span("Passive"), span("Layout") })
		end)
	end)
	it(
		"flushes effects serially by flushing old effects before flushing new ones, if they haven't already fired",
		function()
			-- equivalent calls inferred from this helper; original call sites unknown
			local function getCommittedText()
				local children = v3.getChildren()

				if children == nil then
					return nil
				end

				return children[1].prop
			end

			local function Counter(p)
				useEffect(function()
					local unstable_yieldValue = v4.unstable_yieldValue
					local committedText = getCommittedText() -- equivalent call inferred; original call site unknown
					unstable_yieldValue("Committed state when effect was fired: " .. tostring(committedText))
				end)
				return v.createElement(Text, {
					text = p.count
				})
			end

			act(function()
				v3.render(v.createElement(Counter, {
					count = 0
				}), function()
					v4.unstable_yieldValue("Sync effect")
				end)
				expect(v4).toFlushAndYieldThrough({ 0, "Sync effect" })
				expect(v3.getChildren()).toEqual({ span(0) })
				v3.render(v.createElement(Counter, {
					count = 1
				}), function()
					v4.unstable_yieldValue("Sync effect")
				end)
				expect(v4).toFlushAndYieldThrough({ "Committed state when effect was fired: 0", 1, "Sync effect" })
				expect(v3.getChildren()).toEqual({ span(1) })
			end)
			expect(v4).toHaveYielded({ "Committed state when effect was fired: 1" })
		end
	)
	it("defers passive effect destroy functions during unmount", function()
		local function Child(p)
			local bar = p.bar
			local foo = p.foo
			v.useEffect(function()
				v4.unstable_yieldValue("passive bar create")
				return function()
					v4.unstable_yieldValue("passive bar destroy")
				end
			end, { bar })
			v.useLayoutEffect(function()
				v4.unstable_yieldValue("layout bar create")
				return function()
					v4.unstable_yieldValue("layout bar destroy")
				end
			end, { bar })
			v.useEffect(function()
				v4.unstable_yieldValue("passive foo create")
				return function()
					v4.unstable_yieldValue("passive foo destroy")
				end
			end, { foo })
			v.useLayoutEffect(function()
				v4.unstable_yieldValue("layout foo create")
				return function()
					v4.unstable_yieldValue("layout foo destroy")
				end
			end, { foo })
			v4.unstable_yieldValue("render")
			return nil
		end

		act(function()
			v3.render(v.createElement(Child, {
				bar = 1,
				foo = 1
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({
				"render",
				"layout bar create",
				"layout foo create",
				"Sync effect"
			})
			expect(v4).toFlushAndYield({ "passive bar create", "passive foo create" })
		end)
		act(function()
			v3.render(v.createElement(Child, {
				bar = 1,
				foo = 2
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({
				"render",
				"layout foo destroy",
				"layout foo create",
				"Sync effect"
			})
			expect(v4).toFlushAndYield({ "passive foo destroy", "passive foo create" })
		end)
		act(function()
			v3.render(nil, function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "layout bar destroy", "layout foo destroy", "Sync effect" })
			expect(v4).toFlushAndYield({ "passive bar destroy", "passive foo destroy" })
		end)
	end)
	it("does not warn about state updates for unmounted components with pending passive unmounts", function()
		local fn

		local function Component()
			v4.unstable_yieldValue("Component")
			local state, setState = v.useState(false)
			v.useLayoutEffect(function()
				v4.unstable_yieldValue("layout create")
				return function()
					v4.unstable_yieldValue("layout destroy")
				end
			end, {})
			v.useEffect(function()
				v4.unstable_yieldValue("passive create")

				fn = function()
					setState(true)
				end

				return function()
					v4.unstable_yieldValue("passive destroy")
				end
			end, {})
			return state
		end

		act(function()
			v3.renderToRootWithID(v.createElement(Component), "root", function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Component", "layout create", "Sync effect" })
			v3.flushPassiveEffects()
			expect(v4).toHaveYielded({ "passive create" })
			v3.unmountRootWithID("root")
			expect(v4).toFlushAndYieldThrough({ "layout destroy" })
			fn()
			v3.flushPassiveEffects()
			expect(v4).toHaveYielded({ "passive destroy" })
		end)
	end)
	it(
		"does not warn about state updates for unmounted components with pending passive unmounts for alternates",
		function()
			local v5 = nil
			local setStates = {}

			local function Child(p)
				local label = p.label
				local state, setState = useState(0)
				useLayoutEffect(function()
					v4.unstable_yieldValue("Child " .. label .. " commit")
				end)
				useEffect(function()
					table.insert(setStates, setState)
					v4.unstable_yieldValue("Child " .. label .. " passive create")
					return function()
						v4.unstable_yieldValue("Child " .. label .. " passive destroy")
					end
				end, {})
				v4.unstable_yieldValue("Child " .. label .. " render")
				return state
			end

			local function Parent()
				local state, setState = useState(true)
				v5 = setState
				v4.unstable_yieldValue("Parent " .. tostring(state) .. " render")
				useLayoutEffect(function()
					v4.unstable_yieldValue("Parent " .. tostring(state) .. " commit")
				end)

				if state then
					return v.createElement(v.Fragment, nil, v.createElement(Child, {
						label = "one"
					}), v.createElement(Child, {
						label = "two"
					}))
				end

				return nil
			end

			act(function()
				v3.render(v.createElement(Parent))
				expect(v4).toFlushAndYieldThrough({
					"Parent true render",
					"Child one render",
					"Child two render",
					"Child one commit",
					"Child two commit",
					"Parent true commit",
					"Child one passive create",
					"Child two passive create"
				})
				array.map(setStates, function(callback)
					return callback(1)
				end)
				expect(v4).toFlushAndYieldThrough({
					"Child one render",
					"Child two render",
					"Child one commit",
					"Child two commit"
				})
				array.map(setStates, function(callback)
					return callback(2)
				end)
				expect(v4).toFlushAndYieldThrough({ "Child one render" })
				v4.unstable_runWithPriority(v4.unstable_UserBlockingPriority, function()
					return v5(false)
				end)
				expect(v4).toFlushAndYieldThrough({ "Parent false render", "Parent false commit" })
				array.map(setStates, function(callback)
					return callback(2)
				end)
				expect(v4).toFlushAndYield({ "Child one passive destroy", "Child two passive destroy" })
			end)
		end
	)
	it("does not warn about state updates for unmounted components with no pending passive unmounts", function()
		local fn

		local function Component()
			v4.unstable_yieldValue("Component")
			local state, setState = v.useState(false)
			v.useLayoutEffect(function()
				v4.unstable_yieldValue("layout create")

				fn = function()
					setState(true)
				end

				return function()
					v4.unstable_yieldValue("layout destroy")
				end
			end, {})
			return state
		end

		act(function()
			v3.renderToRootWithID(v.createElement(Component), "root", function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Component", "layout create", "Sync effect" })
			v3.unmountRootWithID("root")
			expect(v4).toFlushAndYieldThrough({ "layout destroy" })
			fn()
		end)
	end)
	it("does not warn if there are pending passive unmount effects but not for the current fiber", function()
		local fn

		local function ComponentWithXHR()
			v4.unstable_yieldValue("Component")
			local state, setState = v.useState(false)
			v.useLayoutEffect(function()
				v4.unstable_yieldValue("a:layout create")
				return function()
					v4.unstable_yieldValue("a:layout destroy")
				end
			end, {})
			v.useEffect(function()
				v4.unstable_yieldValue("a:passive create")

				fn = function()
					setState(true)
				end
			end, {})
			return state
		end

		local function ComponentWithPendingPassiveUnmount()
			v.useEffect(function()
				v4.unstable_yieldValue("b:passive create")
				return function()
					v4.unstable_yieldValue("b:passive destroy")
				end
			end, {})
			return nil
		end

		act(function()
			v3.renderToRootWithID(
				v.createElement(
					v.Fragment,
					nil,
					v.createElement(ComponentWithXHR),
					v.createElement(ComponentWithPendingPassiveUnmount)
				),
				"root",
				function()
					return v4.unstable_yieldValue("Sync effect")
				end
			)
			expect(v4).toFlushAndYieldThrough({ "Component", "a:layout create", "Sync effect" })
			v3.flushPassiveEffects()
			expect(v4).toHaveYielded({ "a:passive create", "b:passive create" })
			v3.unmountRootWithID("root")
			expect(v4).toFlushAndYieldThrough({ "a:layout destroy" })
			fn()
		end)
	end)
	it("does not warn if there are updates after pending passive unmount effects have been flushed", function()
		local v5 = nil

		local function Component()
			v4.unstable_yieldValue("Component")
			local state, setState = v.useState(false)
			v5 = setState
			v.useEffect(function()
				v4.unstable_yieldValue("passive create")
				return function()
					v4.unstable_yieldValue("passive destroy")
				end
			end, {})
			return state
		end

		act(function()
			v3.renderToRootWithID(v.createElement(Component), "root", function()
				v4.unstable_yieldValue("Sync effect")
			end)
		end)
		expect(v4).toHaveYielded({ "Component", "Sync effect", "passive create" })
		v3.unmountRootWithID("root")
		expect(v4).toFlushAndYield({ "passive destroy" })
		act(function()
			v5(true)
		end)
	end)
	it("does not show a warning when a component updates its own state from within passive unmount function", function()
		local function Component()
			v4.unstable_yieldValue("Component")
			local state, setState = v.useState(false)
			v.useEffect(function()
				v4.unstable_yieldValue("passive create")
				return function()
					setState(true)
					v4.unstable_yieldValue("passive destroy")
				end
			end, {})
			return state
		end

		act(function()
			v3.renderToRootWithID(v.createElement(Component), "root", function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Component", "Sync effect", "passive create" })
			v3.unmountRootWithID("root")
			expect(v4).toFlushAndYield({ "passive destroy" })
		end)
	end)
	it(
		"does not show a warning when a component updates a childs state from within passive unmount function",
		function()
			local Child

			local function Parent()
				v4.unstable_yieldValue("Parent")
				local ref = v.useRef(nil)
				v.useEffect(function()
					v4.unstable_yieldValue("Parent passive create")
					return function()
						assert(ref.current ~= nil, "updaterRef was't initialized before render")
						ref.current(true)
						v4.unstable_yieldValue("Parent passive destroy")
					end
				end, {})
				return v.createElement(Child, {
					updaterRef = ref
				})
			end

			Child = function(p)
				local updaterRef = p.updaterRef
				v4.unstable_yieldValue("Child")
				local state, setState = v.useState(false)
				v.useEffect(function()
					v4.unstable_yieldValue("Child passive create")
					updaterRef.current = setState
				end, {})
				return state
			end

			act(function()
				v3.renderToRootWithID(v.createElement(Parent), "root")
				expect(v4).toFlushAndYieldThrough({
					"Parent",
					"Child",
					"Child passive create",
					"Parent passive create"
				})
				v3.unmountRootWithID("root")
				expect(v4).toFlushAndYield({ "Parent passive destroy" })
			end)
		end
	)
	it(
		"does not show a warning when a component updates a parents state from within passive unmount function",
		function()
			local Child

			local function Parent()
				local state, setState = v.useState(false)
				v4.unstable_yieldValue("Parent")
				return v.createElement(Child, {
					setState = setState,
					state = state
				})
			end

			Child = function(p)
				local state = p.state
				local setState = p.setState
				v4.unstable_yieldValue("Child")
				v.useEffect(function()
					v4.unstable_yieldValue("Child passive create")
					return function()
						v4.unstable_yieldValue("Child passive destroy")
						setState(true)
					end
				end, {})
				return state
			end

			act(function()
				v3.renderToRootWithID(v.createElement(Parent), "root")
				expect(v4).toFlushAndYieldThrough({ "Parent", "Child", "Child passive create" })
				v3.unmountRootWithID("root")
				expect(v4).toFlushAndYield({ "Child passive destroy" })
			end)
		end
	)
	it("updates have async priority", function()
		local function Counter(p)
			local state, setState = useState("(empty)")
			useEffect(function()
				v4.unstable_yieldValue(string.format("Schedule update {%d}", p.count))
				setState((tostring(p.count)))
			end, { p.count })
			return v.createElement(Text, {
				text = "Count: " .. state
			})
		end

		act(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: (empty)", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: (empty)") })
			v3.flushPassiveEffects()
			expect(v4).toHaveYielded({ "Schedule update {0}" })
			expect(v4).toFlushAndYield({ "Count: 0" })
		end)
		act(function()
			v3.render(v.createElement(Counter, {
				count = 1
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 0") })
			v3.flushPassiveEffects()
			expect(v4).toHaveYielded({ "Schedule update {1}" })
			expect(v4).toFlushAndYield({ "Count: 1" })
		end)
	end)
	it("updates have async priority even if effects are flushed early", function()
		local function Counter(p)
			local state, setState = useState("(empty)")
			useEffect(function()
				v4.unstable_yieldValue(string.format("Schedule update {%d}", p.count))
				setState((tostring(p.count)))
			end, { p.count })
			return v.createElement(Text, {
				text = "Count: " .. state
			})
		end

		act(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: (empty)", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: (empty)") })
			v3.render(v.createElement(Counter, {
				count = 1
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Schedule update {0}", "Count: 0" })
			expect(v3.getChildren()).toEqual({ span("Count: (empty)") })
			expect(v4).toFlushAndYieldThrough({ "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 0") })
			v3.flushPassiveEffects()
			expect(v4).toHaveYielded({ "Schedule update {1}" })
			expect(v4).toFlushAndYield({ "Count: 1" })
			expect(v3.getChildren()).toEqual({ span("Count: 1") })
		end)
	end)
	it("does not flush non-discrete passive effects when flushing sync", function()
		local v5 = nil

		local function Counter(_)
			local state, setState = useState(0)
			v5 = setState
			useEffect(function()
				v4.unstable_yieldValue("Will set count to 1")
				setState(1)
			end, {})
			return v.createElement(Text, {
				text = "Count: " .. tostring(state)
			})
		end

		expect(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 0") })
		end).toErrorDev({ "An update to Counter ran an effect" })
		act(function()
			v3.flushSync(function()
				v5(2)
			end)
		end)
		expect(v4).toHaveYielded({ "Will set count to 1", "Count: 2", "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Count: 1") })
	end)
	it("in legacy mode, useEffect is deferred and updates finish synchronously (in a single batch)", function()
		local function Counter(p)
			local state, setState = useState("(empty)")
			useEffect(function()
				setState((tostring(p.count)))
				setState((tostring(p.count)))
				setState((tostring(p.count)))
				setState((tostring(p.count)))
				setState((tostring(p.count)))
				setState((tostring(p.count)))
			end, { p.count })
			return v.createElement(Text, {
				text = "Count: " .. state
			})
		end

		act(function()
			v3.renderLegacySyncRoot(v.createElement(Counter, {
				count = 0
			}))
			expect(v4).toFlushAndYieldThrough({ "Count: (empty)" })
			expect(v3.getChildren()).toEqual({ span("Count: (empty)") })
		end)
		expect(v4).toHaveYielded({ "Count: 0" })
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
	end)
	it("flushSync is not allowed", function()
		local function Counter(p)
			local state, setState = useState("(empty)")
			useEffect(function()
				v4.unstable_yieldValue(string.format("Schedule update [%d]", p.count))
				v3.flushSync(function()
					setState((tostring(p.count)))
				end)
				expect(v3.getChildren()).never.toEqual({
					{
						type = "span",
						hidden = false,
						children = {},
						prop = string.format("Count: %d", p.count)
					}
				})
			end, { p.count })
			return v.createElement(Text, {
				text = "Count: " .. state
			})
		end

		expect(function()
			return act(function()
				v3.render(v.createElement(Counter, {
					count = 0
				}), function()
					return v4.unstable_yieldValue("Sync effect")
				end)
				expect(v4).toFlushAndYieldThrough({ "Count: (empty)", "Sync effect" })
				expect(v3.getChildren()).toEqual({ span("Count: (empty)") })
			end)
		end).toErrorDev("flushSync was called from inside a lifecycle method")
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
	end)
	it("unmounts previous effect", function()
		local function Counter(p)
			useEffect(function()
				v4.unstable_yieldValue(string.format("Did create [%d]", p.count))
				return function()
					v4.unstable_yieldValue(string.format("Did destroy [%d]", p.count))
				end
			end)
			return v.createElement(Text, {
				text = "Count: " .. p.count
			})
		end

		act(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 0") })
		end)
		expect(v4).toHaveYielded({ "Did create [0]" })
		act(function()
			v3.render(v.createElement(Counter, {
				count = 1
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 1", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 1") })
		end)
		expect(v4).toHaveYielded({ "Did destroy [0]", "Did create [1]" })
	end)
	it("unmounts on deletion", function()
		local function Counter(p)
			useEffect(function()
				v4.unstable_yieldValue("Did create [" .. tostring(p.count) .. "]")
				return function()
					v4.unstable_yieldValue("Did destroy [" .. tostring(p.count) .. "]")
				end
			end)
			return v.createElement(Text, {
				text = "Count: " .. tostring(p.count)
			})
		end

		act(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 0") })
		end)
		expect(v4).toHaveYielded({ "Did create [0]" })
		v3.render(nil)
		expect(v4).toFlushAndYield({ "Did destroy [0]" })
		expect(v3.getChildren()).toEqual({})
	end)
	it("unmounts on deletion after skipped effect", function()
		local function Counter(p)
			useEffect(function()
				v4.unstable_yieldValue(string.format("Did create [%d]", p.count))
				return function()
					v4.unstable_yieldValue(string.format("Did destroy [%d]", p.count))
				end
			end, {})
			return v.createElement(Text, {
				text = "Count: " .. p.count
			})
		end

		act(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 0") })
		end)
		expect(v4).toHaveYielded({ "Did create [0]" })
		act(function()
			v3.render(v.createElement(Counter, {
				count = 1
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 1", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 1") })
		end)
		expect(v4).toHaveYielded({})
		v3.render(nil)
		expect(v4).toFlushAndYield({ "Did destroy [0]" })
		expect(v3.getChildren()).toEqual({})
	end)
	it("always fires effects if no dependencies are provided", function()
		local function effect()
			v4.unstable_yieldValue("Did create")
			return function()
				v4.unstable_yieldValue("Did destroy")
			end
		end

		local function Counter(p)
			useEffect(effect)
			return v.createElement(Text, {
				text = "Count: " .. tostring(p.count)
			})
		end

		act(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				return v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 0") })
		end)
		expect(v4).toHaveYielded({ "Did create" })
		act(function()
			v3.render(v.createElement(Counter, {
				count = 1
			}), function()
				return v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 1", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 1") })
		end)
		expect(v4).toHaveYielded({ "Did destroy", "Did create" })
		v3.render(nil)
		expect(v4).toFlushAndYield({ "Did destroy" })
		expect(v3.getChildren()).toEqual({})
	end)
	it("skips effect if inputs have not changed", function()
		local function Counter(p)
			local text = tostring(p.label) .. ": " .. tostring(p.count)
			useEffect(function()
				v4.unstable_yieldValue("Did create [" .. text .. "]")
				return function()
					v4.unstable_yieldValue("Did destroy [" .. text .. "]")
				end
			end, { p.label, p.count })
			return v.createElement(Text, {
				text = text
			})
		end

		act(function()
			v3.render(v.createElement(Counter, {
				label = "Count",
				count = 0
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 0", "Sync effect" })
		end)
		expect(v4).toHaveYielded({ "Did create [Count: 0]" })
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
		act(function()
			v3.render(v.createElement(Counter, {
				label = "Count",
				count = 1
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 1", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 1") })
		end)
		expect(v4).toHaveYielded({ "Did destroy [Count: 0]", "Did create [Count: 1]" })
		act(function()
			v3.render(v.createElement(Counter, {
				label = "Count",
				count = 1
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 1", "Sync effect" })
		end)
		expect(v4).toHaveYielded({})
		expect(v3.getChildren()).toEqual({ span("Count: 1") })
		act(function()
			v3.render(v.createElement(Counter, {
				label = "Total",
				count = 1
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Total: 1", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Total: 1") })
		end)
		expect(v4).toHaveYielded({ "Did destroy [Count: 1]", "Did create [Total: 1]" })
	end)
	it("skips or reruns effects correctly when deps have nil values", function()
		local function Counter(p)
			local v5 = {}

			for k, v6 in string.split(p.deps, "") do
				if v6 == "." then
					v6 = nil
				end

				v5[k] = v6
			end

			useEffect(function()
				v4.unstable_yieldValue("Did create [" .. p.deps .. "]")
				return function()
					v4.unstable_yieldValue("Did destroy [" .. p.deps .. "]")
				end
			end, v5)
			return v.createElement(Text, {
				text = p.deps
			})
		end

		expect(function()
			act(function()
				v3.render(v.createElement(Counter, {
					deps = "A...."
				}), function()
					v4.unstable_yieldValue("Sync effect")
				end)
				expect(v4).toFlushAndYieldThrough({ "A....", "Sync effect" })
			end)
		end).toErrorDev({})
		expect(v4).toHaveYielded({ "Did create [A....]" })
		expect(v3.getChildren()).toEqual({ span("A....") })
		expect(function()
			act(function()
				v3.render(v.createElement(Counter, {
					deps = "A...E"
				}), function()
					v4.unstable_yieldValue("Sync effect")
				end)
				expect(v4).toFlushAndYieldThrough({ "A...E", "Sync effect" })
				expect(v3.getChildren()).toEqual({ span("A...E") })
			end)
		end).toErrorDev({})
		expect(v4).toHaveYielded({ "Did destroy [A....]", "Did create [A...E]" })
		expect(function()
			act(function()
				v3.render(v.createElement(Counter, {
					deps = "ABCDE"
				}), function()
					v4.unstable_yieldValue("Sync effect")
				end)
				expect(v4).toFlushAndYieldThrough({ "ABCDE", "Sync effect" })
				expect(v3.getChildren()).toEqual({ span("ABCDE") })
			end)
		end).toErrorDev({})
		expect(v4).toHaveYielded({ "Did destroy [A...E]", "Did create [ABCDE]" })
		expect(function()
			act(function()
				v3.render(v.createElement(Counter, {
					deps = "....E"
				}), function()
					v4.unstable_yieldValue("Sync effect")
				end)
				expect(v4).toFlushAndYieldThrough({ "....E", "Sync effect" })
				expect(v3.getChildren()).toEqual({ span("....E") })
			end)
		end).toErrorDev({})
		expect(v4).toHaveYielded({ "Did destroy [ABCDE]", "Did create [....E]" })
		expect(function()
			act(function()
				v3.render(v.createElement(Counter, {
					deps = "..C.."
				}), function()
					v4.unstable_yieldValue("Sync effect")
				end)
				expect(v4).toFlushAndYieldThrough({ "..C..", "Sync effect" })
				expect(v3.getChildren()).toEqual({ span("..C..") })
			end)
		end).toErrorDev({})
		expect(v4).toHaveYielded({ "Did destroy [....E]", "Did create [..C..]" })
	end)
	it("multiple effects", function()
		local function Counter(p)
			useEffect(function()
				v4.unstable_yieldValue("Did commit 1 [" .. tostring(p.count) .. "]")
			end)
			useEffect(function()
				v4.unstable_yieldValue("Did commit 2 [" .. tostring(p.count) .. "]")
			end)
			return v.createElement(Text, {
				text = "Count: " .. tostring(p.count)
			})
		end

		act(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 0") })
		end)
		expect(v4).toHaveYielded({ "Did commit 1 [0]", "Did commit 2 [0]" })
		act(function()
			v3.render(v.createElement(Counter, {
				count = 1
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 1", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 1") })
		end)
		expect(v4).toHaveYielded({ "Did commit 1 [1]", "Did commit 2 [1]" })
	end)
	it("unmounts all previous effects before creating any new ones", function()
		local function Counter(p)
			useEffect(function()
				v4.unstable_yieldValue("Mount A [" .. p.count .. "]")
				return function()
					v4.unstable_yieldValue("Unmount A [" .. p.count .. "]")
				end
			end)
			useEffect(function()
				v4.unstable_yieldValue("Mount B [" .. p.count .. "]")
				return function()
					v4.unstable_yieldValue("Unmount B [" .. p.count .. "]")
				end
			end)
			return v.createElement(Text, {
				text = "Count: " .. p.count
			})
		end

		act(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 0") })
		end)
		expect(v4).toHaveYielded({ "Mount A [0]", "Mount B [0]" })
		act(function()
			v3.render(v.createElement(Counter, {
				count = 1
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 1", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 1") })
		end)
		expect(v4).toHaveYielded({
			"Unmount A [0]",
			"Unmount B [0]",
			"Mount A [1]",
			"Mount B [1]"
		})
	end)
	it("unmounts all previous effects between siblings before creating any new ones", function()
		local function Counter(p)
			local count = p.count
			local label = p.label
			useEffect(function()
				v4.unstable_yieldValue(string.format("Mount %s [%d]", label, count))
				return function()
					v4.unstable_yieldValue(string.format("Unmount %s [%d]", label, count))
				end
			end)
			return v.createElement(Text, {
				text = string.format("%s %d", label, count)
			})
		end

		act(function()
			v3.render(v.createElement(v.Fragment, nil, v.createElement(Counter, {
				label = "A",
				count = 0
			}), v.createElement(Counter, {
				label = "B",
				count = 0
			})), function()
				return v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "A 0", "B 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("A 0"), span("B 0") })
		end)
		expect(v4).toHaveYielded({ "Mount A [0]", "Mount B [0]" })
		act(function()
			v3.render(v.createElement(v.Fragment, nil, v.createElement(Counter, {
				label = "A",
				count = 1
			}), v.createElement(Counter, {
				label = "B",
				count = 1
			})), function()
				return v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "A 1", "B 1", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("A 1"), span("B 1") })
		end)
		expect(v4).toHaveYielded({
			"Unmount A [0]",
			"Unmount B [0]",
			"Mount A [1]",
			"Mount B [1]"
		})
		act(function()
			v3.render(v.createElement(v.Fragment, nil, v.createElement(Counter, {
				label = "B",
				count = 2
			}), v.createElement(Counter, {
				label = "C",
				count = 0
			})), function()
				return v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "B 2", "C 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("B 2"), span("C 0") })
		end)
		expect(v4).toHaveYielded({
			"Unmount A [1]",
			"Unmount B [1]",
			"Mount B [2]",
			"Mount C [0]"
		})
	end)
	it("handles errors in create on mount", function()
		local function Counter(p)
			useEffect(function()
				v4.unstable_yieldValue(string.format("Mount A [%d]", p.count))
				return function()
					v4.unstable_yieldValue(string.format("Unmount A [%d]", p.count))
				end
			end)
			useEffect(function()
				v4.unstable_yieldValue("Oops!")
				error("Oops!")
			end)
			return v.createElement(Text, {
				text = "Count: " .. p.count
			})
		end

		act(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				return v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 0") })
			expect(function()
				return v3.flushPassiveEffects()
			end).toThrow("Oops")
		end)
		expect(v4).toHaveYielded({ "Mount A [0]", "Oops!", "Unmount A [0]" })
		expect(v3.getChildren()).toEqual({})
	end)
	it("handles errors in create on update", function()
		local function Counter(p)
			useEffect(function()
				v4.unstable_yieldValue(string.format("Mount A [%d]", p.count))
				return function()
					v4.unstable_yieldValue(string.format("Unmount A [%d]", p.count))
				end
			end)
			useEffect(function()
				if p.count == 1 then
					v4.unstable_yieldValue("Oops!")
					error("Oops!")
				end

				v4.unstable_yieldValue(string.format("Mount B [%d]", p.count))
				return function()
					v4.unstable_yieldValue(string.format("Unmount B [%d]", p.count))
				end
			end)
			return v.createElement(Text, {
				text = "Count: " .. p.count
			})
		end

		act(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				return v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 0") })
			v3.flushPassiveEffects()
			expect(v4).toHaveYielded({ "Mount A [0]", "Mount B [0]" })
		end)
		act(function()
			v3.render(v.createElement(Counter, {
				count = 1
			}), function()
				return v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 1", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 1") })
			expect(function()
				return v3.flushPassiveEffects()
			end).toThrow("Oops")
			expect(v4).toHaveYielded({
				"Unmount A [0]",
				"Unmount B [0]",
				"Mount A [1]",
				"Oops!"
			})
			expect(v3.getChildren()).toEqual({})
		end)
		expect(v4).toHaveYielded({ "Unmount A [1]" })
	end)
	it("handles errors in destroy on update", function()
		local function Counter(p)
			useEffect(function()
				v4.unstable_yieldValue(string.format("Mount A [%d]", p.count))
				return function()
					v4.unstable_yieldValue("Oops!")

					if p.count == 0 then
						error("Oops!")
					end
				end
			end)
			useEffect(function()
				v4.unstable_yieldValue(string.format("Mount B [%d]", p.count))
				return function()
					v4.unstable_yieldValue(string.format("Unmount B [%d]", p.count))
				end
			end)
			return v.createElement(Text, {
				text = "Count: " .. p.count
			})
		end

		act(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				return v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 0", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 0") })
			v3.flushPassiveEffects()
			expect(v4).toHaveYielded({ "Mount A [0]", "Mount B [0]" })
		end)
		act(function()
			v3.render(v.createElement(Counter, {
				count = 1
			}), function()
				return v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Count: 1", "Sync effect" })
			expect(v3.getChildren()).toEqual({ span("Count: 1") })
			expect(function()
				return v3.flushPassiveEffects()
			end).toThrow("Oops")
			expect(v4).toHaveYielded({
				"Oops!",
				"Unmount B [0]",
				"Mount A [1]",
				"Mount B [1]"
			})
		end)
		expect(v4).toHaveYielded({ "Oops!", "Unmount B [1]" })
		expect(v3.getChildren()).toEqual({})
	end)
	it("works with memo", function()
		local function Counter(p)
			local count = p.count
			useLayoutEffect(function()
				v4.unstable_yieldValue("Mount: " .. count)
				return function()
					return v4.unstable_yieldValue("Unmount: " .. count)
				end
			end)
			return v.createElement(Text, {
				text = "Count: " .. count
			})
		end

		local v5 = memo(Counter)
		v3.render(v.createElement(v5, {
			count = 0
		}), function()
			return v4.unstable_yieldValue("Sync effect")
		end)
		expect(v4).toFlushAndYieldThrough({ "Count: 0", "Mount: 0", "Sync effect" })
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
		v3.render(v.createElement(v5, {
			count = 1
		}), function()
			return v4.unstable_yieldValue("Sync effect")
		end)
		expect(v4).toFlushAndYieldThrough({
			"Count: 1",
			"Unmount: 0",
			"Mount: 1",
			"Sync effect"
		})
		expect(v3.getChildren()).toEqual({ span("Count: 1") })
		v3.render(nil)
		expect(v4).toFlushAndYieldThrough({ "Unmount: 1" })
		expect(v3.getChildren()).toEqual({})
	end)
end)
describe("useLayoutEffect", function()
	it("fires layout effects after the host has been mutated", function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function getCommittedText()
			local unstable_clearYields = v4.unstable_clearYields()
			local children = v3.getChildren()
			v4.unstable_yieldValue(unstable_clearYields)

			if children == nil then
				return nil
			end

			return children[1].prop
		end

		local function Counter(p)
			useLayoutEffect(function()
				local unstable_yieldValue = v4.unstable_yieldValue
				local committedText = getCommittedText() -- equivalent call inferred; original call site unknown
				unstable_yieldValue("Current: " .. tostring(committedText))
			end)
			return v.createElement(Text, {
				text = p.count
			})
		end

		v3.render(v.createElement(Counter, {
			count = 0
		}), function()
			v4.unstable_yieldValue("Sync effect")
		end)
		expect(v4).toFlushAndYieldThrough({
			{ 0 },
			"Current: 0",
			"Sync effect"
		})
		expect(v3.getChildren()).toEqual({ span(0) })
		v3.render(v.createElement(Counter, {
			count = 1
		}), function()
			v4.unstable_yieldValue("Sync effect")
		end)
		expect(v4).toFlushAndYieldThrough({
			{ 1 },
			"Current: 1",
			"Sync effect"
		})
		expect(v3.getChildren()).toEqual({ span(1) })
	end)
	it("force flushes passive effects before firing new layout effects", function()
		local count = "(empty)"

		local function Counter(p)
			useLayoutEffect(function()
				count = tostring(p.count)
				v4.unstable_yieldValue("Mount layout [current: " .. count .. "]")
				return function()
					v4.unstable_yieldValue("Unmount layout [current: " .. count .. "]")
				end
			end)
			useEffect(function()
				v4.unstable_yieldValue("Mount normal [current: " .. count .. "]")
				return function()
					v4.unstable_yieldValue("Unmount normal [current: " .. count .. "]")
				end
			end)
			return nil
		end

		act(function()
			v3.render(v.createElement(Counter, {
				count = 0
			}), function()
				return v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Mount layout [current: 0]", "Sync effect" })
			expect(count).toEqual("0")
			v3.render(v.createElement(Counter, {
				count = 1
			}), function()
				return v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({
				"Mount normal [current: 0]",
				"Unmount layout [current: 0]",
				"Mount layout [current: 1]",
				"Sync effect"
			})
			expect(count).toEqual("1")
		end)
		expect(v4).toHaveYielded({ "Unmount normal [current: 1]", "Mount normal [current: 1]" })
	end)
	xit("catches errors thrown in useLayoutEffect", function()
		local extended = v.Component:extend("ErrorBoundary")

		function extended:init()
			self.state = {
				error = nil
			}
		end

		function extended.getDerivedStateFromError(error2)
			v4.unstable_yieldValue("ErrorBoundary static getDerivedStateFromError")
			return {
				error = error2
			}
		end

		local function Component(p)
			local id = p.id
			v4.unstable_yieldValue("Component render " .. id)
			return v.createElement(span, {
				prop = id
			})
		end

		function extended.render(p)
			local children = p.props.children
			local id = p.props.id
			local fallbackID = p.props.fallbackID

			if p.state.error then
				v4.unstable_yieldValue(id .. " render error")
				return v.createElement(Component, {
					id = fallbackID
				})
			end

			v4.unstable_yieldValue(id .. " render success")
			return children
		end

		local function BrokenLayoutEffectDestroy()
			useLayoutEffect(function()
				return function()
					v4.unstable_yieldValue("BrokenLayoutEffectDestroy useLayoutEffect destroy")
					error("Expected")
				end
			end, {})
			v4.unstable_yieldValue("BrokenLayoutEffectDestroy render")
			return v.createElement(span, {
				prop = "broken"
			})
		end

		v3.render(v.createElement(extended, {
			id = "OuterBoundary",
			fallbackID = "OuterFallback"
		}, { v.createElement(Component, {
				id = "sibling"
			}), v.createElement(extended, {
				id = "InnerBoundary",
				fallbackID = "InnerFallback"
			}, v.createElement(BrokenLayoutEffectDestroy)) }))
		expect(v4).toFlushAndYield({
			"OuterBoundary render success",
			"Component render sibling",
			"InnerBoundary render success",
			"BrokenLayoutEffectDestroy render"
		})
		expect(v3.getChildren()).toEqual({ v.createElement(span, {
				id = "sibling"
			}), v.createElement(span, {
				id = "broken"
			}) })
		v3.render(v.createElement(extended, {
			id = "OuterBoundary",
			fallbackID = "OuterFallback"
		}, v.createElement(Component, {
			id = "sibling"
		})))
		expect(v4).toFlushAndYield({
			"OuterBoundary render success",
			"Component render sibling",
			"BrokenLayoutEffectDestroy useLayoutEffect destroy",
			"ErrorBoundary static getDerivedStateFromError",
			"OuterBoundary render error",
			"Component render OuterFallback"
		})
		expect(v3.getChildren()).toEqual({ span("OuterFallback") })
	end)
end)
describe("useCallback", function()
	it("memoizes callback by comparing inputs", function()
		local ref = v.createRef()
		local extended = v.PureComponent:extend("IncrementButton")

		function extended.increment(p)
			p.props.increment()
		end

		function extended.render(_)
			return v.createElement(Text, {
				text = "Increment"
			})
		end

		local v5 = nil

		local function Counter(p)
			local incrementBy = p.incrementBy
			local state, setState = useState(0)
			local increment = useCallback(function()
				return setState(function(p2)
					return p2 + incrementBy
				end)
			end, { incrementBy })
			v5 = v.createElement(extended, {
				key = "1",
				increment = increment,
				ref = ref
			})
			return v.createElement(v.Fragment, {}, { v5, v.createElement(Text, {
					key = "2",
					text = "Count: " .. state
				}) })
		end

		v3.render(v.createElement(Counter, {
			incrementBy = 1
		}))
		expect(v4).toFlushAndYield({ "Increment", "Count: 0" })
		expect(v3.getChildren()).toEqual({ span("Increment"), span("Count: 0") })
		act(function()
			ref.current.increment(v5)
		end)
		expect(v4).toHaveYielded({ "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Increment"), span("Count: 1") })
		v3.render(v.createElement(Counter, {
			incrementBy = 10
		}))
		expect(v4).toFlushAndYield({ "Increment", "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Increment"), span("Count: 1") })
		act(function()
			ref.current.increment(v5)
		end)
		expect(v4).toHaveYielded({ "Count: 11" })
		expect(v3.getChildren()).toEqual({ span("Increment"), span("Count: 11") })
	end)
	it("correctly interprets input changes with nil values", function()
		local increment = nil
		local extended = v.PureComponent:extend("IncrementButton")

		function extended.render(p)
			increment = p.props.increment
			return v.createElement(Text, {
				text = "Increment"
			})
		end

		local function Counter(p)
			local v5 = {}

			for k, v6 in string.split(p.input, "") do
				if v6 == "." then
					v6 = nil
				end

				v5[k] = v6
			end

			local state, setState = useState(0)
			local increment2 = useCallback(function()
				return setState(function(p2)
					return p2 + p.incrementBy
				end)
			end, v5)
			return v.createElement(v.Fragment, {}, v.createElement(extended, {
				increment = increment2
			}), v.createElement(Text, {
				text = "Count: " .. state
			}))
		end

		v3.render(v.createElement(Counter, {
			input = "A....",
			incrementBy = 1
		}))
		expect(v4).toFlushAndYield({ "Increment", "Count: 0" })
		expect(v3.getChildren()).toEqual({ span("Increment"), span("Count: 0") })
		act(increment)
		expect(v4).toHaveYielded({ "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Increment"), span("Count: 1") })
		v3.render(v.createElement(Counter, {
			input = "A....",
			incrementBy = 10
		}))
		expect(v4).toFlushAndYield({ "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Increment"), span("Count: 1") })
		act(increment)
		expect(v4).toHaveYielded({ "Count: 2" })
		expect(v3.getChildren()).toEqual({ span("Increment"), span("Count: 2") })
		v3.render(v.createElement(Counter, {
			input = "A...E",
			incrementBy = 10
		}))
		expect(v4).toFlushAndYield({ "Increment", "Count: 2" })
		expect(v3.getChildren()).toEqual({ span("Increment"), span("Count: 2") })
		act(increment)
		expect(v4).toHaveYielded({ "Count: 12" })
		expect(v3.getChildren()).toEqual({ span("Increment"), span("Count: 12") })
	end)
end)
describe("useMemo", function()
	it("memoizes value by comparing to previous inputs", function()
		local function CapitalizedText(p)
			local text = p.text
			local text2 = useMemo(function()
				v4.unstable_yieldValue("Capitalize '" .. text .. "'")
				return string.upper(text)
			end, { text })
			return v.createElement(Text, {
				text = text2
			})
		end

		v3.render(v.createElement(CapitalizedText, {
			text = "hello"
		}))
		expect(v4).toFlushAndYield({ "Capitalize 'hello'", "HELLO" })
		expect(v3.getChildren()).toEqual({ span("HELLO") })
		v3.render(v.createElement(CapitalizedText, {
			text = "hi"
		}))
		expect(v4).toFlushAndYield({ "Capitalize 'hi'", "HI" })
		expect(v3.getChildren()).toEqual({ span("HI") })
		v3.render(v.createElement(CapitalizedText, {
			text = "hi"
		}))
		expect(v4).toFlushAndYield({ "HI" })
		expect(v3.getChildren()).toEqual({ span("HI") })
		v3.render(v.createElement(CapitalizedText, {
			text = "goodbye"
		}))
		expect(v4).toFlushAndYield({ "Capitalize 'goodbye'", "GOODBYE" })
		expect(v3.getChildren()).toEqual({ span("GOODBYE") })
	end)
	it("returns multiple input values", function()
		local function Doubler(p)
			local x = p.x
			local y = p.y
			local v5, v6 = useMemo(function()
				local v7 = x - y
				local v8 = x + y
				v4.unstable_yieldValue("x - y = " .. tostring(v7) .. ", x + y = " .. tostring(v8))
				return v7, v8
			end, { x, y })
			return v.createElement(Text, {
				text = tostring(v5) .. tostring(v6)
			})
		end

		v3.render(v.createElement(Doubler, {
			x = 1,
			y = 2
		}))
		expect(v4).toFlushAndYield({ "x - y = -1, x + y = 3", "-13" })
		expect(v3.getChildren()).toEqual({ span("-13") })
		v3.render(v.createElement(Doubler, {
			x = 4,
			y = 2
		}))
		expect(v4).toFlushAndYield({ "x - y = 2, x + y = 6", "26" })
		expect(v3.getChildren()).toEqual({ span("26") })
		v3.render(v.createElement(Doubler, {
			x = 4,
			y = 2
		}))
		expect(v4).toFlushAndYield({ "26" })
		expect(v3.getChildren()).toEqual({ span("26") })
		v3.render(v.createElement(Doubler, {
			x = 8,
			y = 2
		}))
		expect(v4).toFlushAndYield({ "x - y = 6, x + y = 10", "610" })
		expect(v3.getChildren()).toEqual({ span("610") })
	end)
	it("always re-computes if no inputs are provided", function()
		local function LazyCompute(p)
			local text = useMemo(p.compute)
			return v.createElement(Text, {
				text = text
			})
		end

		local function computeA()
			v4.unstable_yieldValue("compute A")
			return "A"
		end

		local function computeB()
			v4.unstable_yieldValue("compute B")
			return "B"
		end

		v3.render(v.createElement(LazyCompute, {
			compute = computeA
		}))
		expect(v4).toFlushAndYield({ "compute A", "A" })
		v3.render(v.createElement(LazyCompute, {
			compute = computeA
		}))
		expect(v4).toFlushAndYield({ "compute A", "A" })
		v3.render(v.createElement(LazyCompute, {
			compute = computeA
		}))
		expect(v4).toFlushAndYield({ "compute A", "A" })
		v3.render(v.createElement(LazyCompute, {
			compute = computeB
		}))
		expect(v4).toFlushAndYield({ "compute B", "B" })
	end)
	it("should not invoke memoized function during re-renders unless inputs change", function()
		local function LazyCompute(p)
			local text = useMemo(function()
				return p.compute(p.input)
			end, { p.input })
			local state, setState = useState(0)

			if state < 3 then
				setState(state + 1)
			end

			return v.createElement(Text, {
				text = text
			})
		end

		local function compute(p)
			v4.unstable_yieldValue("compute " .. p)
			return p
		end

		v3.render(v.createElement(LazyCompute, {
			compute = compute,
			input = "A"
		}))
		expect(v4).toFlushAndYield({ "compute A", "A" })
		v3.render(v.createElement(LazyCompute, {
			compute = compute,
			input = "A"
		}))
		expect(v4).toFlushAndYield({ "A" })
		v3.render(v.createElement(LazyCompute, {
			compute = compute,
			input = "B"
		}))
		expect(v4).toFlushAndYield({ "compute B", "B" })
	end)
	it("correctly interprets input changes with nil values", function()
		local function LazyCompute(p)
			local v5 = {}

			for k, v6 in string.split(p.input, "") do
				if v6 == "." then
					v6 = nil
				end

				v5[k] = v6
			end

			local text = useMemo(function()
				return p.compute(p.input)
			end, v5)
			return v.createElement(Text, {
				text = text
			})
		end

		local function compute(p)
			v4.unstable_yieldValue("compute " .. p)
			return p
		end

		v3.render(v.createElement(LazyCompute, {
			compute = compute,
			input = "A...."
		}))
		expect(v4).toFlushAndYield({ "compute A....", "A...." })
		v3.render(v.createElement(LazyCompute, {
			compute = compute,
			input = "A...E"
		}))
		expect(v4).toFlushAndYield({ "compute A...E", "A...E" })
		v3.render(v.createElement(LazyCompute, {
			compute = compute,
			input = "ABCDE"
		}))
		expect(v4).toFlushAndYield({ "compute ABCDE", "ABCDE" })
		v3.render(v.createElement(LazyCompute, {
			compute = compute,
			input = "....E"
		}))
		expect(v4).toFlushAndYield({ "compute ....E", "....E" })
		v3.render(v.createElement(LazyCompute, {
			compute = compute,
			input = "..C.."
		}))
		expect(v4).toFlushAndYield({ "compute ..C..", "..C.." })
	end)
end)
describe("useRef", function()
	it("creates a ref object initialized with the provided value", function()
		local function useDebouncedCallback(fn, p, p2)
			local v5 = useRef(setTimeout(function() end, 0))
			useEffect(function()
				return function()
					if typeof(v5.current) == "table" then
						clearTimeout(v5.current)
					end
				end
			end, {})
			local v6 = useCallback(function(...)
				if typeof(v5.current) == "table" then
					clearTimeout(v5.current)
				end

				v5.current = setTimeout(fn, p, ...)
			end, { fn, p })
			return useCallback(v6, p2)
		end

		local v5 = nil

		local function App()
			v5 = useDebouncedCallback(function(p)
				v4.unstable_yieldValue("ping: " .. p)
			end, 100, {})
			return nil
		end

		act(function()
			v3.render(v.createElement(App))
		end)
		expect(v4).toHaveYielded({})
		v5(1)
		v5(2)
		v5(3)
		expect(v4).toHaveYielded({})
		jest.advanceTimersByTime(100)
		expect(v4).toHaveYielded({ "ping: 3" })
		v5(4)
		jest.advanceTimersByTime(20)
		expect(v4).toHaveYielded({})
		v5(5)
		expect(v4).toHaveYielded({})
		v5(6)
		expect(v4).toHaveYielded({})
		jest.advanceTimersByTime(80)
		expect(v4).toHaveYielded({})
		jest.advanceTimersByTime(20)
		expect(v4).toHaveYielded({ "ping: 6" })
	end)
	it("should return the same ref during re-renders", function()
		local function Counter()
			local v5 = useRef("val")
			local state, setState = useState(0)

			if useState(v5) ~= v5 then
				error("should never change")
			end

			if state < 3 then
				setState(state + 1)
			end

			return v.createElement(Text, {
				text = v5.current
			})
		end

		v3.render(v.createElement(Counter))
		expect(v4).toFlushAndYield({ "val" })
		v3.render(v.createElement(Counter))
		expect(v4).toFlushAndYield({ "val" })
	end)
end)
describe("useBinding", function()
	it("creates a binding object initialized with the provided value", function()
		local function useDebouncedCallback(fn, p, p2)
			local v5, v6 = useBinding(setTimeout(function() end, 0))
			useEffect(function()
				return function()
					if typeof(v5:getValue()) == "table" then
						clearTimeout(v5:getValue())
					end
				end
			end, {})
			local v7 = useCallback(function(...)
				if typeof(v5:getValue()) == "table" then
					clearTimeout(v5:getValue())
				end

				v6(setTimeout(fn, p, ...))
			end, { fn, p })
			return useCallback(v7, p2)
		end

		local v5 = nil

		local function App()
			v5 = useDebouncedCallback(function(p)
				v4.unstable_yieldValue("ping: " .. p)
			end, 100, {})
			return nil
		end

		act(function()
			v3.render(v.createElement(App))
		end)
		expect(v4).toHaveYielded({})
		v5(1)
		v5(2)
		v5(3)
		expect(v4).toHaveYielded({})
		jest.advanceTimersByTime(100)
		expect(v4).toHaveYielded({ "ping: 3" })
		v5(4)
		jest.advanceTimersByTime(20)
		expect(v4).toHaveYielded({})
		v5(5)
		expect(v4).toHaveYielded({})
		v5(6)
		expect(v4).toHaveYielded({})
		jest.advanceTimersByTime(80)
		expect(v4).toHaveYielded({})
		jest.advanceTimersByTime(20)
		expect(v4).toHaveYielded({ "ping: 6" })
	end)
	it("should return the same binding value during re-renders", function()
		local function Counter()
			local v5, _ = useBinding("val")
			local state, setState = useState(0)

			if useState(v5) ~= v5 then
				error("should never change")
			end

			if state < 3 then
				setState(state + 1)
			end

			return v.createElement(Text, {
				text = v5:getValue()
			})
		end

		v3.render(v.createElement(Counter))
		expect(v4).toFlushAndYield({ "val" })
		v3.render(v.createElement(Counter))
		expect(v4).toFlushAndYield({ "val" })
	end)
end)
describe("useImperativeHandle", function()
	it("does not update when deps are the same", function()
		local function reducer_(p: number, p2)
			if p2 == "INCREMENT" then
				return p + 1
			end

			return p
		end

		local function Counter(_, p)
			local count, dispatch = useReducer(reducer_, 0)
			useImperativeHandle(p, function()
				return {
					count = count,
					dispatch = dispatch
				}
			end, {})
			return v.createElement(Text, {
				text = "Count: " .. count
			})
		end

		local v5 = forwardRef(Counter)
		local ref = v.createRef()
		v3.render(v.createElement(v5, {
			ref = ref
		}))
		expect(v4).toFlushAndYield({ "Count: 0" })
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
		expect(ref.current.count).toEqual(0)
		act(function()
			ref.current.dispatch("INCREMENT")
		end)
		expect(v4).toHaveYielded({ "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Count: 1") })
		expect(ref.current.count).toEqual(0)
	end)
	it("automatically updates when deps are not specified", function()
		local function reducer_(p: number, p2)
			if p2 == "INCREMENT" then
				return p + 1
			end

			return p
		end

		local function Counter(_, p)
			local count, dispatch = useReducer(reducer_, 0)
			useImperativeHandle(p, function()
				return {
					count = count,
					dispatch = dispatch
				}
			end)
			return v.createElement(Text, {
				text = "Count: " .. count
			})
		end

		local v5 = forwardRef(Counter)
		local ref = v.createRef()
		v3.render(v.createElement(v5, {
			ref = ref
		}))
		expect(v4).toFlushAndYield({ "Count: 0" })
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
		expect(ref.current.count).toEqual(0)
		act(function()
			ref.current.dispatch("INCREMENT")
		end)
		expect(v4).toHaveYielded({ "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Count: 1") })
		expect(ref.current.count).toEqual(1)
	end)
	it("updates when deps are different", function()
		local function reducer_(p: number, p2)
			if p2 == "INCREMENT" then
				return p + 1
			end

			return p
		end

		local count = 0

		local function Counter(_, p)
			local count2, dispatch = useReducer(reducer_, 0)
			useImperativeHandle(p, function()
				count += 1
				return {
					count = count2,
					dispatch = dispatch
				}
			end, { count2 })
			return v.createElement(Text, {
				text = "Count: " .. count2
			})
		end

		local v5 = forwardRef(Counter)
		local ref = v.createRef()
		v3.render(v.createElement(v5, {
			ref = ref
		}))
		expect(v4).toFlushAndYield({ "Count: 0" })
		expect(v3.getChildren()).toEqual({ span("Count: 0") })
		expect(ref.current.count).toEqual(0)
		expect(count).toEqual(1)
		act(function()
			ref.current.dispatch("INCREMENT")
		end)
		expect(v4).toHaveYielded({ "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Count: 1") })
		expect(ref.current.count).toEqual(1)
		expect(count).toEqual(2)
		v3.render(v.createElement(v5, {
			ref = ref
		}))
		expect(v4).toFlushAndYield({ "Count: 1" })
		expect(v3.getChildren()).toEqual({ span("Count: 1") })
		expect(ref.current.count).toEqual(1)
		expect(count).toEqual(2)
	end)
end)
describe("progressive enhancement (not supported)", function()
	it("mount additional state", function()
		local v5 = nil
		local v6 = nil

		local function App(p)
			local state, setState = useState(0)
			local state2, setState2 = useState(0)
			v5 = setState
			v6 = setState2
			local v7 = nil

			if p.loadC then
				useState(0)
			else
				v7 = "[not loaded]"
			end

			return v.createElement(Text, {
				text = string.format("A: %s, B: %s, C: %s", tostring(state), tostring(state2), (tostring(v7)))
			})
		end

		v3.render(v.createElement(App, {
			loadC = false
		}))
		expect(v4).toFlushAndYield({ "A: 0, B: 0, C: [not loaded]" })
		expect(v3.getChildren()).toEqual({ span("A: 0, B: 0, C: [not loaded]") })
		act(function()
			v5(2)
			v6(3)
		end)
		expect(v4).toHaveYielded({ "A: 2, B: 3, C: [not loaded]" })
		expect(v3.getChildren()).toEqual({ span("A: 2, B: 3, C: [not loaded]") })
		v3.render(v.createElement(App, {
			loadC = true
		}))
		expect(function()
			expect(function()
				expect(v4).toFlushAndYield({ "A: 2, B: 3, C: 0" })
			end).toThrow("Rendered more hooks than during the previous render")
		end).toErrorDev({ [[
Warning: React has detected a change in the order of Hooks called by App. This will lead to bugs and errors if not fixed. For more information, read the Rules of Hooks: https://reactjs.org/link/rules-of-hooks

   Previous render            Next render
   ------------------------------------------------------
1. useState                   useState
2. useState                   useState
3. undefined                  useState
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

]] })
	end)
	it("unmount state", function()
		local v5 = nil
		local v6 = nil
		local v7 = nil

		local function App(p)
			local state, setState = useState(0)
			local state2, setState2 = useState(0)
			v5 = setState
			v6 = setState2
			local state3

			if p.loadC then
				local setState3
				state3, setState3 = useState(0)
				v7 = setState3
			else
				state3 = "[not loaded]"
			end

			return v.createElement(Text, {
				text = string.format("A: %s, B: %s, C: %s", tostring(state), tostring(state2), (tostring(state3)))
			})
		end

		v3.render(v.createElement(App, {
			loadC = true
		}))
		expect(v4).toFlushAndYield({ "A: 0, B: 0, C: 0" })
		expect(v3.getChildren()).toEqual({ span("A: 0, B: 0, C: 0") })
		act(function()
			v5(2)
			v6(3)
			v7(4)
		end)
		expect(v4).toHaveYielded({ "A: 2, B: 3, C: 4" })
		expect(v3.getChildren()).toEqual({ span("A: 2, B: 3, C: 4") })
		v3.render(v.createElement(App, {
			loadC = false
		}))
		expect(v4).toFlushAndThrow("Rendered fewer hooks than expected. This may be caused by an accidental early return statement.")
	end)
	it("unmount effects", function()
		local function App(p)
			useEffect(function()
				v4.unstable_yieldValue("Mount A")
				return function()
					v4.unstable_yieldValue("Unmount A")
				end
			end, {})

			if p.showMore then
				useEffect(function()
					v4.unstable_yieldValue("Mount B")
					return function()
						v4.unstable_yieldValue("Unmount B")
					end
				end, {})
			end

			return nil
		end

		act(function()
			v3.render(v.createElement(App, {
				showMore = false
			}), function()
				v4.unstable_yieldValue("Sync effect")
			end)
			expect(v4).toFlushAndYieldThrough({ "Sync effect" })
		end)
		expect(v4).toHaveYielded({ "Mount A" })
		act(function()
			v3.render(v.createElement(App, {
				showMore = true
			}))
			expect(function()
				expect(function()
					expect(v4).toFlushAndYield({})
				end).toThrow("Rendered more hooks than during the previous render")
			end).toErrorDev({ [[
Warning: React has detected a change in the order of Hooks called by App. This will lead to bugs and errors if not fixed. For more information, read the Rules of Hooks: https://reactjs.org/link/rules-of-hooks

   Previous render            Next render
   ------------------------------------------------------
1. useEffect                  useEffect
2. undefined                  useEffect
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

]] })
		end)
	end)
end)
it("eager bailout optimization should always compare to latest rendered reducer", function()
	local state = nil
	local setState = nil

	local function Component(p)
		local count = p.count
		local v5, v6 = useReducer(function(_, _: nil)
			v4.unstable_yieldValue("Reducer: " .. tostring(count))
			return count
		end, -1)
		useEffect(function()
			v4.unstable_yieldValue("Effect: " .. tostring(count))
			v6()
		end, { count })
		v4.unstable_yieldValue("Render: " .. v5)
		return count
	end

	local function App()
		state, setState = useState(1)
		return v.createElement(Component, {
			count = state
		})
	end

	act(function()
		v3.render(v.createElement(App))
		expect(v4).toFlushAndYield({
			"Render: -1",
			"Effect: 1",
			"Reducer: 1",
			"Reducer: 1",
			"Render: 1"
		})
		expect(v3).toMatchRenderedOutput("1")
	end)
	act(function()
		setState(2)
	end)
	expect(v4).toHaveYielded({
		"Render: 1",
		"Effect: 2",
		"Reducer: 2",
		"Reducer: 2",
		"Render: 2"
	})
	expect(v3).toMatchRenderedOutput("2")
end)
it("should update latest rendered reducer when a preceding state receives a render phase update", function()
	local v5 = nil
	local v6 = nil

	local function App()
		local state, setState = useState(0)
		v5, v6 = useReducer(function(_, _: nil)
			return state
		end, state)

		if state < 5 then
			setState(state + 1)
		end

		v4.unstable_yieldValue("Step: " .. state .. ", Shadow: " .. v5)
		return v5
	end

	v3.render(v.createElement(App))
	expect(v4).toFlushAndYield({
		"Step: 0, Shadow: 0",
		"Step: 1, Shadow: 0",
		"Step: 2, Shadow: 0",
		"Step: 3, Shadow: 0",
		"Step: 4, Shadow: 0",
		"Step: 5, Shadow: 0"
	})
	expect(v3).toMatchRenderedOutput("0")
	act(function()
		return v6()
	end)
	expect(v4).toHaveYielded({ "Step: 5, Shadow: 5" })
	expect(v3).toMatchRenderedOutput("5")
end)
it("should process the rest pending updates after a render phase update", function()
	local v5 = nil
	local v6 = nil

	local function App()
		local state, setState = useState(false)
		local state2, setState2 = useState(false)

		if state ~= state2 then
			setState2(state)
		end

		local state3, setState3 = useState(false)
		v5 = setState
		v6 = setState3
		return string.format("%s%s%s", state and "A" or "a", state2 and "B" or "b", state3 and "C" or "c")
	end

	act(function()
		v3.render(v.createElement(App))
	end)
	expect(v3).toMatchRenderedOutput("abc")
	act(function()
		v5(true)
		v6(true)
	end)
	expect(v3).toMatchRenderedOutput("ABC")
end)
it("regression test: don't unmount effects on siblings of deleted nodes", function()
	local root = v3.createRoot()

	local function Child(p)
		local label = p.label
		useLayoutEffect(function()
			v4.unstable_yieldValue("Mount layout " .. label)
			return function()
				v4.unstable_yieldValue("Unmount layout " .. label)
			end
		end, { label })
		useEffect(function()
			v4.unstable_yieldValue("Mount passive " .. label)
			return function()
				v4.unstable_yieldValue("Unmount passive " .. label)
			end
		end, { label })
		return label
	end

	act(function()
		root.render(v.createElement(v.Fragment, nil, v.createElement(Child, {
			key = "A",
			label = "A"
		}), v.createElement(Child, {
			key = "B",
			label = "B"
		})))
	end)
	expect(v4).toHaveYielded({
		"Mount layout A",
		"Mount layout B",
		"Mount passive A",
		"Mount passive B"
	})
	act(function()
		root.render(v.createElement(v.Fragment, nil, v.createElement(Child, {
			key = "B",
			label = "B"
		})))
	end)
	expect(v4).toHaveYielded({ "Unmount layout A", "Unmount passive A" })
	act(function()
		root.render(nil)
	end)
	expect(v4).toHaveYielded({ "Unmount layout B", "Unmount passive B" })
end)
it("regression: deleting a tree and unmounting its effects after a reorder", function()
	local root = v3.createRoot()

	local function Child(p)
		local label = p.label
		useEffect(function()
			v4.unstable_yieldValue("Mount " .. label)
			return function()
				v4.unstable_yieldValue("Unmount " .. label)
			end
		end, { label })
		return label
	end

	act(function()
		root.render(v.createElement(v.Fragment, nil, v.createElement(Child, {
			key = "A",
			label = "A"
		}), v.createElement(Child, {
			key = "B",
			label = "B"
		})))
	end)
	expect(v4).toHaveYielded({ "Mount A", "Mount B" })
	act(function()
		root.render(v.createElement(v.Fragment, nil, v.createElement(Child, {
			key = "B",
			label = "B"
		}), v.createElement(Child, {
			key = "A",
			label = "A"
		})))
	end)
	expect(v4).toHaveYielded({})
	act(function()
		root.render(nil)
	end)
	expect(v4).toHaveYielded({ "Unmount B", "Unmount A" })
end)
it("effect dependencies are persisted after a render phase update", function()
	local fn

	local function Test()
		local state, setState = useState(0)
		useEffect(function()
			v4.unstable_yieldValue("Effect: " .. state)
		end, { state })

		if state > 0 then
			setState(0)
		end

		fn = function()
			return setState(2)
		end

		return v.createElement(Text, {
			text = string.format("Render: %d", state)
		})
	end

	act(function()
		v3.render(v.createElement(Test))
	end)
	expect(v4).toHaveYielded({ "Render: 0", "Effect: 0" })
	act(function()
		fn()
	end)
	expect(v4).toHaveYielded({ "Render: 0" })
	act(function()
		fn()
	end)
	expect(v4).toHaveYielded({ "Render: 0" })
	act(function()
		fn()
	end)
	expect(v4).toHaveYielded({ "Render: 0" })
end)