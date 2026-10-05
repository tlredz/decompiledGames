require(game.ReplicatedStorage.Modules.Gacha.SharedGachaTypes)
local SimulationSession = {
	BULK_CHUNK = 250,
	TARGET_BATCHES = 12,
	chunkFor = function(data)
		if data.FreshPlayer then
			return 1, "one call per pull, so every pull starts clean"
		end

		if data.AccumulateOwned then
			return 1, "one call per pull, so a win is owned in time for the next one"
		end

		if not data.TrackEvolution then
			return 250, "batched, no per pull chance snapshots"
		end

		local v = math.max(1, data.EvolutionStride)
		return v, (`one call per {v} pulls, one chance snapshot each`)
	end,
	readPityKeys = function(p)
		local v = nil

		for k in p.SoftPity_Gacha do
			v = k
			break
		end

		for k in p.HardPity_Gacha do
			return v, k
		end

		return v, nil
	end,
	newPlayerData = function(data, p: string?, p2: string?)
		local softPities = {}
		local hardPities = {}

		if p ~= nil then
			softPities[p] = data.SoftPity
		end

		if p2 ~= nil then
			hardPities[p2] = data.HardPity
		end

		local cheatFlags

		if data.CheatFlag ~= nil then
			cheatFlags = {}
			cheatFlags[data.CheatFlag] = true
		end

		return {
			IsPartial = true,
			Level = data.Level,
			SoftPity_Gacha = softPities,
			HardPity_Gacha = hardPities,
			cheatFlags = cheatFlags,
			OwnedItemIds = table.clone(data.OwnedItemIds)
		}
	end,
	buildRequest = function(data, playerData, sampleSize: number)
		local gachaRateOverrides

		if next(data.RateOverrides) ~= nil then
			local rateOverrides = {}

			for k, rateOverride in data.RateOverrides do
				rateOverrides[k] = rateOverride
			end

			gachaRateOverrides = {}
			gachaRateOverrides[data.BoxName] = rateOverrides
		end

		local bannerItem = {
			BoxName = data.BoxName,
			Ids = table.clone(data.BannerItemIds),
			Chance = 0,
			CheaterChance = 0
		}
		local chance

		if #data.BannerItemIds > 0 then
			chance = data.BannerChance
		end

		bannerItem.Chance = chance
		local cheaterChance

		if #data.BannerItemIds > 0 and data.BannerCheaterChance > 0 then
			cheaterChance = data.BannerCheaterChance
		end

		bannerItem.CheaterChance = cheaterChance
		local v5 = {
			Context = "RunSimulation",
			PullInfo = {
				Type = "V2",
				PlayerData = playerData,
				PullCount = data.PullCount
			},
			ComingSoonProducts = 0,
			GachaRateOverrides = 0,
			BannerItem = 0,
			Raffle = 0,
			SampleSize = 0
		}
		local comingSoonProducts

		if #data.ComingSoonProducts > 0 then
			comingSoonProducts = table.clone(data.ComingSoonProducts)
		end

		v5.ComingSoonProducts = comingSoonProducts
		v5.GachaRateOverrides = gachaRateOverrides
		v5.BannerItem = bannerItem
		v5.Raffle = {
			Type = "V2",
			BoxName = data.BoxName
		}
		v5.SampleSize = sampleSize
		return v5
	end
}

function SimulationSession.solveChances(callback, p, p2: string?, p3: string?)
	local playerData = SimulationSession.newPlayerData(p, p2, p3)
	local v = callback(SimulationSession.buildRequest(p, playerData, 1))
	local pityKeys, v2 = SimulationSession.readPityKeys(playerData)
	return v.Chances, pityKeys, v2
end

function SimulationSession.numberKeyedNumbers(items)
	local result = {}

	if typeof(items) ~= "table" then
		return result
	end

	for k, item in items do
		if typeof(k) ~= "number" then
			k = tonumber(k)
		end

		if k ~= nil and typeof(item) == "number" then
			result[k] = item
		end
	end

	return result
end

