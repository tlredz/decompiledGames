local BattleSimulation = require(script.Parent:WaitForChild("BattleSimulation"))
local BattleExcitementScorer = require(script.Parent:WaitForChild("BattleExcitementScorer"))
local BattleStateClone = require(script.Parent:WaitForChild("BattleStateClone"))
local ArenaOverride = require(script.Parent:WaitForChild("ArenaOverride"))
local cloneArray = BattleStateClone.cloneArray
local cloneSpiderWebs = BattleStateClone.cloneSpiderWebs
local cloneLaserSegments = BattleStateClone.cloneLaserSegments
local clonePoisonSpikes = BattleStateClone.clonePoisonSpikes
local cloneHiveVenomStacks = BattleStateClone.cloneHiveVenomStacks
local cloneAcidPoisonStacks = BattleStateClone.cloneAcidPoisonStacks
local _ = BattleStateClone.clonePolygon
local cloneZoneRegions = BattleStateClone.cloneZoneRegions
local BattleReplayBuilder = {}
local estimateByteSize

estimateByteSize = function(list)
	local typeName = typeof(list)

	if typeName == "number" then
		return 8
	elseif typeName == "boolean" then
		return 1
	elseif typeName == "string" then
		return #list
	elseif typeName == "Vector2" then
		return 8
	elseif typeName == "Vector3" then
		return 12
	elseif typeName == "Color3" then
		return 12
	elseif typeName == "CFrame" then
		return 28
	end

	if typeName ~= "table" then
		return 0
	end

	local total = 0

	for k, v in list do
		total += estimateByteSize(k) + estimateByteSize(v)
	end

	return total
end

BattleReplayBuilder.estimateByteSize = estimateByteSize

function BattleReplayBuilder.printSizeBreakdown(p)
	print(string.format(
		"[回放大小拆分] 时长=%.2fs 快照数=%d 事件数=%d 总估算大小=%.1f KB",
		p.duration,
		#p.snapshots,
		#p.events,
		estimateByteSize(p) / 1024
	))
	local v = {}

	for k, v2 in p do
		v[k] = estimateByteSize(v2)
	end

	local v2 = {}

	for k, size in v do
		table.insert(v2, {
			key = k,
			size = size
		})
	end

	table.sort(v2, function(a, b)
		return a.size > b.size
	end)

	for _, v3 in v2 do
		print(string.format("  [顶层] %s: %.1f KB", v3.key, v3.size / 1024))
	end

	local v3 = {}

	for _, snapshot in p.snapshots do
		for _, ball in snapshot.state.balls do
			for k, v4 in ball do
				v3[k] = (v3[k] or 0) + estimateByteSize(v4)
			end
		end
	end

	local v4 = {}

	for k, size in v3 do
		table.insert(v4, {
			field = k,
			size = size
		})
	end

	table.sort(v4, function(a, b)
		return a.size > b.size
	end)

	for k, v5 in v4 do
		if k <= 8 then
			print(string.format("    [球字段] %s: %.1f KB", v5.field, v5.size / 1024))
		end
	end

	local v5 = {}

	for _, snapshot in p.snapshots do
		for _, ball in snapshot.state.balls do
			for k, trait in ball.traits do
				v5[k] = (v5[k] or 0) + estimateByteSize(trait)
			end
		end
	end

	local v6 = {}

	for k, size in v5 do
		table.insert(v6, {
			traitId = k,
			size = size
		})
	end

	table.sort(v6, function(a, b)
		return a.size > b.size
	end)

	for _, v7 in v6 do
		print(string.format("      [traits] %s: %.1f KB", v7.traitId, v7.size / 1024))
	end
end

local function sumTeam(p, p2: string, p3: string)
	local v = p.teams and p.teams[p2]

	if not v then
		local ball = p.balls[p2]
		return ball and ball[p3] or 0
	end

	local total = 0

	for _, v2 in v do
		local ball = p.balls[v2]
		total += not ball and 0 or ball[p3] or 0
	end

	return total
end

local function teamMaxHpOf(p, p2: string)
	return (sumTeam(p, p2, "maxHp"))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teamHpSample(p)
	return {
		blue = sumTeam(p, "Blue", "hp"),
		yellow = sumTeam(p, "Yellow", "hp")
	}
end

local function cloneDictionary(items)
	local result = {}

	for k, item in items do
		result[k] = item
	end

	return result
end

local function cloneBladeTraitState(item)
	if item then
		return {
			bladeCount = item.bladeCount,
			bladeGrowthCooldown = item.bladeGrowthCooldown,
			bladeRotation = item.bladeRotation,
			bladePositions = cloneArray(item.bladePositions),
			bladeHitCooldowns = cloneArray(item.bladeHitCooldowns),
			rotationSpeed = item.rotationSpeed
		}
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isBladeShapedState(p)
	return p.bladePositions ~= nil or p.bladeHitCooldowns ~= nil
end

local function cloneHookGrappleState(item)
	local v = {
		rotationAngle = item.rotationAngle,
		appliedRotationAngle = item.appliedRotationAngle,
		ropePositions = 0,
		capturedTargetId = 0,
		captureElapsed = 0,
		captureCooldownRemaining = 0,
		wallDamageCooldownRemaining = 0
	}
	local ropePositions

	if item.ropePositions then
		ropePositions = cloneArray(item.ropePositions) or nil
	end

	v.ropePositions = ropePositions
	v.capturedTargetId = item.capturedTargetId
	v.captureElapsed = item.captureElapsed
	v.captureCooldownRemaining = item.captureCooldownRemaining
	v.wallDamageCooldownRemaining = item.wallDamageCooldownRemaining
	return v
