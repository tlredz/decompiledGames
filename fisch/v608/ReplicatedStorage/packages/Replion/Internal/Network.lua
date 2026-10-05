local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Utils = require(script.Parent.Utils)
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local parent

if Utils.ShouldMock then
	parent = nil
elseif isServer then
	parent = Instance.new("Folder")
	parent.Name = "Remotes"
	parent.Parent = script.Parent.Parent
else
	parent = assert(
		script.Parent.Parent:WaitForChild("Remotes", 5),
		"Did you forget to require the Replion module on the server?"
	)
end

local function get(name: string)
	local child = parent:FindFirstChild(name)

	if child then
		return child
	end

	if isClient then
		error("Did you forget to require the Replion module on the server?")
	end

	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent.Parent = parent
	return remoteEvent
end

local function create(items)
	for _, childName in items do
		if parent:FindFirstChild(childName) then
			continue
		end

		if isClient then
			error("Did you forget to require the Replion module on the server?")
		end

		local remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = childName
		remoteEvent.Parent = parent
	end
end

local function sendTo(player, name: string, ...)
	if Utils.ShouldMock then
		return
	end

	local v2 = parent:FindFirstChild(name)

	if not v2 then
		if isClient then
			error("Did you forget to require the Replion module on the server?")
		end

		v2 = Instance.new("RemoteEvent")
		v2.Name = name
		v2.Parent = parent
	end

	if player == "All" then
		v2:FireAllClients(...)
	elseif type(player) == "table" then
		for _, item in player do
			if item:IsDescendantOf(Players) then
				v2:FireClient(item, ...)
			end
		end
	elseif typeof(player) == "Instance" and player:IsA("Player") then
		v2:FireClient(player, ...)
	else
		error("Invalid replicateTo!")
	end
end

return (table.freeze({
	get = get,
	create = create,
	sendTo = sendTo
}))