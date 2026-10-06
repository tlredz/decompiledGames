local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BattleAnalysisTypes = require(script.Parent.BattleAnalysisTypes)
local BattleAnalysisStore = require(script.Parent.BattleAnalysisStore)
local BattleAnalysisJobQueue = require(script.Parent.BattleAnalysisJobQueue)
local BattleComputePool = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Battle"):WaitForChild("BattleComputePool"))
local BattleAnalysisWorker = {}
local v = {
	started = false,
	running = true,
	versionKey = "",
	ballConfigSnapshot = nil,
	aggregate = nil,
	delta = {},
	deltaMatches = 0,
	lastFlushAt = 0,
	totalMatches = 0,
	roleIds = {},
	allPairKeys = {},
	pairKeysByRole = {},
	queue = nil,
	battleConfig = nil,
	replayBuilder = nil,
	invalidWinnerWarned = false,
	reservedSeed = {},
	epoch = 0,
	flushing = false,
	parallel = false,
	parallelFallbackWarned = false
}

local function ensurePair(p, p2: string)
	local v2 = p[p2]

	if not v2 then
		v2 = BattleAnalysisTypes.newPairStat()
		p[p2] = v2
	end

	return v2
end

local function applySample(pairKey: string, blueRoleId: string?, p: number, seed: number)
	local bucketIndexForDuration = BattleAnalysisTypes.bucketIndexForDuration(p)

	for _, v2 in ipairs({ v.aggregate.pairs, v.delta }) do
		local v3 = v2[pairKey]

		if not v3 then
			v3 = BattleAnalysisTypes.newPairStat()
			v2[pairKey] = v3
		end

		v3.matches += 1
		v3.totalDuration += p
		v3.durationBuckets[bucketIndexForDuration] += 1
		v3.lastSeed = math.max(v3.lastSeed, seed)

		if blueRoleId then
			v3.winsByRole[blueRoleId] = (v3.winsByRole[blueRoleId] or 0) + 1
		else
			v3.draws += 1
		end
	end

	v.deltaMatches += 1
	v.totalMatches += 1
end

local function bumpSeedOnly(pairKey: string, seed: number)
	for _, v2 in ipairs({ v.aggregate.pairs, v.delta }) do
		local v3 = v2[pairKey]

		if not v3 then
			v3 = BattleAnalysisTypes.newPairStat()
			v2[pairKey] = v3
		end

		v3.lastSeed = math.max(v3.lastSeed, seed)
	end
end

local function planUnit(pairKey: string)
	local pairKey2, v2 = BattleAnalysisTypes.parsePairKey(pairKey)

	if not (pairKey2 and v2) then
		return nil
	end

	local pair = v.aggregate.pairs[pairKey]
	local seed = math.max(v.reservedSeed[pairKey] or 0, pair and pair.lastSeed or 0) + 1
	v.reservedSeed[pairKey] = seed

	if Random.new(seed):NextNumber() < 0.5 then
		v2, pairKey2 = pairKey2, v2
	end

	local battleConfig = v.battleConfig
	return {
		pairKey = pairKey,
		seed = seed,
		blueRoleId = pairKey2,
		yellowRoleId = v2,
		options = {
			fixedDt = battleConfig.replay.fixedDt,
			snapshotInterval = 1000000000,
			maxDuration = battleConfig.replay.maxDuration,
			selectedRoles = {
				Blue = pairKey2,
				Yellow = v2
			}
		}
	}
end

local function applyUnitResult(data, winner, duration: number)
	local blueRoleId = nil

	if winner == "Blue" then
		blueRoleId = data.blueRoleId
	elseif winner == "Yellow" then
		blueRoleId = data.yellowRoleId
	elseif winner ~= "Draw" and not v.invalidWinnerWarned then
		v.invalidWinnerWarned = true
		warn(string.format("[对局分析] 意外的 winner 值：%s（后续同类告警不再重复）", (tostring(winner))))
	end

	applySample(data.pairKey, blueRoleId, duration, data.seed)
end

local function runUnitSerial(data)
	local success, result = pcall(v.replayBuilder.buildResult, v.battleConfig, data.seed, data.options)

	if success then
		applyUnitResult(data, result.winner, result.duration)
		return true
	end

	warn(string.format("[对局分析] 模拟失败 %s (seed=%d)：%s", data.pairKey, data.seed, (tostring(result))))
	bumpSeedOnly(data.pairKey, data.seed)
	return false
end

