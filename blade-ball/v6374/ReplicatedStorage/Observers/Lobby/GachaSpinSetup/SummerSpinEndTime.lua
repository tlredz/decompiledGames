local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local SummerWheelData = require(ReplicatedStorage.Shared.SummerWheelData)
return Observers.observeTagNoAncestry("SummerSpinEndTime", function(instance)
	instance:SetAttribute("EndTime", SummerWheelData.End.UnixTimestamp)
	return function()
		instance:SetAttribute("EndTime", nil)
	end
end)