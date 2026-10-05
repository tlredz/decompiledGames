local parent = script.Parent.Parent.Parent
local LuauPolyfill = require(parent.LuauPolyfill)
local error2 = LuauPolyfill.Error
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local jest = JestGlobals.jest
require(script.Parent.Parent.ReactInternalTypes)
local v = nil
describe("ReactFiberComponentStack", function()
	beforeEach(function()
		jest.resetModules()
		local ReactFiberComponentStack = require(script.Parent.Parent.ReactFiberComponentStack)
		v = ReactFiberComponentStack
	end)
	it("given a nil fiber then it gives correct error message", function()
		expect((v.getStackByFiberInDevAndProd(nil))).toContain("attempt to index nil")
	end)
	it("given a fiber that throws Error then it gives correct error message", function()
		local v2 = {}
		setmetatable(v2, {
			__index = function(_, p)
				if p == "tag" then
					error(error2.new("this was an error object in a spec file"))
				end

				return nil
			end
		})
		expect((v.getStackByFiberInDevAndProd(v2))).toContain("this was an error object in a spec file")
	end)
	it("given a fiber that throws a non-Error table then it gives correct error message", function()
		local v2 = {}
		setmetatable(v2, {
			__tostring = function(_, _)
				return "this was a custom __tostring"
			end
		})
		local v3 = {}
		setmetatable(v3, {
			__index = function(_, p)
				if p == "tag" then
					error(v2)
				end

				return nil
			end
		})
		expect((v.getStackByFiberInDevAndProd(v3))).toContain("this was a custom __tostring")
	end)
end)