local function toNumberArray(item)
	local result = {}

	if typeof(item) ~= "table" then
		return result
	end

	local v = {}
	local v2 = 0

	for k, item2 in item do
		if typeof(k) ~= "number" then
			k = tonumber(k)
		end

		if not (k ~= nil and k >= 1 and k <= 1000000 and typeof(item2) == "number") then
			continue
		end

		v[k] = item2
		v2 = math.max(v2, k)
	end

	for i = 1, v2 do
		result[i] = v[i] or 0
	end

	return result
end

function SimulationSession.numberKeyedArrays(items)
	local result = {}

	if typeof(items) ~= "table" then
		return result
	end

	for k, item in items do
		if typeof(k) ~= "number" then
			k = tonumber(k)
		end

		if k ~= nil then
			result[k] = toNumberArray(item)
		end
	end

	return result
end

function SimulationSession.normalizeResponse(data)
	local snapshots = {}

	for _, snapshot in data.Snapshots do
		table.insert(snapshots, {
			Pull = snapshot.Pull,
			Chances = SimulationSession.numberKeyedNumbers(snapshot.Chances)
		})
	end

	table.sort(snapshots, function(a, b)
		return a.Pull < b.Pull
	end)
	local hits = {}

	for _, hit in data.Hits do
		table.insert(hits, hit)
	end

	table.sort(hits, function(a, b)
		return a.Pull < b.Pull
	end)
	local ownedGained = {}

	for _, v3 in data.OwnedGained do
		if typeof(v3) == "number" then
			table.insert(ownedGained, v3)
		end
	end

	local clone = table.clone(data)
	clone.BaseChances = SimulationSession.numberKeyedNumbers(data.BaseChances)
	clone.Counts = SimulationSession.numberKeyedNumbers(data.Counts)
	clone.BonusCounts = SimulationSession.numberKeyedNumbers(data.BonusCounts)
	clone.BatchRates = SimulationSession.numberKeyedArrays(data.BatchRates)
	clone.Snapshots = snapshots
	clone.Hits = hits
	clone.OwnedGained = ownedGained
	return clone
end

function SimulationSession.splitWinners(p)
	local bonusItems = p.BonusItems
	local winners = p.Winners

	if bonusItems == nil or #bonusItems == 0 then
		return winners, {}
	end

	local clone = table.clone(bonusItems)
	local winners2 = {}

	for _, winner in winners do
		local index = table.find(clone, winner)

		if index == nil then
			table.insert(winners2, winner)
		else
			table.remove(clone, index)
		end
	end

	return winners2, bonusItems
end

function SimulationSession.groupHits(items)
	local result = {}

	for _, item in items do
		local pulls = result[item.ItemId]

		if pulls == nil then
			pulls = {}
			result[item.ItemId] = pulls
		end

		table.insert(pulls, item.Pull)
	end

	return result
end

function SimulationSession.compose(config, data)
	local clones = {}

	for k, batchRate in data.BatchRates do
		clones[k] = table.clone(batchRate)
	end

	return {
		Config = config,
		BaseChances = data.BaseChances,
		Counts = table.clone(data.Counts),
		BonusCounts = table.clone(data.BonusCounts),
		Snapshots = table.clone(data.Snapshots),
		BatchRates = clones,
		BatchSize = data.BatchSize,
		Hits = SimulationSession.groupHits(data.HitLog),
		PullsDone = data.PullsDone,
		RollsDone = data.RollsDone,
		EndSoftPity = data.EndSoftPity,
		EndHardPity = data.EndHardPity,
		OwnedGained = table.clone(data.OwnedGained),
		Elapsed = data.Elapsed
	}
end

function SimulationSession.new(config, solve, softPityKey: string?, hardPityKey: string?)
	local chunkFor = SimulationSession.chunkFor(config)
	local v = math.ceil(config.SampleSize / chunkFor)
	return {
		Config = config,
		Solve = solve,
		Chunk = chunkFor,
		Total = config.SampleSize,
		SnapshotEvery = math.max(1, (math.ceil(v / 800))),
		BatchSize = math.max(chunkFor, (math.ceil(config.SampleSize / 12))),
		SoftPityKey = softPityKey,
		HardPityKey = hardPityKey,
		PlayerData = SimulationSession.newPlayerData(config, softPityKey, hardPityKey),
		ChunkIndex = 0,
		PullsDone = 0,
		RollsDone = 0,
		BaseChances = {},
		Counts = {},
		BonusCounts = {},
		BatchRates = {},
		BatchCounts = {},
		BatchRolls = 0,
		BatchIndex = 0,
		Snapshots = {},
		HitLog = {},
		OwnedGained = {},
		StartedAt = os.clock(),
		IsDone = false
	}
