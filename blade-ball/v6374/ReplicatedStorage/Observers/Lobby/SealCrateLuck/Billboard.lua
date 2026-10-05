local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Common.Utils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local StPatricksDayEventController = require(ReplicatedStorage.Controllers.StPatricksDayEventController)
return Observers.observeTag("SealCrateLuckEnabled", function(instance)
	if pcall(function()
		return instance.Enabled
	end) then
		local connection = Utils.Thread.Every(1, function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local instantFFlag = Utils.FFlag.GetInstantFFlag("SealCrateLuckStartTime", 0)
			local instantFFlag2 = Utils.FFlag.GetInstantFFlag("SealCrateLuckEndTime", 0)
			instance.Enabled = instantFFlag <= serverTimeNow and serverTimeNow < instantFFlag2 or StPatricksDayEventController:HasLuck()
		end)
		return function()
			connection:Disconnect()
		end
	end

	warn((`Tag "SealCrateLuckEnabled" was used in a object that doesn't has a .Enabled property: {instance:GetFullName()}`))
	return function() end
end, { workspace })