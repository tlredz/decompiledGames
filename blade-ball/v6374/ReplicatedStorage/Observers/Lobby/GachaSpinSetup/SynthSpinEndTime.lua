local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local SynthWheelData = require(ReplicatedStorage.Shared.SynthWheelData)
return Observers.observeTagNoAncestry("SynthSpinEndTime", function(instance)
	instance:SetAttribute("EndTime", SynthWheelData.End.UnixTimestamp)
	return function()
		instance:SetAttribute("EndTime", nil)
	end
end)