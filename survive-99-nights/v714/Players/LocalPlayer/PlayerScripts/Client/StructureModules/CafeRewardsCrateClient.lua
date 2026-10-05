local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.InteractionHandler.RegisterInteraction("OpenCafeRewardsCrate", function(p)
	Client.Events.RequestOpenCafeRewardsCrate:FireServer(p)
end)
return {}