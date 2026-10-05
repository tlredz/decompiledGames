local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local LootboxData = require(ReplicatedStorage.Shared.LootboxData)
local _ = LootboxData.GachaEvents[LootboxData.ActiveGacha.Name]
return Observers.observeTagNoAncestry("SerpentBreakoutExpiresTime", function(p)
	local connection = Utils.Thread.Every(1, function()
		p.Text = Utils.ValueConvertor:FormatTimeWithDaysFull(1790438400 - workspace:GetServerTimeNow())
	end)
	return function()
		connection:Disconnect()
	end
end)