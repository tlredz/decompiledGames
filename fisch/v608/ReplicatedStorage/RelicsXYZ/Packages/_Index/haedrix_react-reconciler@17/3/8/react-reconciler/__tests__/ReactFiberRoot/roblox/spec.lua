local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local v = nil
local v2 = nil
beforeEach(function()
	jest.resetModules()
	local ReactFiberRootnew = require(script.Parent.Parent["ReactFiberRoot.new"])
	v = ReactFiberRootnew
	local ReactRootTags = require(script.Parent.Parent.ReactRootTags)
	v2 = ReactRootTags
end)
it("should properly initialize a fiber created with createFiberRoot", function()
	local fiberRoot = v.createFiberRoot({}, v2.BlockingRoot, false)
	expect(fiberRoot.current).toBeDefined()
	expect(fiberRoot.current.updateQueue).toBeDefined()
end)