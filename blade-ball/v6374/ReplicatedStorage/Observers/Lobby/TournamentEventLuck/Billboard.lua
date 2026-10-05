local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Common.Utils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local StPatricksDayEventController = require(ReplicatedStorage.Controllers.StPatricksDayEventController)
return Observers.observeTag("TournamentEventLuckEnabled", function(instance)
	if pcall(function()
		return instance.Enabled
	end) then
		local connection = Utils.Thread.Every(1, function()
			local serverTimeNow = workspace:GetServerTimeNow()
			instance.Enabled = Utils.FFlag.GetInstantFFlag("TournamentEventLuckStartTime", 0) <= serverTimeNow and serverTimeNow < Utils.FFlag.GetInstantFFlag(
				"TournamentEventLuckEndTime",
				0
			) or StPatricksDayEventController:HasLuck()
		end)
		return function()
			connection:Disconnect()
		end
	end

	warn((`Tag "TournamentEventLuckEnabled" was used in a object that doesn't has a .Enabled property: {instance:GetFullName()}`))
	return function() end
end, { workspace })