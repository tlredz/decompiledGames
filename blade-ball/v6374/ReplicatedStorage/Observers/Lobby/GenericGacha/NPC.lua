local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local fFlag = Utils.FFlag
local thread = Utils.Thread
local LootboxData = require(ReplicatedStorage.Shared.LootboxData)
local gachaEvent = LootboxData.GachaEvents[LootboxData.ActiveGacha.Name]
return Observers.observeTagNoAncestry("GenericGachaNPC", function(instance)
	local connection = nil
	connection = thread.Every(1, function()
		local v = fFlag.GetFFlag("UpdateTime-9/27/25", 1758992400) > workspace:GetServerTimeNow() and 0 or gachaEvent.EventEndTimeStamp.UnixTimestamp

		if v > 0 and connection then
			connection:Disconnect()
			connection = nil
		end

		instance:SetAttribute("EndTime", v)
	end)
	return function()
		if connection and connection.Connected then
			connection:Disconnect()
		end

		connection = nil
		instance:SetAttribute("EndTime", nil)
	end
end)