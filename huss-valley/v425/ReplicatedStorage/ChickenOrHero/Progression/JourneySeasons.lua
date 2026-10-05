local JourneySeasons = {
	ActiveSeason = "season_1",
	Seasons = {
		season_1 = {
			Number = 1,
			Name = "THE FIRST CROSSING",
			TrackId = "valley_journey_1",
			PremiumPassId = 1988852667,
			RewardsModule = "JourneySeason1Rewards",
			MaxTier = 30,
			FirstTierXP = 150,
			TierStepXP = 25
		}
	}
}
local v = {}
local v2 = {}

for _, season in JourneySeasons.Seasons do
	local v3

	if type(season.TrackId) == "string" then
		v3 = not v[season.TrackId]
	else
		v3 = false
	end

	assert(v3, "Every Journey season needs a unique TrackId")
	v[season.TrackId] = true
	local v4

	if type(season.PremiumPassId) == "number" and season.PremiumPassId >= 0 then
		v4 = season.PremiumPassId % 1 == 0
	else
		v4 = false
	end

	assert(v4, "Invalid season pass")

	if season.PremiumPassId > 0 then
		assert(not v2[season.PremiumPassId], "Each season needs its own premium pass")
		v2[season.PremiumPassId] = true
	end

	local v5

	if season.MaxTier >= 1 and season.MaxTier <= 100 then
		v5 = season.MaxTier % 1 == 0
	else
		v5 = false
	end

	assert(v5, "Invalid season tier count")
	local v6

	if season.FirstTierXP > 0 then
		v6 = season.TierStepXP >= 0
	else
		v6 = false
	end

	assert(v6, "Invalid season XP curve")
end

assert(JourneySeasons.Seasons[JourneySeasons.ActiveSeason], "Unknown active Journey season")
return JourneySeasons