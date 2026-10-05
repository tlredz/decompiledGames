local RunService = game:GetService("RunService")
local Utility = {
	tf = table.find,
	tof = typeof,
	tr = table.remove,
	tins = table.insert,
	functiontxt = "function",
	IsRunning = RunService:IsRunning(),
	IsServer = RunService:IsServer()
}
local _ = {
	Event = "Event",
	Function = "Function",
	Unreliable = "Unreliable"
}

function Utility.GetRemote(parent, name: string)
	if not Utility.IsRunning then
		return
	end

	if not Utility.IsServer then
		return parent:WaitForChild(name)
	end

	local remoteEvent = parent:FindFirstChild(name)

	if remoteEvent == nil then
		remoteEvent = name == "Event" and Instance.new("RemoteEvent") or name == "Function" and Instance.new("RemoteFunction") or Instance.new("UnreliableRemoteEvent")
		remoteEvent.Name = name
		remoteEvent.Parent = parent
	end

	return remoteEvent
end

function Utility.GetFireFunction(instance, flag: boolean?)
	if not Utility.IsRunning then
		return
	end

	if instance.ClassName == "RemoteEvent" or instance.ClassName == "UnreliableRemoteEvent" then
		if not Utility.IsServer then
			return instance.FireServer
		end

		if flag then
			return instance.FireAllClients
		end

		return instance.FireClient
	else
		if not Utility.IsServer then
			return instance.InvokeServer
		end

		if flag then
			return nil
		end

		return instance.InvokeClient
	end
end

function Utility:Connect(callback)
	if not Utility.IsRunning then
		return
	end

	if self.ClassName == "RemoteEvent" or self.ClassName == "UnreliableRemoteEvent" then
		if Utility.IsServer then
			return self.OnServerEvent:Connect(callback)
		end

		return self.OnClientEvent:Connect(callback)
	elseif Utility.IsServer then
		self.OnServerInvoke = callback
	else
		self.OnClientInvoke = callback
	end
end

Utility.WatchedFocus = {}

function Utility.WatchPosition(player)
	local v = Utility.WatchedFocus[player] or player.ReplicationFocus

	if v ~= nil and v.Parent ~= nil then
		return v.Position
	end

	local primaryPart = player.Character ~= nil and player.Character.PrimaryPart or nil
	return primaryPart ~= nil and primaryPart.Position or nil
end

if Utility.IsServer and Utility.IsRunning then
	Utility.Players = game.Players:GetPlayers()
	game.Players.PlayerAdded:Connect(function(player)
		if Utility.tf(Utility.Players, player) ~= nil then
			return
		end

		Utility.tins(Utility.Players, player)
	end)
	game.Players.PlayerRemoving:Connect(function(player)
		local v = Utility.tf(Utility.Players, player)

		if v ~= nil then
			Utility.tr(Utility.Players, v)
		end
	end)
end

return Utility