end

function SimulationSession:closeBatch()
	if self.BatchRolls <= 0 then
		return
	end

	self.BatchIndex += 1

	for k in self.Counts do
		local batchRate = self.BatchRates[k]

		if batchRate == nil then
			batchRate = table.create(12)
			self.BatchRates[k] = batchRate
		end

		while #batchRate < self.BatchIndex - 1 do
			table.insert(batchRate, 0)
		end

		batchRate[self.BatchIndex] = (self.BatchCounts[k] or 0) / self.BatchRolls
	end

	table.clear(self.BatchCounts)
	self.BatchRolls = 0
end

function SimulationSession:step()
	if self.IsDone then
		return false
	end

	local config = self.Config
	local v = math.min(self.Chunk, self.Total - self.PullsDone)

	if v <= 0 then
		SimulationSession.closeBatch(self)
		self.IsDone = true
		return false
	else
		self.ChunkIndex += 1

		if config.FreshPlayer then
			self.PlayerData = SimulationSession.newPlayerData(config, self.SoftPityKey, self.HardPityKey)
		end

		local solve = self.Solve(SimulationSession.buildRequest(config, self.PlayerData, v))

		if self.ChunkIndex == 1 then
			self.BaseChances = solve.Chances
		end

		if (self.ChunkIndex - 1) % self.SnapshotEvery == 0 then
			table.insert(self.Snapshots, {
				Pull = self.PullsDone + 1,
				Chances = solve.Chances
			})
		end

		for k, pull in solve.Pulls do
			local pull2 = self.PullsDone + k
			local splitWinners, v3 = SimulationSession.splitWinners(pull)

			for _, splitWinner in splitWinners do
				self.Counts[splitWinner] = (self.Counts[splitWinner] or 0) + 1
				self.BatchCounts[splitWinner] = (self.BatchCounts[splitWinner] or 0) + 1
				table.insert(self.HitLog, {
					ItemId = splitWinner,
					Pull = pull2
				})
				self.RollsDone += 1
				self.BatchRolls += 1
			end

			for _, v4 in v3 do
				self.BonusCounts[v4] = (self.BonusCounts[v4] or 0) + 1
			end

			if not config.AccumulateOwned or config.FreshPlayer then
				continue
			end

			for _, winner in pull.Winners do
				if table.find(self.PlayerData.OwnedItemIds, winner) ~= nil then
					continue
				end

				table.insert(self.PlayerData.OwnedItemIds, winner)
				table.insert(self.OwnedGained, winner)
			end
		end

		self.PullsDone += v

		if self.PullsDone >= (self.BatchIndex + 1) * self.BatchSize then
			SimulationSession.closeBatch(self)
		end

		if self.PullsDone >= self.Total then
			SimulationSession.closeBatch(self)
			self.IsDone = true
			return false
		else
			return true
		end
	end
end

function SimulationSession.pity(p)
	local pityKeys, v = SimulationSession.readPityKeys(p.PlayerData)
	local selected = pityKeys == nil and 0 or p.PlayerData.SoftPity_Gacha[pityKeys] or 0

	if v == nil then
		return selected, 0
	end

	return selected, p.PlayerData.HardPity_Gacha[v] or 0
end

function SimulationSession.accumulator(data)
	local pity, endHardPity = SimulationSession.pity(data)
	return {
		BaseChances = data.BaseChances,
		Counts = data.Counts,
		BonusCounts = data.BonusCounts,
		BatchRates = data.BatchRates,
		BatchSize = data.BatchSize,
		Snapshots = data.Snapshots,
		HitLog = data.HitLog,
		OwnedGained = data.OwnedGained,
		PullsDone = data.PullsDone,
		RollsDone = data.RollsDone,
		EndSoftPity = pity,
		EndHardPity = endHardPity,
		Elapsed = os.clock() - data.StartedAt
	}
end

function SimulationSession.result(p)
	return SimulationSession.compose(p.Config, SimulationSession.accumulator(p))
end

return SimulationSession