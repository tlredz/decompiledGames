require(game.ReplicatedStorage.Modules.FishHelper)
local FishingIndexInventoryData = require(game.ReplicatedStorage.FishReplicated.FishingIndexInventoryData)
local v = assert(FishingIndexInventoryData.FishIndex[FishingIndexInventoryData.NameMap["Golden Carp"]])
return {
	AUTO_SUBMIT_FISH = true,
	EVENT_ENABLED = false,
	GET_LEADERBOARD_INTERVAL = 60,
	MAX_RANK_CUTOFF = 1000,
	MAX_CLIENT_DISPLAY = 1000,
	MIN_SUBMISSIONS = 3,
	EVENT_FISH = table.clone(v)
}