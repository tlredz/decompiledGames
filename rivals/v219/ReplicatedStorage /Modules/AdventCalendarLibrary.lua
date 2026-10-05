local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local Utility = require(ReplicatedStorage.Modules.Utility)
local AdventCalendarLibrary = {
	IS_ACTIVE = false,
	VERSION = 4,
	START_TIME = not CONSTANTS.IS_STUDIO and 1765515600 or os.time(),
	Rewards = {},
	NumRewards = 0,
	GetTimeUntilRefresh = function(_)
		return math.ceil(ServerOsTime:GetRounded() / 86400) * 86400 - ServerOsTime:GetRounded()
	end
}

function AdventCalendarLibrary.GetReward(_, value)
	local v = math.floor((ServerOsTime:Get() - AdventCalendarLibrary.START_TIME) / 86400) + 1 + (value or 0)

	for _, reward in pairs(AdventCalendarLibrary.Rewards) do
		if reward.Day == v then
			return reward, v
		end
	end
end

local function add_reward(...)
	local day = AdventCalendarLibrary.NumRewards + 1
	local rewards = { ... }

	for _, v3 in pairs({}) do
		table.insert(rewards, Utility:CloneTable(v3))
	end

	local v3 = {
		Day = day,
		StartTime = AdventCalendarLibrary.START_TIME + (day - 1) * 86400,
		Rewards = rewards
	}
	AdventCalendarLibrary.Rewards[day] = v3
	AdventCalendarLibrary.NumRewards += 1
end

return AdventCalendarLibrary