local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Types)

local function use(p, p2)
	if p == nil then
		return Osiris.State(p2)
	end

	return p
end

local Store = {}
Store.DEFAULT_BOX = "DogHouseGacha26"
Store.DEFAULT_SAMPLE_SIZE = 2000

function Store.use(options, options2)
	local arguments = options or {}
	local v2 = options2 or {}
	local boxName = v2.boxName
	local defaultBox = arguments.DefaultBox or "DogHouseGacha26"

	if boxName == nil then
		boxName = Osiris.State(defaultBox)
	end

	local sampleSize = v2.sampleSize
	local defaultSampleSize = arguments.DefaultSampleSize or 2000

	if sampleSize == nil then
		sampleSize = Osiris.State(defaultSampleSize)
	end

	local pullCount = v2.pullCount

	if pullCount == nil then
		pullCount = Osiris.State(1)
	end

	local level = v2.level

	if level == nil then
		level = Osiris.State(1)
	end

	local freshPlayer = v2.freshPlayer

	if freshPlayer == nil then
		freshPlayer = Osiris.State(true)
	end

	local accumulateOwned = v2.accumulateOwned

	if accumulateOwned == nil then
		accumulateOwned = Osiris.State(false)
	end

	local trackEvolution = v2.trackEvolution

	if trackEvolution == nil then
		trackEvolution = Osiris.State(true)
	end

	local evolutionStride = v2.evolutionStride

	if evolutionStride == nil then
		evolutionStride = Osiris.State(1)
	end

	local softPity = v2.softPity

	if softPity == nil then
		softPity = Osiris.State(0)
	end

	local hardPity = v2.hardPity

	if hardPity == nil then
		hardPity = Osiris.State(0)
	end

	local ownedItemIds = v2.ownedItemIds
	local v5 = {}

	if ownedItemIds == nil then
		ownedItemIds = Osiris.State(v5)
	end

	local rateOverrides = v2.rateOverrides
	local v6 = {}

	if rateOverrides == nil then
		rateOverrides = Osiris.State(v6)
	end

	local comingSoonProducts = v2.comingSoonProducts
	local v7 = {}

	if comingSoonProducts == nil then
		comingSoonProducts = Osiris.State(v7)
	end

	local bannerItemIds = v2.bannerItemIds
	local v8 = {}

	if bannerItemIds == nil then
		bannerItemIds = Osiris.State(v8)
	end

	local bannerChance = v2.bannerChance

	if bannerChance == nil then
		bannerChance = Osiris.State(0)
	end

	local bannerCheaterChance = v2.bannerCheaterChance

	if bannerCheaterChance == nil then
		bannerCheaterChance = Osiris.State(0)
	end

	local cheatFlag = v2.cheatFlag

	if cheatFlag == nil then
		cheatFlag = Osiris.State("")
	end

	local v4 = {
		Arguments = arguments,
		boxName = boxName,
		sampleSize = sampleSize,
		pullCount = pullCount,
		level = level,
		freshPlayer = freshPlayer,
		accumulateOwned = accumulateOwned,
		trackEvolution = trackEvolution,
		evolutionStride = evolutionStride,
		softPity = softPity,
		hardPity = hardPity,
		ownedItemIds = ownedItemIds,
		rateOverrides = rateOverrides,
		comingSoonProducts = comingSoonProducts,
		bannerItemIds = bannerItemIds,
		bannerChance = bannerChance,
		bannerCheaterChance = bannerCheaterChance,
		cheatFlag = cheatFlag,
		job = Osiris.State({
			Token = 0,
			Revision = 0,
			Published = 0,
			Status = "Idle",
			SelectedBox = nil,
			FailedBox = nil,
			StartedAt = 0,
			Progress = 0,
			Message = "no simulation run yet",
			Pool = nil,
			Result = nil,
			ResultStamp = 0,
			PublishedResult = 0,
			PendingScenario = nil,
			Error = nil
		})
	}
	local pool = v2.pool

	if pool == nil then
		pool = Osiris.State(nil)
	end

	v4.pool = pool
	local result = v2.result

	if result == nil then
		result = Osiris.State(nil)
	end

	v4.result = result
	local scenarios = v2.scenarios
	local v9 = {}

	if scenarios == nil then
		scenarios = Osiris.State(v9)
	end

	v4.scenarios = scenarios
	v4.progress = Osiris.State(0)
	local drill = v2.drill

	if drill == nil then
		drill = Osiris.State(nil)
	end

	v4.drill = drill
	local groupByRarity = v2.groupByRarity
	local groupByRarity2 = arguments.GroupByRarity ~= false

	if groupByRarity == nil then
		groupByRarity = Osiris.State(groupByRarity2)
	end

	v4.groupByRarity = groupByRarity
	local focusItemId = v2.focusItemId

	if focusItemId == nil then
		focusItemId = Osiris.State(nil)
	end

	v4.focusItemId = focusItemId
	v4.scenarioName = Osiris.State("")
	v4.scenarioIndex = Osiris.State(0)
	v4.pickerItem = Osiris.State("")
	v4.pickerValue = Osiris.State(0)
	v4.journeyItem = Osiris.State("")
	v4.cumulativeGaps = Osiris.State(false)
	v4.showOutlierTable = Osiris.State(true)
	v4.setupOpen = Osiris.State(arguments.OpenSetup ~= false)
	v4.accuracyOpen = Osiris.State(arguments.OpenAccuracy ~= false)
	v4.sensitivityOpen = Osiris.State(arguments.OpenSensitivity ~= false)
	v4.journeyOpen = Osiris.State(arguments.OpenJourney ~= false)
	v4.setupPosition = Osiris.State(Vector2.new(24, 24))
	v4.errorPosition = Osiris.State(Vector2.new(120, 120))
	v4.accuracyPosition = Osiris.State(Vector2.new(420, 24))
	v4.sensitivityPosition = Osiris.State(Vector2.new(420, 570))
	v4.journeyPosition = Osiris.State(Vector2.new(1000, 24))
	v4.setupSize = Osiris.State(Vector2.new(380, 725))
	v4.accuracySize = Osiris.State(Vector2.new(560, 530))
	v4.sensitivitySize = Osiris.State(Vector2.new(560, 180))
	v4.journeySize = Osiris.State(Vector2.new(560, 725))
	return v4
