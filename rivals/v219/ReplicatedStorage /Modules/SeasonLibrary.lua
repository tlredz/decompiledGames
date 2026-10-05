local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local rankedQueues2 = {
	{ "ranked_1v1", "ranked" },
	{ "ranked_2v2", "ranked" },
	{ "ranked_3v3", "ranked" }
}
local SeasonLibrary = {
	UNIVERSAL_ELO_NAME = "ranked",
	PASS_TRACK_IMAGES = { "rbxassetid://81577092220450", "rbxassetid://74965952714478" },
	SEASON_PASS_LEVELS_IN_SEASON_BUNDLE = 20,
	PASS_XP_PER_LEVEL_VISUAL = 10,
	Seasons = {},
	SeasonsByVersion = {},
	CurrentSeason = nil,
	RankProfiles = {},
	IsRankedQueue = function(p, p2, p3)
		local v6 = p3 or p.CurrentSeason.Name

		for _, rankedQueue in pairs(p.Seasons[v6].RankedQueues) do
			if rankedQueue[1] == p2 then
				return rankedQueue[2]
			end
		end
	end
}

function SeasonLibrary.GetCurrentSeasonWeek(_)
	return (math.ceil((ServerOsTime:Get() - SeasonLibrary.CurrentSeason.StartTime) / 604800))
end

function SeasonLibrary.GetTimeUntilNextSeasonWeek(_)
	return math.ceil((ServerOsTime:Get() - SeasonLibrary.CurrentSeason.StartTime) / 604800) * 7 * 24 * 60 * 60 + SeasonLibrary.CurrentSeason.StartTime - ServerOsTime:Get()
end

function SeasonLibrary:GetHighestELOLeaderboardRanking(p, p2)
	local LeaderboardService

	if CONSTANTS.IS_SERVER then
		LeaderboardService = require(ServerStorage.Services.LeaderboardService)
	else
		LeaderboardService = require(Players.LocalPlayer.PlayerScripts.Controllers.LeaderboardController)
	end

	if p2 then
		return LeaderboardService:GetRankingByUserID("Highest ELO", p2)
	end

	if p then
		return LeaderboardService:GetRankingByValue("Highest ELO", p)
	end
end

