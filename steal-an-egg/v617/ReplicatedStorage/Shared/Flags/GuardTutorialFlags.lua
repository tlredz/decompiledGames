local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local t = require(ReplicatedStorage.Packages.t)

local function assertBoolean(p)
	local boolean, v = t.boolean(p)
	assert(boolean, v)
	return p
end

local v = {
	PauseNotificationEnabled = FastFlags.Replicated("Game.GuardTutorial.PauseNotificationEnabled", assertBoolean, false)
}
return table.freeze(v)