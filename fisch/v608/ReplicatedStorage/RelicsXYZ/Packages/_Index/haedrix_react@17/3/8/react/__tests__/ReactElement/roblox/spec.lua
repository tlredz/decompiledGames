local parent = script.Parent.Parent.Parent
local ReactElement = require(script.Parent.Parent.ReactElement)
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local Shared = require(parent.Shared)
local isValidElementType = Shared.isValidElementType
local Shared2 = require(parent.Shared)
local reactSymbols = Shared2.ReactSymbols
local v = nil
describe("creates valid React elements", function()
	it("from strings", function()
		v = ReactElement.createElement("TextLabel")
		expect(v).toBeDefined()
		expect(ReactElement.isValidElement(v)).toEqual(true)
		expect(v["$$typeof"]).toEqual(reactSymbols.REACT_ELEMENT_TYPE)
		expect(isValidElementType(v)).toBe(false)
	end)
	it("from functions", function()
		v = ReactElement.createElement(function()
			return nil
		end)
		expect(v).toBeDefined()
		expect(ReactElement.isValidElement(v)).toEqual(true)
		expect(isValidElementType(v)).toBe(false)
	end)
end)
describe("keys", function()
	it("should leave number keys as number", function()
		v = ReactElement.createElement("Frame", {
			key = 2,
			Size = UDim2.new(1, 0, 1, 0)
		})
		expect(v.key).toEqual(2)
	end)
	it("should convert table keys to string", function()
		local v2 = {}
		v = ReactElement.createElement("Frame", {
			key = v2,
			Size = UDim2.new(1, 0, 1, 0)
		})
		expect(v.key).toEqual((tostring(v2)))
	end)
	it("should leave string keys as strings", function()
		v = ReactElement.createElement("Frame", {
			key = "hello",
			Size = UDim2.new(1, 0, 1, 0)
		})
		expect(v.key).toEqual("hello")
	end)
	it("should have element.key == nil if no key is passed", function()
		v = ReactElement.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0)
		})
		expect(v.key).toEqual(nil)
	end)
end)
describe("should accept", function()
	it("props", function()
		v = ReactElement.createElement("StringValue", {
			Value = "Foo"
		})
		expect(v).toBeDefined()
		expect(v.props.Value).toEqual("Foo")
		expect(v.props.children).never.toBeDefined()
	end)
	it("a child and props", function()
		local element = ReactElement.createElement("IntValue")
		v = ReactElement.createElement("StringValue", {
			Value = "Foo"
		}, element)
		expect(v).toBeDefined()
		expect(v.props.Value).toEqual("Foo")
		expect(v.props.children).toBeDefined()
		expect(v.props.children).toEqual(element)
	end)
	it("a child and no props", function()
		local element = ReactElement.createElement("IntValue")
		v = ReactElement.createElement("StringValue", nil, element)
		expect(v).toBeDefined()
		expect(v.props.Value).toEqual(nil)
		expect(v.props.children).toBeDefined()
		expect(v.props.children).toEqual(element)
	end)
	it("multiple children and no props", function()
		local element = ReactElement.createElement("IntValue")
		local element2 = ReactElement.createElement("StringValue")
		v = ReactElement.createElement("StringValue", nil, element, element2)
		expect(v).toBeDefined()
		expect(v.props.Value).toEqual(nil)
		expect(v.props.children).toBeDefined()
		expect(v.props.children).toEqual({ element, element2 })
	end)
	it("a table of children and no props", function()
		local element = ReactElement.createElement("IntValue")
		local element2 = ReactElement.createElement("StringValue")
		v = ReactElement.createElement("StringValue", nil, {
			Child1 = element,
			Child2 = element2
		})
		expect(v).toBeDefined()
		expect(v.props.Value).toEqual(nil)
		expect(v.props.children).toBeDefined()
		expect(v.props.children).toEqual({
			Child1 = element,
			Child2 = element2
		})
	end)
	it("a false value for a boolean prop", function()
		v = ReactElement.createElement("BoolValue", {
			Value = false
		})
		expect(v).toBeDefined()
		expect(v.props.Value).toEqual(false)
	end)
end)