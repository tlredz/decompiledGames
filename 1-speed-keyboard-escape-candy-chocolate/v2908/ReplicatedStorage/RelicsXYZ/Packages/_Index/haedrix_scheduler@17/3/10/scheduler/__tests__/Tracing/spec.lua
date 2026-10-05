local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local it = JestGlobals.it
local jest = JestGlobals.jest
describe("Tracing", function()
	local JestGlobals2 = require(parent.Dev.JestGlobals)
	local expect = JestGlobals2.expect
	local tracing = nil
	beforeEach(function()
		jest.resetModules()
		local Scheduler = require(parent.Scheduler)
		tracing = Scheduler.tracing
	end)
	it("should return the value of a traced function", function()
		expect(tracing.unstable_trace("arbitrary", 0, function()
			return 123
		end)).toBe(123)
	end)
	it("should return the value of a wrapped function", function()
		local v = nil
		tracing.unstable_trace("arbitrary", 0, function()
			v = tracing.unstable_wrap(function()
				return 123
			end)
		end)
		expect(v()).toBe(123)
	end)
	it("should execute traced callbacks", function()
		local v = false
		tracing.unstable_trace("some event", 0, function()
			v = true
		end)
		expect(v).toBe(true)
	end)
	it("should return the value of a clear function", function()
		expect(tracing.unstable_clear(function()
			return 123
		end)).toBe(123)
	end)
	it("should execute wrapped callbacks", function()
		local v = false
		tracing.unstable_wrap(function()
			v = true
		end)()
		expect(v).toBe(true)
	end)
end)