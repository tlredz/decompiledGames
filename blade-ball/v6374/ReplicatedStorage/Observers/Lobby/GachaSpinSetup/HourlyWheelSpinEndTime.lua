local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local HourlyWheelData = require(ReplicatedStorage.Shared.HourlyWheelData)
return Observers.observeTagNoAncestry("HourlyWheelSpinEndTime", function(instance)
	instance:SetAttribute("EndTime", HourlyWheelData.End.UnixTimestamp)
	return function()
		instance:SetAttribute("EndTime", nil)
	end
end)