local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Common.Utils)
local StPatricksDayEventController = require(ReplicatedStorage.Controllers.StPatricksDayEventController)
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
return Observers.observeTagNoAncestry("StPatricksDayEventVisibility", function(instance)
	if StPatricksDayEventController:GetRemaining() > 0 and not StPatricksDayEventController:IsActive() then
		instance:SetAttribute("EndTime", 0)
		return nil
	end

	instance:SetAttribute("EndTime", StPatricksDayEventController:GetEndTime())
	local dataUpdatedEventConnection = FFlagClient.DataUpdatedEvent:Connect(function()
		instance:SetAttribute("EndTime", StPatricksDayEventController:GetEndTime())
	end)
	return function()
		dataUpdatedEventConnection:Disconnect()
	end
end)