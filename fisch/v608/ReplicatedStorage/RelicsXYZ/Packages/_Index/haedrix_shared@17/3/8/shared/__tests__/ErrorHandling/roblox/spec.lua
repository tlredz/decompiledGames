local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local LuauPolyfill = require(parent.LuauPolyfill)
local error2 = LuauPolyfill.Error
local inspect = LuauPolyfill.util.inspect
local ErrorHandlingroblox = require(script.Parent.Parent["ErrorHandling.roblox"])
local describeError = ErrorHandlingroblox.describeError
local errorToString = ErrorHandlingroblox.errorToString
local parseReactError = ErrorHandlingroblox.parseReactError
describe("describeError", function()
	it("preserves original stack from string error when rethrown", function()
		local function throws()
			error("preserve stack from string error")
		end

		local v, v2 = xpcall(throws, describeError)
		expect(v).toBe(false)
		expect(v2.message).toBe("preserve stack from string error")
		local stack = v2.stack
		local v3, v4 = xpcall(function()
			error(v2)
		end, describeError)
		expect(v3).toBe(false)
		expect(v4.message).toBe("preserve stack from string error")
		expect(v4.stack).toBe(stack)
	end)
	it("preserves original stack from Error when rethrown", function()
		local function throws()
			error(error2.new("preserve stack from Error"))
		end

		local v, v2 = xpcall(throws, describeError)
		expect(v).toBe(false)
		expect(v2.message).toBe("preserve stack from Error")
		local stack = v2.stack
		local v3, v4 = xpcall(function()
			error(v2)
		end, describeError)
		expect(v3).toBe(false)
		expect(v4.message).toBe("preserve stack from Error")
		expect(v4.stack).toBe(stack)
	end)
	it("transforms string errors into Error objects", function()
		local function throws()
			error("transform string into Error")
		end

		local v, v2 = xpcall(throws, describeError)
		expect(v).toBe(false)
		expect(LuauPolyfill.instanceof(v2, error2)).toBe(true)
		expect(v2.message).toBe("transform string into Error")
		expect(v2.stack).toContain(script:GetFullName())
	end)
	it("rethrows Error objects without changing them", function()
		local rethrowErrorwithoutchanges = error2.new("rethrow Error without changes")

		local function throws()
			error(rethrowErrorwithoutchanges)
		end

		local v, v2 = xpcall(throws, describeError)
		expect(v).toBe(false)
		expect(v2).toBe(rethrowErrorwithoutchanges)
	end)
end)
describe("errorToString", function()
	it("gives stack trace for Error", function()
		local v = errorToString(error2.new("h0wdy"))
		expect(v).toContain(script.Name)
		expect(v).toContain("h0wdy")
	end)
	it("prints random tables", function()
		local v = errorToString({
			["$$h0wdy\n"] = 31337
		})
		expect(v).toContain("$$h0wdy")
		expect(v).toContain("31337")
	end)
	it("prints arrays", function()
		expect((errorToString({
			foo = 1,
			2,
			3
		}))).toContain("foo: 1")
	end)
end)
describe("parseReactError", function()
	it("returns the whole message if not formatted as expected", function()
		local v = inspect(error2.new("not formatted for split"))
		local v2, v3 = parseReactError(v)
		expect(v2.message).toBe(v)
		expect(v2.stack).toBeNil()
		expect(v3).toBe("")
	end)
	it("does not split errors with the wrong number of sections", function()
		local joined = table.concat({
			"a",
			"b",
			"c",
			"d"
		}, ErrorHandlingroblox.__ERROR_DIVIDER)
		local v, v2 = parseReactError(joined)
		expect(v.message).toBe(joined)
		expect(v.stack).toBeNil()
		expect(v2).toBe("")
	end)
	it("parses errors created by errorToString", function()
		local v = errorToString(error2.new("foo"))
		local v2 = debug.info(1, "l") - 1
		local v3 = string.format("%s:%d", debug.info(1, "s"), v2)
		local v4, v5 = parseReactError(v)
		expect(v4.message).toBe("foo")
		expect(v4.stack).toContain(v3)
		expect(v5).toBe("")
	end)
	it("separates the stack frame from the rethrow", function()
		local bar = error2.new("bar")
		local v = debug.info(1, "l") - 1
		local v2 = string.format("%s:%d", debug.info(1, "s"), v)
		local v3, v4 = xpcall(function()
			error(bar)
		end, errorToString)
		expect(v3).toBe(false)
		local success, result = pcall(function()
			error(v4)
		end)
		local v5 = debug.info(1, "l") - 2
		local v6 = string.format("%s:%d", debug.info(1, "s"), v5)
		expect(success).toBe(false)
		local v7, v8 = parseReactError(result)
		expect(v7.message).toBe("bar")
		expect(v7.stack).toContain(v2)
		expect(v8).toContain(v6)
	end)
end)