end

local function cloneMachineGunState(item)
	local bullets = {}

	for k, v2 in item.bullets or {} do
		bullets[k] = {
			bulletId = v2.bulletId,
			position = v2.position,
			direction = v2.direction
		}
	end

	return {
		cooldown = item.cooldown,
		firingElapsed = item.firingElapsed,
		shotCooldown = item.shotCooldown,
		nextBulletId = item.nextBulletId,
		bullets = bullets
	}
end

local function cloneDiceBarrageState(item)
	local dice = {}

	for k, v2 in item.dice or {} do
		local v3 = {
			diceId = v2.diceId,
			position = v2.position,
			topValue = v2.topValue,
			touchingByTarget = 0
		}
		local touchingByTarget = {}

		for k2, v5 in v2.touchingByTarget or {} do
			touchingByTarget[k2] = v5
		end

		v3.touchingByTarget = touchingByTarget
		dice[k] = v3
	end

	return {
		placeCooldown = item.placeCooldown,
		nextDiceId = item.nextDiceId,
		dice = dice
	}
end

local function cloneIceConeTrailState(item)
	local bombs = {}

	for k, v2 in item.bombs or {} do
		bombs[k] = {
			bombId = v2.bombId,
			position = v2.position,
			fuseElapsed = v2.fuseElapsed
		}
	end

	local iceCones = {}

	for k, v3 in item.iceCones or {} do
		iceCones[k] = {
			projectileId = v3.projectileId,
			position = v3.position,
			previousPosition = v3.previousPosition,
			direction = v3.direction,
			distanceTravelled = v3.distanceTravelled
		}
	end

	return {
		placeCooldown = item.placeCooldown,
		bombs = bombs,
		nextBombId = item.nextBombId,
		iceCones = iceCones,
		nextProjectileId = item.nextProjectileId
	}
end

local function cloneTimeBombState(item)
	local bombs = {}

	for k, v2 in item.bombs or {} do
		bombs[k] = {
			bombId = v2.bombId,
			position = v2.position,
			fuseElapsed = v2.fuseElapsed
		}
	end

	return {
		placeCooldown = item.placeCooldown,
		bombs = bombs,
		nextBombId = item.nextBombId
	}
end

local function clonePotionThrowState(item)
	local potions = {}

	for k, v2 in item.potions or {} do
		local v3 = {
			potionId = v2.potionId,
			potionType = v2.potionType,
			position = v2.position,
			elapsed = v2.elapsed,
			tickCooldownByTarget = 0
		}
		local tickCooldownByTarget = {}

		for k2, v5 in v2.tickCooldownByTarget or {} do
			tickCooldownByTarget[k2] = v5
		end

		v3.tickCooldownByTarget = tickCooldownByTarget
		potions[k] = v3
	end

	return {
		cooldown = item.cooldown,
		isWindingUp = item.isWindingUp,
		windupElapsed = item.windupElapsed,
		isFlying = item.isFlying,
		flightElapsed = item.flightElapsed,
		pendingType = item.pendingType,
		flightStartPosition = item.flightStartPosition,
		flightTargetPosition = item.flightTargetPosition,
		potions = potions,
		nextPotionId = item.nextPotionId
	}
end

local function cloneCactusThrowState(item)
	local cacti = {}

	for k, v2 in item.cacti or {} do
		local v3 = {
			cactusId = v2.cactusId,
			position = v2.position,
			elapsed = v2.elapsed,
			hitCooldownByTarget = 0
		}
		local hitCooldownByTarget = {}

		for k2, v5 in v2.hitCooldownByTarget or {} do
			hitCooldownByTarget[k2] = v5
		end

		v3.hitCooldownByTarget = hitCooldownByTarget
		cacti[k] = v3
	end

	local pendingTargets

	if item.pendingTargets then
		pendingTargets = table.clone(item.pendingTargets)
	end

	return {
		cooldown = item.cooldown,
		isFlying = item.isFlying,
		flightElapsed = item.flightElapsed,
		flightStartPosition = item.flightStartPosition,
		pendingTargets = pendingTargets,
		cacti = cacti,
		nextCactusId = item.nextCactusId
	}
end

local function cloneTrapReleaseState(item)
	local traps = {}

	for k, v2 in item.traps or {} do
		local v3 = {
			trapId = v2.trapId,
			position = v2.position,
			elapsed = v2.elapsed,
			isActive = v2.isActive,
			hitCooldownByTarget = 0,
			trappedTargets = 0
		}
		local hitCooldownByTarget = {}

		for k2, v5 in v2.hitCooldownByTarget or {} do
			hitCooldownByTarget[k2] = v5
		end

		v3.hitCooldownByTarget = hitCooldownByTarget
		local trappedTargets = {}

		for k2, v6 in v2.trappedTargets or {} do
			trappedTargets[k2] = v6
		end

		v3.trappedTargets = trappedTargets
		traps[k] = v3
	end

	return {
		cooldown = item.cooldown,
		traps = traps,
		nextTrapId = item.nextTrapId
	}
