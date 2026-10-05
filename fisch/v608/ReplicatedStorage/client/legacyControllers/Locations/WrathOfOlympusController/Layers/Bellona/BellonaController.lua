local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage.packages.Net)
local fx = require(ReplicatedStorage.shared.modules.fx)
local localPlayer = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("Bellona/AreaShake")
return {
	Start = function()
		remoteEvent.OnClientEvent:Connect(function()
			local shake = script:FindFirstChild("Shake")

			if shake then
				shake:Play()
			end

			fx:ShakeScreen(localPlayer, 4, 4)
			fx:ShakeScreen(localPlayer, 6, 3)
		end)
	end
}