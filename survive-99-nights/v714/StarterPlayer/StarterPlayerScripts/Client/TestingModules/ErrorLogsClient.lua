local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local LogService = game:GetService("LogService")
Client.Events.RequestClientErrorLogs:OnClientInvoke(function()
	return (LogService:GetLogHistory())
end)
return {}