local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local GenericCoinCrateData = require(ReplicatedStorage.Shared.GenericCoinCrateData)
return Observers.observeTagNoAncestry("GenericCoinCrateEndTime", function(instance)
	instance:SetAttribute("EndTime", GenericCoinCrateData.EndTime)
	return function() end
end)