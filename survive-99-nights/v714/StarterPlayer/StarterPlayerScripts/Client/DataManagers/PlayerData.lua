local PlayerData = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.ReplicatePlayerData:Connect(function(p, p2)
	PlayerData[p] = p2
	Client.Events["PlayerDataReplicated" .. p]:Fire()
end)
return PlayerData