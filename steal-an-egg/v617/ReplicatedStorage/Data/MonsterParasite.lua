local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Flyswatter = require(ReplicatedStorage.Data.Gears.Configs.Flyswatter)
local MonsterParasiteFlags = require(ReplicatedStorage.Shared.Flags.MonsterParasiteFlags)
local MonsterParasite = require(ReplicatedStorage.Shared.Types.MonsterParasite)
local rewardIds = MonsterParasite.RewardIds
local spawnChanceByArea = {
	Snow = 29,
	Volcano = 26,
	["Abyss Ocean"] = 18,
	Prehistoric = 15,
	Cosmic = 13,
	["Cherry Blossom"] = 11,
	["Titan Temple"] = 9
}
local bellyStages = {
	{
		Charge = 0,
		Scale = 1
	},
	{
		Charge = 20,
		Scale = 1.12
	},
	{
		Charge = 40,
		Scale = 1.25
	},
	{
		Charge = 60,
		Scale = 1.45
	},
	{
		Charge = 80,
		Scale = 1.75
	},
	{
		Charge = 100,
		Scale = 2
	}
}

local function buildMonstrousEggIdsList()
	local Areas = require(ReplicatedStorage.Data.Areas)
	local result = {}

	for _, v3 in Areas.Directory["Titan Temple"].DropTable do
		table.insert(result, {
			Id = v3[1],
			Weight = v3[2]
		})
	end

	assert(#result > 0, "Titan Temple has no drop table for the Monstrous Egg")
	return result
end

local rewards = {
	{
		Id = rewardIds.EggGrowthBoost,
		Weight = 43.5,
		DisplayName = "1.25x Egg Growth",
		DisplayNote = "5 Minutes",
		Rarity = "Common",
		Icon = "rbxassetid://84954605144740",
		Metadata = {
			DurationSeconds = 300,
			Multiplier = 1.25
		}
	},
	{
		Id = rewardIds.SpeedBoost,
		Weight = 30,
		DisplayName = "1.25x Speed",
		DisplayNote = "5 Minutes",
		Rarity = "Uncommon",
		Icon = "rbxassetid://78137530993637",
		Metadata = {
			DurationSeconds = 300,
			Multiplier = 1.25
		}
	},
	{
		Id = rewardIds.TreadmillBoost,
		Weight = 20,
		DisplayName = "2x Treadmill Speed",
		DisplayNote = "5 Minutes",
		Rarity = "Rare",
		Metadata = {
			DurationSeconds = 300
		}
	},
	{
		Id = rewardIds.ExclusiveWeapon,
		Weight = 5,
		DisplayName = "Flyswatter",
		DuplicateRewardId = rewardIds.TreadmillBoost,
		Rarity = "Epic",
		Icon = Flyswatter.Icon,
		Metadata = {
			GearId = Flyswatter._id
		}
	},
	{
		Id = rewardIds.MonsterEgg,
		Weight = 1.5,
		DisplayName = "PARASITE EGG",
		DisplayNote = "Guaranteed Monstrous Mutation",
		NoteIsPanelOnly = true,
		Rarity = "BEST REWARD",
		Icon = "rbxassetid://121553987798547",
		Metadata = {
			MutationId = "Monstrous",
			EggIdsList = buildMonstrousEggIdsList()
		}
	}
}
local v4 = {
	EventName = "MonsterParasite",
	EndsAt = 1788620400,
	MinimumRarityNumber = 5,
	EligibilityGuardId = "Jungle",
	SpawnChanceByArea = spawnChanceByArea,
	ChargePerFeed = 20,
	MaxCharge = 100,
	BellyStages = bellyStages,
	Rewards = rewards,
	FeedDistance = 14,
	HudDistance = 24,
	RequestCooldown = 0.75,
	PromptHoldDuration = 0.25,
	MonsterOffset = CFrame.new(0, 0, -8),
	MarkerFolderName = "MonsterParasiteMarkers",
	MonsterSpawnMarkerName = "MonsterSpawn",
	ChestSpawnMarkerName = "MonsterChestSpawn",
	ChestSpawnCFrameAttributeName = "MonsterChestSpawnCFrame",
	AssetsFolderName = "MonsterParasite",
	ParasiteModelName = "Parasite",
	ParasiteVisualName = "MonsterParasiteVisual",
	ParasiteIdleAnimationId = 113082199990805,
	ParasiteCrownOffset = Vector2.zero,
	ParasiteScaleMultiplier = 0.45,
	MonsterModelName = "Monster",
	MonsterModelNames = {
		"Monster1",
		"Monster2",
		"Monster3",
		"Monster4"
	},
	MonsterModelIndexAttributeName = "MonsterModelIndex",
	MonsterRetiringAttributeName = "MonsterRetiring",
	MonsterRetireSeconds = 0.45,
	MonsterAnimationIdsByIndex = {
		{
			Idle = 128217356432291,
			Yank = 86644195835902
		},
		{
			Idle = 99744254158313,
			Yank = 131549849408123
		},
		{
			Idle = 122218896916983,
			Yank = 140178521003505
		},
		{
			Idle = 124151642143348,
			Yank = 110901356129499,
			Burp = 94789436133823
		}
	},
	ChestModelName = "MonsterChest",
	ChestToolName = "Monster Chest",
	ChestToolItemType = "MonsterChest",
	ChestToolScale = 0.42,
	ChestToolGrip = CFrame.new(0, -0.15, -0.35) * CFrame.Angles(0, 1.5707963267948966, 0),
	ChestToolIcon = "rbxassetid://139693832314356",
	ChestPickupDuration = 0.6,
	ParasiteBillboardName = "MonsterParasite",
	ParasiteBillboardScale = 0.5,
	ParasiteHighlightName = "MonsterParasiteHighlight",
	ParasiteHighlightColor = Color3.fromRGB(198, 158, 255),
	ParasiteHighlightTransparency = 0.25,
	ParasiteHighlightFillTransparency = 0.7,
	HudName = "MonsterChargeUI",
	WorldFolderName = "MonsterParasiteMonsters",
	PadName = "Monster",
	MonsterDisplayName = "The Hungry Monster",
	TalkPromptName = "TalkPrompt",
	TalkPromptText = "Who are you?",
	FeedPromptName = "FeedPrompt",
	FeedPromptText = "Feed Parasite",
	ChestPromptName = "ChestPrompt",
	ChestPromptText = "Claim Monster Chest",
	DialogueText = "Parasites make me stronger. Bring me an infested egg, and I will eat the parasite without harming what is inside.",
	RewardTitle = "MONSTER CHEST REWARD",
	BellyPartName = "Belly",
	ParasiteEatTargetPartName = "ParasiteEatTarget",
	TongueTipName = "Tongue3",
	ChestOriginPartName = "ChestOrigin",
	ChestOriginNames = { "ChestOrigin", "MouthCenter1", "Tongue3" },
	GrabMarkerName = "Grab",
	BurpMarkerName = "burp_start",
	ChestOffset = CFrame.new(0, 2, -4),
	YankDuration = 0.35,
	BellyTweenDuration = 0.45,
	FullChargeHoldDuration = 0.8,
	FullChargeModelHoldDuration = 15,
	BurpBeatDuration = 0.18,
	RoarDuration = 0.55,
	ChestLaunchDelay = 0.06,
	ChestLaunchDuration = 0.78,
	ChestBounceDuration = 0.4,
	ChestLaunchHeight = 5,
	ChestBounceHeight = 1.4,
	ChestLaunchStartScale = 0.65,
	ChestLaunchSpins = 2,
	ChestLaunchBeatFallback = 2.4,
	ChestThrowDistanceMin = 12,
	ChestThrowDistanceMax = 19,
	ChestThrowSpreadDegrees = 26,
	ChestThrowStraightJitterDegrees = 5,
	ChestThrowAttempts = 5,
	ChestGroundRestDuration = 0.3,
	ChestPickupRise = 2.5,
	ChestGroundProbeHeight = 6,
	ChestGroundProbeDepth = 90,
	ChestImpactShakeMagnitude = 1.4,
	ChestImpactShakeRoughness = 9,
	ChestImpactShakeFadeIn = 0.04,
	ChestImpactShakeFadeOut = 0.5,
	ChestImpactShakeRange = 110,
	SoundFolderName = "MonsterParasite",
	YankSoundName = "Yank",
	ChompSoundName = "Chomp",
	BurpSoundName = "Burp",
	RoarSoundName = "Roar",
	EnergyBurstSoundName = "EnergyBurst",
	ChestLandingSoundName = "ChestLanding",
	ChestSoundName = "ChestOpen",
	VfxFolderName = "MonsterParasite",
	EnergyBurstVfxName = "EnergyBurst",
	SwapPoofVfxName = "SwapPoof",
	GroundHitParticlesName = "BigHitGroundAttach",
	HudRootName = "Root",
	HudBarName = "Bar",
	HudFillName = "Fill",
	HudPercentName = "Percent",
	HudStatusName = "Status",
	HudTimerName = "Timer",
	HudChargingText = "MONSTER CHARGE",
	HudReadyText = "MONSTER CHEST READY!",
	GetSpawnChance = function(p: string)
		local v5 = MonsterParasiteFlags.SpawnChanceByArea:Get()[p]

		if v5 == nil then
			return spawnChanceByArea[p] or 0
		end

		return v5
	end,
	GetBellyScale = function(p: number)
		local scale = bellyStages[1].Scale

		for _, v5 in bellyStages do
			if p < v5.Charge then
				break
			else
				scale = v5.Scale
			end
		end

		return scale
	end,
	GetMonsterModelIndex = function(p: number)
		if p >= 80 then
			return 4
		end

		if p >= 60 then
			return 3
		end

		if p >= 40 then
			return 2
		end

		return 1
	end,
	GetReward = function(p)
		for _, v5 in rewards do
			if v5.Id == p then
				return v5
			end
		end

		error(`Unknown Monster Chest reward {p}`, 2)
	end,
	RewardLabel = function(data)
		if data.DisplayNote == nil or data.NoteIsPanelOnly then
			return data.DisplayName
		end

		return (`{data.DisplayName} ({data.DisplayNote})`)
	end,
	BoostMultiplier = function(p)
		local boostRewardId = MonsterParasite.BoostRewardIds[p]
		local v5 = nil
		local flag = true

		for _, v6 in rewards do
			if v6.Id ~= boostRewardId then
				continue
			end

			v5 = v6
			flag = false
			break
		end

		if flag then
			error(`Unknown Monster Chest reward {boostRewardId}`, 2)
		end

		return v5.Metadata.Multiplier or 1
	end,
	BoostDurationSeconds = function(p)
		local boostRewardId = MonsterParasite.BoostRewardIds[p]
		local v5 = nil
		local flag = true

		for _, v6 in rewards do
			if v6.Id ~= boostRewardId then
				continue
			end

			v5 = v6
			flag = false
			break
		end

		if flag then
			error(`Unknown Monster Chest reward {boostRewardId}`, 2)
		end

		return v5.Metadata.DurationSeconds or 0
	end,
	GetRewardWeight = function(p)
		local v5 = MonsterParasiteFlags.RewardWeights:Get()[p]

		if v5 ~= nil then
			return v5
		end

		local v6 = nil
		local flag = true

		for _, v7 in rewards do
			if v7.Id ~= p then
				continue
			end

			v6 = v7
			flag = false
			break
		end

		if flag then
			error(`Unknown Monster Chest reward {p}`, 2)
		end

		return v6.Weight
	end
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v5 = require(ReplicatedStorage2.Shared.Flags.BalanceConfig).Bind("Game.Balance.MonsterParasite", v4, {
	MinimumRarityNumber = true,
	ChargePerFeed = true,
	MaxCharge = true,
	FeedDistance = true,
	RequestCooldown = true,
	PromptHoldDuration = true
}, false, function(data)
	local v6

	if data.ChargePerFeed > 0 and data.MaxCharge > 0 then
		v6 = data.FeedDistance > 0
	else
		v6 = false
	end

	assert(v6)
end)
local v6 = {}

for _, v7 in rewards do
	v6[v7.Id] = {
		DurationSeconds = v7.Metadata.DurationSeconds,
		Multiplier = v7.Metadata.Multiplier
	}
end

local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v7 = require(ReplicatedStorage3.Shared.Flags.BalanceConfig).Bind(
	"Game.Balance.MonsterChestRewards",
	v6,
	true,
	false
)

local function refreshRewards()
	for _, v8 in rewards do
		local v9 = v7[v8.Id]
		v8.Metadata.DurationSeconds = v9.DurationSeconds
		v8.Metadata.Multiplier = v9.Multiplier

		if v9.DurationSeconds then
			v8.DisplayNote = `{v9.DurationSeconds / 60} Minutes`

			if v8.Id == rewardIds.EggGrowthBoost then
				v8.DisplayName = `{v9.Multiplier}x Egg Growth`
			end

			if v8.Id == rewardIds.SpeedBoost then
				v8.DisplayName = `{v9.Multiplier}x Speed`
			end
		end

		if v8.Id == rewardIds.MonsterEgg then
			v8.Metadata.EggIdsList = buildMonstrousEggIdsList()
		end
	end
end

refreshRewards()
local BalanceConfig = require(ReplicatedStorage.Shared.Flags.BalanceConfig)
BalanceConfig.Changed:Connect(refreshRewards)
return v5