end

local function cloneSpearThrustState(item)
	local v = {
		speedBonus = item.speedBonus,
		poseProgress = item.poseProgress,
		isThrusting = item.isThrusting,
		targetHitCooldowns = 0
	}
	local targetHitCooldowns = {}

	for k, v3 in item.targetHitCooldowns or {} do
		targetHitCooldowns[k] = v3
	end

	v.targetHitCooldowns = targetHitCooldowns
	return v
end

local function cloneSnakeTailState(item)
	local tailSegments = {}

	for k, v2 in item.tailSegments or {} do
		local v3 = {
			tailId = v2.tailId,
			index = v2.index,
			position = v2.position,
			direction = v2.direction,
			fullScale = v2.fullScale,
			scale = v2.scale,
			radius = v2.radius,
			growthAlpha = v2.growthAlpha,
			isFullyGrown = v2.isFullyGrown,
			hitCooldownByTarget = 0
		}
		local hitCooldownByTarget = {}

		for k2, v5 in v2.hitCooldownByTarget or {} do
			hitCooldownByTarget[k2] = v5
		end

		v3.hitCooldownByTarget = hitCooldownByTarget
		tailSegments[k] = v3
	end

	return {
		tailSegments = tailSegments,
		nextTailId = item.nextTailId,
		growthCharge = item.growthCharge,
		growthThreshold = item.growthThreshold,
		waveElapsed = item.waveElapsed
	}
end

local function cloneOrbitSatelliteState(item)
	local ringCapacities = {}

	for k, v2 in item.ringCapacities or {} do
		ringCapacities[k] = v2
	end

	local ringRotations = {}

	for k, v3 in item.ringRotations or {} do
		ringRotations[k] = v3
	end

	local slots = {}

	for k, v4 in item.slots or {} do
		slots[k] = {
			ring = v4.ring,
			occupied = v4.occupied,
			rotationAngle = v4.rotationAngle,
			position = v4.position
		}
	end

	return {
		ringCapacities = ringCapacities,
		ringRotations = ringRotations,
		slots = slots,
		spawnCooldown = item.spawnCooldown
	}
end

local function cloneThiefKnivesState(item)
	local heldKnives = {}

	for k, v2 in item.heldKnives or {} do
		heldKnives[k] = {
			index = v2.index,
			angle = v2.angle,
			direction = v2.direction,
			position = v2.position
		}
	end

	local projectiles = {}

	for k, v3 in item.projectiles or {} do
		projectiles[k] = {
			projectileId = v3.projectileId,
			position = v3.position,
			direction = v3.direction
		}
	end

	return {
		phase = item.phase,
		chargeElapsed = item.chargeElapsed,
		chargeDuration = item.chargeDuration,
		plannedKnifeCount = item.plannedKnifeCount,
		lockedTargetId = item.lockedTargetId,
		lockedAimDirection = item.lockedAimDirection,
		throwInterval = item.throwInterval,
		throwCooldown = item.throwCooldown,
		nextKnifeIndex = item.nextKnifeIndex,
		nextProjectileId = item.nextProjectileId,
		heldKnives = heldKnives,
		projectiles = projectiles
	}
end

local function cloneChessPathState(item)
	local routeGroups = {}

	for k, v2 in item.routeGroups or {} do
		routeGroups[k] = cloneArray(v2)
	end

	local v2 = {
		cooldown = item.cooldown,
		phase = item.phase,
		selectedPiece = item.selectedPiece,
		routeGroups = routeGroups,
		routeGroupIndex = item.routeGroupIndex,
		waypointIndex = item.waypointIndex,
		previousPosition = item.previousPosition,
		targetHitCooldowns = 0,
		isActive = 0,
		phaseElapsed = 0
	}
	local targetHitCooldowns = {}

	for k, v4 in item.targetHitCooldowns or {} do
		targetHitCooldowns[k] = v4
	end

	v2.targetHitCooldowns = targetHitCooldowns
	v2.isActive = item.isActive
	v2.phaseElapsed = item.phaseElapsed
	return v2
end

local function cloneGlassShardsState(item)
	local shards = {}

	for k, v2 in item.shards or {} do
		shards[k] = {
			shardId = v2.shardId,
			position = v2.position,
			rotationX = v2.rotationX,
			rotationY = v2.rotationY
		}
	end

	return {
		shards = shards,
		nextShardId = item.nextShardId,
		wallCooldown = item.wallCooldown,
		collisionCooldown = item.collisionCooldown,
		damageCooldown = item.damageCooldown
	}
end

local function cloneAppleThrowState(item)
	local apples = {}

	for k, v2 in item.apples or {} do
		apples[k] = {
			appleId = v2.appleId,
			phase = v2.phase,
			position = v2.position,
			direction = v2.direction,
			traveled = v2.traveled,
			targetDistance = v2.targetDistance,
			ownerTeam = v2.ownerTeam,
			residueRemaining = v2.residueRemaining
		}
	end

	return {
		throwCooldown = item.throwCooldown,
		nextAppleId = item.nextAppleId,
		apples = apples
	}
end

