local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Common.Utils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
local StPatricksDayEventController = require(ReplicatedStorage.Controllers.StPatricksDayEventController)
return Observers.observeTag("HalloweenGachaLuckTimer", function(p)
	local connection = Utils.Thread.Every(1, function()
		local v = not FFlagClient:IsDataReady() and 0 or math.max(
			(FFlagClient:GetKey("BattlepassGachaLuckEndTime") or 0) - workspace:GetServerTimeNow(),
			StPatricksDayEventController:HasLuck() and StPatricksDayEventController:GetRemaining() or 0
		)
		p.Text = Utils.ValueConvertor:FormatTimeHHMMSS(v)
	end)
	return function()
		connection:Disconnect()
	end
end, { workspace })