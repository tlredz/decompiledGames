local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpecialTrainingData = require(ReplicatedStorage.Shared.SpecialTrainingData)
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("TrainingNPC", function(instance)
	if instance:HasTag("UIPromptNPC") then
		instance:SetAttribute("EndTime", SpecialTrainingData.MAXEVENTTIME.UnixTimestamp)
		return function()
			instance:SetAttribute("EndTime", nil)
		end
	else
		warn((`TrainingNPC tag should be used with UIPromptNPC! {instance:GetFullName()}`))
	end
end)