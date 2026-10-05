local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTag("NewYearsEventTimer", function(instance)
	local function updateTimer()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v = instance:GetAttribute("StartTime") - serverTimeNow

		if v > 0 and not workspace:GetAttribute("NewYearsEvent") then
			instance.Text = `Starts in: {Utils.ValueConvertor:FormatTimeWithDaysFull(v)}`
		else
			instance.Text = "Happening now!"
		end
	end

	local connection = Utils.Thread.Every(1, updateTimer)
	return function()
		connection:Disconnect()
		connection = nil
	end
end, { workspace })