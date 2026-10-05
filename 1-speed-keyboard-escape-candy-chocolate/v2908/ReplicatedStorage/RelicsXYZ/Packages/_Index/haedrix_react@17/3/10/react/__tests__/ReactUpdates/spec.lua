local parent = script.Parent.Parent.Parent
local LuauPolyfill = require(parent.LuauPolyfill)
local array = LuauPolyfill.Array
local boolean = LuauPolyfill.Boolean
local error2 = LuauPolyfill.Error
local v = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local jest = JestGlobals.jest
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local expect = JestGlobals.expect
describe("ReactUpdates", function()
	beforeEach(function()
		jest.resetModules()
		local Shared = require(parent.Shared)
		Shared.ReactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode = true
		local parentModule = require(script.Parent.Parent)
		v = parentModule
		local ReactTestRenderer = require(parent.Dev.ReactTestRenderer)
		v2 = ReactTestRenderer
		local Scheduler = require(parent.Dev.Scheduler)
		v3 = Scheduler
	end)
	it("should batch state when updating state twice", function()
		local v4 = nil
		local count = 0
		local extended = v.Component:extend("Component")

		function extended:init()
			self.state = {
				x = 0
			}
		end

		function extended.componentDidUpdate(_)
			count += 1
		end

		function extended.render(p)
			v4 = p
			return v.createElement("div", nil, p.state.x)
		end

		v2.create(v.createElement(extended))
		expect(v4.state.x).toBe(0)
		v2.unstable_batchedUpdates(function()
			v4:setState({
				x = 1
			})
			v4:setState({
				x = 2
			})
			expect(v4.state.x).toBe(0)
			expect(count).toBe(0)
		end)
		expect(v4.state.x).toBe(2)
		expect(count).toBe(1)
	end)
	it("should batch state when updating two different state keys", function()
		local v4 = nil
		local count = 0
		local extended = v.Component:extend("Component")

		function extended:init()
			self.state = {
				x = 0,
				y = 0
			}
		end

		function extended.componentDidUpdate(_)
			count += 1
		end

		function extended.render(p)
			v4 = p
			return v.createElement("div", nil, string.format("(%s, %s)", p.state.x, p.state.y))
		end

		v2.create(v.createElement(extended))
		expect(v4.state.x).toBe(0)
		expect(v4.state.y).toBe(0)
		v2.unstable_batchedUpdates(function()
			v4:setState({
				x = 1
			})
			v4:setState({
				y = 2
			})
			expect(v4.state.x).toBe(0)
			expect(v4.state.y).toBe(0)
			expect(count).toBe(0)
		end)
		expect(v4.state.x).toBe(1)
		expect(v4.state.y).toBe(2)
		expect(count).toBe(1)
	end)
	it("should batch state and props together", function()
		local v4 = nil
		local count = 0
		local extended = v.Component:extend("Component")

		function extended:init()
			v4 = self
			self.state = {
				y = 0
			}
		end

		function extended.componentDidUpdate(_)
			count += 1
		end

		function extended.render(p)
			return v.createElement("div", nil, string.format("(%s, %s)", tostring(p.props.x), (tostring(p.state.y))))
		end

		local v5 = v2.create(v.createElement(extended, {
			x = 0
		}))
		expect(v4.props.x).toBe(0)
		expect(v4.state.y).toBe(0)
		v2.unstable_batchedUpdates(function()
			v5.update(v.createElement(extended, {
				x = 1
			}))
			v4:setState({
				y = 2
			})
			expect(v4.props.x).toBe(0)
			expect(v4.state.y).toBe(0)
			expect(count).toBe(0)
		end)
		expect(v4.props.x).toBe(1)
		expect(v4.state.y).toBe(2)
		expect(count).toBe(1)
	end)
	it("should batch parent/child state updates together", function()
		local v4 = nil
		local extended = v.Component:extend("Child")
		local count = 0
		local extended2 = v.Component:extend("Parent")

		function extended2:init()
			v4 = self
			self.state = {
				x = 0
			}
		end

		function extended2.componentDidUpdate(_)
			count += 1
		end

		local ref = v.createRef()

		function extended2.render(p)
			return v.createElement("div", nil, v.createElement(extended, {
				ref = ref,
				x = p.state.x
			}))
		end

		local count2 = 0

		function extended:init()
			self.state = {
				y = 0
			}
		end

		function extended.componentDidUpdate(_)
			count2 += 1
		end

		function extended.render(p)
			return v.createElement("div", nil, tostring(p.props.x) .. tostring(p.state.y))
		end

		v2.create(v.createElement(extended2))
		local current = ref.current
		expect(v4.state.x).toBe(0)
		expect(current.state.y).toBe(0)
		v2.unstable_batchedUpdates(function()
			v4:setState({
				x = 1
			})
			current:setState({
				y = 2
			})
			expect(v4.state.x).toBe(0)
			expect(current.state.y).toBe(0)
			expect(count).toBe(0)
			expect(count2).toBe(0)
		end)
		expect(v4.state.x).toBe(1)
		expect(current.state.y).toBe(2)
		expect(count).toBe(1)
		expect(count2).toBe(1)
	end)
	it("should batch child/parent state updates together", function()
		local extended = v.Component:extend("Child")
		local v4 = nil
		local count = 0
		local extended2 = v.Component:extend("Parent")

		function extended2:init()
			v4 = self
			self.state = {
				x = 0
			}
		end

		function extended2.componentDidUpdate(_)
			count += 1
		end

		local ref = v.createRef()

		function extended2.render(p)
			return v.createElement("div", nil, v.createElement(extended, {
				ref = ref,
				x = p.state.x
			}))
		end

		local count2 = 0

		function extended:init()
			self.state = {
				y = 0
			}
		end

		function extended.componentDidUpdate(_)
			count2 += 1
		end

		function extended.render(p)
			return v.createElement("div", nil, tostring(p.props.x) .. tostring(p.state.y))
		end

		v2.create(v.createElement(extended2))
		local current = ref.current
		expect(v4.state.x).toBe(0)
		expect(current.state.y).toBe(0)
		v2.unstable_batchedUpdates(function()
			current:setState({
				y = 2
			})
			v4:setState({
				x = 1
			})
			expect(v4.state.x).toBe(0)
			expect(current.state.y).toBe(0)
			expect(count).toBe(0)
			expect(count2).toBe(0)
		end)
		expect(v4.state.x).toBe(1)
		expect(current.state.y).toBe(2)
		expect(count).toBe(1)
		expect(count2).toBe(1)
	end)
	it("should support chained state updates", function()
		local v4 = nil
		local count = 0
		local extended = v.Component:extend("Component")

		function extended:init()
			v4 = self
			self.state = {
				x = 0
			}
		end

		function extended.componentDidUpdate(_)
			count += 1
		end

		function extended.render(p)
			return v.createElement("div", nil, p.state.x)
		end

		v2.create(v.createElement(extended))
		expect(v4.state.x).toBe(0)
		local v5 = false
		v2.unstable_batchedUpdates(function()
			v4:setState({
				x = 1
			}, function()
				v4:setState({
					x = 2
				}, function(p)
					expect(p).toBe(v4)
					v5 = true
					expect(v4.state.x).toBe(2)
					expect(count).toBe(2)
				end)
				expect(v4.state.x).toBe(1)
				expect(count).toBe(1)
			end)
			expect(v4.state.x).toBe(0)
			expect(count).toBe(0)
		end)
		expect(v5).toBeTruthy()
		expect(v4.state.x).toBe(2)
		expect(count).toBe(2)
	end)
	it("should batch forceUpdate together", function()
		local v4 = nil
		local count = 0
		local count2 = 0
		local extended = v.Component:extend("Component")

		function extended:init()
			v4 = self
			self.state = {
				x = 0
			}
		end

		function extended.shouldComponentUpdate(_)
			count += 1
			return false
		end

		function extended.componentDidUpdate(_)
			count2 += 1
		end

		function extended.render(p)
			return v.createElement("div", nil, p.state.x)
		end

		v2.create(v.createElement(extended))
		expect(v4.state.x).toBe(0)
		local count3 = 0
		v2.unstable_batchedUpdates(function()
			v4:setState({
				x = 1
			}, function()
				count3 += 1
			end)
			v4:forceUpdate(function()
				count3 += 1
			end)
			expect(v4.state.x).toBe(0)
			expect(count2).toBe(0)
		end)
		expect(count3).toBe(2)
		expect(count).toBe(0)
		expect(v4.state.x).toBe(1)
		expect(count2).toBe(1)
	end)
	it("should update children even if parent blocks updates", function()
		local v4 = nil
		local extended = v.Component:extend("Child")
		local count = 0
		local count2 = 0
		local extended2 = v.Component:extend("Parent")

		function extended2.init(p)
			v4 = p
		end

		function extended2.shouldComponentUpdate(_)
			return false
		end

		local ref = v.createRef()

		function extended2.render(_)
			count += 1
			return v.createElement(extended, {
				ref = ref
			})
		end

		function extended.render(_)
			count2 += 1
			return v.createElement("div")
		end

		expect(count).toBe(0)
		expect(count2).toBe(0)
		local element = v.createElement(extended2)
		v2.create(element)
		expect(count).toBe(1)
		expect(count2).toBe(1)
		v2.unstable_batchedUpdates(function()
			v4:setState({
				x = 1
			})
		end)
		expect(count).toBe(1)
		expect(count2).toBe(1)
		v2.unstable_batchedUpdates(function()
			ref.current:setState({
				x = 1
			})
		end)
		expect(count).toBe(1)
		expect(count2).toBe(2)
	end)
	it("should not reconcile children passed via props", function()
		local extended = v.Component:extend("Bottom")
		local extended2 = v.Component:extend("Middle")
		local count = 0
		local count2 = 0
		local extended3 = v.Component:extend("Top")

		function extended3.render(_)
			return v.createElement(extended2, nil, v.createElement(extended))
		end

		function extended2.componentDidMount(object)
			object:forceUpdate()
		end

		function extended2.render(p)
			count += 1
			return v.Children.only(p.props.children)
		end

		function extended.render(_)
			count2 += 1
			return nil
		end

		v2.create(v.createElement(extended3))
		expect(count).toBe(2)
		expect(count2).toBe(1)
	end)
	it.skip("should flow updates correctly", function() end)
	it.skip("should queue mount-ready handlers across different roots", function() end)
	it("should flush updates in the correct order", function()
		local v4 = nil
		local extended = v.Component:extend("Inner")
		local v5 = {}
		local extended2 = v.Component:extend("Outer")

		function extended2:init()
			v4 = self
			self.state = {
				x = 0
			}
		end

		local ref = v.createRef()

		function extended2.render(p)
			table.insert(v5, "Outer-render-" .. tostring(p.state.x))
			return v.createElement("div", nil, v.createElement(extended, {
				x = p.state.x,
				ref = ref
			}))
		end

		function extended2.componentDidUpdate(p)
			local x = p.state.x
			table.insert(v5, "Outer-didUpdate-" .. tostring(x))
			table.insert(v5, "Inner-setState-" .. tostring(x))
			ref.current:setState({
				x = x
			}, function()
				table.insert(v5, "Inner-callback-" .. tostring(x))
			end)
		end

		function extended:init()
			self.state = {
				x = 0
			}
		end

		function extended.render(p)
			table.insert(v5, "Inner-render-" .. tostring(p.props.x) .. "-" .. tostring(p.state.x))
			return v.createElement("div")
		end

		function extended.componentDidUpdate(p)
			table.insert(v5, "Inner-didUpdate-" .. tostring(p.props.x) .. "-" .. tostring(p.state.x))
		end

		v2.create(v.createElement(extended2))
		table.insert(v5, "Outer-setState-1")
		v4:setState({
			x = 1
		}, function()
			table.insert(v5, "Outer-callback-1")
			table.insert(v5, "Outer-setState-2")
			v4:setState({
				x = 2
			}, function()
				table.insert(v5, "Outer-callback-2")
			end)
		end)
		expect(v5).toEqual({
			"Outer-render-0",
			"Inner-render-0-0",
			"Outer-setState-1",
			"Outer-render-1",
			"Inner-render-1-0",
			"Inner-didUpdate-1-0",
			"Outer-didUpdate-1",
			"Inner-setState-1",
			"Outer-callback-1",
			"Outer-setState-2",
			"Outer-render-2",
			"Inner-render-2-1",
			"Inner-didUpdate-2-1",
			"Inner-callback-1",
			"Outer-didUpdate-2",
			"Inner-setState-2",
			"Outer-callback-2",
			"Inner-render-2-2",
			"Inner-didUpdate-2-2",
			"Inner-callback-2"
		})
	end)
	it("should flush updates in the correct order across roots", function()
		local v4 = {}
		local depths = {}
		local extended = v.Component:extend("MockComponent")

		function extended.render(p)
			table.insert(depths, p.props.depth)
			return v.createElement("div")
		end

		function extended.componentDidMount(p)
			table.insert(v4, p)

			if p.props.depth < p.props.count then
				v2.create(v.createElement(extended, {
					depth = p.props.depth + 1,
					count = p.props.count
				}))
			end
		end

		v2.create(v.createElement(extended, {
			depth = 0,
			count = 2
		}))
		expect(depths).toEqual({ 0, 1, 2 })
		v2.unstable_batchedUpdates(function()
			array.forEach(v4, function(object)
				object:forceUpdate()
			end)
		end)
		expect(depths).toEqual({
			0,
			1,
			2,
			0,
			1,
			2
		})
	end)
	it("should queue nested updates", function()
		local v4 = nil
		local v5 = nil
		local extended = v.Component:extend("Y")
		local extended2 = v.Component:extend("Z")
		local extended3 = v.Component:extend("X")

		function extended3:init()
			v4 = self
			self.state = {
				s = 0
			}
		end

		function extended3.render(p)
			if p.state.s == 0 then
				return v.createElement("div", nil, v.createElement("span", nil, "0"))
			end

			return v.createElement("div", nil, "1")
		end

		function extended3:go()
			self:setState({
				s = 1
			})
			self:setState({
				s = 0
			})
			self:setState({
				s = 1
			})
		end

		function extended.render(p)
			v5 = p
			return v.createElement("div", nil, v.createElement(extended2))
		end

		function extended2.render(_)
			return v.createElement("div")
		end

		function extended2.UNSAFE_componentWillUpdate(_)
			v4:go()
		end

		local v6 = v2.create(v.createElement(extended3))
		v2.create(v.createElement(extended))
		expect(v6.toJSON().children[1].children[1]).toBe("0")
		v5:forceUpdate()
		expect(v6.toJSON().children[1]).toBe("1")
	end)
	it("should queue updates from during mount", function()
		local v4 = nil
		local extended = v.Component:extend("")

		function extended:init()
			self.state = {
				x = 0
			}
		end

		function extended.UNSAFE_componentWillMount(p)
			v4 = p
		end

		function extended.render(p)
			return v.createElement("div", nil, "A" .. tostring(p.state.x))
		end

		local extended2 = v.Component:extend("")

		function extended2.UNSAFE_componentWillMount(_)
			v4:setState({
				x = 1
			})
		end

		function extended2.render(_)
			return v.createElement("div")
		end

		local v5 = nil
		v2.unstable_batchedUpdates(function()
			v5 = v2.create(v.createElement("div", nil, v.createElement(extended), v.createElement(extended2)))
		end)
		expect(v4.state.x).toBe(1)
		expect(v5.toJSON().children[1].children[1]).toBe("A1")
	end)
	it.skip("calls componentWillReceiveProps setState callback properly", function()
		local count = 0
		local extended = v.Component:extend("")

		function extended:init()
			self.state = {
				x = self.props.x
			}
		end

		function extended.UNSAFE_componentWillReceiveProps(object, p)
			local x = p.x
			object:setState({
				x = x
			}, function()
				expect(object.state.x).toBe(x)
				count += 1
			end)
		end

		function extended.render(p)
			return v.createElement("div", nil, p.state.x)
		end

		v2.create(v.createElement(extended, {
			x = 1
		}))
		v2.create(v.createElement(extended, {
			x = 2
		}))
		expect(count).toBe(1)
	end)
	it("does not call render after a component as been deleted", function()
		local count = 0
		local v4 = nil
		local v5 = nil
		local extended = v.Component:extend("")

		function extended:init()
			self.state = {
				updates = 0
			}
		end

		function extended.componentDidMount(p)
			v4 = p
		end

		function extended.render(_)
			count += 1
			return v.createElement("div")
		end

		local extended2 = v.Component:extend("")

		function extended2:init()
			v5 = self
			self.state = {
				showB = true
			}
		end

		function extended2.render(p)
			return (function()
				if boolean.toJSBoolean(p.state.showB) then
					return v.createElement(extended)
				end

				return v.createElement("div")
			end)()
		end

		v2.create(v.createElement(extended2))
		v2.unstable_batchedUpdates(function()
			v4:setState({
				updates = 1
			})
			v5:setState({
				showB = false
			})
		end)
		expect(count).toBe(1)
	end)
	it("throws in setState if the update callback is not a function", function()
		local v4 = nil
		local extended = v.Component:extend("A")

		function extended:init()
			self.state = {}
		end

		function extended.render(p)
			v4 = p
			return v.createElement("div")
		end

		v2.create(v.createElement(extended))
		expect(function()
			expect(function()
				v4:setState({}, "no")
			end).toErrorDev("setState(...): Expected the last optional `callback` argument to be a function. Instead received: no.", {
				withoutStack = true
			})
		end).toThrowError("Invalid argument passed as callback. Expected a function. Instead received: no")
		v2.create(v.createElement(extended))
		local v5 = {
			foo = "bar"
		}
		expect(function()
			expect(function()
				v4:setState({}, v5)
			end).toErrorDev("setState(...): Expected the last optional `callback` argument to be a function. Instead received: table.")
		end).toThrowError("Invalid argument passed as callback. Expected a function. Instead received: table")
		v2.create(v.createElement(extended))
		expect(function()
			v4:setState({}, v5)
		end).toThrowError("Invalid argument passed as callback. Expected a function. Instead received: table")
	end)
	it("throws in forceUpdate if the update callback is not a function", function()
		local v4 = nil
		local extended = v.Component:extend("A")

		function extended:init()
			self.state = {}
		end

		function extended.render(p)
			v4 = p
			return v.createElement("div")
		end

		v2.create(v.createElement(extended))
		expect(function()
			expect(function()
				v4:forceUpdate("no")
			end).toErrorDev("forceUpdate(...): Expected the last optional `callback` argument to be a function. Instead received: no.", {
				withoutStack = true
			})
		end).toThrowError("Invalid argument passed as callback. Expected a function. Instead received: no")
		v2.create(v.createElement(extended))
		local v5 = {
			foo = "bar"
		}
		expect(function()
			expect(function()
				v4:forceUpdate(v5)
			end).toErrorDev("forceUpdate(...): Expected the last optional `callback` argument to be a function. Instead received: table.")
		end).toThrowError("Invalid argument passed as callback. Expected a function. Instead received: table")
		v2.create(v.createElement(extended))
		expect(function()
			v4:forceUpdate(v5)
		end).toThrowError("Invalid argument passed as callback. Expected a function. Instead received: table")
	end)
	it("does not update one component twice in a batch (#2410)", function()
		local v4 = nil
		local extended = v.Component:extend("Child")
		local ref = v.createRef()
		local extended2 = v.Component:extend("Parent")

		function extended2:getChild()
			return ref.current
		end

		function extended2.render(p)
			v4 = p
			return v.createElement(extended, {
				ref = ref
			})
		end

		local count = 0
		local count2 = 0
		local v5 = false

		function extended:init()
			self.state = {
				updated = false
			}
		end

		function extended.UNSAFE_componentWillUpdate(object)
			if not boolean.toJSBoolean(v5) then
				v5 = true
				object:setState({
					updated = true
				})
			end
		end

		function extended.componentDidMount(_)
			expect(count).toBe(count2 + 1)
			count2 += 1
		end

		function extended.componentDidUpdate(_)
			expect(count).toBe(count2 + 1)
			count2 += 1
		end

		function extended.render(_)
			expect(count).toBe(count2)
			count += 1
			return v.createElement("div")
		end

		v2.create(v.createElement(extended2))
		local child = v4:getChild()
		v2.unstable_batchedUpdates(function()
			v4:forceUpdate()
			child:forceUpdate()
		end)
	end)
	it("unstable_batchedUpdates should return value from a callback", function()
		expect((v2.unstable_batchedUpdates(function()
			return 42
		end))).toEqual(42)
	end)
	it.skip("unmounts and remounts a root in the same batch", function()
		local v4 = v2.create(v.createElement("span", nil, "a"))
		v2.unstable_batchedUpdates(function()
			v4:update(v.createElement("span", nil, "b"))
		end)
		expect(v4.toJSON().children[1]).toBe("b")
	end)
	it("uses correct base state for setState inside render phase", function()
		local v4 = {}
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {
				step = 0
			}
		end

		function extended.render(object)
			local step = object.state.step
			object:setState(function(p)
				local step2 = p.step
				table.insert(v4, string.format("base: %s, memoized: %s", tostring(step2), step))
				return step2 == 0 and {
					step = 1
				} or nil
			end)
			return nil
		end

		expect(function()
			v2.create(v.createElement(extended))
		end).toErrorDev("Cannot update during an existing state transition")
		expect(v4).toEqual({ "base: 0, memoized: 0", "base: 1, memoized: 1" })
	end)
	it("does not re-render if state update is null", function()
		local v4 = nil
		local v5 = {}
		local extended = v.Component:extend("Foo")

		function extended.render(p)
			v4 = p
			table.insert(v5, "render")
			return v.createElement("div")
		end

		v2.create(v.createElement(extended))
		v5 = {}
		v4:setState(function()
			return nil
		end)
		expect(v5).toEqual({})
	end)
	it("synchronously renders hidden subtrees", function()
		local v4 = {}

		local function Baz()
			table.insert(v4, "Baz")
			return nil
		end

		local function Bar()
			table.insert(v4, "Bar")
			return nil
		end

		local function Foo()
			table.insert(v4, "Foo")
			return v.createElement("div", nil, v.createElement("div", {
				hidden = true
			}, v.createElement(Bar)), v.createElement(Baz))
		end

		v2.create(v.createElement(Foo))
		expect(v4).toEqual({ "Foo", "Bar", "Baz" })
		v4 = {}
		v2.create(v.createElement(Foo))
		expect(v4).toEqual({ "Foo", "Bar", "Baz" })
	end)
	it("does not fall into an infinite update loop with useLayoutEffect", function()
		local function NonTerminating()
			local state, setState = v.useState(0)
			v.useLayoutEffect(function()
				setState(function(p)
					return p + 1
				end)
			end)
			return state
		end

		expect(function()
			v2.create(v.createElement(NonTerminating))
		end).toThrow("Maximum")
	end)
	it("can recover after falling into an infinite update loop", function()
		local extended = v.Component:extend("NonTerminating")

		function extended:init()
			self.state = {
				step = 0
			}
		end

		function extended.componentDidMount(object)
			object:setState({
				step = 1
			})
		end

		function extended.componentDidUpdate(object)
			object:setState({
				step = 2
			})
		end

		function extended.render(p)
			return p.state.step
		end

		local extended2 = v.Component:extend("Terminating")

		function extended2:init()
			self.state = {
				step = 0
			}
		end

		function extended2.componentDidMount(object)
			object:setState({
				step = 1
			})
		end

		function extended2.render(p)
			return p.state.step
		end

		expect(function()
			v2.create(v.createElement(extended))
		end).toThrow("Maximum")
		expect(v2.create(v.createElement(extended2)).toJSON()).toBe("1")
		expect(function()
			v2.create(v.createElement(extended))
		end).toThrow("Maximum")
		expect(v2.create(v.createElement(extended2)).toJSON()).toBe("1")
	end)
	it.skip("does not fall into mutually recursive infinite update loop with same container", function()
		local extended = v.Component:extend("B")
		local v4 = v2.create(v.createElement("div"))
		local extended2 = v.Component:extend("A")

		function extended2.componentDidMount(_)
			v4:update(v.createElement(extended))
		end

		function extended2.render(_)
			return nil
		end

		function extended.componentDidMount(_)
			v4:update(v.createElement(extended2))
		end

		function extended.render(_)
			return nil
		end

		expect(function()
			v4:update(v.createElement(extended2))
		end).toThrow("Maximum")
	end)
	it("does not fall into an infinite error loop", function()
		local function BadRender()
			error(error2.new("error"))
		end

		local extended = v.Component:extend("ErrorBoundary")

		function extended.componentDidCatch(object)
			object:setState({})
			object.props.parent:remount()
		end

		function extended.render(_)
			return v.createElement(BadRender)
		end

		local extended2 = v.Component:extend("NonTerminating")

		function extended2:init()
			self.state = {
				step = 0
			}
		end

		function extended2:remount()
			self:setState(function(p)
				return {
					step = p.step + 1
				}
			end)
		end

		function extended2.render(parent2)
			return v.createElement(extended, {
				key = parent2.state.step,
				parent = parent2
			})
		end

		expect(function()
			v2.create(v.createElement(extended2))
		end).toThrow("Maximum")
	end)
	it("can have nested updates if they do not cross the limit", function()
		local v4 = nil

		local function Terminating()
			local state, setState = v.useState(0)
			v4 = setState
			v.useEffect(function()
				if state < 50 then
					setState(function(p)
						return p + 1
					end)
				end
			end)
			v3.unstable_yieldValue(state)
			return state
		end

		local v5 = nil
		v2.act(function()
			v5 = v2.create(v.createElement(Terminating))
		end)
		expect(v5.toJSON()).toBe("50")
		v2.act(function()
			v4(0)
		end)
		expect(v5.toJSON()).toBe("50")
	end)
	it("can have many updates inside useEffect without triggering a warning", function()
		local function Terminating()
			local state, setState = v.useState(0)
			v.useEffect(function()
				for _ = 1, 10000 do
					setState(function(p)
						return p + 1
					end)
				end

				v3.unstable_yieldValue("Done")
			end, {})
			return state
		end

		local v4 = nil
		v2.act(function()
			v4 = v2.create(v.createElement(Terminating))
		end)
		expect(v3).toHaveYielded({ "Done" })
		expect(v4.toJSON()).toBe("10000")
	end)
end)