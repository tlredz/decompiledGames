local ReplicatedStorage = game:GetService("ReplicatedStorage")
local battleDemo = ReplicatedStorage:WaitForChild("BattleDemo")
local BattleConfig = require(battleDemo:WaitForChild("BattleConfig"))
local GameEngine = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("GameEngine"))
local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))

-- equivalent calls inferred from this helper; original call sites unknown
local function cnLabel(p)
	if p.kind == "basicStat" then
		local basicStat = BattleConfig.tournament_upgrade.basicStats[p.id]
		return basicStat and basicStat.displayName or p.id
	end

	local trait = BattleConfig.traits[p.id]
	return trait and trait.displayName or p.id
end

local function formatOffer(offerUpgrade)
	local v = {}

	for _, v2 in ipairs(offerUpgrade) do
		local v4 = cnLabel(v2) -- equivalent call inferred; original call site unknown
		table.insert(v, string.format("%s(%s/%s)", v4, v2.kind, v2.id))
	end

	return table.concat(v, "，")
end

local function candidateEquals(p, p2)
	return p.kind == p2.kind and p.id == p2.id
end

-- equivalent calls inferred from this helper; original call sites unknown
local function offerContains(offerUpgrade, p)
	for _, v in ipairs(offerUpgrade) do
		local v2

		if v.kind == p.kind then
			v2 = v.id == p.id
		else
			v2 = false
		end

		if v2 then
			return true
		end
	end

	return false
end

local GameEngineTestRunner = {}

