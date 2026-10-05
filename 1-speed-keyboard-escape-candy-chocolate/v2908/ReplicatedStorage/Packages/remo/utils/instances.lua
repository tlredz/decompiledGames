local Promise = require(script.Parent.Parent.Promise)
local constants = require(script.Parent.Parent.constants)
local mockRemotes = require(script.Parent.mockRemotes)
local container = script.Parent.Parent.container
local Instances = {}

function Instances.promiseRemoteFunction(childName: string)
	if container:FindFirstChild(childName) then
		return Promise.resolve(container[childName])
	end

	if constants.IS_EDIT then
		return Promise.resolve(mockRemotes.createMockRemoteFunction(childName))
	end

	return Promise.fromEvent(container.ChildAdded, function(remoteFunction)
		return remoteFunction:IsA("RemoteFunction") and remoteFunction.Name == childName
	end)
end

function Instances.promiseRemoteEvent(childName: string)
	if container:FindFirstChild(childName) then
		return Promise.resolve(container[childName])
	end

	if constants.IS_EDIT then
		return Promise.resolve(mockRemotes.createMockRemoteEvent(childName))
	end

	return Promise.fromEvent(container.ChildAdded, function(remoteEvent)
		return remoteEvent:IsA("RemoteEvent") and remoteEvent.Name == childName
	end)
end

function Instances.createRemoteFunction(name: string)
	if container:FindFirstChild(name) then
		return container[name]
	end

	if constants.IS_EDIT then
		return mockRemotes.createMockRemoteFunction(name)
	end

	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = name
	remoteFunction.Parent = container
	return remoteFunction
end

function Instances.createRemoteEvent(name: string, flag: boolean)
	if container:FindFirstChild(name) then
		return container[name]
	end

	if constants.IS_EDIT then
		return mockRemotes.createMockRemoteEvent(name)
	end

	local instance = Instance.new(flag and "UnreliableRemoteEvent" or "RemoteEvent")
	instance.Name = name
	instance.Parent = container
	return instance
end

return Instances