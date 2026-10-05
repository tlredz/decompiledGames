local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local EasterEvent = require(ReplicatedStorage.Shared.Easter.EasterEvent)
return Observers.observeTagNoAncestry("EasterEventEndTime", function(instance)
	instance:SetAttribute("EndTime", EasterEvent.EndTime.UnixTimestamp)
	return function()
		instance:SetAttribute("EndTime", nil)
	end
end)