function GameEngineTestRunner.runScenario(data)
	assert(typeof(data) == "table", "GameEngineTestRunner.runScenario 需要 params")
	local participants = data.participants
	local v

	if typeof(participants) == "table" then
		v = #participants >= 2
	else
		v = false
	end

	assert(v, "params.participants 至少需要 2 个 {userId, roleId}")
	local userIds = {}

	for _, participant in ipairs(participants) do
		table.insert(userIds, participant.userId)
	end

	local seed = data.seed or BattleConfig.seed.value
	local v2 = GameEngine.new(BattleConfig, seed, userIds, {
		raceHp = data.raceHp or 3,
		pickCandidateCount = data.pickCandidateCount or BattleConfig.tournament.pickCandidateCount,
		upgradeCandidateCount = data.upgradeCandidateCount or BattleConfig.tournament.upgradeCandidateCount,
		upgradeChoiceList = Config.upgradeChoice and Config.upgradeChoice.list
	})

	for _, participant in ipairs(participants) do
		if not participant.roleId then
			continue
		end

		local ballOffer = v2:getBallOffer(participant.userId)

		if ballOffer and not table.find(ballOffer, participant.roleId) then
			table.insert(ballOffer, participant.roleId)
		end

		v2:selectBall(participant.userId, participant.roleId)
	end

	v2:lockRemainingBalls()
	print(string.format("========== GameEngineTestRunner.runScenario：参赛人数=%d，seed=%d ==========", #participants, seed))
	local forcedUpgradePicks = data.forcedUpgradePicks or {}
	local maxRounds = data.maxRounds
	local rounds = 0

	while not v2:isFinished() do
		rounds += 1

		if maxRounds and maxRounds < rounds then
			print(string.format("[GameEngineTestRunner] 已达到 maxRounds=%d，提前停止", maxRounds))
			rounds -= 1
			break
		else
			local v4 = v2:runRound()
			print(string.format("---- 第 %d 轮（引擎回合号=%d）----", rounds, v4.round))

			for _, pair in ipairs(v4.pairs) do
				print(string.format(
					"  桌 %d：%d(%s%s) vs %d(%s%s) → %s",
					pair.arenaIndex,
					pair.userIdA,
					pair.roleA,
					pair.isGhostA and "·幽灵" or "",
					pair.userIdB,
					pair.roleB,
					pair.isGhostB and "·幽灵" or "",
					pair.replay.winner
				))
				v2:applyPairLoss(pair)
			end

			local finalizeRoundElimination = v2:finalizeRoundElimination()

			for _, v5 in ipairs(finalizeRoundElimination.newlyEliminated) do
				print(string.format("  userId=%d 血量归零，淘汰", v5))
			end

			if v2:isFinished() then
				break
			end

			local offerUpgrades = v2:offerUpgrades()
			local forcedUpgradePick = forcedUpgradePicks[rounds]

			if forcedUpgradePick then
				for k, v5 in forcedUpgradePick do
					local offerUpgrade = offerUpgrades[k]

					if not offerUpgrade then
						continue
					end

					-- equivalent call inferred; original call site unknown
					if not offerContains(offerUpgrade, v5) then
						table.insert(offerUpgrade, v5)
					end
				end
			end

			for k, offerUpgrade in offerUpgrades do
				local v5 = forcedUpgradePick and forcedUpgradePick[k]

				if v5 then
					v2:selectUpgrade(k, v5)
				end

				print(string.format("  userId=%d 三选一候选：[%s]", k, formatOffer(offerUpgrade)))
			end

			v2:finalizeUpgrades()
		end
	end

	local finished = v2:isFinished()
	local championUserId

	if finished then
		championUserId = v2:getChampionUserId()
	end

	print(string.format(
		"========== 测试结束：共打 %d 轮，%s ==========",
		rounds,
		not finished and "尚未分出冠军" or "冠军=" .. tostring(championUserId) or "尚未分出冠军"
	))
	return {
		rounds = rounds,
		finished = finished,
		championUserId = championUserId,
		finalState = v2:getState()
	}
end

function GameEngineTestRunner.runDuelScenario(data)
	assert(typeof(data) == "table", "runDuelScenario 需要 params")
	local userIdA = data.userIdA or 1001
	local userIdB = data.userIdB or 1002
	local seed = data.seed or BattleConfig.seed.value
	local v = GameEngine.new(BattleConfig, seed, { userIdA, userIdB }, {
		raceHp = data.raceHp or 3,
		pickCandidateCount = 3,
		preserveParticipantOrder = true
	})
	v:lockRemainingBalls()
	print(string.format("========== runDuelScenario：%d vs %d，raceHp=%d ==========", userIdA, userIdB, data.raceHp or 3))
	print(string.format(
		"  %d 选球=%s，%d 选球=%s",
		userIdA,
		v:getSelectedRoleId(userIdA),
		userIdB,
		v:getSelectedRoleId(userIdB)
	))
	local count = 0

	while not v:isFinished() do
		count += 1
		v:beginAimingSession()
		v:lockRemainingLaunchDirections()
		local pair = v:runRound().pairs[1]
		local v2 = v:applyPairLoss(pair)
		v:finalizeRoundElimination()
		print(string.format("  第 %d 轮 → 胜方=%s，输家 userId=%s", count, pair.replay.winner, (tostring(v2))))
	end

	print(string.format(
		"========== runDuelScenario 结束：共打 %d 轮，冠军=%s ==========",
		count,
		(tostring(v:getChampionUserId()))
	))
	return {
		rounds = count,
		championUserId = v:getChampionUserId(),
		finalState = v:getState()
	}
end

function GameEngineTestRunner.runRPSScenario(data)
	assert(typeof(data) == "table", "runRPSScenario 需要 params")
	local userIdA = data.userIdA or 1001
	local userIdB = data.userIdB or 1002
	local seed = data.seed or BattleConfig.seed.value
	local v = GameEngine.new(BattleConfig, seed, { userIdA, userIdB }, {
		raceHp = data.raceHp or 3,
		pickCandidateCount = 3,
		preserveParticipantOrder = true
	})
	v:lockRemainingBalls()
	print(string.format("========== runRPSScenario：%d vs %d，raceHp=%d ==========", userIdA, userIdB, data.raceHp or 3))
	print(string.format(
		"  %d 球池=[%s]，%d 球池=[%s]",
		userIdA,
		table.concat(v:getBallOffer(userIdA), ","),
		userIdB,
		table.concat(v:getBallOffer(userIdB), ",")
	))
	local count = 0

	while not v:isFinished() do
		count += 1

		if count > 1 then
			v:beginBallReselection(userIdA)
			v:beginBallReselection(userIdB)
			v:lockRemainingBalls()
		end

		v:beginAimingSession()
		v:lockRemainingLaunchDirections()
		local pair = v:runRound().pairs[1]
		v:applyPairLoss(pair)
		v:finalizeRoundElimination()
		print(string.format(
			"  第 %d 轮 → %d 选球=%s，%d 选球=%s，胜方=%s",
			count,
			userIdA,
			pair.roleA,
			userIdB,
			pair.roleB,
			pair.replay.winner
		))
	end

	print(string.format(
		"========== runRPSScenario 结束：共打 %d 轮，冠军=%s ==========",
		count,
		(tostring(v:getChampionUserId()))
	))
	return {
		rounds = count,
		championUserId = v:getChampionUserId(),
		finalState = v:getState()
	}
end

return GameEngineTestRunner