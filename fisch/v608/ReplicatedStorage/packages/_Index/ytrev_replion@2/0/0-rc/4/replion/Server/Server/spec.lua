local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local beforeEach = JestGlobals.beforeEach
local jest = JestGlobals.jest
local v = nil
beforeEach(function()
	jest.resetModules()
	local parentModule = require(script.Parent)
	v = parentModule
end)
describe("ReplionServer.new", function()
	it("should create a new ReplionServer with the correct configuration", function()
		local v2 = v.new({
			ReplicateTo = "All",
			Data = {},
			Channel = "New"
		})
		expect((type(v2))).toBe("table")
		expect(v2.ReplicateTo).toBe("All")
		expect(v2.Channel).toBe("New")
	end)
	it("should throw an error if the same channel and ReplicateTo already exists", function()
		v.new({
			ReplicateTo = "All",
			Data = {},
			Channel = "Duplicated"
		})
		expect(function()
			v.new({
				ReplicateTo = "All",
				Data = {},
				Channel = "Duplicated"
			})
		end).toThrow()
	end)
	it("should throw an error if Channel is not provided", function()
		expect(function()
			v.new({
				ReplicateTo = "All",
				Data = {}
			})
		end).toThrow()
	end)
	it("should throw an error if ReplicateTo is not provided", function()
		expect(function()
			v.new({
				Channel = "New",
				Data = {}
			})
		end).toThrow()
	end)
	it("shouldn't throw an error if the same channel is used with different ReplicateTo", function()
		v.new({
			ReplicateTo = "All",
			Data = {},
			Channel = "SameChannel"
		})
		expect(function()
			v.new({
				ReplicateTo = {},
				Data = {},
				Channel = "SameChannel"
			})
		end).never.toThrow()
	end)
end)
describe("ReplionServer:GetReplion", function()
	it("should return the Replion", function()
		local v2 = v.new({
			ReplicateTo = "All",
			Data = {},
			Channel = "GetReplion"
		})
		expect(v:GetReplion("GetReplion")).toBe(v2)
	end)
	it("should return nil if the Replion does not exist", function()
		expect(v:GetReplion("NonExistent")).toBeNil()
	end)
	it("should throw an error if there are multiple Replions with the same channel", function()
		v.new({
			ReplicateTo = "All",
			Data = {},
			Channel = "MultipleReplions"
		})
		v.new({
			ReplicateTo = {},
			Data = {},
			Channel = "MultipleReplions"
		})
		expect(function()
			v:GetReplion("MultipleReplions")
		end).toThrow()
	end)
end)
describe("ReplionServer:WaitReplion", function()
	it("should wait for the Replion to be created", function()
		task.defer(function()
			v.new({
				Channel = "WaitReplion",
				Data = {},
				ReplicateTo = "All"
			})
		end)
		expect(v:GetReplion("WaitReplion")).toBeNil()
		expect((v:WaitReplion("WaitReplion"))).never.toBeNil()
	end)
	it("should wait for the Replion to be created with a timeout", function()
		local lastTime = os.clock()
		task.delay(0.05, function()
			v.new({
				Channel = "WaitReplionTimeout",
				Data = {},
				ReplicateTo = "All"
			})
		end)
		expect(v:GetReplion("WaitReplionTimeout")).toBeNil()
		local v2 = v:WaitReplion("WaitReplionTimeout", 0.1)
		expect(os.clock() - lastTime).toBeGreaterThan(0.05)
		expect(v2).never.toBeNil()
	end)
	it("should return nil if the Replion is not created before the timeout", function()
		local lastTime = os.clock()
		expect(v:GetReplion("WaitReplionTimeout")).toBeNil()
		local v2 = v:WaitReplion("WaitReplionTimeout", 0.05)
		expect(os.clock() - lastTime).toBeGreaterThan(0.05)
		expect(v2).toBeNil()
	end)
	it("should return the Replion if it already exists", function()
		local v2 = v.new({
			Channel = "WaitReplionExists",
			Data = {},
			ReplicateTo = "All"
		})
		local v3 = false
		task.defer(function()
			v3 = true
		end)
		local v4 = v:WaitReplion("WaitReplionExists")
		expect(v3).toBe(false)
		expect(v4).toBe(v2)
	end)
end)
describe("ReplionServer:AwaitReplion", function()
	it("should be called", function()
		local v2 = jest.fn()

		local function callback(...)
			v2(...)
		end

		v:AwaitReplion("AwaitReplion", callback)
		expect(v2).toHaveBeenCalledTimes(0)
		v.new({
			Channel = "AwaitReplion",
			Data = {},
			ReplicateTo = "All"
		})
		expect(v2).toHaveBeenCalledTimes(1)
	end)
	it("should be called if the Replion exists", function()
		local v2 = jest.fn()

		local function callback(...)
			v2(...)
		end

		v.new({
			Channel = "AwaitReplionCreated",
			Data = {},
			ReplicateTo = "All"
		})
		v:AwaitReplion("AwaitReplionCreated", callback)
		expect(v2).toHaveBeenCalledTimes(1)
	end)
	it("should never be called after timeout", function()
		local v2 = jest.fn()

		local function callback(...)
			v2(...)
		end

		v:AwaitReplion("Timeout", callback, 0)
		task.wait()
		expect(v2).toHaveBeenCalledTimes(0)
	end)
	it("should be called before timeout", function()
		local v2 = jest.fn()

		local function callback(...)
			v2(...)
		end

		v:AwaitReplion("Timeout", callback, 0.1)
		task.wait(0.05)
		v.new({
			Channel = "Timeout",
			Data = {},
			ReplicateTo = "All"
		})
		expect(v2).toHaveBeenCalledTimes(1)
	end)
	it("should never be called if cancelled", function()
		local v2 = jest.fn()

		local function callback(...)
			v2(...)
		end

		local v3 = v:AwaitReplion("Cancelled", callback)
		expect((type(v3))).toBe("function")
		assert(v3, "cancel is not a function")
		v3()
		v.new({
			Channel = "Cancelled",
			Data = {},
			ReplicateTo = "All"
		})
		expect(v2).toHaveBeenCalledTimes(0)
	end)
end)
describe("ReplionServer:GetReplionsFor", function()
	local replicateTo = newproxy()
	it("should return the Replions for the given player", function()
		local v3 = v.new({
			Channel = "GetReplionsFor",
			Data = {},
			ReplicateTo = replicateTo
		})
		local v4 = v.new({
			Channel = "OtherChannel",
			Data = {},
			ReplicateTo = replicateTo
		})
		local replionsFor = v:GetReplionsFor(replicateTo)
		expect(#replionsFor).toBe(2)
		expect(table.find(replionsFor, v3)).never.toBeNil()
		expect(table.find(replionsFor, v4)).never.toBeNil()
	end)
	it("should return an empty table if the player has no Replions", function()
		expect(#v:GetReplionsFor(replicateTo)).toBe(0)
	end)
end)
describe("ReplionServer:GetReplionFor", function()
	local replicateTo = newproxy()
	it("should return the Replion for the given player", function()
		local v3 = v.new({
			Channel = "GetReplionFor",
			Data = {},
			ReplicateTo = replicateTo
		})
		expect(v:GetReplionFor(replicateTo, "GetReplionFor")).toBe(v3)
	end)
	it("should return nil if the player has no Replion for the given channel", function()
		expect(v:GetReplionFor(replicateTo, "NonExistent")).toBeNil()
	end)
end)
describe("ReplionServer:WaitReplionFor", function()
	local replicateTo = newproxy()
	it("should wait for the Replion to be created", function()
		task.defer(function()
			v.new({
				Channel = "WaitReplionFor",
				Data = {},
				ReplicateTo = replicateTo
			})
		end)
		expect(v:GetReplionFor(replicateTo, "WaitReplionFor")).toBeNil()
		expect((v:WaitReplionFor(replicateTo, "WaitReplionFor"))).never.toBeNil()
	end)
	it("should wait for the Replion to be created with a timeout", function()
		local lastTime = os.clock()
		task.delay(0.05, function()
			v.new({
				Channel = "WaitReplionForTimeout",
				Data = {},
				ReplicateTo = replicateTo
			})
		end)
		expect(v:GetReplionFor(replicateTo, "WaitReplionForTimeout")).toBeNil()
		local v3 = v:WaitReplionFor(replicateTo, "WaitReplionForTimeout", 0.1)
		expect(os.clock() - lastTime).toBeGreaterThan(0.05)
		expect(v3).never.toBeNil()
	end)
	it("should return nil if the Replion is not created before the timeout", function()
		local lastTime = os.clock()
		expect(v:GetReplionFor(replicateTo, "WaitReplionForTimeout")).toBeNil()
		local v3 = v:WaitReplionFor(replicateTo, "WaitReplionForTimeout", 0.05)
		expect(os.clock() - lastTime).toBeGreaterThan(0.05)
		expect(v3).toBeNil()
	end)
	it("should return the Replion if it already exists", function()
		local v3 = v.new({
			Channel = "WaitReplionForExists",
			Data = {},
			ReplicateTo = replicateTo
		})
		local v4 = false
		task.defer(function()
			v4 = true
		end)
		local v5 = v:WaitReplionFor(replicateTo, "WaitReplionForExists")
		expect(v4).toBe(false)
		expect(v5).toBe(v3)
	end)
end)
describe("ReplionServer:AwaitReplionFor", function()
	local replicateTo = newproxy()
	it("should be called", function()
		local v3 = jest.fn()

		local function callback(...)
			v3(...)
		end

		v:AwaitReplionFor(replicateTo, "AwaitReplionFor", callback)
		expect(v3).toHaveBeenCalledTimes(0)
		v.new({
			Channel = "AwaitReplionFor",
			Data = {},
			ReplicateTo = replicateTo
		})
		expect(v3).toHaveBeenCalledTimes(1)
	end)
	it("should never be called after timeout", function()
		local v3 = jest.fn()

		local function callback(...)
			v3(...)
		end

		v:AwaitReplionFor(replicateTo, "TimeoutFor", callback, 0)
		task.wait()
		expect(v3).toHaveBeenCalledTimes(0)
	end)
	it("should be called before timeout", function()
		local v3 = jest.fn()

		local function callback(...)
			v3(...)
		end

		v:AwaitReplionFor(replicateTo, "TimeoutFor", callback, 0.1)
		task.wait(0.05)
		v.new({
			Channel = "TimeoutFor",
			Data = {},
			ReplicateTo = replicateTo
		})
		expect(v3).toHaveBeenCalledTimes(1)
	end)
	it("should return the Replion", function()
		local v3 = nil
		v:AwaitReplionFor(replicateTo, "AwaitReplionFor", function(p)
			v3 = p
		end)
		expect(v3).never.toBeTruthy()
		v.new({
			Channel = "AwaitReplionFor",
			Data = {},
			ReplicateTo = replicateTo
		})
		task.wait()
		expect(v3).toBeTruthy()
	end)
	it("should never be called if cancelled", function()
		local v3 = jest.fn()

		local function callback(...)
			v3(...)
		end

		local v4 = v:AwaitReplionFor(replicateTo, "CancelledFor", callback)
		expect((type(v4))).toBe("function")
		assert(v4, "cancel is not a function")
		v4()
		v.new({
			Channel = "CancelledFor",
			Data = {},
			ReplicateTo = replicateTo
		})
		task.wait()
		expect(v3).toHaveBeenCalledTimes(0)
	end)
end)
describe("ReplionServer:OnReplionAdded", function()
	it("should return a Connection", function()
		local v2 = v:OnReplionAdded(function(p)
			expect(p).toBe("OnReplionAdded")
		end)
		expect((type(v2))).toBe("table")
		expect((type(v2.Disconnect))).toBe("function")
	end)
	it("should fire the event when a Replion is added", function()
		local v2 = false
		local v3 = nil
		v:OnReplionAdded(function(p, p2)
			expect(p).toBe("OnReplionAdded")
			v2 = true
			v3 = p2
		end)
		local v4 = v.new({
			ReplicateTo = "All",
			Data = {},
			Channel = "OnReplionAdded"
		})
		expect(v2).toBe(true)
		expect(v3).toBe(v4)
	end)
end)
describe("ReplionServer:OnReplionRemoved", function()
	it("should return a Connection", function()
		local v2 = v:OnReplionRemoved(function(p)
			expect(p).toBe("OnReplionRemoved")
		end)
		expect((type(v2))).toBe("table")
		expect((type(v2.Disconnect))).toBe("function")
	end)
	it("should fire the event when a Replion is removed", function()
		local v2 = false
		local v3 = nil
		v:OnReplionRemoved(function(p, p2)
			expect(p).toBe("OnReplionRemoved")
			v2 = true
			v3 = p2
		end)
		local v4 = v.new({
			ReplicateTo = "All",
			Data = {},
			Channel = "OnReplionRemoved"
		})
		v4:Destroy()
		expect(v2).toBe(true)
		expect(v3).toBe(v4)
	end)
end)