local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Thread = require(ReplicatedStorage.Common.Utils.Utilities.Thread)
local ValueConvertor = require(ReplicatedStorage.Common.Utils.Utilities.ValueConvertor)
return Observers.observeTagNoAncestry("TextEndTime", function(instance)
	local miliseconds = instance:GetAttribute("Miliseconds")
	local connection = Thread.Every(miliseconds and 0.1 or 1, function()
		local endTime = instance:GetAttribute("EndTime") or 0
		local serverTimeNow = workspace:GetServerTimeNow()

		if miliseconds then
			instance.Text = ValueConvertor:FormatTimeWithMS((math.max(endTime - serverTimeNow, 0)))
		else
			instance.Text = ValueConvertor:FormatTimeWithDaysFull((math.max(endTime - serverTimeNow, 0)))
		end
	end)
	return function()
		connection:Disconnect()
	end
end)