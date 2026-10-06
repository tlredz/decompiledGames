local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BattleReplayBuilder = require(ReplicatedStorage:WaitForChild("BattleDemo"):WaitForChild("BattleReplayBuilder"))
local BattleComputePool = {}

local function destroyWorkerContainers()
	local ServerScriptService = game:GetService("ServerScriptService")

	for _, child in ipairs(ServerScriptService:GetChildren()) do
		if child.Name == "BattleComputeWorkers" then
			child:Destroy()
		end
	end
end

local v = {
	initialized = false,
	actors = nil,
	resultEvents = nil,
	failureReason = nil,
	nextJobId = 1,
	actorLoad = {}
}

local function isServer()
	return RunService:IsServer()
end

local function teardown()
	if v.actors then
		for _, actor in v.actors do
			actor:Destroy()
		end
	end

	v.actors = nil
	v.resultEvents = nil
	v.actorLoad = {}
end

local function ensureInitialized(p)
	if v.initialized then
		return v.actors ~= nil
	end

	v.initialized = true

	if not RunService:IsServer() then
		v.failureReason = "非服务器环境"
		return false
	end

	local ServerStorage = game:GetService("ServerStorage")
	local ServerScriptService = game:GetService("ServerScriptService")
	local battleComputeWorker = ServerStorage:FindFirstChild("BattleComputeWorker")

	if not battleComputeWorker then
		v.failureReason = "ServerStorage.BattleComputeWorker 不存在"
		return false
	end

	local v2 = math.max(1, (math.floor(tonumber(p.replay.parallelActorCount) or 4)))
	destroyWorkerContainers()
	local folder = Instance.new("Folder")
	folder.Name = "BattleComputeWorkers"
	folder.Parent = ServerScriptService
	local clones = {}
	local workerResults = {}
	local connections = {}
	local count = 0
	local v3 = true
	local v4 = nil

	for i = 1, v2 do
		local clone = battleComputeWorker:Clone()
		clone.Name = string.format("BattleComputeWorker_%d", i)
		local workerResult = clone:FindFirstChild("WorkerResult")
		clones[i] = clone
		workerResults[i] = workerResult
		table.insert(connections, workerResult.Event:Connect(function(p2, p3, p4)
			if p2 == 0 then
				count += 1

				if not p3 then
					v3 = false
					v4 = tostring(p4)
				end
			end
		end))
		clone.Parent = folder
	end

	local v5 = os.clock() + 30

	while count < v2 and os.clock() < v5 do
		task.wait()
	end

	for _, connection in connections do
		connection:Disconnect()
	end

	if count < v2 or not v3 then
		v.failureReason = string.format("worker 预热失败（ready=%d/%d）%s", count, v2, v4 and ": " .. v4 or "")
		teardown()
		destroyWorkerContainers()
		return false
	else
		v.actors = clones
		v.resultEvents = workerResults
		v.actorLoad = table.create(v2, 0)
		print(string.format("[战斗并行计算] 已启动 %d 个 Actor worker", v2))
		return true
	end
end

function BattleComputePool.isEnabled(p)
	return RunService:IsServer() and p.replay.parallelCompute == true
end

