local v = nil
local v2 = nil
local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local jest = JestGlobals.jest
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
describe("ReactIncrementalUpdatesMinimalism", function()
	beforeEach(function()
		jest.resetModules()
		local React = require(parent.React)
		v = React
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
	end)
	it("should render a simple component", function()
		local function Child()
			return v.createElement("div", nil, "Hello World")
		end

		local function Parent()
			return v.createElement(Child)
		end

		v2.render(v.createElement(Parent))
		expect((v2.flushWithHostCounters())).toEqual({
			hostDiffCounter = 0,
			hostUpdateCounter = 0
		})
		v2.render(v.createElement(Parent))
		expect(v2.flushWithHostCounters()).toEqual({
			hostDiffCounter = 1,
			hostUpdateCounter = 1
		})
	end)
	it("should not diff referentially equal host elements", function()
		local function Leaf(p)
			return v.createElement("span", nil, "hello", v.createElement("b"), p.name)
		end

		local element = v.createElement("div", nil, v.createElement(Leaf, {
			name = "world"
		}))

		local function Child()
			return element
		end

		local function Parent()
			return v.createElement(Child)
		end

		v2.render(v.createElement(Parent))
		expect(v2.flushWithHostCounters()).toEqual({
			hostDiffCounter = 0,
			hostUpdateCounter = 0
		})
		v2.render(v.createElement(Parent))
		expect(v2.flushWithHostCounters()).toEqual({
			hostDiffCounter = 0,
			hostUpdateCounter = 0
		})
	end)
	it("should not diff parents of setState targets", function()
		local v3 = nil

		local function Leaf(p)
			return v.createElement("span", nil, "hello", v.createElement("b"), p.name)
		end

		local extended = v.Component:extend("Child")

		function extended:init()
			self.state = {
				name = "Batman"
			}
		end

		function extended.render(p)
			v3 = p
			return v.createElement("div", nil, v.createElement(Leaf, {
				name = p.state.name
			}))
		end

		local function Parent()
			return v.createElement("section", nil, v.createElement("div", nil, v.createElement(Leaf, {
				name = "world"
			}), v.createElement(extended), v.createElement("hr"), v.createElement(Leaf, {
				name = "world"
			})))
		end

		v2.render(v.createElement(Parent))
		expect(v2.flushWithHostCounters()).toEqual({
			hostDiffCounter = 0,
			hostUpdateCounter = 0
		})
		v3:setState({
			name = "Robin"
		})
		expect(v2.flushWithHostCounters()).toEqual({
			hostDiffCounter = 3,
			hostUpdateCounter = 4
		})
		v2.render(v.createElement(Parent))
		expect(v2.flushWithHostCounters()).toEqual({
			hostDiffCounter = 10,
			hostUpdateCounter = 10
		})
	end)
end)