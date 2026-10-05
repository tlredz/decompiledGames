local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local Shared = require(parent.Shared)
local isValidElementType = Shared.isValidElementType
local Shared2 = require(parent.Shared)
local reactSymbols = Shared2.ReactSymbols
local fn = nil
describe("accept element primitives", function()
	it("from strings", function()
		fn = "TextLabel"
		expect(isValidElementType(fn)).toBe(true)
	end)
	it("from functions", function()
		fn = function() end

		expect(isValidElementType(fn)).toBe(true)
	end)
	it("from tables", function()
		fn = {}
		fn["$$typeof"] = reactSymbols.REACT_CONTEXT_TYPE
		expect(isValidElementType(fn)).toBe(true)
	end)
end)
describe("does not accept", function()
	it("REACT_ELEMENT_TYPE", function()
		fn = {}
		fn["$$typeof"] = reactSymbols.REACT_ELEMENT_TYPE
		expect(isValidElementType(fn)).toBe(false)
	end)
end)