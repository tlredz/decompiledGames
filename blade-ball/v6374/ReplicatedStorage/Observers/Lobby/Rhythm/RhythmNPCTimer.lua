game:GetService("ReplicatedStorage")
local module = require("@game/ReplicatedStorage/Packages/Observers")
local module2 = require("@game/ReplicatedStorage/Common/Utils")
local fFlag = module2.FFlag

local function GetTimeElapsed()
	return workspace:GetServerTimeNow() - EasterEvent.AdminEvent.StartTime
end

return module.observeTagNoAncestry("RhythmNPCTimer", function(p)
	local connection = module2.Thread.Every(1, function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v = (fFlag.GetInstantFFlag("RhythmEventEndTimestamp") or 0) - serverTimeNow
		p.Text = module2.ValueConvertor:FormatTimeWithDaysFull(v)
	end)
	return function()
		connection:Disconnect()
	end
end)