local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local TournamentEventData = require(ReplicatedStorage.Shared.TournamentEvent.TournamentEventData)
return Observers.observeTagNoAncestry("TournamentEventEndTime", function(label)
	local endTime = label:GetAttribute("EndTime") or TournamentEventData.EndTime.UnixTimestamp
	local connection = nil
	connection = Utils.Thread.Every(1, function()
		local v = Utils.FFlag.GetFFlag("UpdateTime-9/27/25", 1758992400) > workspace:GetServerTimeNow() and 0 or endTime

		if v > 0 and connection then
			connection:Disconnect()
			connection = nil
		end

		label:SetAttribute("EndTime", v)
	end)
	local connection2

	if label:IsA("TextLabel") then
		connection2 = Utils.Thread.Every(1, function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local v = math.max(endTime - serverTimeNow, 0)
			label.Text = Utils.ValueConvertor:FormatTimeWithDaysFull(v)
		end)
	else
		connection2 = nil
	end

	return function()
		if connection2 then
			connection2:Disconnect()
			connection2 = nil
		end

		if connection then
			connection:Disconnect()
			connection = nil
		end
	end
end)