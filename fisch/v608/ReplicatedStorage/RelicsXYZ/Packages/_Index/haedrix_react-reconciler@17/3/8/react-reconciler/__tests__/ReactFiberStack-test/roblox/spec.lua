local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local jest = JestGlobals.jest
local it = JestGlobals.it
local v = nil
describe("ReactFiberStack", function()
	beforeEach(function()
		jest.resetModules()
		local ReactFiberStacknew = require(script.Parent.Parent["ReactFiberStack.new"])
		v = ReactFiberStacknew
	end)
	it("creates a cursor with the given default value", function()
		local current = {
			foo = 3
		}
		expect(v.createCursor(current)).toEqual({
			current = current
		})
	end)
	it("initializes the stack empty", function()
		expect(v.isEmpty()).toBe(true)
	end)
	describe("stack manipulations", function()
		local v2 = nil
		local v3 = nil
		beforeEach(function()
			v2 = v.createCursor(nil)
			v3 = {}
		end)
		it("pushes an element and the stack is not empty", function()
			v.push(v2, true, v3)
			expect(v.isEmpty()).toBe(false)
		end)
		it("pushes an element and assigns the value to the cursor", function()
			local v4 = {
				foo = 3
			}
			v.push(v2, v4, v3)
			expect(v2.current).toEqual(v4)
		end)
		it("pushes an element, pops it back and the stack is empty", function()
			v.push(v2, true, v3)
			v.pop(v2, v3)
			expect(v.isEmpty()).toBe(true)
		end)
		it("pushes an element, pops it back and the cursor has its initial value", function()
			v2.current = "foo"
			v.push(v2, true, v3)
			v.pop(v2, v3)
			expect(v2.current).toBe("foo")
		end)
	end)
end)