local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local parent = script.Parent
local BattleConfig = require(parent:WaitForChild("BattleConfig"))
local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))
local BattleReplayBuilder = require(parent:WaitForChild("BattleReplayBuilder"))
local BattleRenderer = require(parent:WaitForChild("BattleRenderer"))
local BattlePlaybackController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Battle"):WaitForChild("BattlePlaybackController"))
local BattleRenderTestRunner = {}
local v = nil
local count = 0

local function countDescendants(folder)
	if folder then
		return #folder:GetDescendants()
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function validateRoleId(p: string)
	assert(BattleConfig.roles[p] ~= nil, string.format("[BattleRenderTestRunner] 未知球角色: %s", p))
end

local function destroyRun(data, p: string)
	data.playback:clear()
	data.playback:destroy()
	data.renderer:destroy()
	local v2 = data.rootFolder == nil or data.rootFolder.Parent == nil
	print(string.format("[BattleRenderTestRunner] 清理：id=%d reason=%s cleaned=%s", data.id, p, (tostring(v2))))
	return v2
end

function BattleRenderTestRunner.stop()
	local v2 = v

	if not v2 then
		return true
	end

	v = nil
	return (destroyRun(v2, "manual_stop"))
end

function BattleRenderTestRunner.getActiveRun()
	return v
end

function BattleRenderTestRunner.runScenario(p: string, p2: string, options)
	assert(RunService:IsClient(), "[BattleRenderTestRunner] 必须在 Play 模式的 Client 侧调用")
	local v2 = options or {}
	validateRoleId(p) -- equivalent call inferred; original call site unknown
	validateRoleId(p2) -- equivalent call inferred; original call site unknown
	BattleRenderTestRunner.stop()
	count += 1
	local id = count
	local seed = v2.seed or BattleConfig.seed.value
	local v4 = math.max(0, v2.countdown or 0.25)
	local playbackSpeed = math.max(0.01, v2.playbackSpeed or 1)
	local arenaCenter = v2.arenaCenter or BattleConfig.arena.worldCenter + createVector(0, 0, 40)
	local arenaScale = v2.arenaScale or 1
	local replayOptions = {
		fixedDt = BattleConfig.replay.fixedDt,
		snapshotInterval = BattleConfig.replay.snapshotInterval,
		maxDuration = BattleConfig.replay.maxDuration,
		selectedRoles = {
			Blue = p,
			Yellow = p2
		},
		statLevels = v2.statLevels,
		selectedSecondaryTraits = v2.selectedSecondaryTraits
	}
	local replay

	if v2.useExcitementSelection == true then
		replay = BattleReplayBuilder.buildBestOfN(
			BattleConfig,
			seed,
			replayOptions,
			BattleConfig.replay.candidateCount,
			BattleConfig.replay.yieldEveryTrials
		)
	else
		replay = BattleReplayBuilder.buildReplay(BattleConfig, seed, replayOptions)
	end

	local renderer = BattleRenderer.new(BattleConfig, {
		instanceId = "RenderTest_" .. tostring(id),
		arenaCenter = arenaCenter,
		arenaScale = arenaScale,
		audioMode = "global"
	})
	renderer:setParticipantView(true, "Playing")
	renderer:setLocalParticipantSlot("Blue")
	local playback = BattlePlaybackController.new(BattleConfig, renderer)
	local serverTimeNow = Workspace:GetServerTimeNow()
	playback:loadReplay({
		kind = "replay",
		players = {
			Blue = {
				name = "RenderTest Blue",
				username = "RenderTest Blue",
				roleId = p
			},
			Yellow = {
				name = "RenderTest Yellow",
				username = "RenderTest Yellow",
				roleId = p2
			}
		},
		seed = replay.seed,
		replayOptions = replayOptions,
		identificationStartTime = serverTimeNow,
		playbackStartTime = serverTimeNow + v4,
		playbackSpeed = playbackSpeed
	})
	local rootFolder = renderer._ctx.rootFolder
	local v10

	if rootFolder == nil then
		v10 = false
	else
		v10 = rootFolder.Parent ~= nil
	end

	assert(v10, "[BattleRenderTestRunner] 渲染根节点未创建")
	local v11 = rootFolder and #rootFolder:GetDescendants() or 0
	assert(v11 > 0, "[BattleRenderTestRunner] 初始渲染没有创建任何对象")
	local v12 = {
		id = id,
		renderer = renderer,
		playback = playback,
		rootFolder = rootFolder,
		replay = replay
	}
	v = v12
	print(string.format(
		"[BattleRenderTestRunner] START id=%d %s vs %s seed=%d duration=%.2f snapshots=%d events=%d descendants=%d",
		id,
		p,
		p2,
		seed,
		replay.duration,
		#replay.snapshots,
		#replay.events,
		v11
	))
	task.spawn(function()
		task.wait(v4 + replay.duration / playbackSpeed + 0.5)

		if v ~= v12 then
			return
		end

		local completed = not playback:isPlaying()
		local folder = rootFolder
		local descendantCount = folder and #folder:GetDescendants() or 0
		local passed = completed and descendantCount > 0
		local v16 = {
			id = id,
			passed = passed,
			completed = completed,
			descendantCount = descendantCount,
			winner = replay.winner
		}
		print(string.format(
			"[BattleRenderTestRunner] FINISH id=%d status=%s completed=%s descendants=%d winner=%s",
			id,
			passed and "PASS" or "FAIL",
			tostring(completed),
			descendantCount,
			(tostring(replay.winner))
		))

		if typeof(v2.onComplete) == "function" then
			v2.onComplete(v16)
		end

		if v2.keepStage ~= true then
			v = nil

			if not destroyRun(v12, "auto_cleanup") then
				warn(string.format("[BattleRenderTestRunner] FAIL id=%d 渲染根节点未清理", id))
			end
		end
	end)
	return {
		id = id,
		seed = seed,
		duration = replay.duration,
		wallDuration = v4 + replay.duration / playbackSpeed + 0.5,
		eventCount = #replay.events,
		snapshotCount = #replay.snapshots,
		replay = replay
	}
