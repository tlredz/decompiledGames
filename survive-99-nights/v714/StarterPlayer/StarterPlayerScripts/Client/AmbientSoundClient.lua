local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AmbientSoundClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.BiomeEntered:Connect(function(p)
	if p and p == "Cave" then
		ReplicatedStorage.Core.Sounds.CricketsLoop:Pause()
		ReplicatedStorage.Core.Sounds.CaveAmbient:Play()
	else
		ReplicatedStorage.Core.Sounds.CricketsLoop:Play()
		ReplicatedStorage.Core.Sounds.CaveAmbient:Pause()
	end
end)

function AmbientSoundClient.Init() end

return AmbientSoundClient