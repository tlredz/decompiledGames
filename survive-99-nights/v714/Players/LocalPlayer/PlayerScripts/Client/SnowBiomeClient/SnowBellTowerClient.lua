local SnowBellTowerClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local color = Color3.fromRGB(255, 255, 255)

function ApplyBellRungLighting()
	Client.ColorCorrectionLightingClient.OverrideLightingConfig("SnowBiome", {
		TintColor = color
	})
	Client.ColorCorrectionLightingClient.OverrideLightingConfig("SnowBiomeBlizzard", {
		TintColor = color
	})
end

Client.InteractionHandler.RegisterInteraction("BellRope", function(p)
	Client.Events.RequestRingSnowBell:FireServer(p)
end)

function SnowBellTowerClient.Init()
	if workspace:GetAttribute("SnowBellRung") then
		ApplyBellRungLighting()
	end

	workspace:GetAttributeChangedSignal("SnowBellRung"):Connect(ApplyBellRungLighting)
end

return SnowBellTowerClient