local function maybeFlush(flag: boolean)
	if v.deltaMatches <= 0 or not flag and os.clock() - v.lastFlushAt < 20 and v.deltaMatches < 2000 or v.flushing then
		return
	end

	v.flushing = true
	v.lastFlushAt = os.clock()
	local epoch = v.epoch
	local delta = v.delta
	local deltaMatches = v.deltaMatches
	v.delta = {}
	v.deltaMatches = 0
	local aggregate = BattleAnalysisStore.flush(v.versionKey, v.ballConfigSnapshot, delta)

	if v.epoch == epoch then
		if aggregate then
			for k, v3 in v.delta do
				local pair = aggregate.pairs[k]

				if not pair then
					pair = BattleAnalysisTypes.newPairStat()
					aggregate.pairs[k] = pair
				end

				BattleAnalysisTypes.mergePairStat(pair, v3)
			end

			v.aggregate = aggregate
			v.totalMatches = BattleAnalysisStore.totalMatches(aggregate)
		else
			for k, v3 in delta do
				local v4 = v.delta[k]

				if v4 then
					BattleAnalysisTypes.mergePairStat(v4, v3)
				else
					v.delta[k] = v3
				end
			end

			v.deltaMatches += deltaMatches
		end
	end

	v.flushing = false
end

local function buildBatch(next, p: number)
	local result = {}

	for _ = 1, p do
		local pairKey = BattleAnalysisJobQueue.nextPairKey(next)

		if not pairKey then
			break
		end

		local v2 = planUnit(pairKey)

		if v2 then
			table.insert(result, v2)
		end
	end

	return result
end

