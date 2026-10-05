local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Common.Utils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local StPatricksDayEventController = require(ReplicatedStorage.Controllers.StPatricksDayEventController)
return Observers.observeTag("SealCrateLuckTimer", function(p)
	local connection = Utils.Thread.Every(1, function()
		local instantFFlag = Utils.FFlag.GetInstantFFlag("SealCrateLuckEndTime", 0)
		p.Text = Utils.ValueConvertor:FormatTimeHHMMSS((math.max(
			instantFFlag - workspace:GetServerTimeNow(),
			StPatricksDayEventController:HasLuck() and StPatricksDayEventController:GetRemaining() or 0
		)))
	end)
	return function()
		connection:Disconnect()
	end
end, { workspace })