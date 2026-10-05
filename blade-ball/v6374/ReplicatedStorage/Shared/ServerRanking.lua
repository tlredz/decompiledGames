local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local v = require3(script.Config)
local v2 = require3(script.Parent.ServerBrowserData)

-- equivalent calls inferred from this helper; original call sites unknown
local function smoothstep(p: number, p2: number, p3: number)
	if p2 == p then
		return 0
	end

	local v3 = math.clamp((p3 - p) / (p2 - p), 0, 1)
	return v3 * v3 * (3 - v3 * 2)
end

local function expectedFps(p: number)
	local expectedFps2 = v.Performance.ExpectedFps
	local v3 = 0

	for k in expectedFps2 do
		if k <= p and v3 <= k then
			v3 = k
		end
	end

	return expectedFps2[v3] or 60
end

local function performanceIndex(data, players: number)
	local performance = v.Performance
	local fps = data.fps
	local maxPlayers = data.maxPlayers
	local expectedFps2 = v.Performance.ExpectedFps
	local v3 = 0

	for k in expectedFps2 do
		if k <= maxPlayers and v3 <= k then
			v3 = k
		end
	end

	local v4 = expectedFps2[v3] or 60
	local expectedFps3 = v.Performance.ExpectedFps
	local v5 = 0

	for k in expectedFps3 do
		if k <= players and v5 <= k then
			v5 = k
		end
	end

	local v6 = fps + (v4 - (expectedFps3[v5] or 60))
	local v7 = smoothstep(performance.FpsBad, performance.FpsGood, v6) -- equivalent call inferred; original call site unknown
	local v8 = smoothstep(performance.JitterGood, performance.JitterBad, data.jitter) -- equivalent call inferred; original call site unknown
	local v9 = 1 - v8
	local v10 = smoothstep(performance.HeartbeatGoodMs, performance.HeartbeatBadMs, data.heartbeatMs) -- equivalent call inferred; original call site unknown
	local v11 = 1 - v10
	return performance.FpsWeight * v7 + performance.JitterWeight * v9 + performance.HeartbeatWeight * v11
end

local function memoryIndex(data)
	local memory = v.Memory
	local memWeight = memory.MemWeight
	local v3 = smoothstep(memory.MemOkMb, memory.MemCritMb, data.memMb) -- equivalent call inferred; original call site unknown
	local v4 = memWeight * (1 - v3)
	local heapWeight = memory.HeapWeight
	local v5 = smoothstep(memory.HeapOkMb, memory.HeapCritMb, data.luaHeapMb) -- equivalent call inferred; original call site unknown
	local v6 = v4 + heapWeight * (1 - v5)
	local instanceWeight = memory.InstanceWeight
	local v7 = smoothstep(memory.InstancesOk, memory.InstancesCrit, data.instanceCount) -- equivalent call inferred; original call site unknown
	return v6 + instanceWeight * (1 - v7)
end

local function stabilityIndex(data)
	local stability = v.Stability
	local errorWeight = stability.ErrorWeight
	local v3 = smoothstep(stability.ErrorsOkPerMin, stability.ErrorsCritPerMin, data.errorsPerMin) -- equivalent call inferred; original call site unknown
	local v4 = errorWeight * (1 - v3)
	local datastoreWeight = stability.DatastoreWeight
	local v6 = smoothstep(stability.DatastoreFailOk, stability.DatastoreFailCrit, data.datastoreFailPct / 100) -- equivalent call inferred; original call site unknown
	local v7 = v4 + datastoreWeight * (1 - v6)
	local bounceWeight = stability.BounceWeight
	local v9 = smoothstep(stability.BounceOk, stability.BounceCrit, data.bouncePct / 100) -- equivalent call inferred; original call site unknown
	return v7 + bounceWeight * (1 - v9) + stability.WarningWeight
end

local function desirability(data, players: number, data2)
	local desirability2 = v.Desirability
	local v3 = math.exp(-(players / math.max(data.maxPlayers, 1) - desirability2.FillPeak) ^ 2 / (2 * desirability2.FillSpread ^ 2))
	local v4 = 1 - math.exp(-data2.friendsInServer / desirability2.FriendCurve)
	local v5

	if data.roundSeconds <= 0 then
		v5 = 1
	else
		local readySeconds = desirability2.ReadySeconds
		local roundSeconds = data.roundSeconds

		if readySeconds == 0 then
			v5 = 0
		else
			local v6 = math.clamp((roundSeconds - 0) / (readySeconds - 0), 0, 1)
			v5 = v6 * v6 * (3 - v6 * 2)
		end
	end

	local v6 = math.clamp(data.playerDelta / desirability2.MomentumSpan, -1, 1) * 0.5 + 0.5
	local v7 = data.uptimeMin * 60
	local v8 = smoothstep(desirability2.UptimeWarmupStart, desirability2.UptimeWarmupEnd, v7) -- equivalent call inferred; original call site unknown
	local uptimeDecayAmount = desirability2.UptimeDecayAmount
	local v9 = smoothstep(desirability2.UptimeDecayStart, desirability2.UptimeDecayEnd, v7) -- equivalent call inferred; original call site unknown
	local v10 = v8 * (1 - uptimeDecayAmount * v9)
	return
		desirability2.PopulationWeight * v3 + desirability2.SocialWeight * v4 + desirability2.ReadyWeight * v5 + desirability2.MomentumWeight * v6 + desirability2.AgeWeight * v10,
		v3,
		v4
