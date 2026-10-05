local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
describe("ReactFiberHostContext", function()
	local v = nil
	local v2 = nil
	local v3 = nil
	beforeEach(function()
		jest.resetModules()
		local React = require(parent.React)
		v3 = React
		local parentModule = require(script.Parent.Parent)
		v = parentModule
		local ReactRootTags = require(script.Parent.Parent.ReactRootTags)
		v2 = ReactRootTags
	end)
	it("works with nil host context", function()
		local count = 0
		local v4 = v({
			prepareForCommit = function()
				return nil
			end,
			resetAfterCommit = function() end,
			getRootHostContext = function()
				return nil
			end,
			getChildHostContext = function()
				return nil
			end,
			shouldSetTextContent = function()
				return false
			end,
			createInstance = function()
				count += 1
			end,
			finalizeInitialChildren = function()
				return nil
			end,
			appendInitialChild = function()
				return nil
			end,
			now = function()
				return 0
			end,
			appendChildToContainer = function()
				return nil
			end,
			clearContainer = function() end,
			supportsMutation = true
		})
		local container = v4.createContainer(nil, v2, false, nil)
		v4.updateContainer(v3.createElement("a", nil, v3.createElement("b")), container, nil, nil)
		expect(count).toBe(2)
	end)
	it("should send the context to prepareForCommit and resetAfterCommit", function()
		local v4 = {}
		local v5 = v({
			prepareForCommit = function(p)
				expect(p).toBe(v4)
				return nil
			end,
			resetAfterCommit = function(p)
				expect(p).toBe(v4)
			end,
			getRootHostContext = function()
				return nil
			end,
			getChildHostContext = function()
				return nil
			end,
			shouldSetTextContent = function()
				return false
			end,
			createInstance = function()
				return nil
			end,
			finalizeInitialChildren = function()
				return nil
			end,
			appendInitialChild = function()
				return nil
			end,
			now = function()
				return 0
			end,
			appendChildToContainer = function()
				return nil
			end,
			clearContainer = function() end,
			supportsMutation = true
		})
		local container = v5.createContainer(v4, v2, false, nil)
		v5.updateContainer(v3.createElement("a", nil, v3.createElement("b")), container, nil, nil)
	end)
end)