function SeasonLibrary:GetRank(p, p2, p3, p4)
	if not p then
		return "Unranked"
	end

	local v6 = p4 or self.CurrentSeason.RankProfile.Name
	local rankProfile = self.RankProfiles[v6]
	assert(rankProfile ~= nil)
	local v7 = nil

	for k, v9 in pairs(rankProfile.RanksOrder) do
		local rank = rankProfile.Ranks[v9]

		if not (p < rank.RequiredELO) or rank.RequiredELOLeaderboardRanking then
			continue
		end

		v7 = k - 1
		break
	end

	if not v7 then
		local v9 = p3 or self:GetHighestELOLeaderboardRanking(p, p2)

		for i = #rankProfile.RanksOrder, 1, -1 do
			local v10 = rankProfile.RanksOrder[i]
			local rank = rankProfile.Ranks[v10]

			if not (not rank.RequiredELOLeaderboardRanking or rank.RequiredELO <= p and (v9 or 1e999) <= rank.RequiredELOLeaderboardRanking) then
				continue
			end

			v7 = i
			break
		end
	end

	return rankProfile.RanksOrder[math.clamp(v7, 1, #rankProfile.RanksOrder)]
end

function SeasonLibrary.GetGloryPayout(p, p2, p3)
	local season = p.Seasons[p2]
	local count = 0
	local total = 0

	for _, v6 in pairs(p3.RankedPerformances or {}) do
		count += 1

		if not v6.CurrentELO then
			continue
		end

		local v7 = season.GloryPayoutWinsInfluence * math.clamp(v6.DuelsWon / season.GloryPayoutMaxWins, 0, 1)
		local v8 = season.GloryPayoutELOInfluence * math.clamp(v6.CurrentELO / season.GloryPayoutMaxELO, 0, 1)
		total += season.MaxGloryPayout * (v8 + v7)
	end

	if count <= 0 then
		return 0
	end

	local v6 = math.floor(total / count)
	return (math.clamp(math.max(math.sign(total), v6), 0, season.MaxGloryPayout))
end

function SeasonLibrary.GetRewardSeasonPassPosition(_, p)
	for i = 1, SeasonLibrary.CurrentSeason.NumBattlePassTiers do
		for i2 = 1, SeasonLibrary.CurrentSeason.NumBattlePassTracks do
			local v6 = SeasonLibrary.CurrentSeason.BattlePassRewards[i] and SeasonLibrary.CurrentSeason.BattlePassRewards[i][i2]

			if v6 and v6.Name == p then
				return i, i2
			end
		end
	end
end

function SeasonLibrary.FormatSeasonRankCharm(p, folder, p2, p3, value)
	assert(p2)
	local text = not value and "" or "#" .. value or ""
	local rank = SeasonLibrary:GetRank(p3, nil, value or 1e999, p.Seasons[p2].RankProfile.Name)

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:HasTag("CharmLeaderboardRank") then
			descendant.Text = text
		end
	end

	if folder:FindFirstChild("Extra") then
		for _, child in pairs(folder.Extra:GetChildren()) do
			if child.Name ~= rank then
				task.defer(child.Destroy, child)
			end
		end
	end
end

local function add_rank_profile(name, numPlacementDuels, placementELOMin, placementELOMax)
	SeasonLibrary.RankProfiles[name] = {
		Name = name,
		NumPlacementDuels = numPlacementDuels,
		PlacementELOMin = placementELOMin,
		PlacementELOMax = placementELOMax,
		LowestRankELO = 1e999,
		HighestRankELO = -1e999,
		Ranks = {},
		RanksOrder = {},
		Groups = {},
		GroupsOrder = {}
	}
end

add_rank_profile("ranks_version1", 10, 100, 2500)

local function add_rank_group(p, name, color, image, p4)
	local v6 = {
		Name = name,
		Color = color,
		Image = image,
		SecondaryColor = p4 or Color3.fromRGB(0, 0, 0),
		Ranks = {}
	}
	SeasonLibrary.RankProfiles[p].Groups[name] = v6
	table.insert(SeasonLibrary.RankProfiles[p].GroupsOrder, name)
end

add_rank_group("ranks_version1", "Unranked", Color3.fromRGB(255, 255, 255), "rbxassetid://111599878354131")
add_rank_group("ranks_version1", "Bronze", Color3.fromRGB(184, 117, 69), "rbxassetid://73543520622815")
add_rank_group("ranks_version1", "Silver", Color3.fromRGB(200, 200, 200), "rbxassetid://107898816876115")
add_rank_group("ranks_version1", "Gold", Color3.fromRGB(255, 215, 0), "rbxassetid://90039594400813")
add_rank_group("ranks_version1", "Platinum", Color3.fromRGB(65, 255, 248), "rbxassetid://73345783863790")
add_rank_group("ranks_version1", "Diamond", Color3.fromRGB(50, 159, 255), "rbxassetid://112183171942172")
add_rank_group("ranks_version1", "Onyx", Color3.fromRGB(255, 114, 0), "rbxassetid://127982903682334")
add_rank_group("ranks_version1", "Nemesis", Color3.fromRGB(191, 0, 255), "rbxassetid://116941545385923")
add_rank_group(
	"ranks_version1",
	"Archnemesis",
	Color3.fromRGB(0, 0, 0),
	"rbxassetid://133793956251748",
	Color3.fromRGB(31, 81, 78)
)

-- equivalent calls inferred from this helper; original call sites unknown
local function add_rank(p, rankGroupName, displayName, requiredELO, image, p6, requiredELOLeaderboardRanking)
	local rankProfile = SeasonLibrary.RankProfiles[p]
	local v6 = {
		RankGroupName = rankGroupName,
		DisplayName = displayName,
		RequiredELO = requiredELO,
		RequiredELOLeaderboardRanking = requiredELOLeaderboardRanking,
		Image = image
	}
	rankProfile.Ranks[displayName] = v6
	table.insert(rankProfile.RanksOrder, displayName)

	if not p6 then
		rankProfile.LowestRankELO = math.min(rankProfile.LowestRankELO, v6.RequiredELO)
		rankProfile.HighestRankELO = math.max(rankProfile.HighestRankELO, v6.RequiredELO)
	end

	if v6.RankGroupName then
		table.insert(rankProfile.Groups[v6.RankGroupName].Ranks, displayName)
	end
end

add_rank("ranks_version1", "Unranked", "Unranked", -1, "rbxassetid://111599878354131", true, nil) -- equivalent call inferred; original call site unknown
add_rank("ranks_version1", "Bronze", "Bronze 1", 0, "rbxassetid://106623367501544")
add_rank("ranks_version1", "Bronze", "Bronze 2", 200, "rbxassetid://131795064007344")
add_rank("ranks_version1", "Bronze", "Bronze 3", 400, "rbxassetid://73543520622815")
add_rank("ranks_version1", "Silver", "Silver 1", 600, "rbxassetid://80716950169934")
add_rank("ranks_version1", "Silver", "Silver 2", 800, "rbxassetid://136100661820261")
add_rank("ranks_version1", "Silver", "Silver 3", 1000, "rbxassetid://107898816876115")
add_rank("ranks_version1", "Gold", "Gold 1", 1200, "rbxassetid://134520747948636")
add_rank("ranks_version1", "Gold", "Gold 2", 1400, "rbxassetid://114166096331502")
add_rank("ranks_version1", "Gold", "Gold 3", 1600, "rbxassetid://90039594400813")
add_rank("ranks_version1", "Platinum", "Platinum 1", 1800, "rbxassetid://133903971285645")
add_rank("ranks_version1", "Platinum", "Platinum 2", 2000, "rbxassetid://82834564754747")
add_rank("ranks_version1", "Platinum", "Platinum 3", 2200, "rbxassetid://73345783863790")
add_rank("ranks_version1", "Diamond", "Diamond 1", 2400, "rbxassetid://113997689031026")
add_rank("ranks_version1", "Diamond", "Diamond 2", 2600, "rbxassetid://88059506918419")
add_rank("ranks_version1", "Diamond", "Diamond 3", 2800, "rbxassetid://112183171942172")
add_rank("ranks_version1", "Onyx", "Onyx 1", 3000, "rbxassetid://104871954739030")
add_rank("ranks_version1", "Onyx", "Onyx 2", 3200, "rbxassetid://109012386782238")
add_rank("ranks_version1", "Onyx", "Onyx 3", 3400, "rbxassetid://127982903682334")
add_rank("ranks_version1", "Nemesis", "Nemesis", 3600, "rbxassetid://116941545385923", true, nil) -- equivalent call inferred; original call site unknown
add_rank("ranks_version1", "Archnemesis", "Archnemesis", 3600, "rbxassetid://133793956251748", true, 200) -- equivalent call inferred; original call site unknown

local function add_season(p, resetCounter, name, version, startTime)
	if ServerOsTime:Get() < startTime then
		startTime -= 604800
	end

	local currentSeason = {
		ResetCounter = resetCounter,
		Name = name,
		Version = version,
		StartTime = startTime,
		RankProfile = nil,
		RankedQueues = nil,
		BypassTrustworthySpendRequirement = nil,
		AccountAgeRequirement = nil,
		LevelRequirement = nil,
		MaximumPartyELODifference = nil,
		DailyELOShields = nil,
		ELOShieldMaxELOAllowed = nil,
		ELODecayThreshold = nil,
		ELODecayPerInactiveDay = nil,
		ELODecayInactivePeriodDays = nil,
		ParticipationPrizes = nil,
		ParticipationPointsPerWin = nil,
		ParticipationPointsPerLoss = nil,
		MatchmakingStompRewardName = nil,
		GloryPayoutMaxWins = nil,
		GloryPayoutWinsInfluence = nil,
		GloryPayoutMaxELO = nil,
		GloryPayoutELOInfluence = nil,
		MaxGloryPayout = nil,
		TopPlayerRewardSkinName = nil,
		TopPlayerLeaderboardRank = nil,
		ThumbnailRankedCoverPhoto = nil,
		ThumbnailRanked1v1 = nil,
		ThumbnailRanked2v2 = nil,
		ThumbnailRanked3v3 = nil,
		BattlePassActive = false,
		BattlePassTasksPerWeek = nil,
		BattlePassTaskRequirements = nil,
		BattlePassRewards = nil,
		NumBattlePassTiers = nil,
		NumBattlePassTracks = nil,
		ContrabandBundleSkinName = nil,
		ContrabandBundleFinisherName = nil,
		ContrabandBundleWrapName = nil,
		ContrabandBundleCharmName = nil,
		ContrabandBundleEmoteName = nil
	}
	SeasonLibrary.Seasons[name] = currentSeason
	SeasonLibrary.SeasonsByVersion[version] = currentSeason

	if p then
		assert(not SeasonLibrary.CurrentSeason)
		SeasonLibrary.CurrentSeason = currentSeason
	end
end

add_season(false, 5, "Zero", 0, 1740718800)
add_season(false, 0, "Warp", 1, 1758859200)
add_season(false, 0, "Polar", 2, 1765515600)
add_season(true, 0, "Fame", 3, 1777003200)

local function add_season_ranked_details(p, p2, rankedQueues, bypassTrustworthySpendRequirement, accountAgeRequirement, levelRequirement, tasksCompletedRequirement, maximumPartyELODifference, dailyELOShields, eLOShieldMaxELOAllowed, eLODecayThreshold, eLODecayPerInactiveDay, eLODecayInactivePeriodDays, participationPointsPerWin, participationPointsPerLoss, participationPrizes, matchmakingStompRewardName, gloryPayoutMaxWins, gloryPayoutWinsInfluence, gloryPayoutMaxELO, gloryPayoutELOInfluence, maxGloryPayout, topPlayerRewardSkinName, topPlayerLeaderboardRank, thumbnailRankedCoverPhoto, thumbnailRanked1v, thumbnailRanked2v, thumbnailRanked3v)
	local season = SeasonLibrary.Seasons[p]

	for _, participationPriz in pairs(participationPrizes) do
		local name = participationPriz[2].Name
		local cosmetic = CosmeticLibrary.Cosmetics[name]

		if not cosmetic or CosmeticLibrary.Types[cosmetic.Type].NotCosmetic then
			continue
		end

		CosmeticLibrary:ExternallySetCosmeticDescription(name, "Earned by playing Ranked Season " .. season.Version)
	end

	if topPlayerRewardSkinName and topPlayerLeaderboardRank then
		CosmeticLibrary:ExternallySetCosmeticDescription(
			topPlayerRewardSkinName,
			"Given to the Top " .. topPlayerLeaderboardRank .. " players from Ranked Season " .. season.Version
		)
	end

	season.RankProfile = SeasonLibrary.RankProfiles[p2]
	season.RankedQueues = rankedQueues
	season.BypassTrustworthySpendRequirement = bypassTrustworthySpendRequirement
	season.AccountAgeRequirement = accountAgeRequirement
	season.LevelRequirement = levelRequirement
	season.TasksCompletedRequirement = tasksCompletedRequirement
	season.MaximumPartyELODifference = maximumPartyELODifference
	season.DailyELOShields = dailyELOShields
	season.ELOShieldMaxELOAllowed = eLOShieldMaxELOAllowed
	season.ELODecayThreshold = eLODecayThreshold
	season.ELODecayPerInactiveDay = eLODecayPerInactiveDay
	season.ELODecayInactivePeriodDays = eLODecayInactivePeriodDays
	season.ParticipationPrizes = participationPrizes
	season.ParticipationPointsPerWin = participationPointsPerWin
	season.ParticipationPointsPerLoss = participationPointsPerLoss
	season.MatchmakingStompRewardName = matchmakingStompRewardName
	season.GloryPayoutMaxWins = gloryPayoutMaxWins
	season.GloryPayoutWinsInfluence = gloryPayoutWinsInfluence
	season.GloryPayoutMaxELO = gloryPayoutMaxELO
	season.GloryPayoutELOInfluence = gloryPayoutELOInfluence
	season.MaxGloryPayout = maxGloryPayout
	season.TopPlayerRewardSkinName = topPlayerRewardSkinName
	season.TopPlayerLeaderboardRank = topPlayerLeaderboardRank
	season.ThumbnailRankedCoverPhoto = thumbnailRankedCoverPhoto
	season.ThumbnailRanked1v1 = thumbnailRanked1v
	season.ThumbnailRanked2v2 = thumbnailRanked2v
	season.ThumbnailRanked3v3 = thumbnailRanked3v
	assert(CosmeticLibrary.Cosmetics["Season " .. season.Version] ~= nil)
end

add_season_ranked_details("Zero", "ranks_version1", rankedQueues2, 0, 14, 30, 0, 800, 1, 1800, 3000, 100, 7, 5, 0, {
	{
		1000,
		{
			Name = "Phoenix Rifle",
			Weapon = "Assault Rifle"
		}
	}
}, nil, 250, 0.5, 3600, 0.5, 2500, "Arch Katana", 200, "rbxassetid://103123155567436", "rbxassetid://103123155567436", "rbxassetid://94210614848859", "rbxassetid://136241323883086")
add_season_ranked_details("Warp", "ranks_version1", rankedQueues2, 0, 14, 30, 0, 800, 1, 1800, 3000, 100, 7, 5, 0, {
	{
		50,
		{
			Name = "Mini Unstable Portal",
			Weapon = "IsUniversal"
		}
	},
	{
		100,
		{
			Name = "Glory",
			Quantity = 100
		}
	},
	{
		200,
		{
			Name = "Spiral",
			Weapon = "IsUniversal"
		}
	},
	{
		300,
		{
			Name = "Glory",
			Quantity = 150
		}
	},
	{
		500,
		{
			Name = "Warped Away",
			Weapon = "IsUniversal"
		}
	},
	{
		750,
		{
			Name = "Glory",
			Quantity = 250
		}
	},
	{
		1000,
		{
			Name = "Warp Handgun",
			Weapon = "Handgun"
		}
	}
}, nil, 250, 0.5, 3600, 0.5, 2500, "Arch Crossbow", 200, "rbxassetid://108294156233914", "rbxassetid://108294156233914", "rbxassetid://74079396411050", "rbxassetid://131383109536840")
add_season_ranked_details("Polar", "ranks_version1", rankedQueues2, 1, 14, 50, 30, 800, 1, 1800, 3000, 100, 7, 5, 0, {
	{
		50,
		{
			Name = "Snowman",
			Weapon = "IsUniversal"
		}
	},
	{
		100,
		{
			Name = "Glory",
			Quantity = 100
		}
	},
	{
		200,
		{
			Name = "Tusky",
			Weapon = "IsUniversal"
		}
	},
	{
		300,
		{
			Name = "Glory",
			Quantity = 150
		}
	},
	{
		500,
		{
			Name = "Northern Light Show",
			Weapon = "IsUniversal"
		}
	},
	{
		750,
		{
			Name = "Glory",
			Quantity = 250
		}
	},
	{
		1000,
		{
			Name = "Frozen Grenade",
			Weapon = "Grenade"
		}
	}
}, nil, 250, 0.5, 3600, 0.5, 2500, "Arch Molotov", 200, "rbxassetid://76786660109423", "rbxassetid://77500396480714", "rbxassetid://76786660109423", "rbxassetid://103544907023810")
add_season_ranked_details("Fame", "ranks_version1", rankedQueues2, 200, 14, 100, 30, 800, 1, 1800, 3000, 100, 7, 5, 0, {
	{
		50,
		{
			Name = "Horseshoe",
			Weapon = "IsUniversal"
		}
	},
	{
		100,
		{
			Name = "Glory",
			Quantity = 50
		}
	},
	{
		200,
		{
			Name = "Mesa",
			Weapon = "IsUniversal"
		}
	},
	{
		300,
		{
			Name = "Glory",
			Quantity = 100
		}
	},
	{
		400,
		{
			Name = "Paparazzi Flash",
			Weapon = "IsUniversal"
		}
	},
	{
		500,
		{
			Name = "Glory",
			Quantity = 150
		}
	},
	{
		600,
		{
			Name = "Standoff"
		}
	},
	{
		750,
		{
			Name = "Glory",
			Quantity = 200
		}
	},
	{
		1000,
		{
			Name = "Spy Gloves",
			Weapon = "Fists"
		}
	}
}, "Season 3 Stomp", 250, 0.65, 3600, 0.35, 2500, "Arch Uzi", 200, "rbxassetid://105428897961077", "rbxassetid://76704907616030", "rbxassetid://96045696868067", "rbxassetid://73857466226252")

local function add_season_battlepass_details(childName, battlePassTasksPerWeek, roundsWon, playtime, contrabandBundleSkinName, contrabandBundleFinisherName, contrabandBundleWrapName, contrabandBundleCharmName, contrabandBundleEmoteName)
	local season = SeasonLibrary.Seasons[childName]
	local module = require(script:WaitForChild("SeasonPasses"):WaitForChild(childName))
	local junkRewards = module.JunkRewards
	local rawRewards = module.RawRewards

	for _, list in pairs(junkRewards) do
		table.sort(list, function(a, b)
			return a.Chance < b.Chance
		end)
	end

	local count = 0

	local function get_junk_reward(i)
		count += 1
		local number = Random.new(count):NextNumber()
		local junkReward = junkRewards[i]
		local v6 = junkReward[#junkReward]

		for _, v8 in pairs(junkReward) do
			if not (number <= v8.Chance) then
				continue
			end

			v6 = v8
			break
		end

		return table.clone(v6.RewardData)
	end

	local numBattlePassTiers = 0
	local numBattlePassTracks = 0

	for k, rawReward in pairs(rawRewards) do
		numBattlePassTiers = math.max(numBattlePassTiers, k)

		for k2 in pairs(rawReward) do
			numBattlePassTracks = math.max(numBattlePassTracks, k2)
		end
	end

	for i = 1, numBattlePassTiers do
		rawRewards[i] = rawRewards[i] or {}

		for i2 = 1, numBattlePassTracks do
			if i ~= 1 or i2 ~= 1 then
				rawRewards[i][i2] = rawRewards[i][i2] or get_junk_reward(i2)
			end
		end
	end

	for _, v8 in pairs({
		contrabandBundleSkinName,
		contrabandBundleFinisherName,
		contrabandBundleWrapName,
		contrabandBundleCharmName,
		contrabandBundleEmoteName
	}) do
		CosmeticLibrary:ExternallySetCosmeticDescription(
			v8,
			"Included in the Contraband Bundle from Season " .. season.Version
		)
	end

	for i = 1, numBattlePassTiers do
		for i2 = 1, numBattlePassTracks do
			local v8 = rawRewards[i][i2]
			local v9 = v8 and CosmeticLibrary.Cosmetics[v8.Name]

			if not v9 or (v9.Description or v9.DescriptionSpecific) then
				continue
			end

			CosmeticLibrary:ExternallySetCosmeticDescription(
				v8.Name,
				"Earned from the Season Pass during Season " .. season.Version
			)
		end
	end

	season.BattlePassActive = true
	season.BattlePassTasksPerWeek = battlePassTasksPerWeek
	season.BattlePassTaskRequirements = {
		RoundsWon = roundsWon,
		Playtime = playtime
	}
	season.BattlePassRewards = rawRewards
	season.NumBattlePassTiers = numBattlePassTiers
	season.NumBattlePassTracks = numBattlePassTracks
	season.ContrabandBundleSkinName = contrabandBundleSkinName
	season.ContrabandBundleFinisherName = contrabandBundleFinisherName
	season.ContrabandBundleWrapName = contrabandBundleWrapName
	season.ContrabandBundleCharmName = contrabandBundleCharmName
	season.ContrabandBundleEmoteName = contrabandBundleEmoteName
end

add_season_battlepass_details(
	"Warp",
	7,
	25,
	1200,
	"Electropunk Warper",
	"Spaghettified",
	"Encroached",
	"Warp Disc",
	"Portal Glitch"
)
add_season_battlepass_details("Polar", 7, 25, 1200, nil, "Giant Snowball", "Ice Queen", "Cryo Capsule", "It's Time")
add_season_battlepass_details("Fame", 7, 25, 1200, "Giant Pencil", "BANG!", "Crime Scene", "Duely Award", "Police Car")
return SeasonLibrary