local function cloneAcidSpitState(item)
	local droplets = {}

	for k, v2 in item.droplets or {} do
		droplets[k] = {
			dropletId = v2.dropletId,
			phase = v2.phase,
			position = v2.position,
			direction = v2.direction,
			traveled = v2.traveled,
			targetDistance = v2.targetDistance,
			puddleRadius = v2.puddleRadius,
			puddleResidueRemaining = v2.puddleResidueRemaining
		}
	end

	return {
		spitCooldown = item.spitCooldown,
		nextDropletId = item.nextDropletId,
		droplets = droplets
	}
end

local function cloneCannonTurretState(item)
	local wallEntries = {}

	for k, v in item.turrets or {} do
		wallEntries[k] = {
			turretId = v.turretId,
			position = v.position,
			normal = v.normal,
			residueRemaining = v.residueRemaining,
			fireCooldown = v.fireCooldown,
			aimDirection = v.aimDirection,
			wallKey = v.wallKey
		}
	end

	local bullets = {}

	for k, v2 in item.bullets or {} do
		bullets[k] = {
			bulletId = v2.bulletId,
			position = v2.position,
			direction = v2.direction
		}
	end

	local v2 = {
		turrets = wallEntries,
		nextTurretId = item.nextTurretId,
		bullets = bullets,
		nextBulletId = item.nextBulletId,
		lastSpawnPositionByWall = 0
	}
	local lastSpawnPositionByWall = {}

	for k, v4 in item.lastSpawnPositionByWall or {} do
		lastSpawnPositionByWall[k] = v4
	end

	v2.lastSpawnPositionByWall = lastSpawnPositionByWall
	return v2
end

local function cloneLaserTurretV3State(item)
	local wallEntries = {}

	for k, v in item.turrets or {} do
		wallEntries[k] = {
			turretId = v.turretId,
			position = v.position,
			normal = v.normal,
			aimDirection = v.aimDirection,
			residueRemaining = v.residueRemaining,
			fireCooldown = v.fireCooldown,
			flashRemaining = v.flashRemaining,
			wallKey = v.wallKey
		}
	end

	local v = {
		turrets = wallEntries,
		nextTurretId = item.nextTurretId,
		lastSpawnPositionByWall = 0
	}
	local lastSpawnPositionByWall = {}

	for k, v3 in item.lastSpawnPositionByWall or {} do
		lastSpawnPositionByWall[k] = v3
	end

	v.lastSpawnPositionByWall = lastSpawnPositionByWall
	return v
end

local function cloneElectroKingGridState(item)
	local wallEntries = {}

	for k, v in item.nodes or {} do
		wallEntries[k] = {
			nodeId = v.nodeId,
			position = v.position,
			residueRemaining = v.residueRemaining,
			wallKey = v.wallKey
		}
	end

	local edges = {}

	for k, v2 in item.edges or {} do
		edges[k] = {
			edgeIndex = v2.edgeIndex,
			startPosition = v2.startPosition,
			endPosition = v2.endPosition
		}
	end

	local shockTickCooldownByTarget = {}

	for k, v3 in item.shockTickCooldownByTarget or {} do
		local v4 = {}

		for k2, v5 in v3 do
			v4[k2] = v5
		end

		shockTickCooldownByTarget[k] = v4
	end

	local v3 = {
		nodes = wallEntries,
		nextNodeId = item.nextNodeId,
		edges = edges,
		lastSpawnPositionByWall = 0,
		shockCooldown = 0,
		shockActiveRemaining = 0,
		shockTickCooldownByTarget = 0
	}
	local lastSpawnPositionByWall = {}

	for k, v5 in item.lastSpawnPositionByWall or {} do
		lastSpawnPositionByWall[k] = v5
	end

	v3.lastSpawnPositionByWall = lastSpawnPositionByWall
	v3.shockCooldown = item.shockCooldown
	v3.shockActiveRemaining = item.shockActiveRemaining
	v3.shockTickCooldownByTarget = shockTickCooldownByTarget
	return v3
end

local function cloneChargedBowState(item)
	local arrows = {}

	for k, v2 in item.arrows or {} do
		arrows[k] = {
			arrowId = v2.arrowId,
			position = v2.position,
			direction = v2.direction,
			bouncesRemaining = v2.bouncesRemaining,
			lifetimeRemaining = v2.lifetimeRemaining,
			damage = v2.damage
		}
	end

	return {
		phase = item.phase,
		moveCooldown = item.moveCooldown,
		chargeElapsed = item.chargeElapsed,
		aimDirection = item.aimDirection,
		arrows = arrows,
		nextArrowId = item.nextArrowId
	}
end

local function cloneHarpoonState(item)
	return {
		phase = item.phase,
		throwCooldown = item.throwCooldown,
		direction = item.direction,
		position = item.position,
		pathPoints = table.clone(item.pathPoints or {}),
		bounceCount = item.bounceCount,
		capturedTargetId = item.capturedTargetId,
		pullSegmentIndex = item.pullSegmentIndex,
		pullSegmentProgress = item.pullSegmentProgress,
		pullTickCooldown = item.pullTickCooldown
	}
end

local function cloneHiveSwarmState(item)
	local bees = {}

	for k, v2 in item.bees or {} do
		bees[k] = {
			beeId = v2.beeId,
			phase = v2.phase,
			position = v2.position,
			direction = v2.direction,
			lifetimeRemaining = v2.lifetimeRemaining,
			decelElapsed = v2.decelElapsed,
			deathInitialSpeed = v2.deathInitialSpeed,
			fadeAlpha = v2.fadeAlpha
		}
	end

	local pendingSpawns = {}

	for k, v3 in item.pendingSpawns or {} do
		pendingSpawns[k] = {
			delay = v3.delay
		}
	end

	return {
		waveCooldown = item.waveCooldown,
		waveCount = item.waveCount,
		pendingSpawns = pendingSpawns,
		bees = bees,
		nextBeeId = item.nextBeeId
	}
