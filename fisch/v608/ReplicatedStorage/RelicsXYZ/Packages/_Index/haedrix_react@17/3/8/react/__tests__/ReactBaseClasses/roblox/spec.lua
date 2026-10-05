local parent = script.Parent.Parent.Parent
local ReactBaseClasses = require(script.Parent.Parent.ReactBaseClasses)
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local component = ReactBaseClasses.Component
local component2 = ReactBaseClasses.Component
local v = nil
describe("Component", function()
	it("should prevent extending a second time", function()
		v = component:extend("Sheev")
		expect(function()
			v:extend("Frank")
		end).toThrow()
	end)
	it("should use a given name", function()
		v = component:extend("FooBar")
		local v2 = tostring(v)
		expect(v2).toEqual(expect.any("string"))
		expect(v2).toContain("FooBar")
	end)
end)
describe("PureComponent", function()
	it("should prevent extending a second time", function()
		v = component2:extend("Sheev")
		expect(function()
			v:extend("Frank")
		end).toThrow()
	end)
	it("should use a given name", function()
		v = component2:extend("FooBar")
		local v2 = tostring(v)
		expect(v2).toEqual(expect.any("string"))
		expect(v2).toContain("FooBar")
	end)
end)