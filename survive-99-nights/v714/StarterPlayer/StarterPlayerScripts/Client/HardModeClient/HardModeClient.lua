local HardModeClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)

function HardModeActivated()
	Client.ResearchOutpostClient.TransformResearchOutpost()
end

Client.Events.HardModeActivated:Connect(HardModeActivated)

function NewRiftSpawned()
	HardModeClient.NewRiftSpawnedVisuals()
end

Client.Events.SpawnRiftVisuals:Connect(NewRiftSpawned)

function HardModeClient.NewRiftSpawnedVisuals()
	Client.ColorCorrectionLightingClient.SetRiftSpawning(true)
	Client.Sound.Play("RiftSpawn")
	task.spawn(function()
		wait(1.5)
		Client.Events.SetPopUpMessage:Fire("a new rift has opened on the map", "purple")
		wait(3.5)
		Client.ColorCorrectionLightingClient.SetRiftSpawning(false)
	end)
end

return HardModeClient