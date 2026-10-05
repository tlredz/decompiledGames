local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3("@game/ReplicatedStorage/Packages/Replion")
local v = require3("@game/ReplicatedStorage/Common/Utils")
require3("@self/Types")
require3("@self/Rewards")
local v2 = {
	Season = 6,
	StartTimestampFFlag = `InfiniteBattlepassStartTimestamp/{6}`,
	EndTimestampFFlag = `InfiniteBattlepassEndTimestamp/{6}`,
	ShopRefreshTime = 43200,
	AutoClaimQuests = true
}
local seasons = {}

for _, moduleScript in script.Seasons:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local success, result = pcall(require3, moduleScript)

	if not success then
		error((`Failed to require season {moduleScript.Name}`))
	end

	seasons[tonumber(moduleScript.Name)] = result
end

v2.SeasonData = assert(seasons[6], (`Failed to find season module for season {6}`))
v2.Seasons = seasons

function v2.isInCurrentSeason(object)
	local lastPlayedSeason = object:Get("LastPlayedSeason")
	local bPVersion = object:Get("BPVersion")

	if bPVersion ~= "Infinite" then
		warn((`{object} is not migrated to Infinite Battlepass!`))
	end

	return lastPlayedSeason == 6 and bPVersion == "Infinite"
end

function v2.getTimestamps()
	return {
		startTimestamp = v.FFlag.GetFFlag(v2.StartTimestampFFlag, v2.SeasonData.StartTimestamp),
		endTimestamp = v.FFlag.GetFFlag(v2.EndTimestampFFlag, v2.SeasonData.EndTimestamp)
	}
end

function v2.isEnabled()
	local unixTimestamp = DateTime.now().UnixTimestamp
	local timestamps = v2.getTimestamps()
	return timestamps.startTimestamp < unixTimestamp and unixTimestamp < timestamps.endTimestamp
end

return table.freeze(v2)