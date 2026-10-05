local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local EasterEvent = require(ReplicatedStorage.Shared.Easter.EasterEvent)

-- equivalent calls inferred from this helper; original call sites unknown
local function GetTimeElapsed()
	return workspace:GetServerTimeNow() - EasterEvent.AdminEvent.StartTime
end

local function getCurrentIteration()
	return GetTimeElapsed() // EasterEvent.AdminEvent.IterationTime
end

return Observers.observeTagNoAncestry("EasterAdminEventExpiresTime", function(p)
	local connection = Utils.Thread.Every(1, function()
		local timeElapsed = GetTimeElapsed() -- equivalent call inferred; original call site unknown
		local v2 = (timeElapsed // EasterEvent.AdminEvent.IterationTime + 1) * EasterEvent.AdminEvent.IterationTime - timeElapsed
		p.Text = Utils.ValueConvertor:FormatTimeWithDaysFull(v2)
	end)
	return function()
		connection:Disconnect()
	end
end)