end

local function cloneRobuxBarrageState(item)
	local clone = table.clone(item)
	clone.projectiles = {}

	for k, v in item.projectiles or {} do
		clone.projectiles[k] = table.clone(v)
	end

	return clone
end

local function cloneShurikenState(item)
	local shurikens = {}

	for k, v2 in item.shurikens or {} do
		shurikens[k] = {
			shurikenId = v2.shurikenId,
			position = v2.position,
			direction = v2.direction,
			elapsed = v2.elapsed,
			lifetimeRemaining = v2.lifetimeRemaining
		}
	end

	local pendingSpawns = {}

	for k, v3 in item.pendingSpawns or {} do
		pendingSpawns[k] = {
			delay = v3.delay
		}
	end

	return {
		waveCooldown = item.waveCooldown,
		waveCount = item.waveCount,
		pendingSpawns = pendingSpawns,
		shurikens = shurikens,
		nextShurikenId = item.nextShurikenId
	}
end

local function cloneMedicBarrageState(item)
	local bullets = {}

	for k, v2 in item.bullets or {} do
		bullets[k] = {
			bulletId = v2.bulletId,
			position = v2.position,
			direction = v2.direction,
			bounceCount = v2.bounceCount
		}
	end

	return {
		emitCooldown = item.emitCooldown,
		bullets = bullets,
		nextBulletId = item.nextBulletId
	}
end

local function cloneMathEquationState(item)
	local bullets = {}

	for k, v2 in item.bullets or {} do
		bullets[k] = {
			bulletId = v2.bulletId,
			position = v2.position,
			direction = v2.direction,
			damage = v2.damage,
			lifetimeRemaining = v2.lifetimeRemaining
		}
	end

	local equation = item.equation and {
		a = item.equation.a,
		b = item.equation.b,
		operator = item.equation.operator,
		result = item.equation.result
	} or nil
	return {
		phase = item.phase,
		phaseElapsed = item.phaseElapsed,
		calcSerial = item.calcSerial,
		equation = equation,
		bullets = bullets,
		nextBulletId = item.nextBulletId
	}
end

local function cloneExpandingAuraState(item)
	local v = {
		currentRadius = item.currentRadius,
		tickCooldownByTarget = 0
	}
	local tickCooldownByTarget = {}

	for k, v3 in item.tickCooldownByTarget or {} do
		tickCooldownByTarget[k] = v3
	end

	v.tickCooldownByTarget = tickCooldownByTarget
	return v
end

local function cloneFrostTrailState(item)
	local trail = {}

	for k, v2 in item.trail or {} do
		trail[k] = {
			trailId = v2.trailId,
			position = v2.position,
			residueRemaining = v2.residueRemaining
		}
	end

	return {
		spawnCooldown = item.spawnCooldown,
		trail = trail,
		nextTrailId = item.nextTrailId
	}
end

local function cloneWdcState(item)
	local cells

	if item.cells then
		cells = {}

		for k, cell in item.cells do
			cells[k] = {
				value = cell.value
			}
		end
	end

	return {
		phase = item.phase,
		phaseElapsed = item.phaseElapsed,
		cooldown = item.cooldown,
		cells = cells,
		currentCellIndex = item.currentCellIndex
	}
end

local function cloneDogCannonState(item)
	local v = {
		phase = item.phase,
		chargeElapsed = item.chargeElapsed,
		particleCooldown = item.particleCooldown,
		beamElapsed = item.beamElapsed,
		aimDirection = item.aimDirection,
		beamStart = item.beamStart,
		beamEnd = item.beamEnd,
		hitTickCooldownByTarget = 0
	}
	local hitTickCooldownByTarget = {}

	for k, v3 in item.hitTickCooldownByTarget or {} do
		hitTickCooldownByTarget[k] = v3
	end

	v.hitTickCooldownByTarget = hitTickCooldownByTarget
	return v
end

local function cloneTrainTrackState(item)
	local trackPoints = {}

	for k, v2 in item.trackPoints or {} do
		trackPoints[k] = v2
	end

	local cumulativeLengths = {}

	for k, v3 in item.cumulativeLengths or {} do
		cumulativeLengths[k] = v3
	end

	local nodeIndices = {}

	for k, v4 in item.nodeIndices or {} do
		nodeIndices[k] = v4
	end

	local cars = {}

	for k, v5 in item.cars or {} do
		cars[k] = {
			carIndex = v5.carIndex,
			isHead = v5.isHead,
			mileage = v5.mileage,
			position = v5.position,
			direction = v5.direction,
			isVisible = v5.isVisible
		}
	end

	local targetHitCooldowns = {}

	for k, v6 in item.targetHitCooldowns or {} do
		local v7 = {}

		for k2, v8 in v6 do
			v7[k2] = v8
		end

		targetHitCooldowns[k] = v7
	end

	return {
		phase = item.phase,
		cooldown = item.cooldown,
		waitRemaining = item.waitRemaining,
		trainHeadDistance = item.trainHeadDistance,
		lastNodePosition = item.lastNodePosition,
		trackPoints = trackPoints,
		cumulativeLengths = cumulativeLengths,
		nodeIndices = nodeIndices,
		cars = cars,
		targetHitCooldowns = targetHitCooldowns
	}
