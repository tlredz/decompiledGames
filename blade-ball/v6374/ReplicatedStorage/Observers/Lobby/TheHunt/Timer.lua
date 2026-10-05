local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local unixTimestamp = DateTime.fromUniversalTime(2024, 3, 30, 19).UnixTimestamp
return Observers.observeTagNoAncestry("TheHuntQuestExpiresTime", function(p)
	local connection = Utils.Thread.Every(1, function()
		p.Text = `ENDS IN: {Utils.ValueConvertor:FormatTimeWithDays(unixTimestamp - workspace:GetServerTimeNow()):upper()}`
	end)
	return function()
		connection:Disconnect()
	end
end)