end

function Store.snapshot(data)
	local cheatFlag = data.cheatFlag:get()
	local v2 = {
		BoxName = data.boxName:get(),
		SampleSize = math.max(1, (math.floor((data.sampleSize:get())))),
		PullCount = math.max(1, (math.floor((data.pullCount:get())))),
		Level = math.max(1, (math.floor((data.level:get())))),
		FreshPlayer = data.freshPlayer:get(),
		AccumulateOwned = data.accumulateOwned:get(),
		TrackEvolution = data.trackEvolution:get(),
		EvolutionStride = math.max(1, (math.floor((data.evolutionStride:get())))),
		SoftPity = math.max(0, (math.floor((data.softPity:get())))),
		HardPity = math.max(0, (math.floor((data.hardPity:get())))),
		OwnedItemIds = table.clone(data.ownedItemIds:get()),
		RateOverrides = table.clone(data.rateOverrides:get()),
		ComingSoonProducts = table.clone(data.comingSoonProducts:get()),
		BannerItemIds = table.clone(data.bannerItemIds:get()),
		BannerChance = math.clamp(data.bannerChance:get(), 0, 1),
		BannerCheaterChance = math.clamp(data.bannerCheaterChance:get(), 0, 1),
		CheatFlag = 0
	}

	if not (#cheatFlag > 0) then
		cheatFlag = nil
	end

	v2.CheatFlag = cheatFlag
	return v2
end

function Store.describe(data)
	local v = {}

	if data.PullCount > 1 then
		table.insert(v, (`{data.PullCount}x pulls`))
	end

	if data.SoftPity > 0 then
		table.insert(v, (`soft pity {data.SoftPity}`))
	end

	if data.HardPity > 0 then
		table.insert(v, (`hard pity {data.HardPity}`))
	end

	if #data.OwnedItemIds > 0 then
		table.insert(v, (`owns {#data.OwnedItemIds}`))
	end

	if next(data.RateOverrides) ~= nil then
		local count = 0

		for _ in data.RateOverrides do
			count += 1
		end

		table.insert(v, (`{count} rate overrides`))
	end

	if #data.BannerItemIds > 0 then
		table.insert(v, (`banner {#data.BannerItemIds}`))
	end

	if #data.ComingSoonProducts > 0 then
		table.insert(v, (`{#data.ComingSoonProducts} coming soon`))
	end

	if data.CheatFlag ~= nil then
		table.insert(v, (`cheat "{data.CheatFlag}"`))
	end

	if #v == 0 then
		return "baseline"
	end

	return table.concat(v, ", ")
end

return Store