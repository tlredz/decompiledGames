local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local remotes = nil

local function resolveFolder()
	if remotes then
		return remotes
	end

	if RunService:IsServer() then
		local v = ReplicatedStorage:FindFirstChild("Remotes")

		if not v then
			v = Instance.new("Folder")
			v.Name = "Remotes"
			v.Parent = ReplicatedStorage
		end

		remotes = v
	else
		remotes = ReplicatedStorage:WaitForChild("Remotes")
	end

	return remotes
end

local RemoteEvents = {}

function RemoteEvents.getOrCreate(name, value)
	assert(RunService:IsServer(), "RemoteEvents.getOrCreate is server-only")
	local folder = resolveFolder()
	local child = folder:FindFirstChild(name)

	if child then
		return child
	end

	local instance = Instance.new(value or "RemoteEvent")
	instance.Name = name
	instance.Parent = folder
	return instance
end

function RemoteEvents.waitFor(childName)
	return resolveFolder():WaitForChild(childName)
end

function RemoteEvents.tryGet(childName, value)
	return resolveFolder():WaitForChild(childName, value or 10)
end

return RemoteEvents