local EnrollableRemoteEvent = {
	Players = game:GetService("Players")
}
EnrollableRemoteEvent.__index = EnrollableRemoteEvent

function EnrollableRemoteEvent.new(remoteEvent)
	local object = setmetatable({
		RemoteEvent = remoteEvent,
		TotalPlayers = #EnrollableRemoteEvent.Players:GetPlayers(),
		EnrolledPlayers = {},
		EventConnections = {}
	}, EnrollableRemoteEvent)
	table.insert(object.EventConnections, EnrollableRemoteEvent.Players.PlayerAdded:Connect(function()
		object.TotalPlayers = #EnrollableRemoteEvent.Players:GetPlayers()
	end))
	table.insert(object.EventConnections, EnrollableRemoteEvent.Players.PlayerRemoving:Connect(function(player)
		object.TotalPlayers = #EnrollableRemoteEvent.Players:GetPlayers()
		object:UnenrollPlayer(player)
	end))
	return object
end

function EnrollableRemoteEvent.EnrollPlayer(p, p2)
	if table.find(p.EnrolledPlayers, p2) then
		return
	end

	table.insert(p.EnrolledPlayers, p2)
end

function EnrollableRemoteEvent:UnenrollPlayer(p2)
	local index = table.find(self.EnrolledPlayers, p2)

	if not index then
		return
	end

	table.remove(self.EnrolledPlayers, index)
end

function EnrollableRemoteEvent:FireAllClients(...)
	local v = #self.EnrolledPlayers

	if #self.EnrolledPlayers == 0 then
		return
	end

	local remoteEvent = self.RemoteEvent

	if v == self.TotalPlayers then
		remoteEvent:FireAllClients(...)
		return
	end

	for _, player in self.EnrolledPlayers do
		remoteEvent:FireClient(player, ...)
	end
end

function EnrollableRemoteEvent:Destroy()
	for _, eventConnection in self.EventConnections do
		eventConnection:Disconnect()
	end

	self.EventConnections = {}
end

return EnrollableRemoteEvent