end

local function resolveUpgradeCandidate(p)
	if p.choiceType == "升级" then
		for k, basicStat in BattleConfig.tournament_upgrade.basicStats do
			if basicStat.cnId == p.targetCnId then
				return {
					kind = "basicStat",
					id = k
				}
			end
		end
	elseif p.choiceType == "技能" then
		for k, trait in BattleConfig.traits do
			if trait.cnId == p.targetCnId then
				return {
					kind = "effect",
					id = k
				}
			end
		end
	end

	return nil
end

local function buildThreeUpgradeLoadout(p: number)
	local list = Config.upgradeChoice.list
	assert(#list >= 3, "[BattleRenderTestRunner] 升级三选一池不足 3 项")
	local targetCnIds = {}
	local ids = {}
	local result = {
		speed = 0,
		hp = 0,
		attack = 0,
		allIn = 0
	}

	for i = 0, 2 do
		local v2 = list[(p - 1 + i) % #list + 1]
		local upgradeCandidate = resolveUpgradeCandidate(v2)
		assert(
			upgradeCandidate ~= nil,
			string.format("[BattleRenderTestRunner] 升级项无法映射: %s", (tostring(v2.targetCnId)))
		)
		table.insert(targetCnIds, v2.targetCnId)

		if upgradeCandidate.kind == "basicStat" then
			result[upgradeCandidate.id] = (result[upgradeCandidate.id] or 0) + 1
		elseif upgradeCandidate.id == "AllIn" then
			result.allIn += 1
		elseif not table.find(ids, upgradeCandidate.id) then
			table.insert(ids, upgradeCandidate.id)
		end
	end

	return result, ids, targetCnIds
end

function BattleRenderTestRunner.runAllRolesWithThreeUpgrades(options)
	assert(RunService:IsClient(), "[BattleRenderTestRunner] 必须在 Play 模式的 Client 侧调用")
	local v2 = options or {}
	local rolePool = BattleConfig.battle.rolePool
	assert(#rolePool >= 2, "[BattleRenderTestRunner] 角色池不足 2 个")
	local count2 = #rolePool
	task.spawn(function()
		local seed = v2.seed or BattleConfig.seed.value
		local count3 = 0
		local count4 = 0

		for i, v3 in ipairs(rolePool) do
			local v4 = rolePool[i % #rolePool + 1]
			local threeUpgradeLoadout, blue, v6 = buildThreeUpgradeLoadout(i)
			local threeUpgradeLoadout2, yellow, v8 = buildThreeUpgradeLoadout(i + 3)
			local v9 = nil
			local v10 = v3
			local v12 = i
			local success, result = pcall(function()
				return BattleRenderTestRunner.runScenario(v10, v4, {
					seed = seed + v12,
					countdown = v2.countdown or 0.1,
					playbackSpeed = v2.playbackSpeed or 8,
					useExcitementSelection = v2.useExcitementSelection == true,
					statLevels = {
						Blue = threeUpgradeLoadout,
						Yellow = threeUpgradeLoadout2
					},
					selectedSecondaryTraits = {
						Blue = blue,
						Yellow = yellow
					},
					onComplete = function(p)
						v9 = p
					end
				})
			end)

			if success then
				task.wait(result.wallDuration + 0.1)

				if v9 and v9.passed then
					count3 += 1
					print(string.format(
						"[BattleRenderTestRunner] BATCH PASS %s[%s] vs %s[%s]",
						v3,
						table.concat(v6, ","),
						v4,
						table.concat(v8, ",")
					))
				else
					count4 += 1
					warn(string.format("[BattleRenderTestRunner] BATCH FAIL %s vs %s: 未完成或渲染失败", v3, v4))
				end
			else
				count4 += 1
				warn(string.format("[BattleRenderTestRunner] BATCH FAIL %s vs %s: %s", v3, v4, (tostring(result))))
			end
		end

		print(string.format(
			"[BattleRenderTestRunner] BATCH SUMMARY total=%d passed=%d failed=%d",
			count2,
			count3,
			count4
		))
	end)
	return {
		scheduled = count2
	}
end

return BattleRenderTestRunner