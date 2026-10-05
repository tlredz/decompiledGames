local Analysis = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Analysis)
local SimulationSession = require(game.ReplicatedStorage.Modules.Gacha.SimulationSession)
local Store = require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Store)
require(game.ReplicatedStorage.Osiris.Components.GachaSimulation.Types)
local v = {
	Color3.fromRGB(120, 180, 255),
	Color3.fromRGB(255, 176, 92),
	Color3.fromRGB(126, 217, 143),
	Color3.fromRGB(235, 122, 197),
	Color3.fromRGB(238, 216, 106),
	Color3.fromRGB(160, 143, 255)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function bump(p, status, progress: number, message: string)
	p.Status = status
	p.Progress = progress
	p.Message = message
	p.Revision += 1
end

local function newAccumulator()
	return {
		BaseChances = {},
		Counts = {},
		BonusCounts = {},
		BatchRates = {},
		BatchSize = 0,
		Snapshots = {},
		HitLog = {},
		OwnedGained = {},
		PullsDone = 0,
		RollsDone = 0,
		EndSoftPity = 0,
		EndHardPity = 0,
		Elapsed = 0
	}
end

local function applyResponse(state, state2, p)
	local response = SimulationSession.normalizeResponse(p)
	state.BaseChances = response.BaseChances
	state.Counts = response.Counts
	state.BonusCounts = response.BonusCounts
	state.BatchRates = response.BatchRates
	state.BatchSize = response.BatchSize
	state.PullsDone = response.PullsDone
	state.RollsDone = response.RollsDone
	state.EndSoftPity = response.EndSoftPity
	state.EndHardPity = response.EndHardPity
	state.Elapsed = response.Elapsed

	for _, snapshot in response.Snapshots do
		table.insert(state.Snapshots, snapshot)
	end

	for _, hit in response.Hits do
		table.insert(state.HitLog, hit)
	end

	for _, v2 in response.OwnedGained do
		table.insert(state.OwnedGained, v2)
	end

	state2.Snapshots += #response.Snapshots
	state2.Hits += #response.Hits
	state2.Owned += #response.OwnedGained
end

local Runner = {
	chunkFor = SimulationSession.chunkFor,
	solveChances = function(p, p2, p3)
		local remote = p.Remote

		if remote ~= nil then
			local solveChances, v2, v3 = remote.solveChances(p2, p3 ~= nil)
			return SimulationSession.numberKeyedNumbers(solveChances), v2, v3
		end

		local softPityKey

		if p3 ~= nil then
			softPityKey = p3.SoftPityKey
		end

		local v2

		if p3 ~= nil then
			v2 = p3.HardPityKey
		end

		return SimulationSession.solveChances(p.solveAsync, p2, softPityKey, v2)
	end
}

function Runner.probe(p, p2)
	local v2 = p.job:get()
	local snapshot = Store.snapshot(p)
	v2.Token += 1
	v2.FailedBox = nil
	v2.StartedAt = os.clock()
	local token = v2.Token
	bump(v2, "Probing", 0, `solving "{snapshot.BoxName}"`) -- equivalent call inferred; original call site unknown
	task.defer(function()
		local success, result, softPityKey, hardPityKey = pcall(function()
			return Runner.solveChances(p2, snapshot, nil)
		end)

		if v2.Token ~= token then
			return
		end

		if success then
			local pool = Analysis.buildPool(snapshot.BoxName, result, p2.describe, p2.getItemIcon)
			pool.SoftPityKey = softPityKey
			pool.HardPityKey = hardPityKey
			v2.Pool = pool
			bump(v2, "Idle", 0, `"{snapshot.BoxName}": {#pool.Entries} items, {#pool.Rarities} rarities`) -- equivalent call inferred; original call site unknown
		else
			v2.Error = tostring(result)
			v2.FailedBox = snapshot.BoxName
			bump(v2, "Failed", 0, `probe failed: {v2.Error}`) -- equivalent call inferred; original call site unknown
		end
	end)
end

function Runner.pin(p, p2, name: string)
	local v2 = p.job:get()
	local pool = v2.Pool
	local snapshot = Store.snapshot(p)
	v2.Token += 1
	v2.StartedAt = os.clock()
	local token = v2.Token
	bump(v2, "Probing", 0, `solving "{name}"`) -- equivalent call inferred; original call site unknown
	task.defer(function()
		local success, result = pcall(function()
			return (Runner.solveChances(p2, snapshot, pool))
		end)

		if v2.Token ~= token then
			return
		end

		if success then
			v2.PendingScenario = {
				Name = name,
				Color = v[(#p.scenarios:get() + 1 - 1) % #v + 1],
				Chances = result,
				BoxName = snapshot.BoxName,
				Note = Store.describe(snapshot)
			}
			bump(v2, "Idle", 0, `pinned "{name}"`) -- equivalent call inferred; original call site unknown
		else
			v2.Error = tostring(result)
			bump(v2, "Failed", 0, `scenario failed: {v2.Error}`) -- equivalent call inferred; original call site unknown
		end
	end)
end

local function runLocally(p, p2, snapshot, token: number)
	local v2 = p.job:get()
	local pool = v2.Pool
	local new = SimulationSession.new
	local solveAsync = p2.solveAsync
	local softPityKey

	if pool ~= nil then
		softPityKey = pool.SoftPityKey
	end

	local v3

	if pool ~= nil then
		v3 = pool.HardPityKey
	end

	local v4 = new(snapshot, solveAsync, softPityKey, v3)
	local now = os.clock()
	local v5 = 0
	local success, result = pcall(function()
		while v2.Token == token do
			local v6 = SimulationSession.step(v4)
			local now2 = os.clock()
			v2.Progress = v4.PullsDone / math.max(1, v4.Total)
			v2.Message = `{v4.PullsDone} / {v4.Total} pulls, {v4.RollsDone} rolls`
			v2.Revision += 1

			if now2 - v5 > 0.25 then
				v5 = now2
				v2.Result = SimulationSession.result(v4)
				v2.ResultStamp += 1
			end

			if not v6 then
				break
			end

			if not (now2 - now > 0.011111111111111112) then
				continue
			end

			now = now2
			task.wait()
		end
	end)

	if v2.Token ~= token then
		return
	end

	if success then
		v2.Result = SimulationSession.result(v4)
		v2.ResultStamp += 1
		bump(
			v2,
			"Done",
			1,
			`{v4.PullsDone} pulls, {v4.RollsDone} rolls in {string.format("%.2f", os.clock() - v4.StartedAt)}s`
		) -- equivalent call inferred; original call site unknown
	else
		v2.Error = tostring(result)
		bump(v2, "Failed", v2.Progress, `run failed: {v2.Error}`) -- equivalent call inferred; original call site unknown
	end
end

local function runRemotely(p, p2, snapshot, token: number)
	local v2 = p.job:get()
	local remote = p2.Remote

	if remote == nil then
		return
	end

	local v3 = newAccumulator()
	local v4 = {
		Snapshots = 0,
		Hits = 0,
		Owned = 0
	}
	local jobId = nil
	local success, result = pcall(function()
		local v5 = remote.start(snapshot)

		if v5 == nil then
			error("the server did not start a simulation")
		end

		jobId = v5.JobId

		if v2.Token == token then
			v2.RemoteId = v5.JobId
		end

		applyResponse(v3, v4, v5)
		local v6 = v5

		while v2.Token == token do
			v2.Progress = v6.Progress
			v2.Message = v6.Message
			v2.Result = SimulationSession.compose(snapshot, v3)
			v2.ResultStamp += 1
			v2.Revision += 1

			if v6.Status == "Running" then
				task.wait(0.2)

				if v2.Token ~= token then
					break
				end

				v6 = remote.poll(v5.JobId, v4)

				if v6 == nil then
					error("the server no longer has this simulation; another run may have replaced it")
				end

				applyResponse(v3, v4, v6)
			else
				if v6.Status ~= "Failed" then
					break
				end

				error(v6.Error or "the server reported a failure")
				break
			end
		end
	end)

	if v2.Token == token then
		v2.RemoteId = nil

		if success then
			bump(v2, "Done", 1, `{v3.PullsDone} pulls, {v3.RollsDone} rolls in {string.format("%.2f", v3.Elapsed)}s`) -- equivalent call inferred; original call site unknown
		else
			v2.Error = tostring(result)
			bump(v2, "Failed", v2.Progress, `run failed: {v2.Error}`) -- equivalent call inferred; original call site unknown
		end
	elseif jobId ~= nil then
		if v2.RemoteId == jobId then
			v2.RemoteId = nil
		end

		pcall(remote.cancel, jobId)
	end
end

function Runner.run(p, p2)
	local v2 = p.job:get()
	local snapshot = Store.snapshot(p)
	v2.Token += 1
	v2.StartedAt = os.clock()
	local token = v2.Token
	bump(v2, "Running", 0, `starting {snapshot.SampleSize} pulls`) -- equivalent call inferred; original call site unknown
	task.defer(function()
		if p2.Remote == nil then
			runLocally(p, p2, snapshot, token)
		else
			runRemotely(p, p2, snapshot, token)
		end
	end)
end

function Runner.cancel(p)
	local v2 = p.job:get()
	v2.Token += 1
	bump(v2, "Cancelled", v2.Progress, "cancelled") -- equivalent call inferred; original call site unknown
end

function Runner.isBusy(p)
	local status = p.job:get().Status
	return status == "Running" or status == "Probing"
end

function Runner.step(data, p)
	local v2 = data.job:get()

	if v2.Revision ~= v2.Published then
		v2.Published = v2.Revision
		data.progress:set((math.clamp(v2.Progress, 0, 1)))

		if v2.Pool ~= data.pool:get() then
			data.pool:set(v2.Pool)
		end

		if v2.PublishedResult ~= v2.ResultStamp then
			v2.PublishedResult = v2.ResultStamp
			data.result:set(v2.Result)
		end

		local pendingScenario = v2.PendingScenario

		if pendingScenario ~= nil then
			v2.PendingScenario = nil
			local clone = table.clone(data.scenarios:get())
			table.insert(clone, pendingScenario)
			data.scenarios:set(clone)
			data.scenarioIndex:set(#clone)
		end
	end

	local v3 = data.boxName:get()

	if v2.Status == "Probing" and os.clock() - v2.StartedAt > 20 then
		v2.Token += 1
		v2.FailedBox = v3
		v2.Error = `gave up after {20}s waiting on the solver`
		bump(v2, "Failed", 0, `solve timed out after {20}s`) -- equivalent call inferred; original call site unknown
	end

	if v2.SelectedBox ~= v3 then
		v2.SelectedBox = v3
		v2.FailedBox = nil
	end

	local v4 = data.pool:get()

	if not Runner.isBusy(data) and v2.FailedBox ~= v3 and (v4 == nil or v4.BoxName ~= v3) then
		Runner.probe(data, p)
	end
end

return Runner