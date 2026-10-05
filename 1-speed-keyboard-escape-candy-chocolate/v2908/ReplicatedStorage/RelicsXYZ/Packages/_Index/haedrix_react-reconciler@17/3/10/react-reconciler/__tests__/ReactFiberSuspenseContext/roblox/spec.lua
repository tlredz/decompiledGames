local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local it = JestGlobals.it
local ReactFibernew = require(script.Parent.Parent["ReactFiber.new"])
local v = nil
describe("ReactFiberSuspenseContext", function()
	beforeEach(function()
		jest.resetModules()
		local ReactFiberSuspenseContextnew = require(script.Parent.Parent["ReactFiberSuspenseContext.new"])
		v = ReactFiberSuspenseContextnew
	end)
	describe("suspense context stack", function()
		local current2 = nil
		local v3 = nil
		local suspenseStackCursor = nil
		beforeEach(function()
			current2 = 8
			v3 = ReactFibernew.createFiberFromText("", 0, 0)
			suspenseStackCursor = v.suspenseStackCursor
		end)
		it("pushes the context and assigns the value to the cursor", function()
			v.pushSuspenseContext(v3, current2)
			expect(suspenseStackCursor).toEqual({
				current = current2
			})
		end)
		it("pushes and pops and sets the cursor to its initial value", function()
			local current = suspenseStackCursor.current
			v.pushSuspenseContext(v3, current2)
			v.popSuspenseContext(v3)
			expect(suspenseStackCursor).toEqual({
				current = current
			})
		end)
	end)
	describe("hasSuspenseContext", function()
		it("is true for parent context and its subtree context", function()
			local v2 = v.addSubtreeSuspenseContext(10000, 8)
			expect(v.hasSuspenseContext(v2, 8)).toBe(true)
		end)
		it("is false for two different context", function()
			expect(v.hasSuspenseContext(8, 16)).toBe(false)
		end)
	end)
end)