local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local Shared = require(parent.Shared)
local reactInstanceMap = Shared.ReactInstanceMap
local __DEV__ = ReactGlobals.__DEV__
local SafeFlags = require(parent.SafeFlags)
local v = not SafeFlags.createGetFFlag("ReactInstanceMapDisableErrorChecking")() or __DEV__
describe("get", function()
	it("with invalid fiber", function()
		local v2 = {
			_reactInternals = {
				tag = 0
			}
		}

		if v then
			expect(function()
				reactInstanceMap.get(v2)
			end).toThrow("invalid fiber in UNNAMED Component during get from ReactInstanceMap!")
		else
			expect(function()
				reactInstanceMap.get(v2)
			end).never.toThrow("invalid fiber in UNNAMED Component during get from ReactInstanceMap!")
		end
	end)
	it("with valid fiber that has invalid alternate", function()
		local v2 = {
			_reactInternals = {
				tag = 0,
				subtreeFlags = 0,
				lanes = 0,
				childLanes = 0,
				alternate = {
					tag = 1
				}
			}
		}

		if v then
			expect(function()
				reactInstanceMap.get(v2)
			end).toThrow("invalid alternate fiber (UNNAMED alternate) in UNNAMED Component during get from ReactInstanceMap!")
		else
			expect(function()
				reactInstanceMap.get(v2)
			end).never.toThrow("invalid alternate fiber (UNNAMED alternate) in UNNAMED Component during get from ReactInstanceMap!")
		end
	end)
end)
describe("set", function()
	it("with invalid fiber", function()
		local v2 = {
			tag = 0
		}

		if v then
			expect(function()
				reactInstanceMap.set({
					displayName = "MyComponent"
				}, v2)
			end).toThrow("invalid fiber in MyComponent being set in ReactInstanceMap!")
		else
			expect(function()
				reactInstanceMap.set({
					displayName = "MyComponent"
				}, v2)
			end).never.toThrow("invalid fiber in MyComponent being set in ReactInstanceMap!")
		end
	end)
	it("with valid fiber with no return that has invalid alternate", function()
		local v2 = {
			tag = 0,
			subtreeFlags = 0,
			lanes = 0,
			childLanes = 0,
			alternate = {
				tag = 1
			}
		}

		if v then
			expect(function()
				reactInstanceMap.set({}, v2)
			end).toThrow("invalid alternate fiber (UNNAMED alternate) in UNNAMED Component being set in ReactInstanceMap!")
		else
			expect(function()
				reactInstanceMap.set({}, v2)
			end).never.toThrow("invalid alternate fiber (UNNAMED alternate) in UNNAMED Component being set in ReactInstanceMap!")
		end
	end)
	it("with valid fiber with a valid return_ that has invalid alternate", function()
		local v2 = {
			tag = 0,
			subtreeFlags = 0,
			lanes = 0,
			childLanes = 0,
			alternate = {
				tag = 1,
				subtreeFlags = 1,
				lanes = 1,
				childLanes = 1
			},
			return_ = {
				tag = 2,
				subtreeFlags = 2,
				lanes = 2,
				childLanes = 2,
				alternate = {
					tag = 3
				}
			}
		}

		if v then
			expect(function()
				reactInstanceMap.set({}, v2)
			end).toThrow([[
invalid alternate fiber (UNNAMED alternate) in UNNAMED Component being set in ReactInstanceMap! { tag: 3 }
 (from original fiber UNNAMED Component)]])
		else
			expect(function()
				reactInstanceMap.set({}, v2)
			end).never.toThrow([[
invalid alternate fiber (UNNAMED alternate) in UNNAMED Component being set in ReactInstanceMap! { tag: 3 }
 (from original fiber UNNAMED Component)]])
		end
	end)
end)