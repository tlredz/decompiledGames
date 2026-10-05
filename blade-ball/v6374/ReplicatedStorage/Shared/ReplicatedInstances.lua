local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
print(debug.info(2, "sl"))
print(debug.traceback())
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3("@game/ReplicatedStorage/Packages/Net")
local v2 = require3("@game/ReplicatedStorage/Common/Utils/Utilities/Thread")
local v3 = require3("@game/ReplicatedStorage/Common/Logger")
local v4 = require3("@game/ReplicatedStorage/Packages/Reliever")
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local function fn() end

local v5 = RunService:IsServer() and "Server" or "Client"
local v6 = not script:GetAttribute((`{v5}Required`))
script:SetAttribute(`{v5}Required`, true)
v3.namespace("RepInst", {
	enabled = false,
	filter = function(p)
		return (p.scope ~= "Swords" and p.scope ~= "SwordAccessories" or p.actor) and true or false
	end
})
local remoteFunction = v:RemoteFunction("ReplicatedInstances:FetchInstance")
local remoteFunction2 = v:RemoteFunction("ReplicatedInstances:FetchCollection")
local remoteEvent = v:RemoteEvent("ReplicatedInstances:DeleteReplicatedInstance")
local ReplicatedInstances = {
	Collections = {}
}

local function waitUntilLoaded()
	if not script:GetAttribute(`{v5}Loaded`, true) then
		fn("waitUntilLoaded")
		script:GetAttributeChangedSignal((`{v5}Loaded`)):Wait()
		fn("ReplicatedInstances loaded")
	end
end

function ReplicatedInstances:AddObjectToCollection(p, p2, p3, p4)
	local orCreateCollection = self:GetOrCreateCollection(p)
	orCreateCollection.Contents[p2] = p4
	orCreateCollection.Instances[p2] = p3
	return p4
end

function ReplicatedInstances:GetOrCreateCollection(p2)
	local collection = self.Collections[p2]

	if not collection then
		collection = {
			Instances = {},
			Contents = isServer and {} or nil,
			InstancesFetching = {},
			InstancesAwaitingThreads = {},
			ContentsFetching = false,
			ContentsAwaitingThreads = {}
		}
		self.Collections[p2] = collection
	end

	return collection
end

function ReplicatedInstances:GetCollection(p)
	local orCreateCollection = self:GetOrCreateCollection(p)

	if isServer then
		return assert(orCreateCollection.Contents, (`Expected contents for "{p}"`))
	end

	if orCreateCollection.Contents then
		return orCreateCollection.Contents
	end

	fn("GetCollection", p)

	if orCreateCollection.ContentsFetching then
		table.insert(orCreateCollection.ContentsAwaitingThreads, coroutine.running())
		return coroutine.yield()
	end

	orCreateCollection.ContentsFetching = true
	fn("Collection invoke server", p)
	local contents = remoteFunction2:InvokeServer(p)

	if contents then
		orCreateCollection.Contents = contents
	else
		warn("FetchCollection returned \"nil\" from the server")
	end

	orCreateCollection.ContentsFetching = false
	fn("Resume threads")

	while true do
		local v8, v9 = next(orCreateCollection.ContentsAwaitingThreads)

		if not v8 then
			break
		end

		v2.SafeResume(v9, contents)
		table.remove(orCreateCollection.ContentsAwaitingThreads, v8)
	end

	fn("Got collection", p)
	return contents
end

