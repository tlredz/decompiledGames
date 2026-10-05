local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local remoteEvent = Net:RemoteEvent("Spectate/Update", -1)
local SpectateController = {}
local v = Trove.new()

function SpectateController:UpdateCamera(player)
	if not player.Character then
		return
	end

	workspace.CurrentCamera.CameraSubject = player.Character:WaitForChild("Humanoid")
end

function SpectateController:StartSpectating(p)
	v:Clean()

	if not p then
		SpectateController:UpdateCamera(localPlayer)
		return
	end

	SpectateController:UpdateCamera(p)
	v:Connect(p.CharacterAdded, function()
		SpectateController:UpdateCamera(p)
	end)
end

function SpectateController.Start(_)
	remoteEvent.OnClientEvent:Connect(function(p)
		SpectateController:StartSpectating(p)
	end)
end

return SpectateController