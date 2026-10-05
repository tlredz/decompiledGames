local parent = script.Parent.Parent.Parent
local v = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local jest = JestGlobals.jest
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
JestGlobals.beforeEach(function()
	jest.resetModules()
	local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
	v3 = ReactNoopRenderer
	local parentModule = require(script.Parent.Parent)
	v = parentModule
	local Shared = require(parent.Shared)
	v2 = Shared
end)

local function initTests(fn, p)
	it("has correct state populated in render w/ " .. p, function()
		local extended = v.Component:extend("Component")
		fn(extended, "name", "Mike")
		local state = nil

		function extended.render(p2)
			state = p2.state
		end

		v3.act(function()
			v3.render(v.createElement(extended))
		end)
		expect(state).toEqual({
			name = "Mike"
		})
	end)
	it("has derived state populated in render w/ " .. p, function()
		local extended = v.Component:extend("Component")
		fn(extended, "name", "Mike")
		local state = nil

		function extended.render(p2)
			state = p2.state
		end

		function extended.getDerivedStateFromProps(p2, p3)
			return {
				name = p3.name,
				surname = p2.surname
			}
		end

		v3.act(function()
			v3.render(v.createElement(extended, {
				surname = "Smith"
			}))
		end)
		expect(state).toEqual({
			name = "Mike",
			surname = "Smith"
		})
	end)
	it("respects React.None in derived state w/ " .. p, function()
		local extended = v.Component:extend("Component")
		fn(extended, "name", "Mike")
		local state = nil

		function extended.render(p2)
			state = p2.state
		end

		function extended.getDerivedStateFromProps(p2, _)
			return {
				name = v.None,
				surname = p2.surname
			}
		end

		v3.act(function()
			v3.render(v.createElement(extended, {
				surname = "Smith"
			}))
		end)
		expect(state).toEqual({
			surname = "Smith"
		})
	end)
	it("updates state correctly w/ " .. p, function()
		local extended = v.Component:extend("Component")
		fn(extended, "name", "Mike")
		local state = nil
		local fn2

		function extended.render(object)
			fn2 = function(...)
				object:setState(...)
			end

			state = object.state
		end

		v3.act(function()
			v3.render(v.createElement(extended))
		end)
		expect(state).toEqual({
			name = "Mike"
		})
		v3.act(function()
			fn2({
				surname = "Smith"
			})
		end)
		expect(state).toEqual({
			name = "Mike",
			surname = "Smith"
		})
	end)
	it("updates state correctly with functional setState w/ " .. p, function()
		local extended = v.Component:extend("Component")
		fn(extended, "count", 0)
		local state = nil
		local fn2

		function extended.render(object)
			fn2 = function(...)
				object:setState(...)
			end

			state = object.state
		end

		v3.act(function()
			v3.render(v.createElement(extended))
		end)
		expect(state).toEqual({
			count = 0
		})
		v3.act(function()
			fn2(function(p2, _)
				return {
					count = p2.count + 1
				}
			end)
		end)
		expect(state).toEqual({
			count = 1
		})
	end)
	it("updates a pure component when state changes w/ " .. p, function()
		local extended = v.PureComponent:extend("Component")
		fn(extended, "name", "Mike")
		local state = nil
		local fn2
		local count = 0

		function extended.render(object)
			fn2 = function(...)
				object:setState(...)
			end

			state = object.state
			count += 1
		end

		v3.act(function()
			v3.render(v.createElement(extended))
		end)
		expect(state).toEqual({
			name = "Mike"
		})
		local v4 = count
		v3.act(function()
			fn2({
				name = "Bob"
			})
		end)
		expect(state).toEqual({
			name = "Bob"
		})
		expect(v4 < count).toEqual(true)
	end)
	it("does not update a pure component with a no-op setState w/ " .. p, function()
		local extended = v.PureComponent:extend("Component")
		fn(extended, "name", "Mike")
		local state = nil
		local fn2
		local count = 0

		function extended.render(object)
			fn2 = function(...)
				object:setState(...)
			end

			state = object.state
			count += 1
		end

		v3.act(function()
			v3.render(v.createElement(extended))
		end)
		expect(state).toEqual({
			name = "Mike"
		})
		local v4 = count
		v3.act(function()
			fn2({
				name = "Mike"
			})
		end)
		expect(state).toEqual({
			name = "Mike"
		})
		expect(v4).toEqual(count)
	end)
