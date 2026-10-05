local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local LootboxData = require(ReplicatedStorage.Shared.LootboxData)
local gachaEvent = LootboxData.GachaEvents[LootboxData.ActiveGacha.Name]
return Observers.observeTagNoAncestry("GenericGachaExpiresTime", function(p)
	local connection = Utils.Thread.Every(1, function()
		p.Text = Utils.ValueConvertor:FormatTimeWithDaysFull(gachaEvent.EventEndTimeStamp.UnixTimestamp - workspace:GetServerTimeNow())
	end)
	return function()
		connection:Disconnect()
	end
end)