end

local function cloneVolcanoEruptionState(item)
	local flames = {}

	for k, v2 in item.flames or {} do
		flames[k] = {
			flameId = v2.flameId,
			angleOffset = v2.angleOffset,
			direction = v2.direction,
			length = v2.length,
			maxLength = v2.maxLength
		}
	end

	return {
		phase = item.phase,
		phaseRemaining = item.phaseRemaining,
		aimDirection = item.aimDirection,
		nextFlameId = item.nextFlameId,
		flames = flames
	}
end

local function cloneTraits(traits)
	local result = {}

	for k, item in traits do
		if item == nil then
			result[k] = nil
		elseif isBladeShapedState(item) then
			result[k] = cloneBladeTraitState(item)
		elseif k == "MachineGun" then
			result.MachineGun = cloneMachineGunState(item)
		elseif k == "AppleThrow" then
			result.AppleThrow = cloneAppleThrowState(item)
		elseif k == "AcidSpit" then
			result.AcidSpit = cloneAcidSpitState(item)
		elseif k == "CannonTurret" then
			result.CannonTurret = cloneCannonTurretState(item)
		elseif k == "LaserTurretV3" then
			result.LaserTurretV3 = cloneLaserTurretV3State(item)
		elseif k == "ElectroKingGrid" then
			result.ElectroKingGrid = cloneElectroKingGridState(item)
		elseif k == "TrainTrack" then
			result.TrainTrack = cloneTrainTrackState(item)
		elseif k == "ExpandingAura" then
			result.ExpandingAura = cloneExpandingAuraState(item)
		elseif k == "FrostTrail" then
			result.FrostTrail = cloneFrostTrailState(item)
		elseif k == "AlchemistGasTrail" then
			result.AlchemistGasTrail = cloneFrostTrailState(item)
		elseif k == "ChargedBow" then
			result.ChargedBow = cloneChargedBowState(item)
		elseif k == "Harpoon" then
			result.Harpoon = cloneHarpoonState(item)
		elseif k == "HiveSwarm" then
			result.HiveSwarm = cloneHiveSwarmState(item)
		elseif k == "RobuxBarrage" then
			result.RobuxBarrage = cloneRobuxBarrageState(item)
		elseif k == "Shuriken" then
			result.Shuriken = cloneShurikenState(item)
		elseif k == "MedicBarrage" then
			result.MedicBarrage = cloneMedicBarrageState(item)
		elseif k == "MathEquation" then
			result.MathEquation = cloneMathEquationState(item)
		elseif k == "DiceBarrage" then
			result.DiceBarrage = cloneDiceBarrageState(item)
		elseif k == "SnakeTail" then
			result.SnakeTail = cloneSnakeTailState(item)
		elseif k == "OrbitSatellite" then
			result.OrbitSatellite = cloneOrbitSatelliteState(item)
		elseif k == "ThiefKnives" then
			result.ThiefKnives = cloneThiefKnivesState(item)
		elseif k == "IceConeTrail" then
			result.IceConeTrail = cloneIceConeTrailState(item)
		elseif k == "TimeBomb" then
			result.TimeBomb = cloneTimeBombState(item)
		elseif k == "PotionThrow" then
			result.PotionThrow = clonePotionThrowState(item)
		elseif k == "CactusThrow" then
			result.CactusThrow = cloneCactusThrowState(item)
		elseif k == "TrapRelease" then
			result.TrapRelease = cloneTrapReleaseState(item)
		elseif k == "SpearThrust" then
			result.SpearThrust = cloneSpearThrustState(item)
		elseif k == "Fibonacci" then
			result.Fibonacci = {
				hitIndex = item.hitIndex,
				impactPending = item.impactPending
			}
		elseif k == "GlassShards" then
			result.GlassShards = cloneGlassShardsState(item)
		elseif k == "ChessPath" then
			result.ChessPath = cloneChessPathState(item)
		elseif k == "OnePunch" then
			result.OnePunch = {
				phase = item.phase,
				phaseElapsed = item.phaseElapsed,
				cooldown = item.cooldown,
				targetId = item.targetId,
				dashDirection = item.dashDirection,
				punchSerial = item.punchSerial
			}
		elseif k == "WDC" then
			result.WDC = cloneWdcState(item)
		elseif k == "DogCannon" then
			result.DogCannon = cloneDogCannonState(item)
		elseif k == "VolcanoEruption" then
			result.VolcanoEruption = cloneVolcanoEruptionState(item)
		elseif k == "VoltaicShock" then
			result.VoltaicShock = {
				chargeElapsed = item.chargeElapsed,
				isCharged = item.isCharged
			}
		elseif k == "HookGrapple" then
			result.HookGrapple = cloneHookGrappleState(item)
		elseif k == "ThomasUpgrade" and item.thomas then
			local thomas = {
				position = item.thomas.position,
				direction = item.thomas.direction,
				baseRadius = item.thomas.baseRadius,
				radius = item.thomas.radius,
				level = item.thomas.level,
				scale = item.thomas.scale,
				hitCooldowns = 0
			}
			local hitCooldowns = {}
			local thomasUpgrade = {
				thomas = 0
			}

			for k2, hitCooldown in item.thomas.hitCooldowns do
				hitCooldowns[k2] = hitCooldown
			end

			thomas.hitCooldowns = hitCooldowns
			thomasUpgrade.thomas = thomas
			result.ThomasUpgrade = thomasUpgrade
		else
			local v = {}

			for k2, v2 in item do
				v[k2] = v2
			end

			result[k] = v
		end
	end

	return result
