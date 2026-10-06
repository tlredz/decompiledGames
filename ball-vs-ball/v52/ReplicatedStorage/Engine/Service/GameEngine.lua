local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BattleReplayBuilder = require(ReplicatedStorage:WaitForChild("BattleDemo"):WaitForChild("BattleReplayBuilder"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BattleComputePool = require(ReplicatedStorage2:WaitForChild("Engine"):WaitForChild("Battle"):WaitForChild("BattleComputePool"))
local GameEngine = {}
GameEngine.__index = GameEngine
local v = {
	["升级"] = "basicStat",
	["技能"] = "effect"
}

local function newPlayerUpgradeState()
	return {
		basicLevels = {
			speed = 0,
			hp = 0,
			attack = 0,
			allIn = 0
		},
		secondaryTraitIds = {}
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function candidateEquals(p, p2)
	return p.kind == p2.kind and p.id == p2.id
end

local function findCandidateInOffer(list, p)
	for _, v2 in ipairs(list) do
		local v3

		if v2.kind == p.kind then
			v3 = v2.id == p.id
		else
			v3 = false
		end

		if v3 then
			return v2
		end
	end

	return nil
end

local function buildCnIdLookup(p)
	local result = {}

	for k, basicStat in p.tournament_upgrade.basicStats do
		if typeof(basicStat.cnId) == "string" then
			result[basicStat.cnId] = {
				kind = "basicStat",
				id = k
			}
		end
	end

	for k, trait in p.traits do
		if typeof(trait.cnId) == "string" then
			result[trait.cnId] = {
				kind = "effect",
				id = k
			}
		end
	end

	return result
end

local function buildUpgradeCandidatePool(config, upgradeChoiceList)
	local result = {}

	if typeof(upgradeChoiceList) ~= "table" then
		warn("[GameEngine] upgradeChoice 表为空，局内升级候选池为空")
		return result
	end

	local cnIdLookup = buildCnIdLookup(config)

	for _, v2 in ipairs(upgradeChoiceList) do
		local v3 = cnIdLookup[v2.targetCnId]

		if v3 then
			local v4 = v[v2.choiceType]

			if v4 and v4 ~= v3.kind then
				warn((`[GameEngine] upgradeChoice 表 choiceType 与实际类型不符: {tostring(v2.targetCnId)}`))
			end

			table.insert(result, {
				kind = v3.kind,
				id = v3.id,
				weight = tonumber(v2.weight) or 1
			})
		else
			warn((`[GameEngine] upgradeChoice 表找不到目标: {tostring(v2.targetCnId)}`))
		end
	end

	return result
end

local function pickWeightedWithoutReplacement(p, upgradeCandidateCount: number, random)
	local clone = table.clone(p)
	local result = {}

	for _ = 1, math.min(upgradeCandidateCount, #clone) do
		local total = 0

		for _, v2 in ipairs(clone) do
			total += math.max(0, v2.weight)
		end

		if total <= 0 then
			break
		end

		local number = random:NextNumber(0, total)
		local count = #clone
		local total2 = 0

		for i, v3 in ipairs(clone) do
			total2 += math.max(0, v3.weight)

			if not (number <= total2) then
				continue
			end

			count = i
			break
		end

		local v3 = table.remove(clone, count)
		table.insert(result, {
			kind = v3.kind,
			id = v3.id
		})
	end

	return result
end

local function hasUpgradeCandidate(p, p2)
	if p2.kind == "basicStat" then
		return (p.basicLevels[p2.id] or 0) > 0
	end

	if p2.kind == "effect" and p2.id == "AllIn" then
		return (p.basicLevels.allIn or 0) > 0
	end

	return p2.kind == "effect" and table.find(p.secondaryTraitIds, p2.id) ~= nil
end

local function filterUnownedUpgradeCandidates(upgradeCandidatePool, p)
	local result = {}

	for _, v2 in ipairs(upgradeCandidatePool) do
		if not hasUpgradeCandidate(p, v2) then
			table.insert(result, v2)
		end
	end

	return result
end

local function applyUpgradeCandidate(p, p2)
	if p2.kind == "basicStat" then
		p.basicLevels[p2.id] = (p.basicLevels[p2.id] or 0) + 1
	elseif p2.kind == "effect" then
		if p2.id == "AllIn" then
			p.basicLevels.allIn = (p.basicLevels.allIn or 0) + 1
		elseif not table.find(p.secondaryTraitIds, p2.id) then
			table.insert(p.secondaryTraitIds, p2.id)
		end
	end
end

function GameEngine.new(config, seed: number, list, data)
	assert(typeof(data) == "table", "GameEngine.new 需要 options")
	local v2

	if typeof(data.raceHp) == "number" then
		v2 = data.raceHp >= 1
	else
		v2 = false
	end

	assert(v2, "GameEngine.new 需要 options.raceHp（>=1 的整数）")
	local object = setmetatable({}, GameEngine)
	object.config = config
	object.seed = seed
	object.random = Random.new(seed)
	object.pickCandidateCount = data.pickCandidateCount or config.tournament.pickCandidateCount
	object.upgradeCandidateCount = data.upgradeCandidateCount or config.tournament.upgradeCandidateCount
	object.upgradeChoiceList = data.upgradeChoiceList
	object.round = 0
	object.raceHp = {}
	object.aliveUserIds = table.clone(list)
	object.eliminatedUserIds = {}
	object.selectedRoleId = {}
	object.lastActiveRoleId = {}
	object.roleOffers = {}
	object.playerUpgrades = {}
	object.upgradeOffers = {}
	object.upgradeSelected = {}
	object.launchDirections = {}
	object.lastLaunchDirection = {}
	object.rerollPriceRange = data.rerollPriceRange or {}
	object.selectPriceRange = data.selectPriceRange or {}
	object.ballRerollCount = {}
	object.upgradeRerollCount = {}
	object.ballSelectCount = {}
	object.ballSelectPurchased = {}
	object.upgradeSessionPool = {}
	object.ballShownRoleIds = {}
	object.ownedRoleIdsByUserId = data.ownedRoleIdsByUserId
	object.preserveParticipantOrder = data.preserveParticipantOrder == true
	object.teams = data.teams
	object.arena = data.arena

	for _, v3 in ipairs(list) do
		object.raceHp[v3] = data.raceHp
		object.roleOffers[v3] = object:_pickBallOffer(v3)
		object:_seedBallShownRoleIds(v3)
		object.playerUpgrades[v3] = newPlayerUpgradeState()
	end

	return object
end

local function buildRoleIdSet(list)
	local result = {}

	if list then
		for _, v2 in ipairs(list) do
			if typeof(v2) == "string" then
				result[v2] = true
			end
		end
	end

	return result
end

function GameEngine:_seedBallShownRoleIds(p2: number)
	self.ballShownRoleIds[p2] = buildRoleIdSet(self.roleOffers[p2])
end

function GameEngine:_pickDistinctRoles(list, p2: number, p3)
	local v2 = {}
	local v3 = {}

	for _, v4 in ipairs(list) do
		if typeof(v4) ~= "string" or (p3[v4] or v2[v4]) then
			continue
		end

		v2[v4] = true
		table.insert(v3, v4)
	end

	local result = {}

	for _ = 1, math.min(p2, #v3) do
		local integer = self.random:NextInteger(1, #v3)
		table.insert(result, table.remove(v3, integer))
	end

	return result
end

function GameEngine:_playerRolePool()
	local playerRolePool = self.config.battle.playerRolePool

	if playerRolePool and #playerRolePool > 0 then
		return playerRolePool
	end

	return self.config.battle.rolePool
end

function GameEngine:_getOwnedRoleIds(p: number)
	if self.ownedRoleIdsByUserId then
		return self.ownedRoleIdsByUserId[p] or {}
	end

	return self:_playerRolePool()
end

function GameEngine:_pickBallOffer(p: number)
	local pickCandidateCount = self.pickCandidateCount
	local _getOwnedRoleIds = self:_getOwnedRoleIds(p)
	local result = self:_pickDistinctRoles(_getOwnedRoleIds, pickCandidateCount, {})

	if #result == 0 then
		local _pickDistinctRoles = self:_pickDistinctRoles(self:_playerRolePool(), 1, {})

		if #_pickDistinctRoles == 0 then
			return result
		end

		for _ = 1, pickCandidateCount do
			table.insert(result, _pickDistinctRoles[1])
		end

		return result
	else
		while #result < pickCandidateCount do
			table.insert(result, _getOwnedRoleIds[self.random:NextInteger(1, #_getOwnedRoleIds)])
		end

		return result
	end
end

function GameEngine:_pickRerollBallOffer(p: number)
	local v2 = self.roleOffers[p] or {}
	local ballShownRoleId = self.ballShownRoleIds[p]

	if not ballShownRoleId then
		ballShownRoleId = buildRoleIdSet(v2)
		self.ballShownRoleIds[p] = ballShownRoleId
	end

	local pickCandidateCount = self.pickCandidateCount
	local _pickDistinctRoles = self:_pickDistinctRoles(self:_getOwnedRoleIds(p), pickCandidateCount, ballShownRoleId)

	if #_pickDistinctRoles == 0 then
		return v2
	end

	local clone = table.clone(v2)
	local v3 = {}

	for i = 1, #clone do
		table.insert(v3, i)
	end

	for i = #v3, 2, -1 do
		local integer = self.random:NextInteger(1, i)
		local v4 = v3[integer]
		local v5 = v3[i]
		v3[i] = v4
		v3[integer] = v5
	end

	for i, _pickDistinctRole in ipairs(_pickDistinctRoles) do
		clone[v3[i]] = _pickDistinctRole
		ballShownRoleId[_pickDistinctRole] = true
	end

	return clone
end

function GameEngine:_shuffle(p2)
	local clone = table.clone(p2)

	for i = #clone, 2, -1 do
		local integer = self.random:NextInteger(1, i)
		local v2 = clone[integer]
		local v3 = clone[i]
		clone[i] = v2
		clone[integer] = v3
	end

	return clone
end

function GameEngine:_buildPairs()
	if self.teams then
		return {
			{
				arenaIndex = 1,
				userIdA = self.teams.Blue[1],
				userIdB = self.teams.Yellow[1],
				isGhostA = false,
				isGhostB = false
			}
		}
	end

	local clone

	if self.preserveParticipantOrder then
		clone = table.clone(self.aliveUserIds)
	else
		clone = self:_shuffle(self.aliveUserIds)
	end

	if #clone % 2 == 1 then
		assert(#self.eliminatedUserIds > 0, "存活人数为奇数但没有可用的幽灵候选")
		local integer = self.random:NextInteger(1, #self.eliminatedUserIds)
		table.insert(clone, self.eliminatedUserIds[integer])
	end

	local result = {}

	for i = 1, #clone, 2 do
		local userIdA = clone[i]
		local userIdB = clone[i + 1]
		table.insert(result, {
			arenaIndex = #result + 1,
			userIdA = userIdA,
			userIdB = userIdB,
			isGhostA = table.find(self.aliveUserIds, userIdA) == nil,
			isGhostB = table.find(self.aliveUserIds, userIdB) == nil
		})
	end

	return result
end

function GameEngine.getBallOffer(p, p2: number)
	return p.roleOffers[p2]
end

function GameEngine.hasParticipant(p, p2: number)
	return p.roleOffers[p2] ~= nil
end

function GameEngine.isAlive(p, p2: number)
	return table.find(p.aliveUserIds, p2) ~= nil
end

function GameEngine.selectBall(p, p2: number, p3: string)
	if p.selectedRoleId[p2] then
		return false
	end

	local roleOffer = p.roleOffers[p2]

	if roleOffer and table.find(roleOffer, p3) then
		p.selectedRoleId[p2] = p3
		return true
	else
		return false
	end
end

function GameEngine:getBallSelectPrice(p: number)
	if self.selectedRoleId[p] or self.ballSelectPurchased[p] or (#self.selectPriceRange == 0 or #self:_getOwnedRoleIds(p) == 0) then
		return nil
	end

	local v2 = (self.ballSelectCount[p] or 0) + 1
	local v3 = self.selectPriceRange[math.min(v2, #self.selectPriceRange)]

	if typeof(v3) == "number" and not (v3 < 0) then
		return v3
	end

	return nil
end

function GameEngine:getBallSelectOffer(p: number)
	if self:getBallSelectPrice(p) == nil then
		return nil
	end

	return table.clone(self:_getOwnedRoleIds(p))
end

function GameEngine:confirmBallSelect(p: number, p2: string)
	if not (self:getBallSelectPrice(p) ~= nil and table.find(self:_getOwnedRoleIds(p), p2)) then
		return false
	end

	self.ballSelectPurchased[p] = true
	self.ballSelectCount[p] = (self.ballSelectCount[p] or 0) + 1
	self.selectedRoleId[p] = p2
	return true
end

function GameEngine:allBallsSelected()
	for _, aliveUserId in ipairs(self.aliveUserIds) do
		if not self.selectedRoleId[aliveUserId] then
			return false
		end
	end

	return true
end

function GameEngine:lockRemainingBalls()
	local result = {}

	for _, aliveUserId in ipairs(self.aliveUserIds) do
		if self.selectedRoleId[aliveUserId] then
			continue
		end

		local roleOffer = self.roleOffers[aliveUserId]
		local v2 = self.lastActiveRoleId[aliveUserId]

		if not (v2 and roleOffer and table.find(roleOffer, v2)) then
			if roleOffer and #roleOffer > 0 then
				v2 = roleOffer[self.random:NextInteger(1, #roleOffer)]
			else
				v2 = self:_playerRolePool()[1]
			end
		end

		self.selectedRoleId[aliveUserId] = v2
		result[aliveUserId] = v2
	end

	return result
end

function GameEngine.getSelectedRoleId(p, p2: number)
	return p.selectedRoleId[p2]
end

function GameEngine:getBallRerollPrice(p: number)
	if self.selectedRoleId[p] or #self.rerollPriceRange == 0 then
		return nil
	end

	local _getOwnedRoleIds = self:_getOwnedRoleIds(p)
	local v2 = self.ballShownRoleIds[p] or {}
	local v3 = false

	for _, _getOwnedRoleId in ipairs(_getOwnedRoleIds) do
		if v2[_getOwnedRoleId] then
			continue
		end

		v3 = true
		break
	end

	if not v3 then
		return nil
	end

	local v5 = (self.ballRerollCount[p] or 0) + 1
	return self.rerollPriceRange[math.min(v5, #self.rerollPriceRange)]
end

function GameEngine:rerollBall(p: number)
	if not self:getBallRerollPrice(p) then
		return nil
	end

	local _pickRerollBallOffer = self:_pickRerollBallOffer(p)
	self.roleOffers[p] = _pickRerollBallOffer
	self.ballRerollCount[p] = (self.ballRerollCount[p] or 0) + 1
	return _pickRerollBallOffer
end

function GameEngine:beginBallReselection(p: number)
	local v2 = self.selectedRoleId[p]

	if v2 then
		self.lastActiveRoleId[p] = v2
	end

	self.selectedRoleId[p] = nil
	self.ballSelectPurchased[p] = nil
	self:_seedBallShownRoleIds(p)
end

function GameEngine:beginAimingSession()
	self.launchDirections = {}
end

function GameEngine.setLaunchDirection(data, p: number, point: Vector2)
	if data.launchDirections[p] or (typeof(point) ~= "Vector2" or point.Magnitude < 1e-6) or table.find(
		data.aliveUserIds,
		p
	) == nil then
		return false
	end

	local unit = point.Unit
	data.launchDirections[p] = unit
	data.lastLaunchDirection[p] = unit
	return true
end

function GameEngine.allLaunchDirectionsSet(p)
	for _, aliveUserId in ipairs(p.aliveUserIds) do
		if not p.launchDirections[aliveUserId] then
			return false
		end
	end

	return true
end

function GameEngine.lockRemainingLaunchDirections(data)
	local vectorsByAliveUserId = {}

	for _, aliveUserId in ipairs(data.aliveUserIds) do
		if data.launchDirections[aliveUserId] then
			continue
		end

		local vector = data.lastLaunchDirection[aliveUserId]

		if not vector then
			local number = data.random:NextNumber(0, 6.283185307179586)
			vector = Vector2.new(math.cos(number), (math.sin(number)))
		end

		data.launchDirections[aliveUserId] = vector
		data.lastLaunchDirection[aliveUserId] = vector
		vectorsByAliveUserId[aliveUserId] = vector
	end

	return vectorsByAliveUserId
end

function GameEngine.getLaunchDirection(p, p2: number)
	return p.launchDirections[p2]
end

function GameEngine:runRound()
	assert(self:allBallsSelected(), "存在玩家尚未选球，不能开始回合")
	self.round += 1
	local _buildPairs = self:_buildPairs()
	local v2 = {}

	for _, _buildPair in ipairs(_buildPairs) do
		local v3 = self.selectedRoleId[_buildPair.userIdA] or self:_playerRolePool()[1]
		local v4 = self.selectedRoleId[_buildPair.userIdB] or self:_playerRolePool()[1]
		local seed = self.seed + self.round * 1009 + _buildPair.arenaIndex * 97
		local playerUpgrade = self.playerUpgrades[_buildPair.userIdA]
		local playerUpgrade2 = self.playerUpgrades[_buildPair.userIdB]
		local launchDirection = self.launchDirections[_buildPair.userIdA]
		local launchDirection2 = self.launchDirections[_buildPair.userIdB]
		local selectedRoles, initialDirections

		if self.teams then
			selectedRoles = {}
			initialDirections = {}

			for k, list in self.teams do
				local v8 = {}
				local v9 = {}

				for i, v10 in ipairs(list) do
					v8[i] = self.selectedRoleId[v10] or self:_playerRolePool()[1]
					v9[i] = self.launchDirections[v10]
				end

				selectedRoles[k] = v8
				initialDirections[k] = v9
			end
		else
			selectedRoles = {
				Blue = v3,
				Yellow = v4
			}
			initialDirections = launchDirection and launchDirection2 and {
				Blue = launchDirection,
				Yellow = launchDirection2
			} or nil
		end

		table.insert(v2, {
			pair = _buildPair,
			roleA = v3,
			roleB = v4,
			seed = seed,
			replayOptions = {
				fixedDt = self.config.replay.fixedDt,
				snapshotInterval = BattleReplayBuilder.SNAPSHOT_INTERVAL_DISABLED,
				maxDuration = self.config.replay.maxDuration,
				selectedRoles = selectedRoles,
				statLevels = {
					Blue = playerUpgrade.basicLevels,
					Yellow = playerUpgrade2.basicLevels
				},
				selectedSecondaryTraits = {
					Blue = playerUpgrade.secondaryTraitIds,
					Yellow = playerUpgrade2.secondaryTraitIds
				},
				initialDirections = initialDirections,
				arena = self.arena
			}
		})
	end

	local enableExcitementSelection = self.config.replay.enableExcitementSelection
	local candidateCount = not enableExcitementSelection and 1 or self.config.replay.candidateCount
	local v4 = {}

	for k, v5 in v2 do
		v4[k] = {
			seed = v5.seed,
			options = v5.replayOptions,
			candidateCount = candidateCount
		}
	end

	local battles = BattleComputePool.computeBattles(self.config, v4)
	local pairs = {}

	for k, v6 in v2 do
		local replay = battles and battles[k]

		if not replay then
			if enableExcitementSelection then
				replay = BattleReplayBuilder.buildBestOfN(
					self.config,
					v6.seed,
					v6.replayOptions,
					self.config.replay.candidateCount,
					self.config.replay.yieldEveryTrials
				)
			else
				replay = BattleReplayBuilder.buildReplay(self.config, v6.seed, v6.replayOptions)
			end
		end

		table.insert(pairs, {
			arenaIndex = v6.pair.arenaIndex,
			userIdA = v6.pair.userIdA,
			userIdB = v6.pair.userIdB,
			isGhostA = v6.pair.isGhostA,
			isGhostB = v6.pair.isGhostB,
			roleA = v6.roleA,
			roleB = v6.roleB,
			replay = replay,
			replayOptions = v6.replayOptions
		})
	end

	return {
		round = self.round,
		pairs = pairs
	}
end

function GameEngine.applyPairLoss(p, data)
	local winner = data.replay.winner
	local userIdB = nil

	if winner == "Blue" then
		userIdB = data.userIdB
	elseif winner == "Yellow" then
		userIdB = data.userIdA
	end

	if userIdB and p.raceHp[userIdB] ~= nil then
		p.raceHp[userIdB] = math.max(0, p.raceHp[userIdB] - 1)
	end

	return userIdB
end

function GameEngine.applyTeamPairLoss(p, p2)
	assert(p.teams ~= nil, "applyTeamPairLoss 只用于组队玩法")
	local winner = p2.replay.winner
	local v2 = winner == "Blue" and "Yellow" or winner == "Yellow" and "Blue" or nil

	if not v2 then
		return {}
	end

	local clone = table.clone(p.teams[v2])

	for _, v3 in ipairs(clone) do
		if p.raceHp[v3] ~= nil then
			p.raceHp[v3] = math.max(0, p.raceHp[v3] - 1)
		end
	end

	return clone
end

function GameEngine.getTeamOf(p, p2: number)
	if not p.teams then
		return nil
	end

	for k, list in p.teams do
		if table.find(list, p2) then
			return k
		end
	end

	return nil
end

function GameEngine:_isTeamAlive(p2: string)
	for _, v2 in ipairs(self.teams[p2]) do
		if table.find(self.aliveUserIds, v2) then
			return true
		end
	end

	return false
end

function GameEngine:getWinningTeamUserIds()
	if not (self.teams and self:isFinished()) then
		return nil
	end

	for k, team in self.teams do
		if self:_isTeamAlive(k) then
			return table.clone(team)
		end
	end

	return nil
end

function GameEngine:finalizeRoundElimination()
	local aliveUserIds = {}
	local aliveUserIds2 = {}

	for _, aliveUserId in ipairs(self.aliveUserIds) do
		if (self.raceHp[aliveUserId] or 0) <= 0 then
			table.insert(self.eliminatedUserIds, aliveUserId)
			table.insert(aliveUserIds, aliveUserId)
		else
			table.insert(aliveUserIds2, aliveUserId)
		end
	end

	self.aliveUserIds = aliveUserIds2
	return {
		stillAlive = table.clone(aliveUserIds2),
		newlyEliminated = aliveUserIds
	}
end

function GameEngine:isFinished()
	if self.teams then
		return not (self:_isTeamAlive("Blue") and self:_isTeamAlive("Yellow"))
	end

	return #self.aliveUserIds <= 1
end

function GameEngine.getChampionUserId(p)
	return p.aliveUserIds[1]
end

function GameEngine:eliminateNow(p: number)
	local index = table.find(self.aliveUserIds, p)

	if not index then
		return false
	end

	if not self.selectedRoleId[p] then
		local roleOffer = self.roleOffers[p]
		local selectedRoleId = self.selectedRoleId
		local v2

		if roleOffer and #roleOffer > 0 then
			v2 = roleOffer[self.random:NextInteger(1, #roleOffer)]
		else
			v2 = self:_playerRolePool()[1]
		end

		selectedRoleId[p] = v2
	end

	table.remove(self.aliveUserIds, index)
	self.raceHp[p] = 0
	table.insert(self.eliminatedUserIds, p)
	return true
end

function GameEngine:offerUpgrades()
	local upgradeCandidatePool = buildUpgradeCandidatePool(self.config, self.upgradeChoiceList)
	self.upgradeOffers = {}
	self.upgradeSelected = {}
	self.upgradeSessionPool = {}
	local result = {}

	for _, aliveUserId in ipairs(self.aliveUserIds) do
		self.upgradeSessionPool[aliveUserId] = filterUnownedUpgradeCandidates(
			upgradeCandidatePool,
			self.playerUpgrades[aliveUserId]
		)
		local _drawUpgradeOffer = self:_drawUpgradeOffer(aliveUserId)
		self.upgradeOffers[aliveUserId] = _drawUpgradeOffer

		if #_drawUpgradeOffer > 0 then
			result[aliveUserId] = _drawUpgradeOffer
		end
	end

	return result
end

function GameEngine:_drawUpgradeOffer(p: number)
	local v2 = self.upgradeSessionPool[p]

	if not v2 then
		return {}
	end

	local v3 = pickWeightedWithoutReplacement(v2, self.upgradeCandidateCount, self.random)

	for _, v4 in ipairs(v3) do
		for i, v6 in ipairs(v2) do
			if not candidateEquals(v6, v4) then
				continue
			end

			table.remove(v2, i)
			break
		end
	end

	return v3
end

function GameEngine.getUpgradeOffer(p, p2: number)
	return p.upgradeOffers[p2]
end

function GameEngine.selectUpgrade(p, p2: number, p3)
	if p.upgradeSelected[p2] then
		return false
	end

	local list = p.upgradeOffers[p2]
	local v2

	if list then
		for _, list2 in ipairs(list) do
			local v4

			if list2.kind == p3.kind then
				v4 = list2.id == p3.id
			else
				v4 = false
			end

			if not v4 then
				continue
			end

			v2 = list2
			break
		end
	else
		v2 = list
	end

	if not v2 then
		return false
	end

	p.upgradeSelected[p2] = v2
	return true
end

function GameEngine.allUpgradesSelected(data)
	for _, aliveUserId in ipairs(data.aliveUserIds) do
		local upgradeOffer = data.upgradeOffers[aliveUserId]

		if upgradeOffer and #upgradeOffer > 0 and not data.upgradeSelected[aliveUserId] then
			return false
		end
	end

	return true
end

function GameEngine:getUpgradeRerollPrice(p: number)
	if self.upgradeSelected[p] or #self.rerollPriceRange == 0 then
		return nil
	end

	local v2 = self.upgradeSessionPool[p]

	if not v2 or #v2 < self.upgradeCandidateCount then
		return nil
	end

	local v3 = (self.upgradeRerollCount[p] or 0) + 1
	return self.rerollPriceRange[math.min(v3, #self.rerollPriceRange)]
end

function GameEngine:rerollUpgrade(p: number)
	if not self:getUpgradeRerollPrice(p) then
		return nil
	end

	local _drawUpgradeOffer = self:_drawUpgradeOffer(p)
	self.upgradeOffers[p] = _drawUpgradeOffer
	self.upgradeRerollCount[p] = (self.upgradeRerollCount[p] or 0) + 1
	return _drawUpgradeOffer
end

function GameEngine:finalizeUpgrades()
	local result = {}

	for _, aliveUserId in ipairs(self.aliveUserIds) do
		if self.upgradeSelected[aliveUserId] then
			continue
		end

		local upgradeOffer = self.upgradeOffers[aliveUserId]

		if not (upgradeOffer and #upgradeOffer > 0) then
			continue
		end

		local v2 = upgradeOffer[self.random:NextInteger(1, #upgradeOffer)]
		self.upgradeSelected[aliveUserId] = v2
		result[aliveUserId] = v2
	end

	for _, aliveUserId in ipairs(self.aliveUserIds) do
		local v2 = self.upgradeSelected[aliveUserId]

		if v2 then
			applyUpgradeCandidate(self.playerUpgrades[aliveUserId], v2)
		end
	end

	self.upgradeOffers = {}
	self.upgradeSelected = {}
	return result
end

function GameEngine.getPlayerUpgradeState(p, p2: number)
	return p.playerUpgrades[p2]
end

function GameEngine.getState(data)
	local raceHp = {}

	for k, v3 in data.raceHp do
		raceHp[k] = v3
	end

	local playerUpgrades = {}

	for k, playerUpgrade in data.playerUpgrades do
		playerUpgrades[k] = {
			basicLevels = table.clone(playerUpgrade.basicLevels),
			secondaryTraitIds = table.clone(playerUpgrade.secondaryTraitIds)
		}
	end

	return {
		round = data.round,
		aliveUserIds = table.clone(data.aliveUserIds),
		eliminatedUserIds = table.clone(data.eliminatedUserIds),
		raceHp = raceHp,
		selectedRoleId = table.clone(data.selectedRoleId),
		playerUpgrades = playerUpgrades
	}
end

return GameEngine