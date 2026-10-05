local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Common.Utils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
local StPatricksDayEventController = require(ReplicatedStorage.Controllers.StPatricksDayEventController)
local module = require("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
return Observers.observeTag("HalloweenGachaLuckEnabled", function(instance)
	if pcall(function()
		return instance.Enabled
	end) then
		local connection = Utils.Thread.Every(1, function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local v = not FFlagClient:IsDataReady() and 0 or math.max(
				(FFlagClient:GetKey("BattlepassGachaLuckEndTime") or 0) - serverTimeNow,
				StPatricksDayEventController:HasLuck() and StPatricksDayEventController:GetRemaining() or 0
			)
			instance.Enabled = module.isEnabled() and v > 0
		end)
		return function()
			connection:Disconnect()
		end
	end

	warn((`Tag "HalloweenGachaLuckEnabled" was used in a object that doesn't has a .Enabled property: {instance:GetFullName()}`))
	return function() end
end, { workspace })