local function runBatchParallel(batch, epoch: number)
	local v2 = table.create(#batch)

	for k, v3 in batch do
		v2[k] = {
			seed = v3.seed,
			options = v3.options,
			candidateCount = 1
		}
	end

	local battles = BattleComputePool.computeBattles(v.battleConfig, v2)

	if v.epoch ~= epoch then
		return 0
	end

	local count = 0

	if battles then
		for k, v3 in batch do
			local battle = battles[k]
			applyUnitResult(v3, battle.winner, battle.duration)
			count += 1
		end

		return count
	else
		if not v.parallelFallbackWarned then
			v.parallelFallbackWarned = true
			warn(string.format(
				"[对局分析] 并行计算不可用，本批回退串行（后续不再重复提示）：%s",
				(tostring(BattleComputePool.getFailureReason() or "worker 报错或超时"))
			))
		end

		local lastTime = os.clock()

		for _, v3 in batch do
			if v.epoch ~= epoch then
				break
			end

			if runUnitSerial(v3) then
				count += 1
			end

			if not (os.clock() - lastTime >= 0.012) then
				continue
			end

			task.wait()
			lastTime = os.clock()
		end

		return count
	end
end

local function waitForComputePool()
	if not v.parallel then
		return
	end

	if v.battleConfig.replay.parallelActorCount ~= 128 then
		v.battleConfig.replay.parallelActorCount = 128

		if BattleComputePool.isReady() then
			BattleComputePool.reset()
		end
	end

	if not BattleComputePool.isReady() and BattleComputePool.getFailureReason() == nil then
		local roleId = v.roleIds[1]
		BattleComputePool.computeBattles(v.battleConfig, {
			{
				seed = 1,
				candidateCount = 1,
				options = {
					fixedDt = v.battleConfig.replay.fixedDt,
					snapshotInterval = 1000000000,
					maxDuration = 2,
					selectedRoles = {
						Blue = roleId,
						Yellow = roleId
					}
				}
			}
		})
	end

	local v2 = os.clock() + 35

	while not BattleComputePool.isReady() and BattleComputePool.getFailureReason() == nil and os.clock() < v2 do
		task.wait(0.2)
	end
end

local function parallelLaneLoop()
	local v2 = math.max(1, (math.floor(tonumber(v.battleConfig.replay.parallelActorCount) or 4))) * 8

	while true do
		if v.running then
			local next = v.queue:pickNext()

			if next then
				local batch = buildBatch(next, v2)

				if #batch == 0 then
					task.wait()
				else
					local v3 = runBatchParallel(batch, v.epoch)
					v.queue:recordCompletion(next, v3)
					maybeFlush(false)
					task.wait()
				end
			else
				maybeFlush(true)
				task.wait(1)
			end
		else
			task.wait(0.5)
		end
	end
end

function BattleAnalysisWorker.start()
	if v.started then
		return
	end

	v.started = true
	local battleDemo = ReplicatedStorage:WaitForChild("BattleDemo")
	v.battleConfig = require(battleDemo:WaitForChild("BattleConfig"))
	v.replayBuilder = require(battleDemo:WaitForChild("BattleReplayBuilder"))
	local v4 = {}

	for _, v5 in ipairs(v.battleConfig.battle.analyzeRolePool) do
		if not v.battleConfig.roles[v5] or v4[v5] then
			continue
		end

		v4[v5] = true
		table.insert(v.roleIds, v5)
	end

	table.sort(v.roleIds)
	assert(#v.roleIds > 0, "[对局分析] analyzeRolePool 中没有有效角色")

	for i = 1, #v.roleIds do
		for i2 = i, #v.roleIds do
			local pairKey = BattleAnalysisTypes.makePairKey(v.roleIds[i], v.roleIds[i2])
			table.insert(v.allPairKeys, pairKey)
		end
	end

	for _, roleId in ipairs(v.roleIds) do
		local v5 = {}

		for _, roleId2 in ipairs(v.roleIds) do
			table.insert(v5, BattleAnalysisTypes.makePairKey(roleId, roleId2))
		end

		v.pairKeysByRole[roleId] = v5
	end

	v.versionKey = BattleAnalysisStore.computeVersionKey(v.battleConfig)
	v.ballConfigSnapshot = BattleAnalysisStore.buildBallConfigSnapshot(v.battleConfig)
	v.aggregate = BattleAnalysisStore.load(v.versionKey, v.ballConfigSnapshot)
	v.totalMatches = BattleAnalysisStore.totalMatches(v.aggregate)
	v.lastFlushAt = os.clock()
	v.queue = BattleAnalysisJobQueue.new()
	game:BindToClose(function()
		maybeFlush(true)
	end)
	v.parallel = BattleComputePool.isEnabled(v.battleConfig)
	task.spawn(function()
		while not v.running or v.queue:pickNext() == nil do
			task.wait(1)
		end

		waitForComputePool()
		task.spawn(parallelLaneLoop)
		task.spawn(parallelLaneLoop)
		task.spawn(parallelLaneLoop)
	end)
	print(string.format(
		"[对局分析] 已启动：%d 种球 / %d 种组合，版本=%s，已有样本=%d 场，持久化=%s，并行=%s",
		#v.roleIds,
		#v.allPairKeys,
		v.versionKey,
		v.totalMatches,
		tostring(BattleAnalysisStore.isPersistent()),
		(tostring(v.parallel))
	))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function displayNameOf(p, p2: string)
	local v2 = p.ballConfigSnapshot and p.ballConfigSnapshot[p2]

	if v2 then
		return v2.displayNameCN or v2.displayName or p2
	end

	return p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function statOf(p, p2: string)
	return p.pairs[p2] or BattleAnalysisTypes.newPairStat()
end

local function roleIdsOf(p)
	local result = {}

	if typeof(p.ballConfigSnapshot) == "table" then
		for k in p.ballConfigSnapshot do
			table.insert(result, k)
		end
	end

	if #result == 0 then
		for _, roleId in ipairs(v.roleIds) do
			table.insert(result, roleId)
		end
	end

	table.sort(result)
	return result
end

function BattleAnalysisWorker.projectOverview(data)
	local v2 = roleIdsOf(data)
	local balls = {}

	for _, displayNameCN in ipairs(v2) do
		local total = 0
		local total2 = 0
		local total3 = 0
		local total4 = 0

		for _, v4 in ipairs(v2) do
			if v4 == displayNameCN then
				continue
			end

			local v5 = statOf(data, BattleAnalysisTypes.makePairKey(displayNameCN, v4)) -- equivalent call inferred; original call site unknown
			total += v5.matches
			total2 += v5.draws
			total3 += v5.totalDuration
			total4 += v5.winsByRole[displayNameCN] or 0
		end

		local v4 = total - total2
		local v5 = {
			roleId = displayNameCN,
			displayNameCN = 0,
			matches = 0,
			wins = 0,
			draws = 0,
			winRate = 0,
			avgDuration = 0
		}
		local v6 = data.ballConfigSnapshot and data.ballConfigSnapshot[displayNameCN]

		if v6 then
			displayNameCN = v6.displayNameCN or v6.displayName or displayNameCN
		end

		v5.displayNameCN = displayNameCN
		v5.matches = total
		v5.wins = total4
		v5.draws = total2
		v5.winRate = not (v4 > 0) and 0 or total4 / v4
		v5.avgDuration = not (total > 0) and 0 or total3 / total
		table.insert(balls, v5)
	end

	table.sort(balls, function(a, b)
		if a.matches == b.matches then
			return a.roleId < b.roleId
		end

		return a.matches > b.matches
	end)
	return {
		versionKey = data.versionKey,
		startedAt = data.startedAt,
		totalMatches = BattleAnalysisStore.totalMatches(data),
		balls = balls
	}
end

function BattleAnalysisWorker.projectBall(p, roleId: string)
	local opponents = {}

	for _, displayNameCN in ipairs((roleIdsOf(p))) do
		if displayNameCN == roleId then
			continue
		end

		local pairKey = BattleAnalysisTypes.makePairKey(roleId, displayNameCN)
		local v3 = statOf(p, pairKey) -- equivalent call inferred; original call site unknown
		local wins = v3.winsByRole[roleId] or 0
		local losses = v3.winsByRole[displayNameCN] or 0
		local v6 = wins + losses
		local v7 = {
			pairKey = pairKey,
			roleId = displayNameCN,
			displayNameCN = 0,
			matches = 0,
			wins = 0,
			losses = 0,
			draws = 0,
			winRate = 0,
			avgDuration = 0,
			durationBuckets = 0
		}
		local v8 = p.ballConfigSnapshot and p.ballConfigSnapshot[displayNameCN]

		if v8 then
			displayNameCN = v8.displayNameCN or v8.displayName or displayNameCN
		end

		v7.displayNameCN = displayNameCN
		v7.matches = v3.matches
		v7.wins = wins
		v7.losses = losses
		v7.draws = v3.draws
		v7.winRate = not (v6 > 0) and 0 or wins / v6
		v7.avgDuration = not (v3.matches > 0) and 0 or v3.totalDuration / v3.matches
		v7.durationBuckets = v3.durationBuckets
		table.insert(opponents, v7)
	end

	local pairKey = BattleAnalysisTypes.makePairKey(roleId, roleId)
	local v3 = statOf(p, pairKey) -- equivalent call inferred; original call site unknown
	local displayNameCN2 = displayNameOf(p, roleId) -- equivalent call inferred; original call site unknown
	return {
		roleId = roleId,
		displayNameCN = displayNameCN2,
		config = p.ballConfigSnapshot and p.ballConfigSnapshot[roleId],
		opponents = opponents,
		mirror = {
			pairKey = pairKey,
			matches = v3.matches,
			avgDuration = not (v3.matches > 0) and 0 or v3.totalDuration / v3.matches
		}
	}
end

function BattleAnalysisWorker.projectPair(p, pairKey2: string)
	local pairKey, roleB = BattleAnalysisTypes.parsePairKey(pairKey2)

	if not (pairKey and roleB) then
		return nil
	end

	local v3 = statOf(p, pairKey2) -- equivalent call inferred; original call site unknown
	local displayA = displayNameOf(p, pairKey) -- equivalent call inferred; original call site unknown
	local displayB = displayNameOf(p, roleB) -- equivalent call inferred; original call site unknown
	return {
		pairKey = pairKey2,
		roleA = pairKey,
		roleB = roleB,
		displayA = displayA,
		displayB = displayB,
		matches = v3.matches,
		winsA = v3.winsByRole[pairKey] or 0,
		winsB = pairKey == roleB and 0 or v3.winsByRole[roleB] or 0,
		draws = v3.draws,
		avgDuration = not (v3.matches > 0) and 0 or v3.totalDuration / v3.matches,
		durationBuckets = v3.durationBuckets,
		isMirror = pairKey == roleB
	}
end

function BattleAnalysisWorker.isStarted()
	return v.started
end

function BattleAnalysisWorker.getStatus()
	return {
		versionKey = v.versionKey,
		startedAt = v.aggregate and v.aggregate.startedAt or 0,
		totalMatches = v.totalMatches,
		pendingMatches = v.deltaMatches,
		persistent = BattleAnalysisStore.isPersistent(),
		running = v.running,
		roleIds = v.roleIds,
		pairCount = #v.allPairKeys,
		jobs = v.queue and v.queue:list() or {},
		parallel = v.parallel,
		parallelFailure = BattleComputePool.getFailureReason()
	}
end

function BattleAnalysisWorker.getOverview()
	return BattleAnalysisWorker.projectOverview(v.aggregate)
end

function BattleAnalysisWorker.getBall(value: string)
	if typeof(value) == "string" and v.battleConfig.roles[value] then
		return BattleAnalysisWorker.projectBall(v.aggregate, value)
	end

	return nil
end

function BattleAnalysisWorker.getPair(value: string)
	if typeof(value) == "string" then
		return BattleAnalysisWorker.projectPair(v.aggregate, value)
	end

	return nil
end

function BattleAnalysisWorker.getArchives()
	local meta = BattleAnalysisStore.loadMeta(v.versionKey)
	return {
		maxArchives = BattleAnalysisStore.MAX_ARCHIVES,
		currentVersionKey = v.versionKey,
		archives = meta.archives
	}
end

function BattleAnalysisWorker.getArchiveOverview(value: string)
	if typeof(value) ~= "string" then
		return nil
	end

	local archive = BattleAnalysisStore.loadArchive(value)

	if archive then
		return BattleAnalysisWorker.projectOverview(archive)
	end

	return nil
end

function BattleAnalysisWorker.deleteArchive(value: string)
	if typeof(value) == "string" then
		return BattleAnalysisStore.deleteArchive(value, v.versionKey)
	end

	return false
end

function BattleAnalysisWorker.archiveNow()
	while v.flushing do
		task.wait()
	end

	maybeFlush(true)
	v.flushing = true
	local archiveNow, _, v2 = BattleAnalysisStore.archiveNow(v.aggregate, v.versionKey, v.ballConfigSnapshot)
	v.flushing = false

	if not v2 then
		return false
	end

	v.aggregate = archiveNow
	v.delta = {}
	v.deltaMatches = 0
	v.totalMatches = 0
	v.epoch += 1
	v.reservedSeed = {}
	return true
end

function BattleAnalysisWorker.setRunning(flag: boolean)
	v.running = flag == true
end

function BattleAnalysisWorker.startGlobalJob()
	return v.queue:create("global", "__all__", "全部对局", v.allPairKeys).id
end

local function ballMatchCount(roleId: string)
	local total = 0

	for _, roleId2 in ipairs(v.roleIds) do
		if roleId2 == roleId then
			continue
		end

		local pair = v.aggregate.pairs[BattleAnalysisTypes.makePairKey(roleId, roleId2)]

		if pair then
			total += pair.matches
		end
	end

	return total
end

local function ballsAtOrAboveTarget(p: number)
	local count = 0

	for _, roleId in ipairs(v.roleIds) do
		if p <= ballMatchCount(roleId) then
			count += 1
		end
	end

	return count, #v.roleIds
end

function BattleAnalysisWorker.startGlobalJobSync(value)
	local targetPerBall = 500

	if typeof(value) == "number" then
		targetPerBall = value
	elseif typeof(value) == "table" and typeof(value.targetPerBall) == "number" then
		targetPerBall = value.targetPerBall
	end

	local targetPerBall2 = math.max(1, (math.floor(targetPerBall)))
	v.running = true
	local v3 = v.queue:create("global", "__all__", "全部对局（阻塞至达标）", v.allPairKeys)
	local lastTime = os.clock()

	while true do
		local v4, v5 = ballsAtOrAboveTarget(targetPerBall2)

		if v5 <= v4 then
			break
		end

		task.wait(0.5)
	end

	v.queue:remove(v3.id)
	return {
		jobId = v3.id,
		targetPerBall = targetPerBall2,
		totalMatches = v.totalMatches,
		elapsedSeconds = os.clock() - lastTime
	}
end

function BattleAnalysisWorker.startBallJob(p: string)
	local v2 = v.pairKeysByRole[p]

	if not v2 then
		return nil
	end

	local v3 = displayNameOf(v.aggregate, p) -- equivalent call inferred; original call site unknown
	return v.queue:create("ball", p, v3, v2).id
end

function BattleAnalysisWorker.startPairJob(p: string)
	local displayNameCN, displayNameCN2 = BattleAnalysisTypes.parsePairKey(p)

	if not (displayNameCN and displayNameCN2 and (v.battleConfig.roles[displayNameCN] and v.battleConfig.roles[displayNameCN2])) then
		return nil
	end

	local aggregate = v.aggregate
	local v3 = aggregate.ballConfigSnapshot and aggregate.ballConfigSnapshot[displayNameCN]

	if v3 then
		displayNameCN = v3.displayNameCN or v3.displayName or displayNameCN
	end

	local aggregate2 = v.aggregate
	local v4 = aggregate2.ballConfigSnapshot and aggregate2.ballConfigSnapshot[displayNameCN2]

	if v4 then
		displayNameCN2 = v4.displayNameCN or v4.displayName or displayNameCN2
	end

	local v5 = string.format("%s vs %s", displayNameCN, displayNameCN2)
	return v.queue:create("pair", p, v5, { p }).id
end

function BattleAnalysisWorker.setJobPaused(p: string, flag: boolean)
	return v.queue:setPaused(p, flag)
end

function BattleAnalysisWorker.removeJob(p: string)
	return v.queue:remove(p)
end

return BattleAnalysisWorker