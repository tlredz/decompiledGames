local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local StormyLightningController = require(ReplicatedStorage.client.legacyControllers.StormyLightningController)
local WaterBodiesController = require(script.Parent.WaterBodiesController)
local remoteEvent = Net:RemoteEvent("ZeusLightningStrike")
return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(function(p, p2, p3)
			StormyLightningController:Strike(p, p2)

			if p3 then
				WaterBodiesController:OnStrike(p3)
			end
		end)
	end
}