function BattleComputePool.prewarm(p)
	if not BattleComputePool.isEnabled(p) then
		return
	end

	task.spawn(function()
		local lastTime = os.clock()

		if not ensureInitialized(p) then
			warn("[战斗并行计算] 预热失败，将全程回退串行：" .. tostring(v.failureReason))
			return
		end

		local v2 = v.actors and #v.actors or 0
		local rolePool = p.battle.rolePool
		local v3 = {}

		for i = 1, v2 do
			v3[i] = {
				seed = 1,
				candidateCount = 1,
				options = {
					fixedDt = p.replay.fixedDt,
					snapshotInterval = BattleReplayBuilder.SNAPSHOT_INTERVAL_DISABLED,
					maxDuration = 2,
					selectedRoles = {
						Blue = rolePool[(i - 1) % #rolePool + 1],
						Yellow = rolePool[i % #rolePool + 1]
					}
				}
			}
		end

		if v2 > 0 then
			BattleComputePool.computeBattles(p, v3)
		end

		print(string.format("[战斗并行计算] 预热完成，耗时 %.0f ms", (os.clock() - lastTime) * 1000))
	end)
end

function BattleComputePool.getFailureReason()
	return v.failureReason
end

function BattleComputePool.isReady()
	return v.actors ~= nil
end

function BattleComputePool.reset()
	teardown()
	destroyWorkerContainers()
	v.initialized = false
	v.failureReason = nil
end

function BattleComputePool.computeBattles(p, list)
	if #list == 0 then
		return {}
	end

	if not (BattleComputePool.isEnabled(p) and ensureInitialized(p)) then
		return nil
	end

	local actors = v.actors
	local resultEvents = v.resultEvents
	local count = #actors
	local actorLoad = v.actorLoad
	local options = {}
	local v2 = {}
	local v3 = {}

	for k, v4 in list do
		options[k] = v4.options
		local v5 = math.max(1, v4.candidateCount or 1)
		v2[k] = v5

		if v5 <= 1 then
			table.insert(v3, {
				jobIndex = k,
				trial = 0,
				seed = v4.seed,
				needsScore = false
			})
		else
			for i = 1, v5 do
				table.insert(v3, {
					jobIndex = k,
					trial = i,
					seed = v4.seed + i * 7919,
					needsScore = true
				})
			end
		end
	end

	local v4 = {}

	for i = 1, count do
		v4[i] = {}
	end

	for _, v5 in v3 do
		local v6 = 1e999
		local v7 = 1

		for i = 1, count do
			local v8 = actorLoad[i] + #v4[i]

			if not (v8 < v6) then
				continue
			end

			v7 = i
			v6 = v8
		end

		table.insert(v4[v7], v5)
	end

	local nextJobId = v.nextJobId
	v.nextJobId += 1
	local v6 = 0
	local v7 = {}
	local connections = {}
	local v8 = {}
	local v9 = nil

	for i = 1, count do
		if not (#v4[i] > 0) then
			continue
		end

		v6 += 1
		v7[i] = true
		actorLoad[i] += #v4[i]
		table.insert(connections, resultEvents[i].Event:Connect(function(p2, p3, items)
			if p2 ~= nextJobId then
				return
			end

			if p3 then
				for _, item in items do
					table.insert(v8, item)
				end
			else
				v9 = tostring(items)
			end

			v6 -= 1
		end))
	end

	for i = 1, count do
		if not v7[i] then
			continue
		end

		local v10 = {}
		local v11 = {}

		for _, v12 in v4[i] do
			local optionIndex = v10[v12.jobIndex]

			if not optionIndex then
				optionIndex = #v11 + 1
				v10[v12.jobIndex] = optionIndex
				v11[optionIndex] = options[v12.jobIndex]
			end

			v12.optionIndex = optionIndex
		end

		actors[i]:SendMessage("ComputeBattles", nextJobId, v4[i], v11)
	end

	local v10 = os.clock() + 120

	while v6 > 0 and v.actors == actors and os.clock() < v10 do
		task.wait()
	end

	for _, connection in connections do
		connection:Disconnect()
	end

	for i = 1, count do
		if v7[i] then
			actorLoad[i] = math.max(0, actorLoad[i] - #v4[i])
		end
	end

	if v.actors ~= actors or v6 > 0 or v9 or #v8 ~= #v3 then
		warn(string.format(
			"[战斗并行计算] 并行路径异常，回退串行：pending=%d collected=%d/%d%s",
			v6,
			#v8,
			#v3,
			v9 and " err=" .. v9 or ""
		))
		return nil
	end

	local v11 = {}
	local v12 = {}

	for _, v13 in v8 do
		v11[v13.jobIndex] = (v11[v13.jobIndex] or 0) + 1
		local v14 = v12[v13.jobIndex]

		if not (v14 == nil or v13.score > v14.score or v13.score == v14.score and v13.trial < v14.trial) then
			continue
		end

		v12[v13.jobIndex] = v13
	end

	local result = {}

	for i = 1, #list do
		local v13 = v12[i]

		if v13 == nil or v11[i] ~= v2[i] then
			warn(string.format("[战斗并行计算] 第 %d 个任务结果不完整，回退串行", i))
			return nil
		end

		local v14 = {
			seed = v13.seed,
			winner = v13.winner,
			duration = v13.duration,
			excitementScore = 0,
			candidateCount = 0,
			computedInParallel = true
		}
		local excitementScore

		if v2[i] > 1 then
			excitementScore = v13.score
		end

		v14.excitementScore = excitementScore
		v14.candidateCount = v2[i]
		result[i] = v14
	end

	return result
end

function BattleComputePool.buildBestOfN(p, seed: number, options, value: number?, p4: number?)
	local candidateCount = math.max(1, value or 1)

	if candidateCount <= 1 then
		return BattleReplayBuilder.buildBestOfN(p, seed, options, value, p4)
	end

	local battles = BattleComputePool.computeBattles(p, {
		{
			seed = seed,
			options = options,
			candidateCount = candidateCount
		}
	})

	if battles == nil then
		return BattleReplayBuilder.buildBestOfN(p, seed, options, value, p4)
	end

	local battle = battles[1]
	local replay = BattleReplayBuilder.buildReplay(p, battle.seed, options)
	replay.excitementScore = battle.excitementScore
	replay.candidateCount = candidateCount
	replay.computedInParallel = true
	return replay
end

return BattleComputePool