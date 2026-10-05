local v = nil
local v2 = nil
local v3 = nil
local tag = nil
local CollectionService = game:GetService("CollectionService")
local parent = script.Parent.Parent.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local waitForEvents = require(script.Parent.waitForEvents)
local beforeEach = JestGlobals.beforeEach
local afterEach = JestGlobals.afterEach
local it = JestGlobals.it
local describe = JestGlobals.describe
beforeEach(function()
	jest.resetModules()
	local React = require(parent.React)
	v = React
	local ReactRoblox = require(parent.ReactRoblox)
	v2 = ReactRoblox
	local Scheduler = require(parent.Scheduler)
	v3 = Scheduler
	local React2 = require(parent.React)
	tag = React2.Tag
end)
describe("adding tags", function()
	local v4 = nil
	local folder = nil
	local v5 = nil
	local v6 = nil
	local connection = nil
	local connection2 = nil
	beforeEach(function()
		local v7, v8 = jest.fn()
		local v9, v10 = jest.fn()
		connection = CollectionService:GetInstanceAddedSignal("tag1"):Connect(v8)
		connection2 = CollectionService:GetInstanceAddedSignal("tag2"):Connect(v10)
		v5 = v7
		v6 = v9
		folder = Instance.new("Folder")
		folder.Parent = game:GetService("Workspace")
		v4 = v2.createRoot(folder)
	end)
	afterEach(function()
		connection:Disconnect()
		connection2:Disconnect()
		v4:unmount()
		folder:Destroy()
	end)
	it("should add a single tag", function()
		local ref = v.createRef()
		v4:render(v.createElement("TextLabel", {
			ref = ref,
			[tag] = "tag1"
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(v5).toHaveBeenCalledWith(ref.current)
		expect(CollectionService:GetTagged("tag1")).toEqual({ ref.current })
	end)
	it("should add several tags", function()
		local ref = v.createRef()
		v4:render(v.createElement("TextLabel", {
			ref = ref,
			[tag] = "tag1 tag2"
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(v5).toHaveBeenCalledWith(ref.current)
		expect(v6).toHaveBeenCalledWith(ref.current)
		expect(CollectionService:GetTagged("tag1")).toEqual({ ref.current })
		expect(CollectionService:GetTagged("tag2")).toEqual({ ref.current })
	end)
	it("should add tags to several children", function()
		local ref = v.createRef()
		local ref2 = v.createRef()
		v4:render(v.createElement("Frame", nil, v.createElement("TextLabel", {
			ref = ref,
			[tag] = "tag1"
		}), v.createElement("TextBox", {
			ref = ref2,
			[tag] = "tag1"
		})))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(v5).toHaveBeenCalledWith(ref.current)
		expect(v5).toHaveBeenCalledWith(ref2.current)
		local tagged = CollectionService:GetTagged("tag1")
		expect(tagged).toHaveLength(2)
		expect(tagged).toContain(ref.current)
		expect(tagged).toContain(ref2.current)
	end)
	it("should add no tags when given an empty string", function()
		local ref = v.createRef()
		v4:render(v.createElement("TextLabel", {
			ref = ref,
			[tag] = ""
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(CollectionService:GetTags(ref.current)).toEqual({})
	end)
	it("should not change tags that are re-ordered", function()
		local ref = v.createRef()
		v4:render(v.createElement("TextLabel", {
			ref = ref,
			[tag] = "tag1 tag2"
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(v5).toHaveBeenCalledTimes(1)
		expect(v6).toHaveBeenCalledTimes(1)
		v4:render(v.createElement("TextLabel", {
			ref = ref,
			[tag] = "tag2 tag1"
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(v5).toHaveBeenCalledTimes(1)
		expect(v6).toHaveBeenCalledTimes(1)
	end)
end)
describe("removing tags", function()
	local v4 = nil
	local folder = nil
	local v5 = nil
	local v6 = nil
	local connection = nil
	local connection2 = nil
	beforeEach(function()
		local v7, v8 = jest.fn()
		local v9, v10 = jest.fn()
		connection = CollectionService:GetInstanceRemovedSignal("tag1"):Connect(v8)
		connection2 = CollectionService:GetInstanceRemovedSignal("tag2"):Connect(v10)
		v5 = v7
		v6 = v9
		folder = Instance.new("Folder")
		folder.Parent = game:GetService("Workspace")
		v4 = v2.createRoot(folder)
	end)
	afterEach(function()
		connection:Disconnect()
		connection2:Disconnect()
		v4:unmount()
		folder:Destroy()
	end)
	it("should remove a tag when updated", function()
		local ref = v.createRef()
		v4:render(v.createElement("TextLabel", {
			ref = ref,
			[tag] = "tag1"
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(CollectionService:GetTagged("tag1")).toEqual({ ref.current })
		v4:render(v.createElement("TextLabel", {
			ref = ref
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(v5).toHaveBeenCalledWith(ref.current)
		expect(CollectionService:GetTagged("tag1")).toEqual({})
	end)
	it("should remove one tag in a list when updated", function()
		local ref = v.createRef()
		v4:render(v.createElement("TextLabel", {
			ref = ref,
			[tag] = "tag1 tag2"
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(CollectionService:GetTagged("tag1")).toEqual({ ref.current })
		expect(CollectionService:GetTagged("tag2")).toEqual({ ref.current })
		v4:render(v.createElement("TextLabel", {
			ref = ref,
			[tag] = "tag2"
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(v5).toHaveBeenCalledWith(ref.current)
		expect(v6).never.toHaveBeenCalled()
		expect(CollectionService:GetTagged("tag1")).toEqual({})
		expect(CollectionService:GetTagged("tag2")).toEqual({ ref.current })
	end)
	it("should remove several tags when updated", function()
		local ref = v.createRef()
		v4:render(v.createElement("TextLabel", {
			ref = ref,
			[tag] = "tag1 tag2"
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(CollectionService:GetTagged("tag1")).toEqual({ ref.current })
		expect(CollectionService:GetTagged("tag2")).toEqual({ ref.current })
		v4:render(v.createElement("TextLabel", {
			ref = ref
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(v5).toHaveBeenCalledWith(ref.current)
		expect(v6).toHaveBeenCalledWith(ref.current)
		expect(CollectionService:GetTagged("tag1")).toEqual({})
		expect(CollectionService:GetTagged("tag2")).toEqual({})
	end)
	it("should remove tags on unmount", function()
		local ref = v.createRef()
		v4:render(v.createElement("TextLabel", {
			ref = ref,
			[tag] = "tag1 tag2"
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(CollectionService:GetTagged("tag1")).toEqual({ ref.current })
		expect(CollectionService:GetTagged("tag2")).toEqual({ ref.current })
		v4:render(nil)
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(v5).toHaveBeenCalledTimes(1)
		expect(v6).toHaveBeenCalledTimes(1)
		expect(CollectionService:GetTagged("tag1")).toEqual({})
		expect(CollectionService:GetTagged("tag2")).toEqual({})
	end)
	it("should remove tags when provided an empty tag string", function()
		local ref = v.createRef()
		v4:render(v.createElement("TextLabel", {
			ref = ref,
			[tag] = "tag1 tag2"
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(CollectionService:GetTagged("tag1")).toEqual({ ref.current })
		expect(CollectionService:GetTagged("tag2")).toEqual({ ref.current })
		v4:render(v.createElement("TextLabel", {
			ref = ref,
			[tag] = ""
		}))
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
		expect(v5).toHaveBeenCalledTimes(1)
		expect(v6).toHaveBeenCalledTimes(1)
		expect(CollectionService:GetTagged("tag1")).toEqual({})
		expect(CollectionService:GetTagged("tag2")).toEqual({})
	end)
end)
it("should warn when assigning tags with an incorrect type", function()
	local folder = Instance.new("Folder")
	folder.Parent = game:GetService("Workspace")
	local root = v2.createRoot(folder)
	local ref = v.createRef()
	root:render(v.createElement("TextLabel", {
		key = "My Label",
		ref = ref,
		[tag] = 42
	}))
	expect(function()
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
	end).toErrorDev([[
Warning: Type provided for ReactRoblox.Tag is invalid - tags should be specified as a single string, with individual tags delimited by spaces. Instead received:
42]])
end)
it("should warn when assigning tags to unrooted instances", function()
	local folder = Instance.new("Folder")
	local root = v2.createRoot(folder)
	local ref = v.createRef()
	root:render(v.createElement("TextLabel", {
		key = "My Label",
		ref = ref,
		[tag] = "tag1"
	}))
	expect(function()
		v3.unstable_flushAllWithoutAsserting()
		waitForEvents()
	end).toWarnDev("Warning: Tags applied to orphaned TextLabel \"My Label\" cannot be accessed via CollectionService:GetTagged. If you're relying on tag behavior in a unit test, consider mounting your test root into the DataModel.")
	expect(CollectionService:GetTags(ref.current)).toEqual({ "tag1" })
	expect(CollectionService:GetTagged("tag1")).toEqual({})
end)