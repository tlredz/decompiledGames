local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("GachaSpinExpiresTime", function(instance)
	local endTime = instance:GetAttribute("EndTime") or 0
	local connection = Utils.Thread.Every(1, function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v = math.max(endTime - serverTimeNow, 0)
		instance.Text = Utils.ValueConvertor:FormatTimeWithDaysFull(v)
	end)
	return function()
		connection:Disconnect()
	end
end)