end

local ServerRanking = {}

function ServerRanking.isEligible(data, p)
	if data.players >= data.maxPlayers then
		return false, "full"
	end

	if data.jobId == game.JobId then
		return false, "self"
	end

	if os.time() - data.lastUpdate > v2.StaleAfterSeconds then
		return false, "dead"
	end

	if data.flags.ShuttingDown then
		return false, "closing"
	end

	if data.datastoreFailPct > 25 then
		return false, "data risk"
	end

	local latestPlaceVersion = p.latestPlaceVersion

	if p.oldBuildsExcluded and latestPlaceVersion and data.placeVersion < latestPlaceVersion then
		return false, "old build"
	end

	return true, nil
end

function ServerRanking.score(data, data2)
	local gates = v.Gates
	local estimatedPing = v2.getEstimatedPing(data2.myPing, data2.myCountry, data2.myServerCountry, data.country)
	local performance = performanceIndex(data, data.players)
	local memory = memoryIndex(data)
	local stability = stabilityIndex(data)
	local v6 = math.max(0, os.time() - data.lastUpdate)
	local v7 = 1 - gates.LatencyFloor
	local v8 = smoothstep(gates.LatencyGoodMs, gates.LatencyBadMs, estimatedPing) -- equivalent call inferred; original call site unknown
	local latency = 1 - v7 * v8
	local v10 = gates.PerfFloor + (1 - gates.PerfFloor) * performance
	local v11 = gates.StabilityFloor + (1 - gates.StabilityFloor) * stability
	local v12 = gates.MemoryFloor + (1 - gates.MemoryFloor) * memory
	local populatedFloor = gates.PopulatedFloor
	local v13 = 1 - gates.PopulatedFloor
	local v14 = smoothstep(gates.PopulatedLow, gates.PopulatedHigh, data.players) -- equivalent call inferred; original call site unknown
	local v15 = populatedFloor + v13 * v14
	local freshFloor = gates.FreshFloor
	local v16 = 1 - gates.FreshFloor
	local v17 = smoothstep(gates.FreshGoodSeconds, gates.FreshBadSeconds, v6) -- equivalent call inferred; original call site unknown
	local v18 = freshFloor + v16 * (1 - v17)
	local viability = latency * v10 * v11 * v12 * v15 * v18
	local desirability2, population, social = desirability(data, data.players, data2)
	local score = viability * desirability2
	local latestPlaceVersion = data2.latestPlaceVersion

	if latestPlaceVersion and data.placeVersion < latestPlaceVersion then
		score *= v.OldBuildPenalty
	end

	local leftSecondsAgo = data2.leftSecondsAgo

	if leftSecondsAgo and leftSecondsAgo <= v.RecentlyLeftSeconds then
		score *= v.RecentlyLeftPenalty
	end

	local reasons = {}

	if estimatedPing <= gates.LatencyGoodMs then
		table.insert(reasons, (`{math.round(estimatedPing)}ms estimated`))
	elseif gates.LatencyBadMs <= estimatedPing then
		table.insert(reasons, (`{math.round(estimatedPing)}ms is too far`))
	end

	if data2.friendsInServer > 0 then
		table.insert(reasons, (`{data2.friendsInServer} friend{data2.friendsInServer > 1 and "s" or ""} here`))
	end

	if performance < 0.4 then
		table.insert(reasons, "struggling to keep up")
	elseif performance > 0.8 then
		table.insert(reasons, "running smoothly")
	end

	if data.players < gates.PopulatedHigh then
		table.insert(reasons, "still filling up")
	end

	return {
		Score = score,
		Viability = viability,
		Desirability = desirability2,
		EstimatedPing = estimatedPing,
		Latency = latency,
		Performance = performance,
		Memory = memory,
		Stability = stability,
		Population = population,
		Social = social,
		Reasons = reasons
	}
end

function ServerRanking.pickHero(list, p: number)
	if #list == 0 then
		return nil
	end

	local herd = v.Herd
	local v3 = math.min(#list, herd.PoolSize)
	local score = list[1].score
	local v4 = {}
	local total = 0

	for i = 1, v3 do
		local v5 = math.exp((list[i].score - score) / math.max(herd.Temperature, 1e-6))
		v4[i] = v5
		total += v5
	end

	local v5 = Random.new(p):NextNumber() * total

	for i = 1, v3 do
		v5 -= v4[i]

		if v5 <= 0 then
			return list[i].jobId
		end
	end

	return list[1].jobId
end

return ServerRanking