end

local function cloneBallState(ball)
	local v = {
		id = ball.id,
		slotDisplayName = ball.slotDisplayName,
		roleId = ball.roleId,
		displayName = ball.displayName,
		color = ball.color,
		highlightColor = ball.highlightColor,
		position = ball.position,
		direction = ball.direction,
		team = ball.team,
		baseRadius = ball.baseRadius,
		radius = ball.radius,
		maxHp = ball.maxHp,
		hp = ball.hp,
		attack = ball.attack,
		baseSpeed = ball.baseSpeed,
		currentSpeed = ball.currentSpeed,
		collisionCooldown = ball.collisionCooldown,
		nextHitBonusReady = ball.nextHitBonusReady,
		speedBoostTimeRemaining = ball.speedBoostTimeRemaining,
		speedBoostCooldown = ball.speedBoostCooldown,
		chargeMultiplier = ball.chargeMultiplier,
		chargeTimer = ball.chargeTimer
	}
	local skill = {}

	for k, v3 in ball.skill do
		skill[k] = v3
	end

	v.skill = skill
	v.traits = cloneTraits(ball.traits)
	v.activeDamageReduction = ball.activeDamageReduction
	v.attackBuffActive = ball.attackBuffActive
	v.defenseBuffActive = ball.defenseBuffActive
	v.vampireStateRemaining = ball.vampireStateRemaining
	v.vampireTickCooldown = ball.vampireTickCooldown
	v.vampireTicksApplied = ball.vampireTicksApplied
	v.vampireAttachedTargetId = ball.vampireAttachedTargetId
	v.vampireAttachOffsetDirection = ball.vampireAttachOffsetDirection
	v.vampireVictimSourceId = ball.vampireVictimSourceId
	v.spiderWebs = cloneSpiderWebs(ball.spiderWebs)
	v.vampireWebs = cloneSpiderWebs(ball.vampireWebs)
	v.laserAnchorPosition = ball.laserAnchorPosition
	v.laserAnchorWallKey = ball.laserAnchorWallKey
	v.laserSegments = cloneLaserSegments(ball.laserSegments)
	v.poisonSpikes = clonePoisonSpikes(ball.poisonSpikes)
	v.hiveVenomStacks = cloneHiveVenomStacks(ball.hiveVenomStacks or {})
	v.acidPoisonStacks = cloneAcidPoisonStacks(ball.acidPoisonStacks or {})
	v.poisonRemaining = ball.poisonRemaining
	v.poisonTickCooldown = ball.poisonTickCooldown
	v.poisonedByBallId = ball.poisonedByBallId
	v.burnRemaining = ball.burnRemaining
	v.burnTickCooldown = ball.burnTickCooldown
	v.burnedByBallId = ball.burnedByBallId
	v.burnedByTraitId = ball.burnedByTraitId
	v.burnFlameContactRemaining = ball.burnFlameContactRemaining
	v.burnFlameSlowTraitId = ball.burnFlameSlowTraitId
	v.slowRemaining = ball.slowRemaining
	v.slowedByTraitId = ball.slowedByTraitId
	v.hasteRemaining = ball.hasteRemaining
	v.hastenedByTraitId = ball.hastenedByTraitId
	v.electromagneticParalysisProgress = ball.electromagneticParalysisProgress
	v.frostLevel = ball.frostLevel
	v.frostTickCooldown = ball.frostTickCooldown
	v.potionFrostLevel = ball.potionFrostLevel
	v.potionFrostTickCooldown = ball.potionFrostTickCooldown
	v.zonePreviewAnchorPosition = ball.zonePreviewAnchorPosition
	v.zonePreviewWallKey = ball.zonePreviewWallKey
	v.zoneRegions = cloneZoneRegions(ball.zoneRegions)
	v.nextZoneRegionId = ball.nextZoneRegionId
	v.hookCapturedByBallId = ball.hookCapturedByBallId
	v.harpoonCapturedByBallId = ball.harpoonCapturedByBallId
	v.voltaicShockSourceBallId = ball.voltaicShockSourceBallId
	v.voltaicShockAnchorPosition = ball.voltaicShockAnchorPosition
	v.voltaicShockRemaining = ball.voltaicShockRemaining
	v.voltaicShockTickCooldown = ball.voltaicShockTickCooldown
	v.voltaicShockTicksApplied = ball.voltaicShockTicksApplied
	return v
end

local function cloneState(data)
	local balls = {}

	for k, ball in data.balls do
		balls[k] = cloneBallState(ball)
	end

	local teams = {}

	if data.teams then
		for k, team in data.teams do
			teams[k] = cloneArray(team)
		end
	end

	return {
		elapsed = data.elapsed,
		finished = data.finished,
		winner = data.winner,
		balls = balls,
		teams = teams
	}
