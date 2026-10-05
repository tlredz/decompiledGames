_G.__IS_UNIT_TESTING__ = true
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local JestGlobals = require(script.Parent.Parent.Parent.DevPackages.JestGlobals)
local parentModule = require(script.Parent.Parent)
local Promise = require(script.Parent.Parent.Promise)
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it
local bindableEvent = Instance.new("BindableEvent")
local v = false
bindableEvent.Event:Once(function()
	v = true
end)
bindableEvent:Fire()
bindableEvent:Destroy()
local v2 = not v

local function AwaitCondition(fn, value: number?)
	local lastTime = os.clock()
	local v3 = value or 10

	while not fn() do
		if v3 < os.clock() - lastTime then
			return false
		else
			task.wait()
		end
	end

	return true
end

local v3 = {
	ClassName = "BasicClass"
}
v3.__index = v3

function v3.new()
	return (setmetatable({
		CleanupFunction = nil
	}, v3))
end

function v3:AddCleanupFunction(cleanupFunction)
	self.CleanupFunction = cleanupFunction
	return self
end

function v3:Destroy()
	local cleanupFunction = self.CleanupFunction

	if cleanupFunction then
		cleanupFunction()
	end

	table.clear(self)
	setmetatable(self, nil)
end

local function NoOperation() end

