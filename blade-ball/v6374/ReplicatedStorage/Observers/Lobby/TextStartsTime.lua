local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Thread = require(ReplicatedStorage.Common.Utils.Utilities.Thread)
local ValueConvertor = require(ReplicatedStorage.Common.Utils.Utilities.ValueConvertor)
return Observers.observeTagNoAncestry("TextStartTime", function(instance)
	local connection = Thread.Every(1, function()
		local startTime = instance:GetAttribute("StartTime") or 0
		local serverTimeNow = workspace:GetServerTimeNow()
		instance.Text = ValueConvertor:FormatTimeWithDaysFull((math.max(startTime - serverTimeNow, 0)))
	end)
	return function()
		connection:Disconnect()
	end
end)