function ReplicatedInstances:GetInstance(p, p2)
	local orCreateCollection = self:GetOrCreateCollection(p)

	if orCreateCollection.Contents and not orCreateCollection.Contents[p2] then
		return nil
	end

	if isServer or orCreateCollection.Instances[p2] then
		return orCreateCollection.Instances[p2]
	end

	if orCreateCollection.InstancesFetching[p2] then
		local threads = orCreateCollection.InstancesAwaitingThreads[p2]

		if not threads then
			threads = {}
			orCreateCollection.InstancesAwaitingThreads[p2] = threads
		end

		table.insert(threads, coroutine.running())
		return coroutine.yield()
	else
		local instancesAwaitingThread = orCreateCollection.InstancesAwaitingThreads[p2]

		if not instancesAwaitingThread then
			instancesAwaitingThread = {}
			orCreateCollection.InstancesAwaitingThreads[p2] = instancesAwaitingThread
		end

		orCreateCollection.InstancesFetching[p2] = true
		local clone, v7 = remoteFunction:InvokeServer(p, p2)

		if not clone then
			orCreateCollection.InstancesFetching[p2] = nil
			return nil
		end

		local thread = coroutine.running()
		local count = #clone:GetDescendants()
		local descendantAddedConnection = nil
		descendantAddedConnection = clone.DescendantAdded:Connect(function()
			count += 1

			if coroutine.status(thread) == "suspended" then
				if v7 <= count then
					task.spawn(thread)
				end
			elseif descendantAddedConnection then
				descendantAddedConnection:Disconnect()
				descendantAddedConnection = nil
			end
		end)
		local destroyingConnection = clone.Destroying:Once(function()
			v2.SafeResume(thread)
		end)
		local thread2 = task.delay(10, function()
			v2.SafeResume(thread)
		end)

		if count < v7 then
			coroutine.yield()
		end

		if descendantAddedConnection then
			descendantAddedConnection:Disconnect()
			descendantAddedConnection = nil
		end

		if destroyingConnection then
			destroyingConnection:Disconnect()
		end

		v2.SafeCancel(thread2)

		if clone then
			clone = clone:Clone()
			orCreateCollection.Instances[p2] = clone
			remoteEvent:FireServer(p, p2)
		end

		orCreateCollection.InstancesAwaitingThreads[p2] = nil
		orCreateCollection.InstancesFetching[p2] = false

		while true do
			local v8, v9 = next(instancesAwaitingThread)

			if not v8 then
				break
			end

			v2.SafeResume(v9, clone)
			table.remove(instancesAwaitingThread, v8)
		end

		return clone
	end
end

function ReplicatedInstances.DeleteReplicatedInstance(_, p, p2)
	assert(isClient, "This function can be only used by the client")
	remoteEvent:FireServer(p, p2)
end

local class = {}
class.__index = class

function class.new(collection: string)
	return (setmetatable({
		Collection = collection
	}, class))
end

function class:GetCollection()
	return ReplicatedInstances:GetCollection(self.Collection)
end

function class:GetInstance(p2: string)
	return ReplicatedInstances:GetInstance(self.Collection, p2)
end

function ReplicatedInstances.createInstanceReplicatorFor(p: string)
	if isClient then
		xpcall(function()
			ReplicatedInstances:GetCollection(p)
		end, function(p2)
			warn((`Failed to fetch collection {p}: {p2}\n{debug.traceback()}`))
		end)
	end

	return class.new(p)
end

function ReplicatedInstances.Init(_)
	for _, moduleScript in script:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local v7 = moduleScript
		xpcall(require3, function(...)
			warn(v7, ...)
		end, moduleScript)
	end

	script:SetAttribute(`{v5}Loaded`, true)
end

if isServer and v6 then
	local function getReplicatedInstancesFolder(instance, name: string)
		local playerGui = instance:FindFirstChildWhichIsA("PlayerGui")

		if not playerGui then
			return
		end

		local parent = playerGui:FindFirstChild("ReplicatedInstances")

		if not parent then
			parent = Instance.new("Folder")
			parent.Name = "ReplicatedInstances"
			parent.Parent = playerGui
		end

		assert(parent, "ReplicatedInstances Folder not found")
		local v8 = parent:FindFirstChild(name)

		if not v8 then
			v8 = Instance.new("Folder")
			v8.Name = name
			v8.Parent = parent
		end

		return v8
	end

	remoteFunction2.OnServerInvoke = function(p, value: string)
		waitUntilLoaded()

		if type(value) == "string" and ReplicatedInstances.Collections[value] then
			v4.relieve()
			return ReplicatedInstances:GetCollection(value)
		else
			warn(p, "requested invalid collection", value)
		end
	end

	remoteFunction.OnServerInvoke = function(p, name: string, childName: string)
		waitUntilLoaded()

		if type(name) ~= "string" or not ReplicatedInstances.Collections[name] then
			return
		end

		v4.relieve()

		if p.Parent == nil then
			return
		end

		local replicatedInstancesFolder = getReplicatedInstancesFolder(p, name)

		if not replicatedInstancesFolder or type(childName) ~= "string" or replicatedInstancesFolder:FindFirstChild(childName) then
			return
		end

		local instance = ReplicatedInstances:GetInstance(name, childName)

		if not instance then
			return
		end

		local clone = instance:Clone()
		clone.Parent = replicatedInstancesFolder
		return clone, #clone:GetDescendants()
	end

	remoteEvent.OnServerEvent:Connect(function(p, name: string, childName: string)
		waitUntilLoaded()

		if type(childName) ~= "string" or type(name) ~= "string" or not ReplicatedInstances.Collections[name] then
			return
		end

		local replicatedInstancesFolder = getReplicatedInstancesFolder(p, name)

		if not replicatedInstancesFolder then
			return
		end

		local child = replicatedInstancesFolder:FindFirstChild(childName)

		if not child then
			return
		end

		child:Destroy()
	end)
end

return ReplicatedInstances