describe("Janitor.Is", function()
	it("should return true iff the passed value is a Janitor", function()
		local v4 = parentModule.new()
		expect(parentModule.Is(v4)).toBe(true)
		v4:Destroy()
	end)
	it("should return false iff the passed value is anything else", function()
		expect(parentModule.Is(NoOperation)).toBe(false)
		expect(parentModule.Is({})).toBe(false)
		expect(parentModule.Is(v3.new())).toBe(false)
	end)
end)
describe("Janitor.new", function()
	it("should create a new Janitor", function()
		local v4 = parentModule.new()
		expect(v4).toBeDefined()
		expect(parentModule.Is(v4)).toBe(true)
		v4:Destroy()
	end)
end)
describe("Janitor.Add", function()
	it("should add things", function()
		local v4 = parentModule.new()
		expect(function()
			v4:Add(NoOperation, true)
		end).never.toThrow()
		v4:Destroy()
	end)
	it("should add things with the given index", function()
		local v4 = parentModule.new()
		expect(function()
			v4:Add(NoOperation, true, "Function")
		end).never.toThrow()
		expect(v4:Get("Function")).toEqual(expect.any("function"))
		v4:Destroy()
	end)
	it("should overwrite indexes", function()
		local maid = parentModule.new()
		local v4 = false
		maid:Add(function()
			v4 = true
		end, true, "Function")
		maid:Add(NoOperation, true, "Function")
		expect(v4).toBe(true)
		maid:Destroy()
	end)
	it("should return the passed object", function()
		local maid = parentModule.new()
		local v4 = maid:Add(Instance.new("Part"), "Destroy")
		expect(v4).toBeDefined()
		expect(v4).toEqual(expect.any("Instance"))
		expect(v4.ClassName).toBe("Part")
		maid:Destroy()
	end)
	it("should clean up instances, objects, functions, connections, and threads", function()
		local v4 = false
		local v5 = false
		local v6 = false
		local v7 = false
		local maid = parentModule.new()
		local v8 = maid:Add(Instance.new("Part"), "Destroy")
		v8.Parent = ReplicatedStorage
		local v9 = maid:Add(v8.ChildRemoved:Connect(NoOperation), "Disconnect")
		maid:Add(function()
			v4 = true
		end, true)
		maid:Add(parentModule.new(), "Destroy"):Add(function()
			v5 = true
		end, true)
		maid:Add(v3.new(), "Destroy"):AddCleanupFunction(function()
			v6 = true
		end)
		maid:Add(task.delay(1, function()
			v7 = true
		end), true)
		maid:Destroy()
		expect(v8.Parent).toBeUndefined()
		expect(v9.Connected).toBe(false)
		expect(v4).toBe(true)
		expect(v5).toBe(true)
		expect(v6).toBe(true)
		expect(v7).toBe(false)
	end)
	it("should clean up everything correctly", function()
		local maid = parentModule.new()
		local count = 0

		for i = 1, 5000 do
			maid:Add(function()
				count += 1
			end, true, i)
		end

		for i = 5000, 1, -1 do
			maid:Remove(i)
		end

		maid:Destroy()
		expect(count).toBe(5000)
	end)
	it("should infer types if not given", function()
		local maid = parentModule.new()
		local v4 = maid:Add(ReplicatedStorage.AncestryChanged:Connect(NoOperation))
		maid:Destroy()

		if v2 then
			task.wait()
		end

		expect(v4.Connected).toBe(false)
	end)
end)
describe("Janitor.AddPromise", function()
	if not Promise then
		return
	end

	it("should add a Promise", function()
		local v4 = parentModule.new()
		local v5 = v4:AddPromise(Promise.delay(60))
		expect(Promise.is(v5)).toBe(true)
		v4:Destroy()
	end)
	it("should cancel the Promise when destroyed", function()
		local v4 = parentModule.new()
		local v5 = false
		v4:AddPromise(Promise.new(function(p, _, callback)
			if callback(function()
				v5 = true
			end) then
				return
			else
				return Promise.delay(60):andThen(p)
			end
		end))
		v4:Destroy()
		expect(v5).toBe(true)
	end)
	it("should not remove any values from the return", function()
		local v4 = parentModule.new()
		local _, v5 = v4:AddPromise(Promise.new(function(callback)
			callback(true)
		end)):await()
		expect(v5).toBe(true)
		v4:Destroy()
	end)
	it("should throw if the passed value isn't a Promise", function()
		local v4 = parentModule.new()
		expect(function()
			v4:AddPromise((v3.new()))
		end).toThrow()
		v4:Destroy()
	end)
end)
describe("Janitor.Remove", function()
	it("should always return the Janitor", function()
		local v4 = parentModule.new()
		v4:Add(NoOperation, true, "Function")
		expect(v4:Remove("Function")).toBe(v4)
		expect(v4:Remove("Function")).toBe(v4)
		v4:Destroy()
	end)
	it("should always remove the value", function()
		local maid = parentModule.new()
		local v4 = false
		maid:Add(function()
			v4 = true
		end, true, "Function")
		maid:Remove("Function")
		expect(AwaitCondition(function()
			return v4
		end, 1)).toBe(true)
		maid:Destroy()
	end)
	it("should properly remove values that are already destroyed", function()
		local v4 = parentModule.new()
		local count = 0
		local maid = parentModule.new()
		maid:Add(function()
			count += 1
		end, true)
		v4:Add(maid, "Destroy")
		maid:Destroy()
		expect(function()
			v4:Destroy()
		end).never.toThrow()
		expect(count).toBe(1)
	end)
	it("should clean up everything efficiently", function()
		local maid = parentModule.new()
		local count = 0

		for _ = 1, 1000000 do
			count += 1
			maid:Add(NoOperation, true, count)
		end

		for _ = 1, 200000 do
			count += 1
			maid:Add(task.delay(5, NoOperation), true, count)
		end

		for _ = 1, 1000000 do
			count += 1
			maid:Add(v3.new(), "Destroy", count)
		end

		for _ = 1, 100000 do
			count += 1
			maid:Add(Instance.new("Part"), "Destroy", count)
		end

		for i = 1, count do
			maid:Remove(i)
		end

		maid:Destroy()
	end)
end)
describe("Janitor.RemoveList", function()
	it("should always return the Janitor", function()
		local v4 = parentModule.new()
		v4:Add(NoOperation, true, "Function")
		expect(v4:RemoveList("Function")).toBe(v4)
		expect(v4:RemoveList("Function")).toBe(v4)
		v4:Destroy()
	end)
	it("should always remove the value", function()
		local maid = parentModule.new()
		local v4 = false
		maid:Add(function()
			v4 = true
		end, true, "Function")
		maid:RemoveList("Function")
		expect(v4).toBe(true)
		maid:Destroy()
	end)
	it("should properly remove multiple values", function()
		local maid = parentModule.new()
		local v4 = false
		local v5 = false
		local v6 = false
		maid:Add(function()
			v4 = true
		end, true, 1)
		maid:Add(function()
			v5 = true
		end, true, 2)
		maid:Add(function()
			v6 = true
		end, true, 3)
		maid:RemoveList(1, 2, 3)
		expect(v4).toBe(true)
		expect(v5).toBe(true)
		expect(v6).toBe(true)
	end)
end)
describe("Janitor.Get", function()
	it("should return the value iff it exists", function()
		local v4 = parentModule.new()
		v4:Add(NoOperation, true, "Function")
		expect(v4:Get("Function")).toBe(NoOperation)
		v4:Destroy()
	end)
	it("should return void iff the value doesn't exist", function()
		local v4 = parentModule.new()
		expect(v4:Get("Function")).toBeUndefined()
		v4:Destroy()
	end)
end)
describe("Janitor.Cleanup", function()
	it("should cleanup everything", function()
		local maid = parentModule.new()
		local count = 0

		for _ = 1, 500 do
			maid:Add(function()
				count += 1
			end, true)
		end

		maid:Cleanup()
		expect(count).toBe(500)

		for _ = 1, 500 do
			maid:Add(function()
				count += 1
			end, true)
		end

		maid:Cleanup()
		expect(count).toBe(1000)
	end)
	it("should be unique", function()
		local maid = parentModule.new()
		local v4 = parentModule.new()
		expect(maid.CurrentlyCleaning).toBe(false)
		expect(v4.CurrentlyCleaning).toBe(false)
		local count = 0
		local v5 = false

		for i = 1, 500 do
			if i == 500 then
				maid:Add(function()
					count += 1
					task.wait(1)
					v5 = true
				end, true)
			else
				maid:Add(function()
					count += 1
				end, true)
			end
		end

		task.spawn(function()
			maid:Cleanup()
		end)
		task.wait()
		expect(maid.CurrentlyCleaning).toBe(true)
		expect(v4.CurrentlyCleaning).toBe(false)
		expect(AwaitCondition(function()
			return v5
		end, 5)).toBe(true)
		expect(count).toBe(500)
	end)
end)
describe("Janitor.Destroy", function()
	it("should cleanup everything", function()
		local maid = parentModule.new()
		local count = 0

		for _ = 1, 500 do
			maid:Add(function()
				count += 1
			end, true)
		end

		maid:Destroy()
		expect(count).toBe(500)
	end)
	it("should render the Janitor unusable", function()
		local v4 = parentModule.new()
		v4:Destroy()
		expect(function()
			v4:Add(NoOperation, true)
		end).toBeTruthy()
	end)
end)
describe("Janitor.LinkToInstance", function()
	it("should link to an Instance", function()
		local maid = parentModule.new()
		local v4 = maid:Add(Instance.new("Part"), "Destroy")
		v4.Parent = ReplicatedStorage
		expect(function()
			maid:LinkToInstance(v4)
		end).never.toThrow()
		maid:Destroy()
	end)
	it("should cleanup once the Instance is destroyed", function()
		local maid = parentModule.new()
		local v4 = false
		local part = Instance.new("Part")
		part.Parent = Workspace
		maid:Add(function()
			v4 = true
		end, true)
		maid:LinkToInstance(part)
		part:Destroy()
		task.wait(0.1)
		expect(v4).toBe(true)
		maid:Destroy()
	end)
	it("should work if the Instance is parented to nil when started", function()
		local maid = parentModule.new()
		local v4 = false
		local part = Instance.new("Part")
		maid:Add(function()
			v4 = true
		end, true)
		maid:LinkToInstance(part)
		part.Parent = Workspace
		part:Destroy()
		expect(AwaitCondition(function()
			return v4
		end, 1)).toBe(true)
		maid:Destroy()
	end)
	it("should work if the Instance is parented to nil", function()
		local maid = parentModule.new()
		local v4 = false
		local part = Instance.new("Part")
		maid:Add(function()
			v4 = true
		end, true)
		maid:LinkToInstance(part)
		part:Destroy()
		expect(AwaitCondition(function()
			return v4
		end, 1)).toBe(true)
		maid:Destroy()
	end)
	it("shouldn't run if the Instance is removed or parented to nil", function()
		local v4 = parentModule.new()
		local part = Instance.new("Part")
		part.Parent = ReplicatedStorage
		v4:Add(NoOperation, true, "Function")
		v4:LinkToInstance(part)
		part.Parent = nil
		expect(v4:Get("Function")).toBe(NoOperation)
		part.Parent = ReplicatedStorage
		expect(v4:Get("Function")).toBe(NoOperation)
		part:Destroy()
		task.wait(0.1)
		expect(function()
			v4:Destroy()
		end).never.toThrow()
	end)
end)
return false