end

initTests(function(p, p2, p3)
	function p.init(object)
		object:setState({
			[p2] = p3
		})
	end
end, "setState in constructor")
initTests(function(p, p2, p3)
	function p:init()
		self.state = {
			[p2] = p3
		}
	end
end, "self.state in constructor")
describe("setState-specific behavior", function()
	it("allows multiple setStates in sequence during init", function()
		local extended = v.Component:extend("MyComponent")
		local state = nil

		function extended.init(object)
			object:setState({
				value = 1
			})
			object:setState({
				otherValue = 2
			})
		end

		function extended.render(_)
			return nil
		end

		function extended.componentDidMount(p)
			state = p.state
		end

		v3.act(function()
			v3.render(v.createElement(extended))
		end)
		expect(state).toEqual({
			value = 1,
			otherValue = 2
		})
	end)
	it("accounts for `None` values", function()
		local extended = v.Component:extend("MyComponent")
		local state = nil

		function extended.init(object)
			object:setState({
				a = 1,
				b = 2
			})
			object:setState({
				a = v.None
			})
		end

		function extended.render(_)
			return nil
		end

		function extended.componentDidMount(p)
			state = p.state
		end

		v3.act(function()
			v3.render(v.createElement(extended))
		end)
		expect(state).toEqual({
			b = 2
		})
	end)
	it("provides an empty table to functional setState on first run", function()
		local extended = v.Component:extend("MyComponent")
		local state = nil
		local v4 = nil

		function extended.init(object)
			object:setState(function(p)
				v4 = p
				return {
					value = 1
				}
			end)
		end

		function extended.render(_)
			return nil
		end

		function extended.componentDidMount(p)
			state = p.state
		end

		v3.act(function()
			v3.render(v.createElement(extended))
		end)
		assert(v4 == v2.UninitializedState, "captured previous state differs from UninitializedState placeholder")
		expect(state).toEqual({
			value = 1
		})
	end)
	it("warns on accessing the initial empty state table", function()
		local extended = v.Component:extend("MyComponent")

		function extended.init(object)
			object:setState(function(p)
				return {
					value = (p.value or 0) + 1
				}
			end)
		end

		function extended.render(_)
			return nil
		end

		expect(function()
			v3.act(function()
				v3.render(v.createElement(extended))
			end)
		end).toWarnDev("Attempted to access uninitialized state. Use setState to initialize state")
	end)
	it("allows functional setState", function()
		local extended = v.Component:extend("MyComponent")
		local state = nil

		function extended.init(object)
			object:setState({
				value = 1
			})
			object:setState(function(p)
				return {
					value = p.value + 1
				}
			end)
		end

		function extended.render(_)
			return nil
		end

		function extended.componentDidMount(p)
			state = p.state
		end

		v3.act(function()
			v3.render(v.createElement(extended))
		end)
		expect(state).toEqual({
			value = 2
		})
	end)
	it("warns when given a `callback` argument", function()
		local extended = v.Component:extend("MyComponent")

		function extended.init(object)
			object:setState({
				value = 1
			}, function() end)
		end

		function extended.render(_)
			return nil
		end

		expect(function()
			v3.act(function()
				v3.render(v.createElement(extended))
			end)
		end).toWarnDev([[
Received a `callback` argument to `setState` during initialization of "MyComponent". The callback behavior is not supported when using `setState` in `init`.

Consider defining similar behavior in a `compontentDidMount` method instead.]])
	end)
	it("throws when given an invalid state payload", function()
		local extended = v.Component:extend("MyComponent")

		function extended.init(object)
			object:setState(true)
		end

		function extended.render(_)
			return nil
		end

		expect(function()
			expect(function()
				v3.act(function()
					v3.render(v.createElement(extended))
				end)
			end).toErrorDev("The above error occurred in the <MyComponent> component")
		end).toThrow("setState(...): takes an object of state variables to update or a function which returns an object of state variables.")
	end)
end)