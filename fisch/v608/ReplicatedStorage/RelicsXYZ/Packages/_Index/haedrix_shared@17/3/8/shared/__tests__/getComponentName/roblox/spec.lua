local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local v = nil
local getComponentName = nil

local function MyComponent() end

local function fn() end

beforeEach(function()
	local React = require(parent.Dev.React)
	v = React
	local Shared = require(parent.Shared)
	getComponentName = Shared.getComponentName
end)
describe("function components", function()
	it("gets name from non-anonymous function", function()
		expect(getComponentName(MyComponent)).toBe("MyComponent")
	end)
	it("gets fileName:lineNumber from anonymous function", function()
		expect(getComponentName(function() end)).toMatch("getComponentName.roblox.spec:[0-9]*")
	end)
end)
describe("Lazy components", function()
	it("gets name from lazy-wrapped non-anonymous function", function()
		local lazy = v.lazy(function()
			return {
				andThen = function(_, callback)
					callback({
						default = MyComponent
					})
				end
			}
		end)
		expect(getComponentName(lazy)).toBe("MyComponent")
	end)
	it("gets fileName:lineNumber from lazy-wrapped anonymous function", function()
		local lazy = v.lazy(function()
			return {
				andThen = function(_, callback)
					callback({
						default = fn
					})
				end
			}
		end)
		expect(getComponentName(lazy)).toMatch("getComponentName.roblox.spec:[0-9]*")
	end)
end)