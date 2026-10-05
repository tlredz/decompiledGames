local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
require(ReplicatedStorage.Shared.Easter.EasterEvent)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("UGCStockUpdated")
return Observers.observeTagNoAncestry("EasterEventStock", function(p)
	p.Visible = false
	local onClientEventConnection = remoteEvent.OnClientEvent:Connect(function(p2, p3)
		if p2 == "LimitedEgg2026" then
			if p3.RemainingStock <= 0 then
				p.Visible = false
			else
				p.Text = `{Utils.ValueConvertor:AddCommas(p3.RemainingStock)}/{Utils.ValueConvertor:ShrinkNumber(p3.Stock)} Left`
				p.Visible = true
			end
		end
	end)
	return function()
		onClientEventConnection:Disconnect()
	end
end)