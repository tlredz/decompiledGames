local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Common.Utils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local LootboxData = require(ReplicatedStorage.Shared.LootboxData)
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
local GenericGachaController = require(ReplicatedStorage.Controllers.UI.GenericGachaController)
return Observers.observeTag("GenericGachaLuckEnabled", function(instance)
	if pcall(function()
		return instance.Enabled
	end) then
		local connection = Utils.Thread.Every(1, function()
			local serverTimeNow = workspace:GetServerTimeNow()
			instance.Enabled = serverTimeNow < LootboxData.GachaEvents.IceDragonGacha.EventEndTimeStamp.UnixTimestamp and serverTimeNow < (FFlagClient:IsDataReady() and FFlagClient:GetKey((`{GenericGachaController.Identifier}LuckEndTime`)) or 0) and (FFlagClient:IsDataReady() and FFlagClient:GetKey((`{GenericGachaController.Identifier}LuckStartTime`)) or 0) <= serverTimeNow
		end)
		return function()
			connection:Disconnect()
		end
	end

	warn((`Tag "GenericGachaLuckEnabled" was used in a object that doesn't has a .Enabled property: {instance:GetFullName()}`))
	return nil
end, { workspace })