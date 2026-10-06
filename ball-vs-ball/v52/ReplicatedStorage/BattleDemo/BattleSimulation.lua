local BattleSkills = require(script.Parent:WaitForChild("BattleSkills"))
local HookGrappleSolver = require(script.Parent:WaitForChild("HookGrappleSolver"))
local DamageResolution = require(script.Parent:WaitForChild("DamageResolution"))
local GeometryProvider = require(script.Parent:WaitForChild("GeometryProvider"))
local OrbitRingGeometry = require(script.Parent:WaitForChild("OrbitRingGeometry"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local geometry = nil

local function resolveGeometry()
	if geometry == nil then
		geometry = GeometryProvider.new(ReplicatedStorage)
	end

	return geometry
end

local v2 = {}
local BattleSimulation = {}
BattleSimulation.__index = BattleSimulation

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeOrFallback(point: Vector2, point2: Vector2)
	if point.Magnitude < 0.001 then
		return point2
	end

	return point.Unit
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shallowCopy(skill)
	return table.clone(skill)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hpRatio(p)
	if p.maxHp > 0 then
		return p.hp / p.maxHp
	end

	return 0
end

local function clonePolygonPoints(list)
	local result = table.create(#list)

	for k, v3 in list do
		result[k] = v3
	end

	return result
end

local function pointOnSegment(point: Vector2, point2: Vector2, point3: Vector2)
	local vector = point3 - point2
	local vector2 = point - point2

	if math.abs(vector.X * vector2.Y - vector.Y * vector2.X) > 0.0001 then
		return false
	end

	local dot = vector2:Dot(vector)
	return not (dot < -0.0001) and not (vector:Dot(vector) + 0.0001 < dot)
end

local function polygonArea(list)
	local total = 0

	for k, v3 in list do
		local v4 = list[k % #list + 1]
		total += v3.X * v4.Y - v4.X * v3.Y
	end

	return math.abs(total) * 0.5
end

local function pointInPolygon(point: Vector2, list, flag: boolean)
	if #list < 3 then
		return false
	end

	local v3 = false

	for k, v4 in list do
		local v5 = list[k % #list + 1]

		if pointOnSegment(point, v4, v5) then
			return flag
		end

		if v4.Y > point.Y == (v5.Y > point.Y) then
			continue
		end

		local v6 = v5.Y - v4.Y

		if not (math.abs(v6) > 1e-6 and v4.X + (v5.X - v4.X) * ((point.Y - v4.Y) / v6) > point.X) then
			continue
		end

		v3 = not v3
	end

	return v3
end

local function reversePath(list)
	local result = table.create(#list)

	for i = #list, 1, -1 do
		table.insert(result, list[i])
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wallKeyToPerimeterPosition(point: Vector2, p: string, p2: number, p3: number)
	local v3 = p2 * 2
	local v4 = p3 * 2

	if p == "North" then
		return point.X + p2
	elseif p == "East" then
		return v3 + (point.Y + p3)
	elseif p == "South" then
		return v3 + v4 + (p2 - point.X)
	end

	return v3 + v4 + v3 + (p3 - point.Y)
end

local function appendClockwiseBoundaryCorners(points, p: number, total: number, p2: number, p3: number)
	local v3 = p2 * 2
	local v4 = p3 * 2
	local v5 = v3 * 2 + v4 * 2
	local v6 = {
		{
			s = 0,
			point = Vector2.new(-p2, -p3)
		},
		{
			s = v3,
			point = Vector2.new(p2, -p3)
		},
		{
			s = v3 + v4,
			point = Vector2.new(p2, p3)
		},
		{
			s = v3 + v4 + v3,
			point = Vector2.new(-p2, p3)
		}
	}

	if total < p then
		total += v5
	end

	for _, v7 in ipairs(v6) do
		local s = v7.s

		if s <= p then
			s += v5
		end

		if p + 0.0001 < s and s < total - 0.0001 then
			table.insert(points, v7.point)
		end
	end
end

local function buildClockwiseBoundaryPath(point: Vector2, p: string, point2: Vector2, p2: string, p3: number, p4: number)
	local v3 = { point }
	local v4 = wallKeyToPerimeterPosition(point, p, p3, p4) -- equivalent call inferred; original call site unknown
	local v5 = wallKeyToPerimeterPosition(point2, p2, p3, p4) -- equivalent call inferred; original call site unknown
	appendClockwiseBoundaryCorners(v3, v4, v5, p3, p4)
	table.insert(v3, point2)
	return v3
end

local function areOppositeWalls(p: string, p2: string)
	if p == "North" and p2 == "South" or p == "South" and p2 == "North" or p == "East" and p2 == "West" then
		return true
	elseif p == "West" then
		return p2 == "East"
	else
		return false
	end
end

local function buildOppositeWallPolygons(point: Vector2, p: string, point2: Vector2, p2: string, p3: number, p4: number)
	if p == "North" and p2 == "South" or p == "South" and p2 == "North" then
		local v3 = p == "North" and point or point2
		local v4 = p == "South" and point or point2
		local v5 = {
			v4,
			Vector2.new(-p3, p4),
			Vector2.new(-p3, -p4),
			v3
		}
		local v6 = {
			v3,
			Vector2.new(p3, -p4),
			Vector2.new(p3, p4),
			v4
		}

		if p ~= "North" then
			return v5, v6
		end

		local result = table.create(#v5)

		for i = #v5, 1, -1 do
			table.insert(result, v5[i])
		end

		local result2 = table.create(#v6)

		for i = #v6, 1, -1 do
			table.insert(result2, v6[i])
		end

		return result, result2
	else
		local v3 = p == "West" and point or point2
		local v4 = p == "East" and point or point2
		local v5 = {
			v3,
			Vector2.new(-p3, -p4),
			Vector2.new(p3, -p4),
			v4
		}
		local v6 = {
			v4,
			Vector2.new(p3, p4),
			Vector2.new(-p3, p4),
			v3
		}

		if p ~= "East" then
			return v5, v6
		end

		local result = table.create(#v5)

		for i = #v5, 1, -1 do
			table.insert(result, v5[i])
		end

		local result2 = table.create(#v6)

		for i = #v6, 1, -1 do
			table.insert(result2, v6[i])
		end

		return result, result2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isVampireAttached(p)
	return p.vampireStateRemaining > 0 and typeof(p.vampireAttachedTargetId) == "string"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isVampireVictim(p)
	return typeof(p.vampireVictimSourceId) == "string"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isRouteLocked(p)
	local chessPath = p.traits.ChessPath

	if chessPath and chessPath.isActive then
		return true
	end

	local onePunch = p.traits.OnePunch

	if onePunch and onePunch.phase == "Dash" then
		return true
	end

	return false
end

function BattleSimulation.isRouteLocked(_, p)
	local chessPath = p.traits.ChessPath

	if chessPath and chessPath.isActive then
		return true
	end

	local onePunch = p.traits.OnePunch

	if onePunch and onePunch.phase == "Dash" then
		return true
	end

	return false
end

local function isGrabImmune(p)
	local onePunch = p.traits.OnePunch
	return onePunch ~= nil and onePunch.phase == "Dash"
end

function BattleSimulation.isGrabImmune(_, p)
	local onePunch = p.traits.OnePunch
	return onePunch ~= nil and onePunch.phase == "Dash"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isBladeTraitId(p: string)
	return p == "Passive" or p == "PassiveSword" or p == "PassiveAxe"
end

local function wallKeyToNormal(p: string)
	if p == "East" then
		return Vector2.new(-1, 0)
	elseif p == "West" then
		return Vector2.new(1, 0)
	elseif p == "South" then
		return Vector2.new(0, -1)
	end

	return Vector2.new(0, 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function touchKeyForSpike(id: string, spikeId: number)
	return string.format("%s:%d", id, spikeId)
end

local function buildBladePositions(object, p, p2: string, p3)
	local result = {}
	local trait = p.traits[p2]

	if not trait then
		return result
	end

	if p2 == "Passive" then
		if trait.bladeCount <= 0 then
			return result
		end

		for i = 1, trait.bladeCount do
			local v3 = trait.bladeRotation + (i - 1) / trait.bladeCount * 6.283185307179586
			local v4 = Vector2.new(math.cos(v3), (math.sin(v3))) * p3.orbitRadius
			result[i] = p.position + v4
		end
	elseif p2 == "PassiveSword" or p2 == "PassiveAxe" then
		local vector = Vector2.new(math.cos(trait.bladeRotation), (math.sin(trait.bladeRotation)))
		local _getEffectCollisionLength = object:_getEffectCollisionLength(p2 == "PassiveAxe" and object.config.visual.axeTemplateName or object.config.visual.swordTemplateName)
		result[1] = p.position + vector * _getEffectCollisionLength
	end

	return result
end

function BattleSimulation.setDefaultGeometry(p)
	geometry = p
end

function BattleSimulation.new(config, seed: number, options, options2, options3, options4)
	local self = setmetatable({}, BattleSimulation)
	self.config = config
	self.seed = seed
	self.selectedRoles = options or {}
	self.selectedSecondaryTraits = options2 or {}
	self.statLevels = options3 or {}
	self.initialDirections = options4 or {}
	self.random = Random.new(seed)

	if geometry == nil then
		geometry = GeometryProvider.new(ReplicatedStorage)
	end

	self._geometry = geometry
	self.state = {
		elapsed = 0,
		finished = false,
		winner = nil,
		balls = {},
		teams = {
			Blue = {},
			Yellow = {}
		},
		cellSplitCounts = {
			Blue = 1,
			Yellow = 1
		}
	}
	self.nextEntityId = {
		Blue = 1,
		Yellow = 1
	}
	self.multiEntityMode = false
	self:_resetBalls()
	return self
end

function BattleSimulation:_randomDirection()
	local number = self.random:NextNumber(0, 6.283185307179586)
	return Vector2.new(math.cos(number), (math.sin(number)))
end

function BattleSimulation:_resolveInitialDirection(p: string, value: number?)
	local initialDirection = self.initialDirections[p]

	if typeof(initialDirection) == "table" then
		initialDirection = initialDirection[value or 1]
	end

	if typeof(initialDirection) == "Vector2" and initialDirection.Magnitude > 1e-6 then
		return initialDirection.Unit
	end

	return self:_randomDirection()
end

function BattleSimulation:_isSelectableRoleId(value: string?)
	return typeof(value) == "string" and table.find(self.config.battle.rolePool, value) ~= nil and self.config.roles[value] ~= nil
end

function BattleSimulation:_resolveSelectedRoleId(p: string)
	local selectedRole = self.selectedRoles[p]

	if self:_isSelectableRoleId(selectedRole) then
		return selectedRole
	end

	return nil
end

function BattleSimulation:_pickRoleId(p2: string?)
	local rolePool = self.config.battle.rolePool

	if self.config.battle.allowMirrorMatch or not p2 then
		return rolePool[self.random:NextInteger(1, #rolePool)]
	end

	local v3 = {}

	for _, v4 in rolePool do
		if v4 ~= p2 then
			table.insert(v3, v4)
		end
	end

	return v3[self.random:NextInteger(1, #v3)]
end

function BattleSimulation:_selectRoundRoles()
	local _resolveSelectedRoleId = self:_resolveSelectedRoleId("Blue")
	local _resolveSelectedRoleId2 = self:_resolveSelectedRoleId("Yellow")

	if _resolveSelectedRoleId or _resolveSelectedRoleId2 then
		if _resolveSelectedRoleId then
			if not _resolveSelectedRoleId2 then
				local _ = self.config.battle.allowMirrorMatch
				_resolveSelectedRoleId2 = self:_pickRoleId(_resolveSelectedRoleId)
			end
		else
			local _ = self.config.battle.allowMirrorMatch
			_resolveSelectedRoleId = self:_pickRoleId(_resolveSelectedRoleId2)
		end
	else
		_resolveSelectedRoleId = self:_pickRoleId(nil)
		_resolveSelectedRoleId2 = self:_pickRoleId(_resolveSelectedRoleId)
	end

	return {
		Blue = self.config.roles[_resolveSelectedRoleId],
		Yellow = self.config.roles[_resolveSelectedRoleId2]
	}
end

function BattleSimulation:_buildBallState(data, data2, options, options2)
	local _randomDirection = self:_randomDirection()
	local vector = Vector2.new(1, 0)

	if not (_randomDirection.Magnitude < 0.001) then
		vector = _randomDirection.Unit
	end

	local skill = shallowCopy(data2.skill) -- equivalent call inferred; original call site unknown
	local v5 = options2 or {}
	local basicStats = self.config.tournament_upgrade.basicStats
	local v6 = data2.maxHp * (1 + basicStats.hp.amount * (v5.hp or 0))
	local attack = data2.attack * (1 + basicStats.attack.amount * (v5.attack or 0))
	local v8 = data2.speed * (1 + basicStats.speed.amount * (v5.speed or 0))
	local allIn = v5.allIn or 0

	if allIn > 0 then
		local allIn2 = self.config.traits.AllIn
		v6 *= math.max(0, 1 - allIn2.maxHpPenalty * allIn)
		attack *= 1 + allIn2.attackBonus * allIn
		v8 *= 1 + allIn2.speedBonus * allIn
	end

	local radius = data2.radius or self:_getBallRadius(data2.templateName)
	local v9 = {
		id = data.id,
		team = data.id,
		spawnProtectedUntil = 0,
		slotDisplayName = data.displayName,
		roleId = data2.roleId,
		displayName = data2.displayName,
		color = data2.color,
		highlightColor = data2.highlightColor,
		position = data.spawnPosition,
		direction = vector,
		radius = radius,
		baseRadius = radius,
		maxHp = v6,
		hp = v6,
		attack = attack,
		baseSpeed = v8,
		currentSpeed = v8,
		gravityVelocity = Vector2.zero,
		collisionCooldown = 0,
		nextHitBonusReady = false,
		speedBoostTimeRemaining = 0,
		speedBoostCooldown = 0,
		bonusSpeedMultiplier = 1,
		knockbackRemaining = 0,
		knockbackPeakBonus = 0,
		explosionImpulseDirection = Vector2.zero,
		explosionImpulsePeakSpeed = 0,
		explosionImpulseRemaining = 0,
		explosionImpulseDuration = 0,
		chargeMultiplier = skill.baseMultiplier or 1,
		chargeTimer = 0,
		skill = skill,
		traits = {},
		secondaryTraitIds = options or {},
		speedBoostTraitId = nil,
		activeDamageReduction = 0,
		attackBuffActive = false,
		defenseBuffActive = false,
		vampireStateRemaining = 0,
		vampireTickCooldown = skill.tickInterval or 0,
		vampireTicksApplied = 0,
		vampireAttachedTargetId = nil,
		vampireAttachOffsetDirection = nil,
		vampireVictimSourceId = nil,
		vampireReattachCooldownRemaining = 0,
		spiderWebs = {},
		spiderWebTouchingByTarget = {},
		spiderWebTickProgressByTarget = {},
		vampireWebs = {},
		vampireWebTouchingByTarget = {},
		vampireWebTickProgressByTarget = {},
		poisonSpikes = {},
		poisonSpikeTouching = {},
		poisonWallLastSpawnPositions = {},
		nextPoisonSpikeId = 1,
		poisonRemaining = 0,
		poisonTickCooldown = skill.poisonTickInterval or 0,
		poisonedByBallId = nil,
		poisonedByTraitId = nil,
		hiveVenomStacks = {},
		acidPoisonStacks = {},
		burnRemaining = 0,
		burnTickCooldown = 0,
		burnedByBallId = nil,
		burnedByTraitId = nil,
		burnFlameContactRemaining = 0,
		burnFlameSlowTraitId = nil,
		slowRemaining = 0,
		slowedByTraitId = nil,
		hasteRemaining = 0,
		hastenedByTraitId = nil,
		electromagneticParalysisProgress = 0,
		frostLevel = 0,
		frostTickCooldown = 0,
		potionFrostLevel = 0,
		potionFrostTickCooldown = 0,
		healReductionRemaining = 0,
		healReductionByTraitId = nil,
		zonePreviewAnchorPosition = nil,
		zonePreviewWallKey = nil,
		zoneRegions = {},
		nextZoneRegionId = 1,
		laserAnchorPosition = nil,
		laserAnchorWallKey = nil,
		laserSegments = {},
		laserTouchingByTarget = {},
		hookCapturedByBallId = nil,
		harpoonCapturedByBallId = nil,
		voltaicShockSourceBallId = nil,
		voltaicShockAnchorPosition = nil,
		voltaicShockRemaining = 0,
		voltaicShockTickCooldown = 0,
		voltaicShockTicksApplied = 0
	}
	local _activeTraitIds = self:_activeTraitIds(v9)

	for _, _activeTraitId in _activeTraitIds do
		if isBladeTraitId(_activeTraitId) then
			v9.traits[_activeTraitId] = {
				bladeCount = 0,
				bladeGrowthCooldown = 1e999,
				bladeRotation = self.random:NextNumber(0, 6.283185307179586),
				bladePositions = {},
				bladeHitCooldowns = {}
			}
		end
	end

	for _, _activeTraitId in _activeTraitIds do
		local _behaviorForTrait = self:_behaviorForTrait(_activeTraitId)

		if _behaviorForTrait.initialize then
			_behaviorForTrait.initialize(self, v9, _activeTraitId)
		end
	end

	for _, _activeTraitId in _activeTraitIds do
		local trait = v9.traits[_activeTraitId]

		if trait and (_activeTraitId == "Passive" or _activeTraitId == "PassiveSword" or _activeTraitId == "PassiveAxe") then
			trait.bladePositions = buildBladePositions(self, v9, _activeTraitId, self.config.traits[_activeTraitId])
		end
	end

	self:_refreshSnakeTail(v9)
	return v9
end

function BattleSimulation:_spawnEntity(team: string, p, point: Vector2, point2: Vector2, flag: boolean)
	local v3 = self.nextEntityId[team]
	self.nextEntityId[team] += 1
	local id = v3 == 1 and team or string.format("%s#%d", team, v3)
	local _buildBallState = self:_buildBallState({
		id = id,
		displayName = team,
		spawnPosition = point
	}, p, self.selectedSecondaryTraits[team], self.statLevels[team])
	_buildBallState.team = team
	local direction = _buildBallState.direction

	if not (point2.Magnitude < 0.001) then
		direction = point2.Unit
	end

	_buildBallState.direction = direction
	_buildBallState.spawnProtectedUntil = not flag and 0 or self.state.elapsed + (_buildBallState.skill.spawnProtectionDuration or 0.2) or 0
	self.state.balls[id] = _buildBallState
	table.insert(self.state.teams[team], id)
	return _buildBallState
end

function BattleSimulation:_spawn(p: string, p2, point: Vector2, point2: Vector2, flag: boolean)
	return self:_spawnEntity(p, p2, point, point2, flag)
end

function BattleSimulation:_removeEntity(p2)
	self.state.balls[p2.id] = nil
	local team = self.state.teams[p2.team]

	for k, v3 in team do
		if v3 ~= p2.id then
			continue
		end

		table.remove(team, k)
		break
	end
end

function BattleSimulation:_resolveEntityDeath(data, p, list)
	if self.state.balls[data.id] ~= data or data.hp > 0 then
		return
	end

	local v3 = data.vampireAttachedTargetId and self:_ballById(data.vampireAttachedTargetId)

	if v3 then
		self:_clearVampireVictimState(v3)
	end

	for _, ball in self.state.balls do
		if ball.hookCapturedByBallId == data.id then
			ball.hookCapturedByBallId = nil
			table.insert(list, {
				type = "hook_capture_end",
				ballId = ball.id,
				otherBallId = data.id,
				sourceBallId = data.id,
				targetBallId = ball.id,
				position = ball.position
			})
		end

		if ball.harpoonCapturedByBallId ~= data.id then
			continue
		end

		ball.harpoonCapturedByBallId = nil
		table.insert(list, {
			type = "harpoon_capture_end",
			ballId = ball.id,
			otherBallId = data.id,
			sourceBallId = data.id,
			targetBallId = ball.id,
			position = ball.position
		})
	end

	local deathSplit = data.traits.DeathSplit
	local splitCount = data.skill.splitCount or 3

	if deathSplit and deathSplit.grown and self.state.cellSplitCounts[data.team] + splitCount <= (data.skill.maxTotalSplitCount or 20) then
		local cellSplitCounts = self.state.cellSplitCounts
		local team = data.team
		cellSplitCounts[team] += splitCount
		local direction

		if p then
			local v4 = data.position - p.position
			direction = data.direction

			if not (v4.Magnitude < 0.001) then
				direction = v4.Unit
			end

			if not direction then
				direction = data.direction
			end
		else
			direction = data.direction
		end

		local role = self.config.roles[data.roleId]
		self:_removeEntity(data)

		for i = 1, splitCount do
			local v4 = math.atan2(direction.Y, direction.X) + (i - 2) * 6.283185307179586 / splitCount
			local vector = Vector2.new(math.cos(v4), (math.sin(v4)))
			local _spawnEntity = self:_spawnEntity(
				data.team,
				role,
				data.position + vector * (data.baseRadius * 2.1),
				vector,
				true
			)
			table.insert(list, {
				type = "cell_split_child",
				ballId = _spawnEntity.id,
				sourceBallId = data.id,
				position = _spawnEntity.position
			})
		end

		table.insert(list, {
			type = "cell_split",
			ballId = data.id,
			sourceBallId = p and p.id,
			position = data.position,
			count = splitCount
		})
	else
		self:_removeEntity(data)
		table.insert(list, {
			type = "ball_death",
			ballId = data.id,
			sourceBallId = p and p.id,
			position = data.position
		})
	end
end

function BattleSimulation:_damage(state, p, p2: number, list)
	if self.state.elapsed < (state.spawnProtectedUntil or 0) then
		return false
	end

	local _applyIncomingDamage = self:_applyIncomingDamage(state, p2, p)

	if _applyIncomingDamage <= 0 then
		return false
	end

	state.hp = math.max(0, state.hp - _applyIncomingDamage)

	if not p then
		self:_notifyDamageTaken(state, nil, _applyIncomingDamage, list)
	end

	table.insert(list, {
		type = "ball_hit",
		ballId = state.id,
		otherBallId = p and p.id,
		sourceBallId = p and p.id,
		targetBallId = state.id,
		position = state.position,
		damage = _applyIncomingDamage,
		speedSum = (not p and 0 or p.currentSpeed or 0) + (state.currentSpeed or 0)
	})

	if p then
		self:_onDamageDealt(p, state, _applyIncomingDamage, list)
	end

	self:_resolveEntityDeath(state, p, list)
	return true
end

function BattleSimulation:_teamRosterRaw(p2: string)
	local selectedRole = self.selectedRoles[p2]

	if typeof(selectedRole) == "table" and #selectedRole > 1 then
		return selectedRole
	end

	return nil
end

function BattleSimulation:_isTeamRosterMode()
	return self:_teamRosterRaw("Blue") ~= nil or self:_teamRosterRaw("Yellow") ~= nil
end

function BattleSimulation:_resolveTeamRoleIds(p: string)
	local v3 = self:_teamRosterRaw(p) or { self.selectedRoles[p] }
	local result = {}

	for _, v4 in ipairs(v3) do
		if self:_isSelectableRoleId(v4) then
			table.insert(result, v4)
		end
	end

	if #result == 0 then
		table.insert(result, self:_pickRoleId(nil))
	end

	return result
end

function BattleSimulation:_spawnTeamRoster(p: string, list)
	local spawnPositionCorners = self.config.slots[p].spawnPositionCorners

	for i, v3 in ipairs(list) do
		self:_spawnEntity(
			p,
			self.config.roles[v3],
			spawnPositionCorners and spawnPositionCorners[(i - 1) % #spawnPositionCorners + 1] or self.config.slots[p].spawnPosition,
			self:_resolveInitialDirection(p, i),
			false
		)
	end
end

function BattleSimulation:_resetBalls()
	self.state.elapsed = 0
	self.state.finished = false
	self.state.winner = nil
	self.state.balls = {}
	self.state.teams = {
		Blue = {},
		Yellow = {}
	}
	self.state.cellSplitCounts = {
		Blue = 1,
		Yellow = 1
	}
	self.nextEntityId = {
		Blue = 1,
		Yellow = 1
	}

	if self:_isTeamRosterMode() then
		self.multiEntityMode = true
		self:_spawnTeamRoster("Blue", self:_resolveTeamRoleIds("Blue"))
		self:_spawnTeamRoster("Yellow", self:_resolveTeamRoleIds("Yellow"))
	else
		local _selectRoundRoles = self:_selectRoundRoles()
		self.multiEntityMode = _selectRoundRoles.Blue.skill.trigger == "DeathSplit" or _selectRoundRoles.Yellow.skill.trigger == "DeathSplit"
		self:_spawnEntity(
			"Blue",
			_selectRoundRoles.Blue,
			self.config.slots.Blue.spawnPosition,
			self:_resolveInitialDirection("Blue"),
			false
		)
		self:_spawnEntity(
			"Yellow",
			_selectRoundRoles.Yellow,
			self.config.slots.Yellow.spawnPosition,
			self:_resolveInitialDirection("Yellow"),
			false
		)
	end

	self:_refreshAllBuffIndicators()
end

function BattleSimulation:reset(seed: number?)
	if seed ~= nil then
		self.seed = seed
		self.random = Random.new(seed)
	end

	self:_resetBalls()
end

function BattleSimulation.getState(p)
	return p.state
end

function BattleSimulation:_behaviorForTrait(p: string)
	return BattleSkills[p] or v2
end

function BattleSimulation:_behaviorFor(p)
	return self:_behaviorForTrait(p.skill.trigger)
end

function BattleSimulation:_activeTraitIds(p)
	local secondaryTraitIds = { p.skill.trigger }

	for _, secondaryTraitId in p.secondaryTraitIds do
		table.insert(secondaryTraitIds, secondaryTraitId)
	end

	return secondaryTraitIds
end

function BattleSimulation:_getBallRadius(p2: string)
	local ballCollisionBox = self._geometry:getBallCollisionBox(p2)
	assert(
		math.abs(ballCollisionBox.Size.X - ballCollisionBox.Size.Z) <= 0.001,
		string.format("小球素材 '%s' 的碰撞箱必须是水平正方形", p2)
	)
	return ballCollisionBox.Size.X * 0.5
end

function BattleSimulation:_getEffectCollisionRadius(p2: string)
	local size = self._geometry:getEffectCollisionBox(p2).Size
	return math.max(size.X, size.Z) * 0.5
end

function BattleSimulation:_getEffectCollisionThickness(p2: string)
	return self._geometry:getEffectCollisionBox(p2).Size.X
end

function BattleSimulation:_getEffectCollisionLength(p2: string)
	return self._geometry:getEffectCollisionBox(p2).Size.Z
end

function BattleSimulation:_createGlassShard(data, p: string, point: Vector2?, p2: string?, list)
	local trait = data.traits[p]

	if not trait then
		return
	end

	local trait2 = self.config.traits[p]
	local _getEffectCollisionRadius = self:_getEffectCollisionRadius(self.config.visual.glassShardTemplateName)
	local position

	if point and p2 then
		position = point + (p2 == "X" and Vector2.new(point.X < 0 and 1 or -1, 0) or Vector2.new(
			0,
			point.Y < 0 and 1 or -1
		)) * (_getEffectCollisionRadius + (trait2.wallInwardOffset or 0))
	else
		position = data.position + self:_randomDirection() * (data.radius + _getEffectCollisionRadius)
	end

	local randomAngleRange = trait2.randomAngleRange or 360
	local v4 = {
		shardId = trait.nextShardId,
		position = position,
		rotationX = self.random:NextNumber(0, randomAngleRange),
		rotationY = self.random:NextNumber(0, randomAngleRange)
	}
	trait.nextShardId += 1
	table.insert(trait.shards, v4)

	while #trait.shards > math.max(1, trait2.maxShardCount or 1) do
		table.remove(trait.shards, 1)
	end

	table.insert(list, {
		type = "glass_shard_created",
		ballId = data.id,
		position = position,
		shardId = v4.shardId
	})
end

function BattleSimulation._rebuildBladePositions(p, p2, p3: string)
	return (buildBladePositions(p, p2, p3, p.config.traits[p3]))
end

function BattleSimulation:_rebuildOrbitPositions(p2, p3: string)
	local trait = p2.traits[p3]

	if not (trait and trait.slots) then
		return
	end

	local trait2 = self.config.traits[p3]
	local v3 = {}

	for _, slot in trait.slots do
		if slot.occupied then
			v3[slot.ring] = (v3[slot.ring] or 0) + 1
		end
	end

	local v4 = {}

	for _, slot in trait.slots do
		if not slot.occupied then
			continue
		end

		local ring = slot.ring
		local v5 = v4[ring] or 0
		v4[ring] = v5 + 1
		local v6 = (not trait.ringRotations and 0 or trait.ringRotations[ring] or 0) + v5 / v3[ring] * 6.283185307179586
		slot.rotationAngle = v6 % 6.283185307179586
		local radiusForRing = OrbitRingGeometry.radiusForRing(trait2, ring)
		slot.position = p2.position + Vector2.new(math.cos(v6), (math.sin(v6))) * radiusForRing
	end
end

function BattleSimulation._isVampireAttached(_, p)
	return isVampireAttached(p)
end

function BattleSimulation._initHookGrapple(p, p2, p3: string)
	p2.traits[p3] = {
		rotationAngle = p.random:NextNumber(0, 6.283185307179586),
		appliedRotationAngle = nil,
		ropePositions = nil,
		capturedTargetId = nil,
		captureElapsed = 0,
		captureCooldownRemaining = 0,
		wallDamageCooldownRemaining = 0,
		capturedWallKeys = {}
	}
end

function BattleSimulation:_releaseHookCapture(p, state, p2, p3, list)
	p2.capturedTargetId = nil
	p2.captureElapsed = 0
	p2.captureCooldownRemaining = p3.captureCooldown or 0
	p2.capturedWallKeys = {}
	state.hookCapturedByBallId = nil
	table.insert(list, {
		type = "hook_capture_end",
		ballId = state.id,
		otherBallId = p.id,
		sourceBallId = p.id,
		targetBallId = state.id,
		position = state.position
	})
end

function BattleSimulation:_updateHookGrapple(state, _, p: number, list, p2: string)
	local trait = self.config.traits[p2]
	local trait2 = state.traits[p2]

	if not trait2 then
		return
	end

	if not trait2.capturedTargetId then
		trait2.captureCooldownRemaining = math.max(0, (trait2.captureCooldownRemaining or 0) - p)
	end

	local v3

	if trait2.capturedTargetId then
		v3 = trait.captureCircleDuration or 0.6
	else
		v3 = trait.idleCircleDuration or 3
	end

	local v4 = 6.283185307179586 / math.max(v3, 1e-6)
	trait2.rotationAngle = (trait2.rotationAngle - v4 * p) % 6.283185307179586
	local hookChainRestLengths = self._geometry:getHookChainRestLengths()
	local v5 = self.config.arena.size * 0.5

	if trait2.capturedTargetId then
		HookGrappleSolver.solveExtended(trait2, state.position, hookChainRestLengths, v5)
	else
		HookGrappleSolver.solve(trait2, state.position, hookChainRestLengths, v5)
	end

	if not trait2.capturedTargetId then
		return
	end

	local _ballById = self:_ballById(trait2.capturedTargetId)

	if _ballById and _ballById.hookCapturedByBallId == state.id then
		state.bonusSpeedMultiplier *= trait.moveSpeedMultiplier or 1
		local ropePosition = trait2.ropePositions[#trait2.ropePositions]
		trait2.captureElapsed = (trait2.captureElapsed or 0) + p
		_ballById.position = ropePosition
		self:_handleHookCapturedTargetWallHits(_ballById, trait2, ropePosition, list)
		trait2.wallDamageCooldownRemaining = math.max(0, (trait2.wallDamageCooldownRemaining or 0) - p)

		if trait2.wallDamageCooldownRemaining <= 0 then
			local v6 = self.config.arena.size * 0.5

			if math.abs(ropePosition.X) >= v6.X - 0.001 or math.abs(ropePosition.Y) >= v6.Y - 0.001 then
				if _ballById.team ~= state.team then
					local _applyDamageModifiers = self:_applyDamageModifiers(state, _ballById, trait.wallDamage or 0)

					if _applyDamageModifiers > 0 then
						_ballById.hp = math.max(0, _ballById.hp - _applyDamageModifiers)
						table.insert(list, {
							type = "hook_wall_hit",
							ballId = _ballById.id,
							otherBallId = state.id,
							sourceBallId = state.id,
							targetBallId = _ballById.id,
							position = ropePosition,
							damage = _applyDamageModifiers
						})
						self:_onDamageDealt(state, _ballById, _applyDamageModifiers, list)
					end
				end

				trait2.wallDamageCooldownRemaining = trait.wallDamageCooldown or 0.15
			end
		end

		if trait2.captureElapsed >= (trait.captureDuration or 3) then
			self:_releaseHookCapture(state, _ballById, trait2, trait, list)
		end
	else
		trait2.capturedTargetId = nil
		trait2.captureElapsed = 0
	end
end

function BattleSimulation:_handleHookGrappleCapture(data, state, list, p: string)
	local trait = data.traits[p]

	if not trait or trait.capturedTargetId or (trait.captureCooldownRemaining or 0) > 0 or data.hookCapturedByBallId then
		return
	end

	if state.hookCapturedByBallId then
		return
	end

	local onePunch = state.traits.OnePunch
	local v3

	if onePunch == nil then
		v3 = false
	else
		v3 = onePunch.phase == "Dash"
	end

	if v3 then
		return
	end

	local ropePositions = trait.ropePositions
	local position = ropePositions and ropePositions[#ropePositions]

	if not position or state.radius + self:_getEffectCollisionRadius(self.config.visual.hookTemplateName) < (state.position - position).Magnitude then
		return
	end

	trait.capturedTargetId = state.id
	trait.captureElapsed = 0
	trait.capturedWallKeys = {}
	state.hookCapturedByBallId = data.id
	table.insert(list, {
		type = "hook_capture_start",
		ballId = state.id,
		otherBallId = data.id,
		sourceBallId = data.id,
		targetBallId = state.id,
		position = position
	})
end

function BattleSimulation:_handleFriendlyHookGrappleCapture(p, p2, p3)
	if table.find(self:_activeTraitIds(p), "HookGrapple") then
		self:_handleHookGrappleCapture(p, p2, p3, "HookGrapple")
	end

	if table.find(self:_activeTraitIds(p2), "HookGrapple") then
		self:_handleHookGrappleCapture(p2, p, p3, "HookGrapple")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshWebEndpoints(items, position: Vector2)
	for _, item in items do
		item.startPosition = item.anchorPosition or item.startPosition
		item.endPosition = position
	end
end

function BattleSimulation:_refreshSpiderWebEndpoints(data)
	refreshWebEndpoints(data.spiderWebs, data.position) -- equivalent call inferred; original call site unknown
	refreshWebEndpoints(data.vampireWebs, data.position) -- equivalent call inferred; original call site unknown
end

function BattleSimulation:_ballById(value: string?)
	if typeof(value) == "string" then
		return self.state.balls[value]
	end

	return nil
end

function BattleSimulation:_isVoltaicShockControlled(p)
	return p.voltaicShockSourceBallId ~= nil and p.voltaicShockRemaining > 0
end

function BattleSimulation:_clearVoltaicShock(state, list)
	if state.voltaicShockSourceBallId then
		table.insert(list, {
			type = "voltaic_shock_end",
			ballId = state.id,
			sourceBallId = state.voltaicShockSourceBallId,
			targetBallId = state.id,
			position = state.position
		})
	end

	state.voltaicShockSourceBallId = nil
	state.voltaicShockAnchorPosition = nil
	state.voltaicShockRemaining = 0
	state.voltaicShockTickCooldown = 0
	state.voltaicShockTicksApplied = 0
end

function BattleSimulation:_applyVoltaicShock(p, state, p2: string, list)
	if state.hp <= 0 or self:_isVoltaicShockControlled(state) or state.hookCapturedByBallId or isVampireVictim(state) then
		return false
	end

	local trait = self.config.traits[p2]
	local shockTickInterval = trait.shockTickInterval or 0.5
	state.voltaicShockSourceBallId = p.id
	state.voltaicShockAnchorPosition = state.position
	state.voltaicShockRemaining = trait.shockDuration or 0
	state.voltaicShockTickCooldown = shockTickInterval
	state.voltaicShockTicksApplied = 0
	table.insert(list, {
		type = "voltaic_shock_start",
		ballId = state.id,
		otherBallId = p.id,
		sourceBallId = p.id,
		targetBallId = state.id,
		position = state.position
	})
	local v3

	if state.vampireStateRemaining > 0 then
		v3 = typeof(state.vampireAttachedTargetId) == "string"
	else
		v3 = false
	end

	if v3 then
		self:_finishVampireAttach(state, self:_ballById(state.vampireAttachedTargetId))
	end

	return true
end

function BattleSimulation:_updateVoltaicShockTarget(state, p: number, list)
	if not self:_isVoltaicShockControlled(state) then
		return
	end

	local _ballById = self:_ballById(state.voltaicShockSourceBallId)
	local voltaicShock = _ballById and _ballById.traits.VoltaicShock and self.config.traits.VoltaicShock

	if not (_ballById and voltaicShock) then
		self:_clearVoltaicShock(state, list)
		return
	end

	state.voltaicShockRemaining = math.max(0, state.voltaicShockRemaining - p)
	state.voltaicShockTickCooldown -= p
	local v3 = math.max(
		1,
		(math.round((voltaicShock.shockDuration or 0) / math.max(voltaicShock.shockTickInterval or 0.5, 1e-6)))
	)

	while state.voltaicShockTicksApplied < v3 and state.voltaicShockTickCooldown <= 0 and state.voltaicShockRemaining >= 0 do
		state.voltaicShockTickCooldown += voltaicShock.shockTickInterval or 0.5
		state.voltaicShockTicksApplied += 1
		local _applyIncomingDamage = self:_applyIncomingDamage(state, voltaicShock.shockDamagePerTick or 0, _ballById)

		if _applyIncomingDamage > 0 then
			state.hp = math.max(0, state.hp - _applyIncomingDamage)
			self:_onDamageDealt(_ballById, state, _applyIncomingDamage, list)
		end

		table.insert(list, {
			type = "voltaic_shock_tick",
			ballId = state.id,
			otherBallId = _ballById.id,
			sourceBallId = _ballById.id,
			targetBallId = state.id,
			position = state.position,
			damage = _applyIncomingDamage
		})

		if not (state.hp <= 0) then
			continue
		end

		self:_clearVoltaicShock(state, list)

		if self.multiEntityMode then
			self:_resolveEntityDeath(state, _ballById, list)
		end

		return
	end

	if state.voltaicShockRemaining <= 0 or v3 <= state.voltaicShockTicksApplied then
		self:_clearVoltaicShock(state, list)
	end
end

function BattleSimulation:_clearZonePreview(p)
	p.zonePreviewAnchorPosition = nil
	p.zonePreviewWallKey = nil
end

function BattleSimulation:_handleLaserWallHit(state, p, list, p2: string)
	for _, v3 in list do
		if v3 == p then
			break
		end

		if v3.type == "wall_hit" and v3.ballId == state.id then
			return
		end
	end

	local position = p.position
	local _wallKeyFromEvent = self:_wallKeyFromEvent(p)

	if position == nil or _wallKeyFromEvent == nil or math.max(
		0,
		(math.round(self.config.traits[p2].maxLaserCount or 64))
	) <= #state.laserSegments then
		return
	end

	if state.laserAnchorPosition == nil then
		state.laserAnchorPosition = position
		state.laserAnchorWallKey = _wallKeyFromEvent
	else
		local laserIndex = #state.laserSegments + 1
		state.laserSegments[laserIndex] = {
			startPosition = state.laserAnchorPosition,
			endPosition = position
		}
		state.laserAnchorPosition = nil
		state.laserAnchorWallKey = nil
		table.insert(list, {
			type = "laser_created",
			ballId = state.id,
			startPosition = state.laserSegments[laserIndex].startPosition,
			endPosition = position,
			laserIndex = laserIndex
		})
	end
end

function BattleSimulation:_clearZoneEffects(p)
	self:_clearZonePreview(p)
	p.zoneRegions = {}
end

function BattleSimulation:_wallKeyFromEvent(p)
	if not (p.position and p.axis) then
		return nil
	end

	if p.axis == "X" then
		if p.position.X >= 0 then
			return "East"
		end

		return "West"
	else
		if p.axis ~= "Y" then
			return nil
		end

		if p.position.Y >= 0 then
			return "South"
		end

		return "North"
	end
end

function BattleSimulation:_setZonePreview(p, p2)
	local _wallKeyFromEvent = self:_wallKeyFromEvent(p2)

	if not p2.position or _wallKeyFromEvent == nil then
		return
	end

	p.zonePreviewAnchorPosition = p2.position
	p.zonePreviewWallKey = _wallKeyFromEvent
end

function BattleSimulation:_buildZonePolygon(point: Vector2, p2: string, point2: Vector2, p3: string)
	if p2 == p3 then
		return nil, 0
	end

	local v3 = self.config.arena.size.X * 0.5
	local v4 = self.config.arena.size.Y * 0.5
	local v5

	if p2 == "North" and p3 == "South" or p2 == "South" and p3 == "North" or p2 == "East" and p3 == "West" then
		v5 = true
	elseif p2 == "West" then
		v5 = p3 == "East"
	else
		v5 = false
	end

	local v6, result

	if v5 then
		v6, result = buildOppositeWallPolygons(point, p2, point2, p3, v3, v4)
	else
		v6 = buildClockwiseBoundaryPath(point, p2, point2, p3, v3, v4)
		local clockwiseBoundaryPath = buildClockwiseBoundaryPath(point2, p3, point, p2, v3, v4)
		result = table.create(#clockwiseBoundaryPath)

		for i = #clockwiseBoundaryPath, 1, -1 do
			table.insert(result, clockwiseBoundaryPath[i])
		end
	end

	if #v6 < 3 or #result < 3 then
		return nil, 0
	end

	local v7 = polygonArea(v6)
	local v8 = polygonArea(result)

	if math.abs(v7 - v8) <= 0.0001 then
		local v9 = pointInPolygon(Vector2.zero, v6, false)
		local v10 = pointInPolygon(Vector2.zero, result, false)

		if v9 and not v10 then
			return result, v8
		end

		if v10 and not v9 or v7 > 0.0001 then
			return v6, v7
		end
	end

	if v7 <= v8 then
		return v6, v7
	end

	return result, v8
end

function BattleSimulation:_zoneMinAreaThreshold(_, p2: string)
	local size = self.config.arena.size
	local zoneMinAreaRatio = self.config.traits[p2].zoneMinAreaRatio or 0
	return size.X * size.Y * zoneMinAreaRatio
end

function BattleSimulation:_createZoneRegion(state, point: Vector2, point2: Vector2, list, p2: string)
	local nextZoneRegionId = state.nextZoneRegionId
	state.nextZoneRegionId += 1
	local zoneRegions = state.zoneRegions
	local polygon = table.create(#list)
	local v4 = {
		regionId = nextZoneRegionId,
		startPosition = point,
		endPosition = point2,
		polygon = 0,
		remainingLifetime = 0,
		tickProgressByEntityId = 0,
		insideEntityIds = 0
	}

	for k, v5 in list do
		polygon[k] = v5
	end

	v4.polygon = polygon
	v4.remainingLifetime = self.config.traits[p2].zoneDuration or 0
	v4.tickProgressByEntityId = {}
	v4.insideEntityIds = {}
	table.insert(zoneRegions, v4)
end

function BattleSimulation:_tryCreateZoneRegion(p, p2, _, p3: string)
	local zonePreviewAnchorPosition = p.zonePreviewAnchorPosition
	local zonePreviewWallKey = p.zonePreviewWallKey
	local position = p2.position
	local _wallKeyFromEvent = self:_wallKeyFromEvent(p2)

	if zonePreviewAnchorPosition == nil or zonePreviewWallKey == nil or position == nil or _wallKeyFromEvent == nil then
		return false
	end

	local _buildZonePolygon, v3 = self:_buildZonePolygon(
		zonePreviewAnchorPosition,
		zonePreviewWallKey,
		position,
		_wallKeyFromEvent
	)
	local _zoneMinAreaThreshold = self:_zoneMinAreaThreshold(p, p3)
	self:_clearZonePreview(p)

	if _buildZonePolygon == nil or v3 < _zoneMinAreaThreshold then
		return false
	end

	self:_createZoneRegion(p, zonePreviewAnchorPosition, position, _buildZonePolygon, p3)
	return true
end

function BattleSimulation:_updateZoneRegions(data, p: number, list, p2: string)
	local trait = self.config.traits[p2]
	local zoneTickInterval = trait.zoneTickInterval or 1
	local balls = {}

	for _, ball in self.state.balls do
		if ball.team ~= data.team and ball.hp > 0 then
			table.insert(balls, ball)
		end
	end

	for i = #data.zoneRegions, 1, -1 do
		local zoneRegion = data.zoneRegions[i]
		zoneRegion.remainingLifetime = math.max(0, zoneRegion.remainingLifetime - p)

		if zoneRegion.remainingLifetime <= 0 then
			table.remove(data.zoneRegions, i)
		else
			for _, v3 in balls do
				if pointInPolygon(v3.position, zoneRegion.polygon, true) then
					if not zoneRegion.insideEntityIds[v3.id] then
						local _applyIncomingDamage = self:_applyIncomingDamage(
							v3,
							math.round(trait.zoneDamagePerTick or 0),
							data
						)

						if _applyIncomingDamage > 0 then
							v3.hp = math.max(0, v3.hp - _applyIncomingDamage)
							self:_notifyDamageTaken(v3, data, _applyIncomingDamage, list)
							table.insert(list, {
								type = "zone_tick",
								ballId = v3.id,
								otherBallId = data.id,
								sourceBallId = data.id,
								targetBallId = v3.id,
								position = v3.position,
								damage = _applyIncomingDamage
							})
						end
					end

					local v4 = (zoneRegion.tickProgressByEntityId[v3.id] or 0) + p

					while zoneTickInterval <= v4 do
						v4 -= zoneTickInterval
						local _applyIncomingDamage = self:_applyIncomingDamage(
							v3,
							math.round(trait.zoneDamagePerTick or 0),
							data
						)

						if not (_applyIncomingDamage > 0) then
							continue
						end

						v3.hp = math.max(0, v3.hp - _applyIncomingDamage)
						self:_notifyDamageTaken(v3, data, _applyIncomingDamage, list)
						table.insert(list, {
							type = "zone_tick",
							ballId = v3.id,
							otherBallId = data.id,
							sourceBallId = data.id,
							targetBallId = v3.id,
							position = v3.position,
							damage = _applyIncomingDamage
						})
					end

					zoneRegion.tickProgressByEntityId[v3.id] = v4
					zoneRegion.insideEntityIds[v3.id] = true
				else
					zoneRegion.tickProgressByEntityId[v3.id] = nil
					zoneRegion.insideEntityIds[v3.id] = nil
				end
			end
		end
	end
end

function BattleSimulation:_buildPoisonSpikeState(p, wallKey: string, point: Vector2, ownerTraitId: string)
	local width, depth

	if ownerTraitId == "BigSpikeWall" then
		width, depth = self._geometry:getBigSpikeFootprint()
	else
		width, depth = self._geometry:getPoisonSpikeFootprint()
	end

	local normal = wallKeyToNormal(wallKey)
	local vector = Vector2.new(-normal.Y, normal.X)
	local centerPosition = point + normal * (depth * 0.5)
	local v7 = math.abs(vector.X) * (width * 0.5) + math.abs(normal.X) * (depth * 0.5)
	local v8 = math.abs(vector.Y) * (width * 0.5) + math.abs(normal.Y) * (depth * 0.5)
	return {
		spikeId = p.nextPoisonSpikeId,
		ownerBallId = p.id,
		ownerTraitId = ownerTraitId,
		wallKey = wallKey,
		wallPosition = point,
		centerPosition = centerPosition,
		normal = normal,
		tangent = vector,
		width = width,
		depth = depth,
		minX = centerPosition.X - v7,
		maxX = centerPosition.X + v7,
		minY = centerPosition.Y - v8,
		maxY = centerPosition.Y + v8,
		protectedUntil = self.state.elapsed + (self.config.traits[ownerTraitId].spawnGraceDuration or 0)
	}
end

function BattleSimulation:_createPoisonSpikeFromWallHit(state, p, wallEntries, p2: string)
	if not p.position then
		return
	end

	local _wallKeyFromEvent = self:_wallKeyFromEvent(p)

	if _wallKeyFromEvent == nil then
		return
	end

	local trait = self.config.traits[p2]
	local minWallSpawnSpacing = trait.minWallSpawnSpacing or 0
	local poisonWallLastSpawnPosition = state.poisonWallLastSpawnPositions[_wallKeyFromEvent]

	if poisonWallLastSpawnPosition and (p.position - poisonWallLastSpawnPosition).Magnitude < minWallSpawnSpacing then
		return
	end

	local _buildPoisonSpikeState = self:_buildPoisonSpikeState(state, _wallKeyFromEvent, p.position, p2)
	state.nextPoisonSpikeId += 1
	table.insert(state.poisonSpikes, _buildPoisonSpikeState)
	state.poisonWallLastSpawnPositions[_wallKeyFromEvent] = p.position
	local v3 = math.max(1, trait.maxSpikeCount or 1)

	while v3 < #state.poisonSpikes do
		table.remove(state.poisonSpikes, 1)
	end

	table.insert(wallEntries, {
		type = "poison_spike_created",
		ballId = state.id,
		position = p.position,
		wallKey = _wallKeyFromEvent,
		spikeId = _buildPoisonSpikeState.spikeId
	})
end

function BattleSimulation:_applyPoison(p, p2, poisonedByTraitId: string)
	if DamageResolution.isFriendlyFire(p2, p) then
		return
	end

	local trait = self.config.traits[poisonedByTraitId]
	local poisonDuration = trait.poisonDuration or 0

	for _, v3 in self:_activeTraitIds(p) do
		local _behaviorForTrait = self:_behaviorForTrait(v3)

		if _behaviorForTrait.modifyPoisonDuration then
			poisonDuration = _behaviorForTrait.modifyPoisonDuration(self, p, poisonDuration, v3)
		end
	end

	p.poisonRemaining = poisonDuration
	p.poisonTickCooldown = trait.poisonTickInterval or 0.5
	p.poisonedByBallId = p2.id
	p.poisonedByTraitId = poisonedByTraitId
end

function BattleSimulation:_applySlow(p, slowedByTraitId: string, p2)
	if p2 and DamageResolution.isFriendlyFire(p2, p) then
		return
	end

	local slowDuration = self.config.traits[slowedByTraitId].slowDuration or 0

	for _, v3 in self:_activeTraitIds(p) do
		local _behaviorForTrait = self:_behaviorForTrait(v3)

		if _behaviorForTrait.modifySlowDuration then
			slowDuration = _behaviorForTrait.modifySlowDuration(self, p, slowDuration, v3)
		end
	end

	p.slowRemaining = slowDuration
	p.slowedByTraitId = slowedByTraitId

	if slowedByTraitId == "ElectromagneticParalysis" then
		p.electromagneticParalysisProgress = 0
	end
end

function BattleSimulation._applyHaste(p, p2, hastenedByTraitId: string)
	p2.hasteRemaining = p.config.traits[hastenedByTraitId].hasteDuration or 0
	p2.hastenedByTraitId = hastenedByTraitId
end

function BattleSimulation._applyHealReduction(p, p2, healReductionByTraitId: string, p3)
	if p3 and DamageResolution.isFriendlyFire(p3, p2) then
		return
	end

	p2.healReductionRemaining = p.config.traits[healReductionByTraitId].healReductionDuration or 0
	p2.healReductionByTraitId = healReductionByTraitId
end

function BattleSimulation:_healMultiplier(p2)
	if p2.healReductionRemaining > 0 and p2.healReductionByTraitId then
		return 1 - (self.config.traits[p2.healReductionByTraitId].healReduction or 0)
	end

	return 1
end

function BattleSimulation:_notifyDamageTaken(p, p2, p3: number, p4)
	DamageResolution.notifyDamageTaken(self, p, p2, p3, p4, function(p5)
		return self:_behaviorForTrait(p5)
	end, function(p5)
		return self:_activeTraitIds(p5)
	end)
end

function BattleSimulation:_onDamageDealt(p, p2, p3: number, p4)
	DamageResolution.onDamageDealt(self, p, p2, p3, p4, function(p5)
		return self:_behaviorForTrait(p5)
	end, function(p5)
		return self:_activeTraitIds(p5)
	end)
end

function BattleSimulation:_updatePoison(state, p: number, list)
	if not (state.poisonRemaining <= 0) and typeof(state.poisonedByBallId) == "string" then
		state.poisonRemaining = math.max(0, state.poisonRemaining - p)
		state.poisonTickCooldown -= p

		while state.poisonRemaining > 0 and state.poisonTickCooldown <= 0 do
			local _ballById = self:_ballById(state.poisonedByBallId)
			local v3 = state.poisonedByTraitId and self.config.traits[state.poisonedByTraitId]
			local v4 = not v3 and 0.5 or v3.poisonTickInterval or 0.5
			state.poisonTickCooldown += v4

			if not (_ballById and v3) then
				continue
			end

			local _applyDamageModifiers = self:_applyDamageModifiers(
				_ballById,
				state,
				(math.round(v3.poisonTickDamage or 0))
			)

			if not (_applyDamageModifiers > 0) then
				continue
			end

			state.hp = math.max(0, state.hp - _applyDamageModifiers)
			self:_notifyDamageTaken(state, _ballById, _applyDamageModifiers, list)
			table.insert(list, {
				type = "poison_tick",
				ballId = state.id,
				otherBallId = _ballById.id,
				sourceBallId = _ballById.id,
				targetBallId = state.id,
				position = state.position,
				damage = _applyDamageModifiers
			})
		end
	end

	if state.poisonRemaining <= 0 then
		state.poisonRemaining = 0
		state.poisonedByBallId = nil
		state.poisonedByTraitId = nil
	end
end

function BattleSimulation:_updateHiveVenomStacks(state, p: number, list)
	local hiveVenomStacks = state.hiveVenomStacks

	if not hiveVenomStacks or #hiveVenomStacks == 0 then
		return
	end

	for i = #hiveVenomStacks, 1, -1 do
		local hiveVenomStack = hiveVenomStacks[i]
		hiveVenomStack.tickCooldown -= p

		if not (hiveVenomStack.tickCooldown <= 0) then
			continue
		end

		hiveVenomStack.tickCooldown += hiveVenomStack.tickInterval
		local _ballById = self:_ballById(hiveVenomStack.sourceBallId)

		if _ballById then
			local _applyDamageModifiers = self:_applyDamageModifiers(_ballById, state, hiveVenomStack.damage)

			if _applyDamageModifiers > 0 then
				state.hp = math.max(0, state.hp - _applyDamageModifiers)
				self:_notifyDamageTaken(state, _ballById, _applyDamageModifiers, list)

				if self.multiEntityMode then
					self:_resolveEntityDeath(state, _ballById, list)
				end

				table.insert(list, {
					type = "hive_venom_tick",
					ballId = state.id,
					otherBallId = _ballById.id,
					sourceBallId = _ballById.id,
					targetBallId = state.id,
					position = state.position,
					damage = _applyDamageModifiers,
					stackId = hiveVenomStack.stackId
				})
			end
		end

		hiveVenomStack.ticksRemaining -= 1

		if hiveVenomStack.ticksRemaining <= 0 then
			table.remove(hiveVenomStacks, i)
		end
	end
end

function BattleSimulation:_updateAcidPoisonStacks(state, p: number, list)
	local acidPoisonStacks = state.acidPoisonStacks

	if not acidPoisonStacks or #acidPoisonStacks == 0 then
		return
	end

	for i = #acidPoisonStacks, 1, -1 do
		local acidPoisonStack = acidPoisonStacks[i]
		acidPoisonStack.slowElapsed = math.min(acidPoisonStack.slowDuration, acidPoisonStack.slowElapsed + p)
		acidPoisonStack.tickCooldown -= p

		if not (acidPoisonStack.tickCooldown <= 0) then
			continue
		end

		acidPoisonStack.tickCooldown += acidPoisonStack.tickInterval
		local _ballById = self:_ballById(acidPoisonStack.sourceBallId)

		if _ballById then
			local _applyDamageModifiers = self:_applyDamageModifiers(_ballById, state, acidPoisonStack.damage)

			if _applyDamageModifiers > 0 then
				state.hp = math.max(0, state.hp - _applyDamageModifiers)
				self:_notifyDamageTaken(state, _ballById, _applyDamageModifiers, list)

				if self.multiEntityMode then
					self:_resolveEntityDeath(state, _ballById, list)
				end

				table.insert(list, {
					type = "acid_poison_tick",
					ballId = state.id,
					otherBallId = _ballById.id,
					sourceBallId = _ballById.id,
					targetBallId = state.id,
					position = state.position,
					damage = _applyDamageModifiers,
					stackId = acidPoisonStack.stackId
				})
			end
		end

		acidPoisonStack.ticksRemaining -= 1

		if acidPoisonStack.ticksRemaining <= 0 then
			table.remove(acidPoisonStacks, i)
		end
	end
end

function BattleSimulation:_applyBurn(p, p2, p3: string)
	if DamageResolution.isFriendlyFire(p2, p) then
		return
	end

	local trait = self.config.traits[p3]
	local burnDuration = trait.burnDuration or 0

	for _, v3 in self:_activeTraitIds(p) do
		local _behaviorForTrait = self:_behaviorForTrait(v3)

		if _behaviorForTrait.modifyBurnDuration then
			burnDuration = _behaviorForTrait.modifyBurnDuration(self, p, burnDuration, v3)
		end
	end

	if burnDuration > 0 then
		if p.burnRemaining <= 0 then
			p.burnTickCooldown = trait.burnTickInterval or 0.5
		end

		p.burnRemaining = math.max(p.burnRemaining, burnDuration)
		p.burnedByBallId = p2.id
		p.burnedByTraitId = p3
	end

	p.burnFlameContactRemaining = 2 * (self.config.replay and self.config.replay.fixedDt or 0.016666666666666666)
	p.burnFlameSlowTraitId = p3
end

function BattleSimulation:_updateBurn(state, p: number, list)
	if state.burnRemaining <= 0 then
		state.burnRemaining = 0
		state.burnedByBallId = nil
		state.burnedByTraitId = nil
	else
		state.burnRemaining = math.max(0, state.burnRemaining - p)
		state.burnTickCooldown -= p

		while state.burnRemaining > 0 and state.burnTickCooldown <= 0 and state.hp > 0 do
			local _ballById = self:_ballById(state.burnedByBallId)
			local v3 = state.burnedByTraitId and self.config.traits[state.burnedByTraitId]
			local v4 = not v3 and 0.5 or v3.burnTickInterval or 0.5
			state.burnTickCooldown += math.max(v4, 1e-6)

			if not (_ballById and v3) then
				continue
			end

			local _applyDamageModifiers = self:_applyDamageModifiers(
				_ballById,
				state,
				(math.round(v3.burnTickDamage or 0))
			)

			if not (_applyDamageModifiers > 0) then
				continue
			end

			state.hp = math.max(0, state.hp - _applyDamageModifiers)
			self:_notifyDamageTaken(state, _ballById, _applyDamageModifiers, list)
			table.insert(list, {
				type = "volcano_burn_tick",
				ballId = state.id,
				otherBallId = _ballById.id,
				sourceBallId = _ballById.id,
				targetBallId = state.id,
				position = state.position,
				damage = _applyDamageModifiers
			})

			if self.multiEntityMode then
				self:_resolveEntityDeath(state, _ballById, list)
			end
		end

		if state.burnRemaining <= 0 then
			state.burnRemaining = 0
			state.burnedByBallId = nil
			state.burnedByTraitId = nil
		end
	end
end

function BattleSimulation:_resolvePoisonSpikeOverlap(p, data)
	local v3 = math.clamp(p.position.X, data.minX, data.maxX)
	local v4 = math.clamp(p.position.Y, data.minY, data.maxY)
	local vector = Vector2.new(v3, v4)
	local vector2 = p.position - vector
	local dot = vector2:Dot(vector2)

	if p.radius * p.radius < dot then
		return nil
	end

	if dot > 1e-6 then
		local v5 = math.sqrt(dot)
		return {
			normal = vector2 / v5,
			penetration = math.max(0, p.radius - v5) + 0.01,
			contactPoint = vector
		}
	end

	local v5 = math.abs(p.position.X - data.minX)
	local v6 = math.abs(data.maxX - p.position.X)
	local v7 = math.abs(p.position.Y - data.minY)
	local v8 = math.abs(data.maxY - p.position.Y)
	local vector3 = Vector2.new(-1, 0)
	local vector4 = Vector2.new(data.minX, p.position.Y)

	if v6 < v5 then
		vector3 = Vector2.new(1, 0)
		vector4 = Vector2.new(data.maxX, p.position.Y)
	else
		v6 = v5
	end

	if v7 < v6 then
		vector3 = Vector2.new(0, -1)
		vector4 = Vector2.new(p.position.X, data.minY)
		v6 = v7
	end

	if v8 < v6 then
		vector3 = Vector2.new(0, 1)
		vector4 = Vector2.new(p.position.X, data.maxY)
		v6 = v8
	end

	return {
		normal = vector3,
		penetration = p.radius + v6 + 0.01,
		contactPoint = vector4
	}
end

function BattleSimulation:_handleDiceCollisions(list)
	local v3 = {}

	for k in self.state.balls do
		table.insert(v3, k)
	end

	local function fn(p)
		return self:_behaviorForTrait(p)
	end

	local function fn2(p)
		return self:_activeTraitIds(p)
	end

	for _, v4 in v3 do
		local ball = self.state.balls[v4]

		if not ball or ball.hp <= 0 then
			continue
		end

		for _, ball2 in self.state.balls do
			if ball2.team == ball.team then
				continue
			end

			local diceBarrage = ball2.traits.DiceBarrage
			local diceBarrage2 = self.config.traits.DiceBarrage

			if not (diceBarrage and diceBarrage2) then
				continue
			end

			for _, v6 in diceBarrage.dice do
				local v7 = (ball.position - v6.position).Magnitude <= ball.radius + (diceBarrage2.diceHitRadius or 0)
				local v8 = v6.touchingByTarget[ball.id] == true
				v6.touchingByTarget[ball.id] = v7

				if not v7 or v8 then
					continue
				end

				local topValue = v6.topValue
				local resolved = DamageResolution.resolve(self, ball2, ball, topValue, fn, fn2, list, {
					applyOutgoingBonus = false,
					eventType = nil
				})
				local integer = self.random:NextInteger(1, 6)
				v6.topValue = integer
				table.insert(list, {
					type = "dice_hit",
					ballId = ball.id,
					otherBallId = ball2.id,
					sourceBallId = ball2.id,
					targetBallId = ball.id,
					diceId = v6.diceId,
					position = v6.position,
					damage = resolved,
					previousTopValue = topValue,
					nextTopValue = integer
				})

				if not (self.multiEntityMode and resolved > 0) then
					continue
				end

				self:_resolveEntityDeath(ball, ball2, list)

				if self.state.balls[ball.id] ~= ball then
					break
				end
			end

			if self.state.balls[ball.id] ~= ball then
				break
			end
		end
	end
end

function BattleSimulation:_handlePoisonSpikeCollisions(state, list)
	local poisonSpikeTouching = state.poisonSpikeTouching
	local poisonSpikeTouching2 = {}
	local v4 = {}

	for _ = 1, 3 do
		local v5 = false

		for _, ball in self.state.balls do
			if ball.team == state.team then
				continue
			end

			for _, poisonSpike in ball.poisonSpikes do
				local _resolvePoisonSpikeOverlap = self:_resolvePoisonSpikeOverlap(state, poisonSpike)

				if not _resolvePoisonSpikeOverlap then
					continue
				end

				state.position += _resolvePoisonSpikeOverlap.normal * _resolvePoisonSpikeOverlap.penetration
				local v6 = state.direction - _resolvePoisonSpikeOverlap.normal * (2 * state.direction:Dot(_resolvePoisonSpikeOverlap.normal))
				local normal = _resolvePoisonSpikeOverlap.normal

				if not (v6.Magnitude < 0.001) then
					normal = v6.Unit
				end

				state.direction = normal
				v5 = true
				local v7 = touchKeyForSpike(ball.id, poisonSpike.spikeId) -- equivalent call inferred; original call site unknown

				if not (self.state.elapsed + 1e-6 >= poisonSpike.protectedUntil) then
					continue
				end

				poisonSpikeTouching2[v7] = true

				if poisonSpikeTouching[v7] ~= true then
					table.insert(v4, {
						ownerBall = ball,
						spike = poisonSpike,
						contactPoint = _resolvePoisonSpikeOverlap.contactPoint
					})
				end
			end
		end

		if not v5 then
			break
		end
	end

	state.poisonSpikeTouching = poisonSpikeTouching2
	local v5 = v4[1]

	if not v5 then
		return
	end

	local spikeContactDamage = math.round(self.config.traits[v5.spike.ownerTraitId].spikeContactDamage or 0)
	local _applyDamageModifiers = self:_applyDamageModifiers(v5.ownerBall, state, spikeContactDamage)

	if _applyDamageModifiers > 0 then
		state.hp = math.max(0, state.hp - _applyDamageModifiers)
		table.insert(list, {
			type = "poison_spike_hit",
			ballId = state.id,
			otherBallId = v5.ownerBall.id,
			sourceBallId = v5.ownerBall.id,
			targetBallId = state.id,
			position = v5.contactPoint,
			damage = _applyDamageModifiers,
			spikeId = v5.spike.spikeId
		})
		self:_onDamageDealt(v5.ownerBall, state, _applyDamageModifiers, list)
	end

	self:_applyPoison(state, v5.ownerBall, v5.spike.ownerTraitId)
end

function BattleSimulation:_createWallWeb(p, p2: string, p3: string, point: Vector2, point2: Vector2, list)
	local v3 = p[p2]
	local webIndex = #v3 + 1
	v3[webIndex] = {
		anchorPosition = point,
		startPosition = point,
		endPosition = point2
	}
	table.insert(list, {
		type = p3,
		ballId = p.id,
		position = point,
		startPosition = point,
		endPosition = point2,
		webIndex = webIndex
	})
	return webIndex
end

function BattleSimulation:_createSpiderWeb(p, point: Vector2, point2: Vector2, p2)
	return self:_createWallWeb(p, "spiderWebs", "spider_web_created", point, point2, p2)
end

function BattleSimulation:_onCollisionResolved(p, p2, p3)
	for _, v3 in self:_activeTraitIds(p) do
		local _behaviorForTrait = self:_behaviorForTrait(v3)

		if _behaviorForTrait.onCollisionResolved then
			_behaviorForTrait.onCollisionResolved(self, p, p2, p3, v3)
		end
	end
end

function BattleSimulation:_clearVampireVictimState(p)
	p.vampireVictimSourceId = nil
end

function BattleSimulation:_syncVampireAttachment(state, p)
	local vampireAttachOffsetDirection = state.vampireAttachOffsetDirection

	if vampireAttachOffsetDirection == nil then
		local v3 = state.position - p.position
		vampireAttachOffsetDirection = Vector2.new(1, 0)

		if not (v3.Magnitude < 0.001) then
			vampireAttachOffsetDirection = v3.Unit
		end

		state.vampireAttachOffsetDirection = vampireAttachOffsetDirection
	end

	local attachPadding = state.skill.attachPadding or 0
	local v3 = math.max(0.05, state.radius + p.radius + attachPadding)
	state.position = p.position + vampireAttachOffsetDirection * v3
end

function BattleSimulation:_finishVampireAttach(state, p)
	local vampireAttachOffsetDirection = state.vampireAttachOffsetDirection

	if not vampireAttachOffsetDirection then
		local direction = state.direction
		vampireAttachOffsetDirection = Vector2.new(1, 0)

		if not (direction.Magnitude < 0.001) then
			vampireAttachOffsetDirection = direction.Unit
		end
	end

	local vector = Vector2.new(1, 0)

	if not (vampireAttachOffsetDirection.Magnitude < 0.001) then
		vector = vampireAttachOffsetDirection.Unit
	end

	state.direction = vector
	state.vampireStateRemaining = 0
	state.vampireTickCooldown = state.skill.tickInterval or 0
	state.vampireTicksApplied = 0
	state.vampireAttachedTargetId = nil
	state.vampireAttachOffsetDirection = nil
	state.collisionCooldown = math.max(state.collisionCooldown, self.config.battle.contactCooldown)
	state.vampireReattachCooldownRemaining = state.skill.reattachCooldown or 0

	if p then
		p.collisionCooldown = math.max(p.collisionCooldown, self.config.battle.contactCooldown)
		self:_clearVampireVictimState(p)
	end
end

function BattleSimulation:_startVampireAttach(state, state2, list)
	state.vampireStateRemaining = state.skill.duration or 0
	state.vampireTickCooldown = state.skill.tickInterval or 1
	state.vampireTicksApplied = 0
	state.vampireAttachedTargetId = state2.id
	local v3 = state.position - state2.position
	local unit = -state2.direction

	if not (v3.Magnitude < 0.001) then
		unit = v3.Unit
	end

	state.vampireAttachOffsetDirection = unit
	state2.vampireVictimSourceId = state.id
	state.collisionCooldown = self.config.battle.contactCooldown
	state2.collisionCooldown = self.config.battle.contactCooldown
	self:_syncVampireAttachment(state, state2)
	table.insert(list, {
		type = "vampire_attach",
		ballId = state.id,
		otherBallId = state2.id,
		position = (state.position + state2.position) * 0.5
	})
end

function BattleSimulation:_updateVampireAttach(state, state2, p: number, list)
	local v3

	if state.vampireStateRemaining > 0 then
		v3 = typeof(state.vampireAttachedTargetId) == "string"
	else
		v3 = false
	end

	if not v3 then
		return
	end

	state.vampireStateRemaining = math.max(0, state.vampireStateRemaining - p)
	state.vampireTickCooldown -= p
	local tickInterval = state.skill.tickInterval or 1
	local v4 = math.max(1, (math.round((state.skill.duration or 0) / tickInterval)))
	local v5

	if state2.hp <= 0 then
		v5 = true
	else
		v5 = false
	end

	while not v5 and state.vampireTicksApplied < v4 and state.vampireTickCooldown <= 0 do
		state.vampireTickCooldown += tickInterval
		state.vampireTicksApplied += 1
		local drainDamage = math.round(state.skill.drainDamage or 0)

		if drainDamage > 0 then
			local _applyIncomingDamage = self:_applyIncomingDamage(state2, drainDamage, state)

			if _applyIncomingDamage > 0 then
				state2.hp = math.max(0, state2.hp - _applyIncomingDamage)
				self:_notifyDamageTaken(state2, state, _applyIncomingDamage, list)
				table.insert(list, {
					type = "vampire_tick",
					ballId = state2.id,
					otherBallId = state.id,
					sourceBallId = state.id,
					targetBallId = state2.id,
					position = state2.position,
					damage = _applyIncomingDamage,
					heal = math.round(state.skill.healPerTick or 0)
				})
				v5 = state2.hp <= 0
			end
		end

		local v6 = math.round((state.skill.healPerTick or 0) * self:_healMultiplier(state))

		if v6 > 0 then
			state.hp += v6
		end
	end

	if v5 then
		self:_finishVampireAttach(state, state2)

		if self.multiEntityMode then
			self:_resolveEntityDeath(state2, state, list)
		end
	elseif state.vampireStateRemaining <= 0 then
		self:_finishVampireAttach(state, state2)
	end
end

function BattleSimulation:_updateBallSkill(state, data, p: number, p2)
	state.collisionCooldown = math.max(0, state.collisionCooldown - p)
	state.vampireReattachCooldownRemaining = math.max(0, (state.vampireReattachCooldownRemaining or 0) - p)
	self:_updatePoison(state, p, p2)
	self:_updateHiveVenomStacks(state, p, p2)
	self:_updateAcidPoisonStacks(state, p, p2)
	self:_updateBurn(state, p, p2)
	self:_updateVoltaicShockTarget(state, p, p2)

	if state.slowRemaining > 0 then
		state.slowRemaining = math.max(0, state.slowRemaining - p)

		if state.slowRemaining <= 0 then
			state.slowedByTraitId = nil
		end
	end

	if state.hasteRemaining > 0 then
		state.hasteRemaining = math.max(0, state.hasteRemaining - p)

		if state.hasteRemaining <= 0 then
			state.hastenedByTraitId = nil
		end
	end

	if state.healReductionRemaining > 0 then
		state.healReductionRemaining = math.max(0, state.healReductionRemaining - p)

		if state.healReductionRemaining <= 0 then
			state.healReductionByTraitId = nil
		end
	end

	if state.knockbackRemaining > 0 then
		state.knockbackRemaining = math.max(0, state.knockbackRemaining - p)
	end

	if state.explosionImpulseRemaining > 0 then
		state.explosionImpulseRemaining = math.max(0, state.explosionImpulseRemaining - p)
	end

	state.bonusSpeedMultiplier = 1

	for _, v3 in self:_activeTraitIds(state) do
		local _behaviorForTrait = self:_behaviorForTrait(v3)

		if _behaviorForTrait.updateFrame then
			_behaviorForTrait.updateFrame(self, state, data, p, p2, v3)
		end
	end

	state.activeDamageReduction = 0
	local multiplier

	if state.speedBoostTimeRemaining > 0 and state.speedBoostTraitId then
		local trait = self.config.traits[state.speedBoostTraitId]
		multiplier = trait.multiplier
		state.activeDamageReduction = trait.damageReduction or 0
	else
		multiplier = 1
	end

	if isVampireVictim(state) then
		local v3

		if data.vampireStateRemaining > 0 then
			v3 = typeof(data.vampireAttachedTargetId) == "string"
		else
			v3 = false
		end

		if v3 and data.vampireAttachedTargetId == state.id then
			multiplier *= data.skill.slowMultiplier or 1
		end
	end

	if state.poisonRemaining > 0 and state.poisonedByTraitId then
		multiplier *= self.config.traits[state.poisonedByTraitId].poisonSlowMultiplier or 1
	end

	if state.slowRemaining > 0 and state.slowedByTraitId then
		multiplier *= self.config.traits[state.slowedByTraitId].slowMultiplier or 1
	end

	if state.acidPoisonStacks and #state.acidPoisonStacks > 0 then
		local v3 = 1

		for _, acidPoisonStack in state.acidPoisonStacks do
			local v4 = not (acidPoisonStack.slowDuration > 0) and 1 or math.clamp(
				acidPoisonStack.slowElapsed / acidPoisonStack.slowDuration,
				0,
				1
			)
			v3 = math.min(v3, acidPoisonStack.initialSlowMultiplier + (1 - acidPoisonStack.initialSlowMultiplier) * v4)
		end

		multiplier *= v3
	end

	if state.hasteRemaining > 0 and state.hastenedByTraitId then
		multiplier *= self.config.traits[state.hastenedByTraitId].hasteMultiplier or 1
	end

	if state.burnFlameContactRemaining > 0 and state.burnFlameSlowTraitId then
		multiplier *= self.config.traits[state.burnFlameSlowTraitId].flameSlowMultiplier or 1
	end

	if state.burnFlameContactRemaining > 0 then
		state.burnFlameContactRemaining = math.max(0, state.burnFlameContactRemaining - p)

		if state.burnFlameContactRemaining <= 1e-6 then
			state.burnFlameContactRemaining = 0
			state.burnFlameSlowTraitId = nil
		end
	end

	local v3 = multiplier * state.bonusSpeedMultiplier
	state.currentSpeed = state.baseSpeed * v3
end

function BattleSimulation:_refreshBuffIndicators(state, p)
	local attackBuffActive = false
	local defenseBuffActive = false

	for _, v5 in self:_activeTraitIds(state) do
		local trait = self.config.traits[v5]

		if not trait then
			continue
		end

		if v5 == "Interval" then
			if state.speedBoostTimeRemaining > 0 and state.speedBoostTraitId == "Interval" then
				attackBuffActive = true
				defenseBuffActive = true
			end
		elseif v5 == "GamblerStrike" then
			if hpRatio(state) < (trait.hpThreshold or 0) then
				attackBuffActive = true
			end
		elseif v5 == "ArmorBreaker" then
			if p and hpRatio(p) > (trait.hpThreshold or 1) then
				attackBuffActive = true
			end
		elseif v5 == "LowHpArmor" and hpRatio(state) < (trait.hpThreshold or 0) then
			defenseBuffActive = true
		end
	end

	state.attackBuffActive = attackBuffActive
	state.defenseBuffActive = defenseBuffActive
end

function BattleSimulation:_refreshBladeTraits(p)
	for _, v3 in self:_activeTraitIds(p) do
		local trait = p.traits[v3]

		if trait and (v3 == "Passive" or v3 == "PassiveSword" or v3 == "PassiveAxe") then
			trait.bladePositions = buildBladePositions(self, p, v3, self.config.traits[v3])
		elseif trait and v3 == "OrbitSatellite" then
			self:_rebuildOrbitPositions(p, "OrbitSatellite")
		end
	end
end

function BattleSimulation:_refreshSnakeTail(data, value: number?)
	local snakeTail = data.traits.SnakeTail
	local snakeTail2 = self.config.traits.SnakeTail

	if not (snakeTail and snakeTail2) then
		return
	end

	local assetName = snakeTail2.assetName
	local v3

	if type(assetName) == "string" then
		v3 = assetName ~= ""
	else
		v3 = false
	end

	assert(v3, "BattleConfig.traits.SnakeTail.assetName is missing")
	local _getEffectCollisionRadius = self:_getEffectCollisionRadius(assetName)
	local v4 = math.max(1, (math.floor(snakeTail2.maxTailSegments or 1)))
	local position = data.position
	local radius = data.radius
	local direction = data.direction
	local vector = Vector2.new(1, 0)

	if not (direction.Magnitude < 0.001) then
		vector = direction.Unit
	end

	local v5 = not snakeTail.hasInitializedPose and 1 or math.clamp(
		(snakeTail2.tailTurnSpeed or 0) * (value or 0),
		0,
		1
	)

	for _, tailSegment in snakeTail.tailSegments do
		local index = tailSegment.index
		local fullScale = 1 + ((snakeTail2.tailEndFullScale or 0.5) - 1) * ((index - 1) / math.max(1, v4 - 1))
		local incompleteMinScale = snakeTail2.incompleteMinScale or 0.25
		local v7 = tailSegment.isFullyGrown and 1 or incompleteMinScale + (1 - incompleteMinScale) * math.clamp(
			tailSegment.growthAlpha or 0,
			0,
			1
		)
		tailSegment.fullScale = fullScale
		tailSegment.scale = fullScale * v7
		tailSegment.radius = _getEffectCollisionRadius * tailSegment.scale
		local v8 = math.sin((snakeTail.waveElapsed or 0) * 6.283185307179586 * (snakeTail2.tailWaveFrequency or 0) - (index - 1) * (snakeTail2.tailSegmentPhaseOffset or 0)) * (snakeTail2.tailWaveAmplitudeMultiplier or 0)
		local v9 = math.cos(v8)
		local v10 = math.sin(v8)
		local vector2 = Vector2.new(vector.X * v9 - vector.Y * v10, vector.X * v10 + vector.Y * v9)

		if tailSegment.direction == nil then
			tailSegment.direction = vector2
		else
			local lerped = tailSegment.direction:Lerp(vector2, v5)

			if not (lerped.Magnitude < 0.001) then
				vector2 = lerped.Unit
			end

			tailSegment.direction = vector2
		end

		local v11 = (radius + tailSegment.radius) * (snakeTail2.tailSpacingMultiplier or 1)
		tailSegment.position = position - tailSegment.direction * v11
		vector = tailSegment.direction
		position = tailSegment.position
		radius = tailSegment.radius
	end

	snakeTail.hasInitializedPose = true
end

function BattleSimulation:_moveBall(state, p: number, p2)
	for _, v3 in self:_activeTraitIds(state) do
		local _behaviorForTrait = self:_behaviorForTrait(v3)

		if not (_behaviorForTrait.moveOverride and _behaviorForTrait.moveOverride(self, state, p, p2, v3)) then
			continue
		end

		self:_refreshBladeTraits(state)
		self:_refreshSnakeTail(state, p)
		self:_refreshSpiderWebEndpoints(state)
		return
	end

	local v3

	if state.vampireStateRemaining > 0 then
		v3 = typeof(state.vampireAttachedTargetId) == "string"
	else
		v3 = false
	end

	if v3 then
		self:_refreshBladeTraits(state)
		self:_refreshSnakeTail(state, p)
		self:_refreshSpiderWebEndpoints(state)
	elseif self:_isVoltaicShockControlled(state) then
		local voltaicShockAnchorPosition = state.voltaicShockAnchorPosition or state.position
		local voltaicShock = self.config.traits.VoltaicShock
		local v4 = (voltaicShock.shockDuration or 0) - state.voltaicShockRemaining
		local twitchAmplitude = voltaicShock.twitchAmplitude or 0
		state.position = voltaicShockAnchorPosition + Vector2.new(math.sin(v4 * 29), (math.cos(v4 * 37))) * twitchAmplitude
		self:_refreshBladeTraits(state)
		self:_refreshSnakeTail(state, p)
		self:_refreshSpiderWebEndpoints(state)
	elseif state.hookCapturedByBallId then
		self:_refreshBladeTraits(state)
		self:_refreshSnakeTail(state, p)
		self:_refreshSpiderWebEndpoints(state)
	elseif state.harpoonCapturedByBallId then
		self:_refreshBladeTraits(state)
		self:_refreshSnakeTail(state, p)
		self:_refreshSpiderWebEndpoints(state)
	else
		local knockback = self.config.traits.Knockback
		local duration = knockback and knockback.duration or 0
		local v4 = not (state.knockbackRemaining > 0 and duration > 0) and 0 or state.knockbackPeakBonus * (state.knockbackRemaining / duration)
		local timeBomb = self.config.traits.TimeBomb
		local explosionImpulseDuration

		if state.explosionImpulseDuration > 0 then
			explosionImpulseDuration = state.explosionImpulseDuration
		else
			explosionImpulseDuration = timeBomb and timeBomb.explosionImpulseDuration or 0
		end

		local zero = Vector2.zero

		if state.explosionImpulseRemaining > 0 and explosionImpulseDuration > 0 then
			local v5 = state.explosionImpulseRemaining / explosionImpulseDuration
			zero = state.explosionImpulseDirection * (state.explosionImpulsePeakSpeed * v5)
		end

		state.position += (state.direction * (state.currentSpeed + v4) + state.gravityVelocity + zero) * p
		self:_refreshBladeTraits(state)
		self:_refreshSnakeTail(state, p)
		self:_refreshSpiderWebEndpoints(state)
	end
end

function BattleSimulation:_resolveWallBounce(vector: Vector2, p2: number, vector2: Vector2, list, ballId: string?)
	local DISTANCE_EPSILON = 0.001
	local size = self.config.arena.size
	local v3 = size.X * 0.5
	local v4 = size.Y * 0.5
	local v5 = -v3 + p2
	local v6 = v3 - p2
	local v7 = -v4 + p2
	local v8 = v4 - p2
	local v9 = false

	if vector.X < v5 then
		vector = Vector2.new(v5, vector.Y)
		local vector3 = Vector2.new(math.abs(vector2.X), vector2.Y)
		vector2 = Vector2.new(1, 0)

		if not (vector3.Magnitude < DISTANCE_EPSILON) then
			vector2 = vector3.Unit
		end

		v9 = true

		if list and ballId then
			table.insert(list, {
				type = "wall_hit",
				ballId = ballId,
				position = Vector2.new(-v3, vector.Y),
				startPosition = Vector2.new(-v3, vector.Y),
				endPosition = vector,
				axis = "X"
			})
		end
	elseif v6 < vector.X then
		vector = Vector2.new(v6, vector.Y)
		local vector3 = Vector2.new(-math.abs(vector2.X), vector2.Y)
		vector2 = Vector2.new(-1, 0)

		if not (vector3.Magnitude < DISTANCE_EPSILON) then
			vector2 = vector3.Unit
		end

		v9 = true

		if list and ballId then
			table.insert(list, {
				type = "wall_hit",
				ballId = ballId,
				position = Vector2.new(v3, vector.Y),
				startPosition = Vector2.new(v3, vector.Y),
				endPosition = vector,
				axis = "X"
			})
		end
	end

	if vector.Y < v7 then
		vector = Vector2.new(vector.X, v7)
		local vector3 = Vector2.new(vector2.X, (math.abs(vector2.Y)))
		vector2 = Vector2.new(0, 1)

		if not (vector3.Magnitude < DISTANCE_EPSILON) then
			vector2 = vector3.Unit
		end

		v9 = true

		if list and ballId then
			table.insert(list, {
				type = "wall_hit",
				ballId = ballId,
				position = Vector2.new(vector.X, -v4),
				startPosition = Vector2.new(vector.X, -v4),
				endPosition = vector,
				axis = "Y"
			})
			return vector, vector2, true
		end
	elseif v8 < vector.Y then
		vector = Vector2.new(vector.X, v8)
		local vector3 = Vector2.new(vector2.X, -math.abs(vector2.Y))
		vector2 = Vector2.new(0, -1)

		if not (vector3.Magnitude < DISTANCE_EPSILON) then
			vector2 = vector3.Unit
		end

		v9 = true

		if list and ballId then
			table.insert(list, {
				type = "wall_hit",
				ballId = ballId,
				position = Vector2.new(vector.X, v4),
				startPosition = Vector2.new(vector.X, v4),
				endPosition = vector,
				axis = "Y"
			})
		end
	end

	return vector, vector2, v9
end

function BattleSimulation:_handleHookCapturedTargetWallHits(p, p2, point: Vector2, list)
	local size = self.config.arena.size
	local v3 = size.X * 0.5
	local v4 = size.Y * 0.5
	local capturedWallKeys = {}
	local v6 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addWallHit(p3: string, axis: string, vector: Vector2, vector2: Vector2)
		capturedWallKeys[p3] = true

		if p2.capturedWallKeys[p3] then
			return
		end

		table.insert(v6, {
			type = "wall_hit",
			ballId = p.id,
			position = vector,
			startPosition = vector,
			endPosition = vector2,
			axis = axis
		})
	end

	local v7 = math.clamp(point.X, -v3 + p.radius, v3 - p.radius)
	local v8 = math.clamp(point.Y, -v4 + p.radius, v4 - p.radius)

	if point.X <= -v3 + 0.001 then
		addWallHit("West", "X", Vector2.new(-v3, (math.clamp(point.Y, -v4, v4))), Vector2.new(-v3 + p.radius, v8)) -- equivalent call inferred; original call site unknown
	else
		local X = point.X

		if v3 - 0.001 <= X then
			addWallHit("East", "X", Vector2.new(v3, (math.clamp(point.Y, -v4, v4))), Vector2.new(v3 - p.radius, v8)) -- equivalent call inferred; original call site unknown
		end
	end

	if point.Y <= -v4 + 0.001 then
		addWallHit("North", "Y", Vector2.new(v7, -v4), Vector2.new(v7, -v4 + p.radius)) -- equivalent call inferred; original call site unknown
	else
		local Y = point.Y

		if v4 - 0.001 <= Y then
			addWallHit("South", "Y", Vector2.new(v7, v4), Vector2.new(v7, v4 - p.radius)) -- equivalent call inferred; original call site unknown
		end
	end

	p2.capturedWallKeys = capturedWallKeys

	for _, v9 in v6 do
		table.insert(list, v9)

		for _, v10 in self:_activeTraitIds(p) do
			local _behaviorForTrait = self:_behaviorForTrait(v10)

			if _behaviorForTrait.onWallHit then
				_behaviorForTrait.onWallHit(self, p, v9, list, v10)
			end
		end
	end
end

function BattleSimulation:_handleWallBounce(state, list)
	if self:_isVoltaicShockControlled(state) or state.hookCapturedByBallId or state.harpoonCapturedByBallId then
		return
	end

	local v3 = #list + 1
	local _resolveWallBounce, direction = self:_resolveWallBounce(
		state.position,
		state.radius,
		state.direction,
		list,
		state.id
	)
	local count = #list

	if _resolveWallBounce.X ~= state.position.X then
		state.gravityVelocity = Vector2.new(-state.gravityVelocity.X, state.gravityVelocity.Y)
		state.explosionImpulseDirection = Vector2.new(
			-state.explosionImpulseDirection.X,
			state.explosionImpulseDirection.Y
		)
	end

	if _resolveWallBounce.Y ~= state.position.Y then
		state.gravityVelocity = Vector2.new(state.gravityVelocity.X, -state.gravityVelocity.Y)
		state.explosionImpulseDirection = Vector2.new(
			state.explosionImpulseDirection.X,
			-state.explosionImpulseDirection.Y
		)
	end

	state.position = _resolveWallBounce
	state.direction = direction
	self:_refreshSnakeTail(state)
	self:_refreshSpiderWebEndpoints(state)

	if count < v3 then
		return
	end

	local _activeTraitIds = self:_activeTraitIds(state)

	for i = v3, count do
		local v5 = list[i]

		if not (v5.type == "wall_hit" and v5.ballId == state.id) then
			continue
		end

		for _, _activeTraitId in _activeTraitIds do
			local _behaviorForTrait = self:_behaviorForTrait(_activeTraitId)

			if _behaviorForTrait.onWallHit then
				_behaviorForTrait.onWallHit(self, state, v5, list, _activeTraitId)
			end
		end
	end
end

function BattleSimulation:_spawnThomas(data, p, p2: string, list)
	local trait = self.config.traits[p2]
	local trait2 = data.traits[p2]

	if not trait2 or trait2.thomas then
		return
	end

	local position = p.position or data.position
	local vector = p.axis == "X" and Vector2.new(position.X < 0 and 1 or -1, 0) or Vector2.new(
		0,
		position.Y < 0 and 1 or -1
	)
	local _getEffectCollisionRadius = self:_getEffectCollisionRadius(self.config.visual.thomasTemplateName)
	local scale = math.min(trait.maxScale or 1, 1 + 1 * (trait.scaleStep or 0))
	local radius = _getEffectCollisionRadius * scale
	local v5 = math.atan2(vector.Y, vector.X) + self.random:NextNumber(-1.5707963267948966, 1.5707963267948966)
	trait2.thomas = {
		position = data.position + vector * (radius + data.radius + 0.02),
		direction = Vector2.new(math.cos(v5), (math.sin(v5))),
		baseRadius = _getEffectCollisionRadius,
		radius = radius,
		level = 1,
		scale = scale,
		hitCooldowns = {},
		upgradeCooldownRemaining = 0
	}
	table.insert(list, {
		type = "thomas_spawned",
		ballId = data.id,
		position = trait2.thomas.position
	})
end

function BattleSimulation:_bounceThomasAgainst(state, point: Vector2, p2: number)
	local v3 = state.position - point
	local unit = -state.direction

	if not (v3.Magnitude < 0.001) then
		unit = v3.Unit
	end

	local v4 = state.radius + p2 - v3.Magnitude

	if v4 > 0 then
		state.position += unit * (v4 + 0.01)
	end

	local vector = Vector2.new(-unit.Y, unit.X)
	local number = self.random:NextNumber(-0.25, 0.25)
	local direction = normalizeOrFallback(unit + vector * number, unit) -- equivalent call inferred; original call site unknown
	state.direction = direction
	return unit, number
end

function BattleSimulation:_redirectBallFromThomasCollision(p, point: Vector2, p2: number)
	local vector = Vector2.new(-point.Y, point.X)
	local v3 = -point - vector * p2
	local unit = -point

	if not (v3.Magnitude < 0.001) then
		unit = v3.Unit
	end

	p.direction = unit
end

function BattleSimulation:_updateThomas(data, p: number, list)
	local thomasUpgrade = data.traits.ThomasUpgrade
	local thomas = thomasUpgrade and thomasUpgrade.thomas

	if not thomas or data.hp <= 0 then
		return
	end

	local thomasUpgrade2 = self.config.traits.ThomasUpgrade
	thomas.position += thomas.direction * (thomasUpgrade2.thomasSpeed or 0) * p
	local _resolveWallBounce, direction = self:_resolveWallBounce(
		thomas.position,
		thomas.radius,
		thomas.direction,
		list,
		data.id .. ":Thomas"
	)
	thomas.position = _resolveWallBounce
	thomas.direction = direction

	if (thomas.position - data.position).Magnitude <= thomas.radius + data.radius then
		local _bounceThomasAgainst, v4 = self:_bounceThomasAgainst(thomas, data.position, data.radius)
		self:_redirectBallFromThomasCollision(data, _bounceThomasAgainst, v4)

		if thomas.level < (thomasUpgrade2.maxLevel or 0) and thomas.upgradeCooldownRemaining <= 0 then
			thomas.level += 1
			thomas.scale = math.min(thomasUpgrade2.maxScale or 1, 1 + thomas.level * (thomasUpgrade2.scaleStep or 0))
			thomas.radius = thomas.baseRadius * thomas.scale
			thomas.upgradeCooldownRemaining = thomasUpgrade2.upgradeCooldown or 0
			table.insert(list, {
				type = "thomas_upgraded",
				ballId = data.id,
				position = thomas.position,
				count = thomas.level
			})
		end
	else
		for _, ball in self.state.balls do
			if not (ball.team ~= data.team and ball.hp > 0 and (thomas.position - ball.position).Magnitude <= thomas.radius + ball.radius) then
				continue
			end

			local _bounceThomasAgainst, v4 = self:_bounceThomasAgainst(thomas, ball.position, ball.radius)
			self:_redirectBallFromThomasCollision(ball, _bounceThomasAgainst, v4)

			if not ((thomas.hitCooldowns[ball.id] or 0) <= 0) then
				continue
			end

			local v5 = not self.statLevels[data.team] and 0 or self.statLevels[data.team].attack or 0
			local v6 = 1 + self.config.tournament_upgrade.basicStats.attack.amount * v5
			local _applyDamageModifiers = self:_applyDamageModifiers(
				data,
				ball,
				((thomasUpgrade2.baseDamage or 0) + thomas.level * (thomasUpgrade2.damagePerLevel or 0)) * v6
			)

			if _applyDamageModifiers > 0 then
				ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
				self:_notifyDamageTaken(ball, data, _applyDamageModifiers, list)
				table.insert(list, {
					type = "thomas_hit",
					ballId = ball.id,
					otherBallId = data.id,
					sourceBallId = data.id,
					targetBallId = ball.id,
					position = ball.position,
					damage = _applyDamageModifiers
				})
			end

			thomas.hitCooldowns[ball.id] = thomasUpgrade2.hitCooldown or 0
		end

		for k, hitCooldown in thomas.hitCooldowns do
			thomas.hitCooldowns[k] = math.max(0, hitCooldown - p)
		end

		thomas.upgradeCooldownRemaining = math.max(0, thomas.upgradeCooldownRemaining - p)
	end
end

function BattleSimulation:_moveAttachedPair(state, state2, p: number, p2)
	local direction = state2.direction
	local direction2 = state.direction
	local vector = Vector2.new(1, 0)

	if not (direction2.Magnitude < 0.001) then
		vector = direction2.Unit
	end

	if not (direction.Magnitude < 0.001) then
		vector = direction.Unit
	end

	state2.position += vector * state2.currentSpeed * p
	state2.direction = vector
	state.direction = vector
	self:_syncVampireAttachment(state, state2)
	local position = state2.position
	local _resolveWallBounce, direction3, v4 = self:_resolveWallBounce(
		state2.position,
		state2.radius,
		vector,
		p2,
		state2.id
	)

	if v4 then
		local v5 = _resolveWallBounce - position
		state2.position = _resolveWallBounce
		state.position += v5
		state2.direction = direction3
		state.direction = direction3
		vector = direction3
	end

	local position2 = state.position
	local _resolveWallBounce2, v5, v6 = self:_resolveWallBounce(state.position, state.radius, vector, p2, state.id)

	if v6 then
		local v7 = _resolveWallBounce2 - position2
		state.position = _resolveWallBounce2
		state2.position += v7
		local _resolveWallBounce3, direction4 = self:_resolveWallBounce(
			state2.position,
			state2.radius,
			v5,
			p2,
			state2.id
		)
		state2.position = _resolveWallBounce3
		state2.direction = direction4
		state.direction = direction4
		self:_syncVampireAttachment(state, state2)
		state.position = self:_resolveWallBounce(state.position, state.radius, direction4)
	end

	self:_refreshBladeTraits(state)
	self:_refreshSnakeTail(state, p)
	self:_refreshBladeTraits(state2)
	self:_refreshSnakeTail(state2, p)
end

function BattleSimulation:_pushBallAwayFromEffect(state, point: Vector2, p: number, unit: Vector2)
	-- equivalent call inferred; original call site unknown
	if isRouteLocked(state) then
		return state.direction
	end

	local v3 = state.position - point

	if not (v3.Magnitude < 0.001) then
		unit = v3.Unit
	end

	state.position = point + unit * (p + state.radius + 0.01)
	state.direction = unit
	return unit
end

function BattleSimulation:_separateBalls(p, p2, point: Vector2, p3: number)
	if p3 <= 0 then
		return
	end

	local v3 = point * (p3 * 0.5 + 0.01)
	p.position -= v3
	p2.position += v3
end

function BattleSimulation:_resolveChessPathSegmentHit(data, point: Vector2, point2: Vector2, p, p2, list)
	local function fn(p3)
		return self:_behaviorForTrait(p3)
	end

	local function fn2(p3)
		return self:_activeTraitIds(p3)
	end

	for _, ball in self.state.balls do
		if not (ball.team ~= data.team and ball.hp > 0 and (p.targetHitCooldowns[ball.id] or 0) <= 0) then
			continue
		end

		local vector = point2 - point
		local dot = vector:Dot(vector)
		local position = point + vector * (dot <= 1e-6 and 0 or math.clamp(
			(ball.position - point):Dot(vector) / dot,
			0,
			1
		))

		if not ((ball.position - position).Magnitude <= data.radius + ball.radius) then
			continue
		end

		local collisionDamage = DamageResolution.collisionDamage(self, data, fn)
		local resolved = DamageResolution.resolve(self, data, ball, collisionDamage, fn, fn2, list, nil)
		p.targetHitCooldowns[ball.id] = p2.targetHitCooldown or 0
		self:_pushBallAwayFromEffect(ball, data.position, data.radius, data.direction)
		self:_applyKnockback(data, ball, p2.pathSpeed)
		self:_refreshSnakeTail(ball)
		table.insert(list, {
			type = "chess_path_hit",
			ballId = ball.id,
			otherBallId = data.id,
			sourceBallId = data.id,
			targetBallId = ball.id,
			position = position,
			damage = resolved,
			selectedPiece = p.selectedPiece
		})

		if self.multiEntityMode then
			self:_resolveEntityDeath(ball, data, list)
		end
	end
end

function BattleSimulation:_applyDamageModifiers(p, p2, p3: number)
	return DamageResolution.resolve(self, p, p2, p3, function(p4)
		return self:_behaviorForTrait(p4)
	end, function(p4)
		return self:_activeTraitIds(p4)
	end, {}, {
		applyCollisionOutgoingBonus = false,
		applyGlobalOutgoingBonus = true,
		applyToDefender = false
	})
end

function BattleSimulation:_applyProjectileDamage(p, p2, p3: number)
	return DamageResolution.resolve(self, p, p2, p3, function(p4)
		return self:_behaviorForTrait(p4)
	end, function(p4)
		return self:_activeTraitIds(p4)
	end, {}, {
		applyCollisionOutgoingBonus = false,
		applyGlobalOutgoingBonus = true,
		roundToInteger = false,
		applyToDefender = false
	})
end

function BattleSimulation:_applyIncomingDamage(p, p2: number, p3)
	if p3 and DamageResolution.isFriendlyFire(p3, p) then
		return 0
	end

	return DamageResolution.applyIncomingDamage(self, p, p2, function(p4)
		return self:_behaviorForTrait(p4)
	end, function(p4)
		return self:_activeTraitIds(p4)
	end, true)
end

function BattleSimulation:_resolveFriendlyBallCollision(state, state2)
	local DISTANCE_EPSILON = 0.001
	local v3 = state2.position - state.position
	local direction = state.direction
	local vector = Vector2.new(1, 0)

	if not (direction.Magnitude < DISTANCE_EPSILON) then
		vector = direction.Unit
	end

	if not (v3.Magnitude < DISTANCE_EPSILON) then
		vector = v3.Unit
	end

	self:_separateBalls(state, state2, vector, state.radius + state2.radius - v3.Magnitude)
	local vector2 = Vector2.new(-vector.Y, vector.X)
	local number = self.random:NextNumber(-0.2, 0.2)
	local v4 = -vector + vector2 * number
	local unit = -vector

	if not (v4.Magnitude < DISTANCE_EPSILON) then
		unit = v4.Unit
	end

	state.direction = unit
	local v5 = vector - vector2 * number

	if not (v5.Magnitude < DISTANCE_EPSILON) then
		vector = v5.Unit
	end

	state2.direction = vector
	self:_refreshSnakeTail(state)
	self:_refreshSnakeTail(state2)
end

function BattleSimulation:_applyKnockback(p, p2, p3: number?)
	if DamageResolution.isFriendlyFire(p, p2) then
		return
	end

	local v3 = p3 or p.currentSpeed

	if v3 <= p2.currentSpeed or p2.currentSpeed <= 0.0001 then
		return
	end

	local knockback = self.config.traits.Knockback

	if not knockback then
		return
	end

	local v4 = table.find(self:_activeTraitIds(p), "Knockback") == nil and 1 or knockback.speedMultiplier or 1
	p2.knockbackPeakBonus = (v3 - p2.currentSpeed) * v4
	p2.knockbackRemaining = knockback.duration or 0
end

function BattleSimulation:_resolveBallCollision(state, state2, list)
	local DISTANCE_EPSILON = 0.001

	if self:_isVoltaicShockControlled(state) or self:_isVoltaicShockControlled(state2) then
		return
	end

	-- equivalent call inferred; original call site unknown
	if not isRouteLocked(state) then
		-- equivalent call inferred; original call site unknown
		if not isRouteLocked(state2) then
			local v3 = state2.position - state.position
			local direction = state.direction
			local vector = Vector2.new(1, 0)

			if not (direction.Magnitude < DISTANCE_EPSILON) then
				vector = direction.Unit
			end

			if not (v3.Magnitude < DISTANCE_EPSILON) then
				vector = v3.Unit
			end

			local magnitude = v3.Magnitude
			self:_separateBalls(state, state2, vector, state.radius + state2.radius - magnitude)
			local v4

			if state.skill.trigger == "VampireAttach" then
				v4 = not isVampireAttached(state) and typeof(state.vampireVictimSourceId) ~= "string"

				if v4 then
					v4 = not isVampireAttached(state2) and (state.vampireReattachCooldownRemaining or 0) <= 0
				end
			else
				v4 = false
			end

			local v5

			if state2.skill.trigger == "VampireAttach" then
				v5 = not isVampireAttached(state2) and typeof(state2.vampireVictimSourceId) ~= "string"

				if v5 then
					v5 = not isVampireAttached(state) and (state2.vampireReattachCooldownRemaining or 0) <= 0
				end
			else
				v5 = false
			end

			local v6 = v4 or v5

			if v6 then
				if v4 and v5 then
					if state.currentSpeed > state2.currentSpeed then
						self:_startVampireAttach(state, state2, list)
					elseif state2.currentSpeed > state.currentSpeed or self.random:NextInteger(0, 1) == 1 then
						self:_startVampireAttach(state2, state, list)
					else
						self:_startVampireAttach(state, state2, list)
					end
				elseif v4 then
					self:_startVampireAttach(state, state2, list)
				else
					self:_startVampireAttach(state2, state, list)
				end
			else
				local vector2 = Vector2.new(-vector.Y, vector.X)
				local number = self.random:NextNumber(-0.45, 0.45)
				local v7 = -vector + vector2 * number
				local unit = -vector

				if not (v7.Magnitude < DISTANCE_EPSILON) then
					unit = v7.Unit
				end

				state.direction = unit
				local direction2 = normalizeOrFallback(vector - vector2 * number, vector) -- equivalent call inferred; original call site unknown
				state2.direction = direction2
				state.gravityVelocity -= vector * (2 * state.gravityVelocity:Dot(vector))
				state2.gravityVelocity -= vector * (2 * state2.gravityVelocity:Dot(vector))
				self:_applyKnockback(state, state2)
				self:_applyKnockback(state2, state)
				self:_refreshSnakeTail(state)
				self:_refreshSnakeTail(state2)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function fn(p)
				return self:_behaviorForTrait(p)
			end

			local function fn2(p)
				return self:_activeTraitIds(p)
			end

			local collisionDamage, usedBonus = DamageResolution.collisionDamage(self, state, fn)
			local collisionDamage2, usedBonus2 = DamageResolution.collisionDamage(self, state2, fn)
			local v9 = self:_isVoltaicShockControlled(state) and 0 or collisionDamage
			local v10 = self:_isVoltaicShockControlled(state2) and 0 or collisionDamage2
			table.insert(list, {
				type = "ball_contact",
				ballId = state.id,
				targetBallId = state.id,
				otherBallId = state2.id,
				position = state.position
			})
			table.insert(list, {
				type = "ball_contact",
				ballId = state2.id,
				targetBallId = state2.id,
				otherBallId = state.id,
				position = state2.position
			})

			if not v6 then
				state.collisionCooldown = self.config.battle.contactCooldown
				state2.collisionCooldown = self.config.battle.contactCooldown
			end

			DamageResolution.resolve(self, state2, state, v10, fn, fn2, list, {
				eventType = "ball_hit",
				usedBonus = usedBonus2
			})

			if self.multiEntityMode then
				self:_resolveEntityDeath(state, state2, list)

				if self.state.balls[state2.id] == nil then
					self:_onCollisionResolved(state, state2, list)
					self:_onCollisionResolved(state2, state, list)
					return
				end
			end

			DamageResolution.resolve(self, state, state2, v9, fn, fn2, list, {
				eventType = "ball_hit",
				usedBonus = usedBonus
			})

			if self.multiEntityMode then
				self:_resolveEntityDeath(state2, state, list)

				if self.state.balls[state.id] == nil then
					self:_onCollisionResolved(state, state2, list)
					self:_onCollisionResolved(state2, state, list)
					return
				end
			end

			for _, v11 in self:_activeTraitIds(state) do
				local v12 = fn(v11) -- equivalent call inferred; original call site unknown

				if v12.onEnemyCollision then
					v12.onEnemyCollision(self, state, state2, list, v11)
				end
			end

			for _, v11 in self:_activeTraitIds(state2) do
				local v12 = fn(v11) -- equivalent call inferred; original call site unknown

				if v12.onEnemyCollision then
					v12.onEnemyCollision(self, state2, state, list, v11)
				end
			end

			self:_onCollisionResolved(state, state2, list)
			self:_onCollisionResolved(state2, state, list)
		end
	end
end

function BattleSimulation:_handleBladeHits(p, p2, p3)
	for _, v3 in self:_activeTraitIds(p) do
		local _behaviorForTrait = self:_behaviorForTrait(v3)

		if _behaviorForTrait.weaponHits then
			_behaviorForTrait.weaponHits(self, p, p2, p3, v3)
		end
	end
end

function BattleSimulation:_handleMultiEntityCollisions(p)
	local v3 = {}

	for k in self.state.balls do
		table.insert(v3, k)
	end

	for i = 1, #v3 - 1 do
		for i2 = i + 1, #v3 do
			local ball = self.state.balls[v3[i]]
			local ball2 = self.state.balls[v3[i2]]

			if not (ball and ball2) then
				continue
			end

			local v4

			if ball.vampireStateRemaining > 0 then
				v4 = typeof(ball.vampireAttachedTargetId) == "string"
			else
				v4 = false
			end

			local v5

			if v4 and ball.vampireAttachedTargetId == ball2.id then
				v5 = true
			else
				v5 = isVampireAttached(ball2) and ball2.vampireAttachedTargetId == ball.id
			end

			local v6 = ball.hookCapturedByBallId == ball2.id or ball2.hookCapturedByBallId == ball.id
			local v7 = ball.harpoonCapturedByBallId == ball2.id or ball2.harpoonCapturedByBallId == ball.id

			if v6 or v7 then
				continue
			end

			if ball.team == ball2.team then
				-- equivalent call inferred; original call site unknown
				if not isRouteLocked(ball) then
					-- equivalent call inferred; original call site unknown
					if not isRouteLocked(ball2) then
						self:_handleFriendlyHookGrappleCapture(ball, ball2, p)

						if (ball2.position - ball.position).Magnitude <= ball.radius + ball2.radius then
							self:_resolveFriendlyBallCollision(ball, ball2)
						end
					end
				end
			else
				self:_refreshSpiderWebEndpoints(ball)
				self:_refreshSpiderWebEndpoints(ball2)
				local magnitude = (ball2.position - ball.position).Magnitude
				self:_handleBladeHits(ball, ball2, p)
				self:_resolveEntityDeath(ball2, ball, p)

				if self.state.balls[ball.id] and self.state.balls[ball2.id] then
					self:_handleBladeHits(ball2, ball, p)
					self:_resolveEntityDeath(ball, ball2, p)
				end

				if self.state.balls[ball.id] and self.state.balls[ball2.id] and not v5 and magnitude <= ball.radius + ball2.radius and ball.collisionCooldown <= 0 and ball2.collisionCooldown <= 0 then
					self:_resolveBallCollision(ball, ball2, p)
				end
			end
		end
	end
end

function BattleSimulation:_handleBallCollision(p)
	if self.multiEntityMode then
		self:_handleMultiEntityCollisions(p)
		return
	end

	local blue = self.state.balls.Blue
	local yellow = self.state.balls.Yellow
	local v3

	if blue.vampireStateRemaining > 0 then
		v3 = typeof(blue.vampireAttachedTargetId) == "string"
	else
		v3 = false
	end

	local v4

	if v3 and blue.vampireAttachedTargetId == yellow.id then
		v4 = true
	else
		v4 = isVampireAttached(yellow) and yellow.vampireAttachedTargetId == blue.id
	end

	local v5 = blue.hookCapturedByBallId == yellow.id or yellow.hookCapturedByBallId == blue.id
	local v6 = blue.harpoonCapturedByBallId == yellow.id or yellow.harpoonCapturedByBallId == blue.id
	local routeLocked = isRouteLocked(blue) -- equivalent call inferred; original call site unknown
	local routeLocked2 = isRouteLocked(yellow) -- equivalent call inferred; original call site unknown
	local magnitude = (yellow.position - blue.position).Magnitude
	local v7 = blue.radius + yellow.radius
	self:_refreshSpiderWebEndpoints(blue)
	self:_refreshSpiderWebEndpoints(yellow)
	self:_handleBladeHits(blue, yellow, p)
	self:_handleBladeHits(yellow, blue, p)

	if not v4 and not v5 and not v6 and not routeLocked and not routeLocked2 and magnitude <= v7 then
		local v8 = yellow.position - blue.position
		local vector = Vector2.new(1, 0)

		if not (v8.Magnitude < 0.001) then
			vector = v8.Unit
		end

		self:_separateBalls(blue, yellow, vector, v7 - magnitude)

		if blue.collisionCooldown <= 0 and yellow.collisionCooldown <= 0 then
			self:_resolveBallCollision(blue, yellow, p)
		end
	end
end

function BattleSimulation:_updateWinner(list)
	if self.multiEntityMode then
		local v3 = #self.state.teams.Blue > 0
		local v4 = #self.state.teams.Yellow > 0

		if v3 and v4 then
			return
		end

		self.state.finished = true
		self.state.winner = v3 and "Blue" or v4 and "Yellow" or "Draw"
		table.insert(list, {
			type = "battle_end",
			winner = self.state.winner
		})
	else
		local hp = self.state.balls.Blue.hp
		local hp2 = self.state.balls.Yellow.hp

		if hp > 0 and hp2 > 0 then
			return
		end

		self.state.finished = true

		if hp <= 0 and hp2 <= 0 then
			self.state.winner = "Draw"
		elseif hp <= 0 then
			self.state.winner = "Yellow"
		else
			self.state.winner = "Blue"
		end

		self:_clearZoneEffects(self.state.balls.Blue)
		self:_clearZoneEffects(self.state.balls.Yellow)
		table.insert(list, {
			type = "battle_end",
			winner = self.state.winner
		})
	end
end

function BattleSimulation:_firstOpponent(p2)
	local v3 = 1e999
	local v4 = nil

	for _, ball in self.state.balls do
		if ball.team == p2.team then
			continue
		end

		local vector = ball.position - p2.position
		local dot = vector:Dot(vector)

		if not (dot < v3) then
			continue
		end

		v4 = ball
		v3 = dot
	end

	return v4
end

function BattleSimulation:_refreshAllBuffIndicators()
	for _, ball in self.state.balls do
		self:_refreshBuffIndicators(ball, self:_firstOpponent(ball))
	end
end

function BattleSimulation:_stepMultiEntity(p: number, p2)
	local v3 = {}

	for k in self.state.balls do
		table.insert(v3, k)
	end

	for _, v4 in v3 do
		local ball = self.state.balls[v4]

		if not ball then
			continue
		end

		local _firstOpponent = self:_firstOpponent(ball)

		if _firstOpponent then
			self:_updateBallSkill(ball, _firstOpponent, p, p2)
		end
	end

	local v4 = {}

	for _, v5 in v3 do
		local ball = self.state.balls[v5]

		if not ball or v4[v5] then
			continue
		end

		local v6

		if ball.vampireStateRemaining > 0 then
			v6 = typeof(ball.vampireAttachedTargetId) == "string"
		else
			v6 = false
		end

		if v6 then
			local _ballById = self:_ballById(ball.vampireAttachedTargetId)

			if _ballById then
				self:_moveAttachedPair(ball, _ballById, p, p2)
				self:_handlePoisonSpikeCollisions(ball, p2)
				self:_handlePoisonSpikeCollisions(_ballById, p2)
				v4[ball.id] = true
				v4[_ballById.id] = true
				continue
			else
				self:_finishVampireAttach(ball, nil)
			end
		end

		self:_moveBall(ball, p, p2)

		-- equivalent call inferred; original call site unknown
		if not isRouteLocked(ball) then
			self:_handleWallBounce(ball, p2)
			self:_handlePoisonSpikeCollisions(ball, p2)
		end

		v4[ball.id] = true
	end

	for _, v5 in v3 do
		local ball = self.state.balls[v5]

		if ball then
			self:_updateThomas(ball, p, p2)
		end
	end

	self:_handleMultiEntityCollisions(p2)
	self:_handleDiceCollisions(p2)

	for _, v5 in v3 do
		local ball = self.state.balls[v5]

		if ball then
			self:_resolveEntityDeath(ball, nil, p2)
		end
	end
end

function BattleSimulation:step(p: number)
	local v3 = {}

	if self.state.finished then
		return self.state, v3
	end

	self.state.elapsed += p

	if self.multiEntityMode then
		self:_stepMultiEntity(p, v3)
		self:_refreshAllBuffIndicators()
		self:_updateWinner(v3)
		return self.state, v3
	else
		local blue = self.state.balls.Blue
		local yellow = self.state.balls.Yellow
		self:_updateBallSkill(blue, yellow, p, v3)
		self:_updateBallSkill(yellow, blue, p, v3)
		local v4

		if blue.vampireStateRemaining > 0 then
			v4 = typeof(blue.vampireAttachedTargetId) == "string"
		else
			v4 = false
		end

		if v4 and blue.vampireAttachedTargetId == yellow.id then
			self:_moveAttachedPair(blue, yellow, p, v3)
			self:_handlePoisonSpikeCollisions(blue, v3)
			self:_handlePoisonSpikeCollisions(yellow, v3)
		else
			local v5

			if yellow.vampireStateRemaining > 0 then
				v5 = typeof(yellow.vampireAttachedTargetId) == "string"
			else
				v5 = false
			end

			if v5 and yellow.vampireAttachedTargetId == blue.id then
				self:_moveAttachedPair(yellow, blue, p, v3)
				self:_handlePoisonSpikeCollisions(blue, v3)
				self:_handlePoisonSpikeCollisions(yellow, v3)
			else
				self:_moveBall(blue, p, v3)

				-- equivalent call inferred; original call site unknown
				if not isRouteLocked(blue) then
					self:_handleWallBounce(blue, v3)
					self:_handlePoisonSpikeCollisions(blue, v3)
				end

				self:_moveBall(yellow, p, v3)

				-- equivalent call inferred; original call site unknown
				if not isRouteLocked(yellow) then
					self:_handleWallBounce(yellow, v3)
					self:_handlePoisonSpikeCollisions(yellow, v3)
				end
			end
		end

		self:_updateThomas(blue, p, v3)
		self:_updateThomas(yellow, p, v3)
		self:_handleBallCollision(v3)
		self:_handleDiceCollisions(v3)
		self:_refreshAllBuffIndicators()
		self:_updateWinner(v3)
		return self.state, v3
	end
end

return BattleSimulation