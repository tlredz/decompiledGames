local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local SpecialTrainingEventData = require(ReplicatedStorage.Shared.SpecialTrainingEvent.SpecialTrainingEventData)
return Observers.observeTagNoAncestry("SpecialTrainingEndTime", function(model)
	if model:IsA("Model") then
		model:SetAttribute("EndTime", SpecialTrainingEventData.EndTimestamp)
		return nil
	end

	local connection = Utils.Thread.Every(1, function()
		model.Text = Utils.ValueConvertor:FormatTimeWithDaysFull(SpecialTrainingEventData.EndTimestamp - workspace:GetServerTimeNow())
	end)
	return function()
		connection:Disconnect()
	end
end)