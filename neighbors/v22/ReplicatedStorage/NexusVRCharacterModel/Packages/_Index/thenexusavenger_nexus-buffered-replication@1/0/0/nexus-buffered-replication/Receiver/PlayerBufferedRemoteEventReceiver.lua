local BufferedRemoteEventReceiver = require(script.Parent:WaitForChild("BufferedRemoteEventReceiver"))
local PlayerBufferedRemoteEventReceiver = {
	Players = game:GetService("Players")
}
PlayerBufferedRemoteEventReceiver.__index = PlayerBufferedRemoteEventReceiver

function PlayerBufferedRemoteEventReceiver.new(p, callback)
	local playerUserIdLookup = {}
	local self = setmetatable({
		PlayerUserIdLookup = playerUserIdLookup,
		BufferedRemoteEventReceiver = BufferedRemoteEventReceiver.new(p, callback)
	}, PlayerBufferedRemoteEventReceiver)

	for _, v2 in PlayerBufferedRemoteEventReceiver.Players:GetPlayers() do
		playerUserIdLookup[v2.UserId] = v2
	end

	table.insert(
		self.BufferedRemoteEventReceiver.EventConnections,
		PlayerBufferedRemoteEventReceiver.Players.PlayerAdded:Connect(function(player)
			playerUserIdLookup[player.UserId] = player
		end)
	)
	table.insert(
		self.BufferedRemoteEventReceiver.EventConnections,
		PlayerBufferedRemoteEventReceiver.Players.PlayerRemoving:Connect(function(player)
			playerUserIdLookup[player.UserId] = nil
		end)
	)
	return self
end

function PlayerBufferedRemoteEventReceiver:OnDataReceived(callback)
	self.BufferedRemoteEventReceiver:OnDataReceived(function(p2: number, p3)
		local v = self.PlayerUserIdLookup[p2]

		if not v then
			return
		end

		callback(v, p3)
	end)
end

function PlayerBufferedRemoteEventReceiver:Destroy()
	self.BufferedRemoteEventReceiver:Destroy()
end

return PlayerBufferedRemoteEventReceiver