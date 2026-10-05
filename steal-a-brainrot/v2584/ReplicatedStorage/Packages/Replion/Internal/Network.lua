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
		script.Parent.Parent:WaitForChild("Remotes", 60),
		"Did you forget to require the Replion module on the server?"
	)
end

local function get(name: string)
	local child

	if RunService:IsClient() then
		child = parent:WaitForChild(name, 60)
	else
		child = parent:FindFirstChild(name)
	end

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

return (table.freeze({
	get = get,
	create = function(items)
		for _, item in items do
			get(item)
		end
	end,
	sendTo = function(player, name: string, ...)
		if Utils.ShouldMock then
			return
		end

		local v2 = get(name)

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
}))