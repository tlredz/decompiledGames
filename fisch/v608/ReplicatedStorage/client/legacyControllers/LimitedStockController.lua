local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local remoteEvent = Net:RemoteEvent("Shop/Visible")
local shop = HudController:GetSafeZone().shop
return {
	Start = function(_)
		shop:GetPropertyChangedSignal("Visible"):Connect(function()
			remoteEvent:FireServer(shop.Visible)
		end)
	end
}