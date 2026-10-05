local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local t = require(ReplicatedStorage.Packages.t)

local function typecheckAssertion(callback)
	return function(p)
		local v, v2 = callback(p)
		assert(v, v2)
		return p
	end
end

local function typecheckChecker(callback)
	return function(p)
		local success, result = pcall(callback, p)

		if success then
			return success, nil
		end

		return success, (tostring(result))
	end
end

local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))
local intersection2 = t.intersection(intersection, t.numberMin(0))
local intersection3 = t.intersection(intersection, t.numberPositive)
local intersection4 = t.intersection(t.integer, t.numberMin(1))

local function typecheckSetAssertion(p)
	local value = t.valueOf(p)
	return function(p2)
		local v, v2 = value(p2)
		assert(v, v2)
		return p2
	end
end

local replicated = FastFlags.Replicated
local boolean = t.boolean
local enabled = replicated("Game.TreadmillRecommendations.Enabled", function(p)
	local v2, v3 = boolean(p)
	assert(v2, v3)
	return p
end, false)
local replicated2 = FastFlags.Replicated
local value = t.valueOf({
	"MaximizeEngagement",
	"MaximizeTimespent",
	"MaximizeReactions",
	"RecentlyAdded",
	"TreadmillFeedV1",
	"TreadmillFeedV2"
})
local configName = replicated2("Game.TreadmillRecommendations.ConfigName", function(p)
	local v3, v4 = value(p)
	assert(v3, v4)
	return p
end, "MaximizeEngagement")
local replicated3 = FastFlags.Replicated("Game.TreadmillRecommendations.PageSize", function(p)
	local v3, v4 = intersection4(p)
	assert(v3, v4)
	return p
end, 20)
local replicated4 = FastFlags.Replicated("Game.TreadmillRecommendations.PrefetchMargin", function(p)
	local v3, v4 = intersection4(p)
	assert(v3, v4)
	return p
end, 5)
local replicated5 = FastFlags.Replicated("Game.TreadmillRecommendations.PrefetchJitterSeconds", function(p)
	local v3, v4 = intersection2(p)
	assert(v3, v4)
	return p
end, 10)
local replicated6 = FastFlags.Replicated("Game.TreadmillRecommendations.ConfigSwapSpreadSeconds", function(p)
	local v3, v4 = intersection2(p)
	assert(v3, v4)
	return p
end, 60)
local replicated7 = FastFlags.Replicated("Game.TreadmillRecommendations.StaleSeconds", function(p)
	local v3, v4 = intersection3(p)
	assert(v3, v4)
	return p
end, 900)
local replicated8 = FastFlags.Replicated("Game.TreadmillRecommendations.FetchRetryDelaySeconds", function(p)
	local v3, v4 = intersection3(p)
	assert(v3, v4)
	return p
end, 5)
local replicated9 = FastFlags.Replicated("Game.TreadmillRecommendations.FailureCooldownSeconds", function(p)
	local v3, v4 = intersection3(p)
	assert(v3, v4)
	return p
end, 30)
return table.freeze({
	Enabled = enabled,
	ConfigName = configName,
	PageSize = replicated3,
	PrefetchMargin = replicated4,
	PrefetchJitterSeconds = replicated5,
	ConfigSwapSpreadSeconds = replicated6,
	StaleSeconds = replicated7,
	FetchRetryDelaySeconds = replicated8,
	FailureCooldownSeconds = replicated9
})