end

BattleReplayBuilder.cloneState = cloneState

local function cloneEvent(p, p2)
	local result = {
		type = p.type,
		t = p2
	}

	for k, v in p do
		if k ~= "type" then
			result[k] = v
		end
	end

	return result
end

BattleReplayBuilder.SNAPSHOT_INTERVAL_DISABLED = 1000000000

function BattleReplayBuilder.buildReplay(p, seed, data)
	local config = ArenaOverride.resolveConfig(p, data and data.arena)
	local fixedDt = data and data.fixedDt or config.replay.fixedDt
	local snapshotInterval = data and data.snapshotInterval or config.replay.snapshotInterval
	local maxDuration = data and data.maxDuration or config.replay.maxDuration
	local hpSampleInterval = data and data.hpSampleInterval or config.replay.snapshotInterval
	local new = BattleSimulation.new
	local selectedRoles

	if data then
		selectedRoles = data.selectedRoles or nil
	end

	local selectedSecondaryTraits

	if data then
		selectedSecondaryTraits = data.selectedSecondaryTraits or nil
	end

	local v

	if data then
		v = data.statLevels or nil
	end

	local v2 = new(config, seed, selectedRoles, selectedSecondaryTraits, v, data and data.initialDirections or nil)
	local state = v2:getState()
	local roleIds = {}

	for k, ball in state.balls do
		roleIds[k] = ball.roleId
	end

	local snapshots = {
		{
			t = 0,
			state = cloneState(state)
		}
	}
	local hpTrack = { teamHpSample(state) }
	local initialMaxHp = {
		Blue = sumTeam(state, "Blue", "maxHp"),
		Yellow = sumTeam(state, "Yellow", "maxHp")
	}
	local v6 = hpSampleInterval
	local v7 = snapshotInterval
	local events = {}

	for _ = 1, math.max(1, (math.ceil(maxDuration / fixedDt))) do
		local v9, v10 = v2:step(fixedDt)
		local elapsed = v9.elapsed

		for _, v11 in v10 do
			local v12 = {
				type = v11.type,
				t = elapsed
			}

			for k, v13 in v11 do
				if k ~= "type" then
					v12[k] = v13
				end
			end

			table.insert(events, v12)
		end

		while v7 <= elapsed + 1e-6 do
			table.insert(snapshots, {
				t = v7,
				state = cloneState(v9)
			})
			v7 += snapshotInterval
		end

		while v6 <= elapsed + 1e-6 do
			table.insert(hpTrack, teamHpSample(v9))
			v6 += hpSampleInterval
		end

		if v9.finished then
			break
		end
	end

	local state2 = cloneState(v2:getState())
	local v9 = snapshots[#snapshots]

	if v9 and not (math.abs(v9.t - state2.elapsed) > 1e-6) then
		v9.state = state2
		v9.t = state2.elapsed
	else
		table.insert(snapshots, {
			t = state2.elapsed,
			state = state2
		})
	end

	if not state2.finished then
		state2.finished = true
		state2.winner = "Draw"
		table.insert(events, {
			type = "battle_end",
			winner = state2.winner,
			t = state2.elapsed
		})
	end

	table.insert(hpTrack, teamHpSample(state2))
	return {
		seed = seed,
		fixedDt = fixedDt,
		snapshotInterval = snapshotInterval,
		duration = state2.elapsed,
		winner = state2.winner,
		roles = roleIds,
		snapshots = snapshots,
		hpTrack = hpTrack,
		initialMaxHp = initialMaxHp,
		events = events
	}
end

function BattleReplayBuilder.buildBestOfN(p, p2: number, p3, value: number?, value2: number?)
	local candidateCount = math.max(1, value or 1)
	local v2 = math.max(1, value2 or 1)
	local excitementScore = -1e999
	local v4 = nil

	for i = 1, candidateCount do
		local v5 = p2 + i * 7919
		local replay = BattleReplayBuilder.buildReplay(p, v5, p3)
		local score = BattleExcitementScorer.score(replay, p)

		if excitementScore < score then
			v4 = replay
			excitementScore = score
		end

		if i % v2 == 0 and i < candidateCount then
			task.wait()
		end
	end

	v4.excitementScore = excitementScore
	v4.candidateCount = candidateCount
	return v4
end

function BattleReplayBuilder.buildResult(p, seed, data)
	local config = ArenaOverride.resolveConfig(p, data and data.arena)
	local fixedDt = data and data.fixedDt or config.replay.fixedDt
	local maxDuration = data and data.maxDuration or config.replay.maxDuration
	local new = BattleSimulation.new
	local selectedRoles

	if data then
		selectedRoles = data.selectedRoles or nil
	end

	local selectedSecondaryTraits

	if data then
		selectedSecondaryTraits = data.selectedSecondaryTraits or nil
	end

	local v

	if data then
		v = data.statLevels or nil
	end

	local v2 = new(config, seed, selectedRoles, selectedSecondaryTraits, v, data and data.initialDirections or nil)
	local state = v2:getState()

	for _ = 1, math.max(1, (math.ceil(maxDuration / fixedDt))) do
		state = v2:step(fixedDt)

		if state.finished then
			break
		end
	end

	return {
		seed = seed,
		winner = not state.finished and "Draw" or state.winner,
		duration = state.elapsed
	}
end

return BattleReplayBuilder