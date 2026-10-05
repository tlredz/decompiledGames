local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Common.Utils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local StPatricksDayEventController = require(ReplicatedStorage.Controllers.StPatricksDayEventController)
return Observers.observeTag("TournamentEventLuckTimer", function(p)
	local connection = Utils.Thread.Every(1, function()
		p.Text = Utils.ValueConvertor:FormatTimeHHMMSS((math.max(
			Utils.FFlag.GetInstantFFlag("TournamentEventLuckEndTime", 0) - workspace:GetServerTimeNow(),
			StPatricksDayEventController:HasLuck() and StPatricksDayEventController:GetRemaining() or 0
		)))
	end)
	return function()
		connection:Disconnect()
	end
end, { workspace })