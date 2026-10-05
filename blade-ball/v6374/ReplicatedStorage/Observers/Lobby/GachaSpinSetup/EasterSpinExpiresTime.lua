local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("EasterSpinExpiresTime", function(p)
	local connection = Utils.Thread.Every(1, function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v = (serverTimeNow // 3600 + 1) * 3600
		p.Text = Utils.ValueConvertor:FormatTimeWithDaysFull(v - serverTimeNow)
	end)
	return function()
		connection:Disconnect()
	end
end)