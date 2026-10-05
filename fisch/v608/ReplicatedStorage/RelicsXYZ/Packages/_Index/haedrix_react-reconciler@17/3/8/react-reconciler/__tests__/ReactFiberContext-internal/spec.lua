local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local it = JestGlobals.it
local v = nil
local v2 = nil
local v3 = nil
local reactFeatureFlags = nil
beforeEach(function()
	jest.resetModules()
	local ReactFiberContextnew = require(script.Parent.Parent["ReactFiberContext.new"])
	v = ReactFiberContextnew
	local ReactFibernew = require(script.Parent.Parent["ReactFiber.new"])
	v2 = ReactFibernew
	local ReactRootTags = require(script.Parent.Parent.ReactRootTags)
	v3 = ReactRootTags
	local Shared = require(parent.Shared)
	reactFeatureFlags = Shared.ReactFeatureFlags
	reactFeatureFlags.disableLegacyContext = false
end)
describe("Context stack", function()
	it("should throw when pushing to top level of non-empty stack", function()
		local hostRootFiber = v2.createHostRootFiber(v3.BlockingRoot)
		v.pushTopLevelContextObject(hostRootFiber, {
			foo = 1
		}, true)
		expect(function()
			v.pushTopLevelContextObject(hostRootFiber, {
				bar = 2
			}, true)
		end).toThrow("Unexpected context found on stack.")
	end)
	it("should throw if when invalidating a provider that isn't initialized", function()
		local hostRootFiber = v2.createHostRootFiber(v3.BlockingRoot)
		expect(function()
			v.invalidateContextProvider(hostRootFiber, nil, true)
		end).toThrow("Expected to have an instance by this point.")
	end)
end)