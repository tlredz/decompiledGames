local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local GenericCrateData = require(ReplicatedStorage.Shared.GenericCrateData)
return Observers.observeTagNoAncestry("GenericCrateEndTime", function(instance)
	instance:SetAttribute("EndTime", GenericCrateData.EndTime)
	return function() end
end)