local BattleSkills = {
	RobuxBarrage = require(script.Parent.BattleSkill_RobuxBarrage),
	VerityForms = require(script.Parent.BattleSkill_VerityForms)
}
local TrainTrackGeometry = require(script.Parent.TrainTrackGeometry)
local SpearThrustGeometry = require(script.Parent.SpearThrustGeometry)
local OrbitRingGeometry = require(script.Parent.OrbitRingGeometry)
local MathEquationTiming = require(script.Parent.MathEquationTiming)

-- equivalent calls inferred from this helper; original call sites unknown
local function closestPointOnSegment(position: Vector2, position2: Vector2, point: Vector2)
	local vector = point - position2
	local dot = vector:Dot(vector)

	if dot <= 1e-6 then
		return position2
	end

	return position2 + vector * math.clamp((position - position2):Dot(vector) / dot, 0, 1)
end

BattleSkills.Interval = {
	initialize = function(p, p2, p3)
		p2.speedBoostCooldown = p.config.traits[p3].interval
	end,
	updateFrame = function(p, state, _, p2, list, speedBoostTraitId)
		local trait = p.config.traits[speedBoostTraitId]
		state.speedBoostTimeRemaining = math.max(0, state.speedBoostTimeRemaining - p2)
		state.speedBoostCooldown -= p2

		if state.speedBoostCooldown <= 0 then
			state.speedBoostTimeRemaining = trait.duration
			state.speedBoostTraitId = speedBoostTraitId
			state.speedBoostCooldown += trait.interval
			table.insert(list, {
				type = "speed_boost",
				ballId = state.id,
				position = state.position
			})
		end
	end,
	collisionDamage = function(p, p2, p3)
		local trait = p.config.traits[p3]

		if p2.speedBoostTimeRemaining > 0 and trait.boostCollisionDamage then
			return math.round(trait.boostCollisionDamage), false
		end

		return math.round(p2.attack), false
	end
}
BattleSkills.DeathSplit = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			growthElapsed = 0,
			grown = false
		}
	end,
	updateFrame = function(p, state, _, p2, list, p3)
		local trait = p.config.traits[p3]
		local trait2 = state.traits[p3]

		if not trait2 or trait2.grown then
			return
		end

		trait2.growthElapsed += p2

		if trait2.growthElapsed >= (trait.growthTime or 1e999) then
			trait2.grown = true
			state.radius = state.baseRadius * (trait.growthScale or 1)
			table.insert(list, {
				type = "cell_grown",
				ballId = state.id,
				position = state.position
			})
		end
	end,
	collisionDamage = function(_, p, _)
		return math.round(p.attack), false
	end
}
BattleSkills.NoCollisionCharge = {
	updateFrame = function(_, state, _, p, list)
		local baseMultiplier = state.skill.baseMultiplier or 1
		local chargeStep = state.skill.chargeStep or 0
		local maxMultiplier = state.skill.maxMultiplier or baseMultiplier
		local chargeInterval = state.skill.chargeInterval or 1e999
		local scaleStep = state.skill.scaleStep or 0

		if chargeStep <= 0 or chargeInterval <= 0 then
			return
		end

		state.chargeTimer += p

		while chargeInterval <= state.chargeTimer and state.chargeMultiplier < maxMultiplier do
			state.chargeTimer -= chargeInterval
			state.chargeMultiplier = math.min(maxMultiplier, state.chargeMultiplier + chargeStep)

			if scaleStep > 0 then
				state.radius = state.baseRadius * (1 + scaleStep * (state.chargeMultiplier - baseMultiplier) / math.max(
					chargeStep,
					1e-6
				))
			end

			table.insert(list, {
				type = "charge_gain",
				ballId = state.id,
				position = state.position,
				damage = math.round(state.chargeMultiplier * 100)
			})

			if not (maxMultiplier <= state.chargeMultiplier) then
				continue
			end

			state.chargeTimer = 0
			break
		end
	end,
	collisionDamage = function(_, data)
		local attack = math.round(data.attack)
		local v = data.chargeMultiplier > (data.skill.baseMultiplier or 1)
		return math.round(attack * data.chargeMultiplier), v
	end,
	onCollisionResolved = function(_, state, _, list)
		if state.chargeMultiplier > (state.skill.baseMultiplier or 1) then
			table.insert(list, {
				type = "charge_release",
				ballId = state.id,
				position = state.position,
				damage = math.round(state.chargeMultiplier * 100)
			})
		end

		state.chargeMultiplier = state.skill.baseMultiplier or 1
		state.radius = state.baseRadius
		state.chargeTimer = 0
	end
}
BattleSkills.VoltaicShock = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			chargeElapsed = trait.chargeDuration or 0,
			isCharged = true
		}
	end,
	updateFrame = function(p, data, _, p2, list, p3)
		local trait = data.traits[p3]
		local trait2 = p.config.traits[p3]

		if not trait or trait.isCharged then
			return
		end

		trait.chargeElapsed = math.min(trait2.chargeDuration or 0, (trait.chargeElapsed or 0) + p2)

		if trait.chargeElapsed >= (trait2.chargeDuration or 0) then
			trait.isCharged = true
			table.insert(list, {
				type = "voltaic_charge_ready",
				ballId = data.id,
				position = data.position
			})
		end
	end,
	collisionDamage = function(_, p, _)
		return math.round(p.attack), false
	end,
	onEnemyCollision = function(object, p, p2, p3, p4)
		local trait = p.traits[p4]

		if trait and trait.isCharged and object:_applyVoltaicShock(p, p2, p4, p3) then
			trait.chargeElapsed = 0
			trait.isCharged = false
		end
	end
}
BattleSkills.Passive = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		local trait2 = p2.traits[p3]
		trait2.bladeCount = trait.startingBladeCount
		trait2.bladeGrowthCooldown = trait.growthInterval

		for i = 1, trait.maxBladeCount do
			trait2.bladeHitCooldowns[i] = 0
		end
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]
		trait2.bladeRotation = (trait2.bladeRotation + trait.rotationSpeed * p) % 6.283185307179586

		for i = 1, #trait2.bladeHitCooldowns do
			trait2.bladeHitCooldowns[i] = math.max(0, trait2.bladeHitCooldowns[i] - p)
		end

		if trait2.bladeCount < trait.maxBladeCount then
			trait2.bladeGrowthCooldown -= p

			if trait2.bladeGrowthCooldown <= 0 then
				trait2.bladeCount += 1
				trait2.bladeGrowthCooldown += trait.growthInterval
				table.insert(list, {
					type = "blade_growth",
					ballId = data.id,
					position = data.position,
					count = trait2.bladeCount
				})
			end
		end

		trait2.bladePositions = object:_rebuildBladePositions(data, p2)
	end,
	weaponHits = function(object, data, state, list, p)
		local trait = object.config.traits[p]
		local trait2 = data.traits[p]

		for i = 1, trait2.bladeCount do
			local bladePosition = trait2.bladePositions[i]

			if not (bladePosition and trait2.bladeHitCooldowns[i] <= 0 and (state.position - bladePosition).Magnitude <= state.radius + object:_getEffectCollisionRadius(object.config.visual.bladeTemplateName)) then
				continue
			end

			local _applyDamageModifiers = object:_applyDamageModifiers(data, state, (math.round(trait.bladeDamage)))

			if not (_applyDamageModifiers > 0) then
				continue
			end

			state.hp = math.max(0, state.hp - _applyDamageModifiers)
			trait2.bladeHitCooldowns[i] = trait.bladeHitCooldown
			table.insert(list, {
				type = "blade_hit",
				ballId = state.id,
				otherBallId = data.id,
				position = bladePosition,
				startPosition = state.position,
				endPosition = data.position,
				damage = _applyDamageModifiers,
				bladeIndex = i
			})
			object:_onDamageDealt(data, state, _applyDamageModifiers, list)
		end
	end
}
BattleSkills.OrbitSatellite = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		local capacityForRings = {}
		local ringRotations = {}
		local slots = {}

		for i = 1, OrbitRingGeometry.RING_COUNT do
			local capacityForRing = OrbitRingGeometry.capacityForRing(trait, i)
			capacityForRings[i] = capacityForRing
			ringRotations[i] = 0

			for _ = 1, capacityForRing do
				table.insert(slots, {
					ring = i,
					occupied = false,
					rotationAngle = 0,
					position = p2.position
				})
			end
		end

		p2.traits[p3] = {
			ringCapacities = capacityForRings,
			ringRotations = ringRotations,
			slots = slots,
			spawnCooldown = math.max(trait.spawnInterval or 0, 0)
		}
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		for i = 1, OrbitRingGeometry.RING_COUNT do
			local angularSpeedForRing = OrbitRingGeometry.angularSpeedForRing(trait, i)
			trait2.ringRotations[i] = (trait2.ringRotations[i] + OrbitRingGeometry.spinForRing(i) * angularSpeedForRing * p) % 6.283185307179586
		end

		trait2.spawnCooldown -= p

		if trait2.spawnCooldown <= 0 then
			local slotId = nil

			for k, slot in trait2.slots do
				if slot.occupied then
					continue
				end

				slotId = k
				break
			end

			trait2.spawnCooldown += math.max(trait.spawnInterval or 0, 1e-6)

			if slotId then
				local slot = trait2.slots[slotId]
				slot.occupied = true
				table.insert(list, {
					type = "orbit_satellite_spawn",
					ballId = data.id,
					position = data.position,
					ring = slot.ring,
					slotId = slotId
				})
			end
		end

		object:_rebuildOrbitPositions(data, p2)
	end,
	weaponHits = function(object, p, state, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = p.traits[p2]

		if not trait2 then
			return
		end

		local assetName = trait.assetName
		local v

		if type(assetName) == "string" then
			v = assetName ~= ""
		else
			v = false
		end

		assert(v, "BattleConfig.traits.OrbitSatellite.assetName is missing")
		local _getEffectCollisionRadius = object:_getEffectCollisionRadius(assetName)

		for k, slot in trait2.slots do
			if not (slot.occupied and (state.position - slot.position).Magnitude <= state.radius + _getEffectCollisionRadius) then
				continue
			end

			local _applyDamageModifiers = object:_applyDamageModifiers(
				p,
				state,
				(math.round(trait.satelliteDamage or 0))
			)
			slot.occupied = false

			if _applyDamageModifiers > 0 then
				state.hp = math.max(0, state.hp - _applyDamageModifiers)
				object:_onDamageDealt(p, state, _applyDamageModifiers, list)

				if object.multiEntityMode then
					object:_resolveEntityDeath(state, p, list)
				end
			end

			table.insert(list, {
				type = "orbit_satellite_hit",
				ballId = state.id,
				otherBallId = p.id,
				position = slot.position,
				ring = slot.ring,
				slotId = k,
				damage = _applyDamageModifiers
			})
		end
	end
}
BattleSkills.PassiveSword = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		local trait2 = p2.traits[p3]
		trait2.bladeCount = 1
		trait2.bladeHitCooldowns[1] = 0
		trait2.rotationSpeed = trait.startingRotationSpeed or trait.rotationSpeed or 0
	end,
	updateFrame = function(object, p, _, p2, _, p3)
		local trait = object.config.traits[p3]
		local trait2 = p.traits[p3]
		local rotationSpeed = trait2.rotationSpeed or 0
		trait2.rotationSpeed = math.min(
			trait.maxRotationSpeed or rotationSpeed,
			rotationSpeed + (trait.rotationAcceleration or 0) * p2
		)
		trait2.bladeRotation = (trait2.bladeRotation + trait2.rotationSpeed * p2) % 6.283185307179586

		for i = 1, #trait2.bladeHitCooldowns do
			trait2.bladeHitCooldowns[i] = math.max(0, trait2.bladeHitCooldowns[i] - p2)
		end

		trait2.bladePositions = object:_rebuildBladePositions(p, p3)
	end,
	weaponHits = function(object, data, state, list, p)
		local trait = object.config.traits[p]
		local trait2 = data.traits[p]

		if trait2.bladeHitCooldowns[1] == nil or trait2.bladeHitCooldowns[1] > 0 then
			return
		end

		local bladePosition = trait2.bladePositions[1]

		if not bladePosition then
			return
		end

		local _getEffectCollisionThickness = object:_getEffectCollisionThickness(object.config.visual.swordTemplateName)
		local v = state.radius + _getEffectCollisionThickness * 0.5
		local position = state.position
		local position2 = data.position
		local vector = bladePosition - position2
		local dot = vector:Dot(vector)

		if not (dot <= 1e-6) then
			position2 += vector * math.clamp((position - position2):Dot(vector) / dot, 0, 1)
		end

		if v < (state.position - position2).Magnitude then
			return
		end

		local _applyDamageModifiers = object:_applyDamageModifiers(data, state, (math.round(trait.swordDamage or 0)))

		if _applyDamageModifiers <= 0 then
			return
		end

		state.hp = math.max(0, state.hp - _applyDamageModifiers)
		trait2.bladeHitCooldowns[1] = trait.swordHitCooldown or 0
		table.insert(list, {
			type = "blade_hit",
			ballId = state.id,
			otherBallId = data.id,
			position = position2,
			startPosition = data.position,
			endPosition = bladePosition,
			damage = _applyDamageModifiers,
			bladeIndex = 1
		})
		object:_onDamageDealt(data, state, _applyDamageModifiers, list)
	end
}
BattleSkills.PassiveAxe = {
	initialize = function(_, p, p2)
		local trait = p.traits[p2]
		trait.bladeCount = 1
		trait.bladeHitCooldowns[1] = 0
		trait.turns = 0
		trait.lastHitTurnsByTarget = {}
	end,
	updateFrame = function(object, data, _, p, _, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]
		local v = not (data.maxHp > 0) and 0 or data.hp / data.maxHp or 0
		local lowHealthThreshold = trait.lowHealthThreshold or 0.5
		local v2 = math.clamp((lowHealthThreshold - v) / math.max(lowHealthThreshold, 1e-6), 0, 1)
		local rotationSpeed = 6.283185307179586 / math.max(
			(trait.fullHealthCircleDuration or 1.5) + ((trait.lowHealthCircleDuration or 0.75) - (trait.fullHealthCircleDuration or 1.5)) * v2,
			1e-6
		)
		trait2.rotationSpeed = rotationSpeed
		trait2.turns = (trait2.turns or 0) + rotationSpeed * p / 6.283185307179586
		trait2.bladeRotation = (trait2.bladeRotation + rotationSpeed * p) % 6.283185307179586
		trait2.bladePositions = object:_rebuildBladePositions(data, p2)
	end,
	weaponHits = function(object, data, state, list, p)
		local trait = object.config.traits[p]
		local trait2 = data.traits[p]
		local bladePosition = trait2.bladePositions[1]

		if not bladePosition then
			return
		end

		local _getEffectCollisionThickness = object:_getEffectCollisionThickness(object.config.visual.axeTemplateName)
		local position = state.position
		local position2 = data.position
		local vector = bladePosition - position2
		local dot = vector:Dot(vector)

		if not (dot <= 1e-6) then
			position2 += vector * math.clamp((position - position2):Dot(vector) / dot, 0, 1)
		end

		if (state.position - position2).Magnitude > state.radius + _getEffectCollisionThickness * 0.5 then
			return
		end

		local v = trait2.lastHitTurnsByTarget[state.id] or -1e999

		if trait2.turns < v + (trait.hitRefreshTurns or 0.5) then
			return
		end

		local v2 = not (data.maxHp > 0) and 0 or data.hp / data.maxHp or 0
		local lowHealthThreshold = trait.lowHealthThreshold or 0.5
		local v3 = math.clamp((lowHealthThreshold - v2) / math.max(lowHealthThreshold, 1e-6), 0, 1)
		local _applyIncomingDamage = object:_applyIncomingDamage(
			state,
			math.round((trait.fullHealthDamage or 4) + ((trait.lowHealthDamage or 6) - (trait.fullHealthDamage or 4)) * v3),
			data
		)

		if _applyIncomingDamage <= 0 then
			return
		end

		state.hp = math.max(0, state.hp - _applyIncomingDamage)
		trait2.lastHitTurnsByTarget[state.id] = trait2.turns
		table.insert(list, {
			type = "blade_hit",
			ballId = state.id,
			otherBallId = data.id,
			position = position2,
			startPosition = data.position,
			endPosition = bladePosition,
			damage = _applyIncomingDamage,
			bladeIndex = 1
		})
		object:_onDamageDealt(data, state, _applyIncomingDamage, list)
	end
}
BattleSkills.VampireAttach = {
	updateFrame = function(object, p, _, p2, p3)
		if not object:_isVampireAttached(p) then
			return
		end

		local _ballById = object:_ballById(p.vampireAttachedTargetId)

		if _ballById then
			object:_updateVampireAttach(p, _ballById, p2, p3)
		else
			object:_finishVampireAttach(p, nil)
		end
	end,
	collisionDamage = function()
		return 0, false
	end
}

local function makeWallWebBehavior(data)
	local v = {
		collisionDamage = function(_, _)
			return 0, false
		end,
		onWallHit = function(object, p, p2, p3)
			if not (p2.position and p2.endPosition) or (p2.endPosition - p2.position).Magnitude <= 0.01 then
				return
			end

			object:_createWallWeb(p, data.websField, data.createdEvent, p2.position, p2.endPosition, p3)
		end
	}

	local function dealWebDamage(object, state, state2, trait, k, p, startPosition, list)
		local _applyDamageModifiers = object:_applyDamageModifiers(state, state2, (math.round(trait.webDamage or 0)))

		if _applyDamageModifiers > 0 then
			state2.hp = math.max(0, state2.hp - _applyDamageModifiers)
			local heal = nil

			if data.healKey then
				local v3 = (trait[data.healKey] or 0) * object:_healMultiplier(state)

				if v3 > 0 then
					state.hp += v3
					heal = v3
				end
			end

			table.insert(list, {
				type = data.hitEvent,
				ballId = state2.id,
				otherBallId = state.id,
				sourceBallId = state.id,
				targetBallId = state2.id,
				position = startPosition,
				startPosition = p.startPosition,
				endPosition = p.endPosition,
				damage = _applyDamageModifiers,
				heal = heal,
				webIndex = k
			})
			object:_onDamageDealt(state, state2, _applyDamageModifiers, list)
		end
	end

	function v.weaponHits(object, p, data2, p2, p3)
		local trait = object.config.traits[p3]
		local webTickInterval = trait.webTickInterval or 0
		local fixedDt = object.config.replay.fixedDt
		local v2 = p[data.touchingField]
		local v3 = p[data.tickField]
		local v4 = v2[data2.id]

		if not v4 then
			v4 = {}
			v2[data2.id] = v4
		end

		local v5 = v3[data2.id]

		if not v5 then
			v5 = {}
			v3[data2.id] = v5
		end

		for k, v6 in p[data.websField] do
			local position = data2.position
			local startPosition = v6.startPosition
			local vector = v6.endPosition - startPosition
			local dot = vector:Dot(vector)

			if not (dot <= 1e-6) then
				startPosition += vector * math.clamp((position - startPosition):Dot(vector) / dot, 0, 1)
			end

			local v7 = (data2.position - startPosition).Magnitude <= data2.radius + object:_getEffectCollisionThickness(object.config.visual[data.templateNameKey]) * 0.5
			local v8 = v4[k] == true

			if v7 then
				if not v8 then
					dealWebDamage(object, p, data2, trait, k, v6, startPosition, p2)
				end

				if webTickInterval > 0 then
					local v9 = (v5[k] or 0) + fixedDt

					while webTickInterval <= v9 do
						v9 -= webTickInterval
						dealWebDamage(object, p, data2, trait, k, v6, startPosition, p2)
					end

					v5[k] = v9
				end
			else
				v5[k] = 0
			end

			v4[k] = v7
		end
	end

	return v
end

BattleSkills.SpiderWeb = makeWallWebBehavior({
	websField = "spiderWebs",
	touchingField = "spiderWebTouchingByTarget",
	tickField = "spiderWebTickProgressByTarget",
	templateNameKey = "spiderWebTemplateName",
	createdEvent = "spider_web_created",
	hitEvent = "spider_web_hit"
})
BattleSkills.VampireWeb = makeWallWebBehavior({
	websField = "vampireWebs",
	touchingField = "vampireWebTouchingByTarget",
	tickField = "vampireWebTickProgressByTarget",
	templateNameKey = "vampireWebTemplateName",
	createdEvent = "vampire_web_created",
	hitEvent = "vampire_web_hit",
	healKey = "webHeal"
})
BattleSkills.PoisonSpikeWall = {
	collisionDamage = function(_, _)
		return 0, false
	end,
	onWallHit = function(object, p, p2, p3, p4)
		object:_createPoisonSpikeFromWallHit(p, p2, p3, p4)
	end
}
BattleSkills.BigSpikeWall = {
	collisionDamage = function(_, _)
		return 0, false
	end,
	onWallHit = function(object, p, p2, p3, p4)
		object:_createPoisonSpikeFromWallHit(p, p2, p3, p4)
	end
}
BattleSkills.HookGrapple = {
	initialize = function(object, p, p2)
		object:_initHookGrapple(p, p2)
	end,
	updateFrame = function(object, p, p2, p3, p4, p5)
		object:_updateHookGrapple(p, p2, p3, p4, p5)
	end,
	collisionDamage = function()
		return 0, false
	end,
	weaponHits = function(object, p, p2, p3, p4)
		object:_handleHookGrappleCapture(p, p2, p3, p4)
	end
}
BattleSkills.ZoneField = {
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(object, p, _, p2, p3, p4)
		object:_updateZoneRegions(p, p2, p3, p4)
	end,
	onWallHit = function(object, p, p2, p3, p4)
		if not p2.position then
			return
		end

		if p.zonePreviewAnchorPosition == nil then
			object:_setZonePreview(p, p2)
			return
		end

		local _wallKeyFromEvent = object:_wallKeyFromEvent(p2)

		if _wallKeyFromEvent ~= nil and _wallKeyFromEvent == p.zonePreviewWallKey then
			return
		end

		if not object:_tryCreateZoneRegion(p, p2, p3, p4) then
			object:_clearZonePreview(p)
		end
	end
}
BattleSkills.LaserWall = {
	collisionDamage = function(_, _)
		return 0, false
	end,
	onWallHit = function(object, p, p2, p3, p4)
		object:_handleLaserWallHit(p, p2, p3, p4)
	end,
	weaponHits = function(object, data, state, list, p)
		local trait = object.config.traits[p]
		local v = data.laserTouchingByTarget[state.id] or {}
		data.laserTouchingByTarget[state.id] = v

		for k, laserSegment in data.laserSegments do
			local position = state.position
			local startPosition = laserSegment.startPosition
			local vector = laserSegment.endPosition - startPosition
			local dot = vector:Dot(vector)

			if not (dot <= 1e-6) then
				startPosition += vector * math.clamp((position - startPosition):Dot(vector) / dot, 0, 1)
			end

			local v2 = (state.position - startPosition).Magnitude <= state.radius + object:_getEffectCollisionThickness(object.config.visual.laserTemplateName) * 0.5
			local v3 = v[k] == true

			if v2 and not v3 then
				local _applyDamageModifiers = object:_applyDamageModifiers(
					data,
					state,
					(math.round(trait.laserDamage or 0))
				)

				if _applyDamageModifiers > 0 then
					state.hp = math.max(0, state.hp - _applyDamageModifiers)
					table.insert(list, {
						type = "laser_hit",
						ballId = state.id,
						otherBallId = data.id,
						sourceBallId = data.id,
						targetBallId = state.id,
						position = startPosition,
						startPosition = laserSegment.startPosition,
						endPosition = laserSegment.endPosition,
						damage = _applyDamageModifiers,
						laserIndex = k
					})
					object:_onDamageDealt(data, state, _applyDamageModifiers, list)
				end
			end

			v[k] = v2
		end
	end
}
BattleSkills.PoisonOnHit = {
	onDamageDealt = function(object, p, p2, _, _, p3)
		object:_applyPoison(p2, p, p3)
	end
}
BattleSkills.VirusOnHit = {
	onDamageDealt = function(object, p, p2, _, _, p3)
		object:_applyPoison(p2, p, p3)
	end
}
BattleSkills.SlowOnHit = {
	onDamageDealt = function(object, p, p2, _, _, p3)
		object:_applySlow(p2, p3, p)
	end
}
BattleSkills.FreezeOnHit = {
	onCollisionResolved = function(object, p, p2, _, p3)
		object:_applySlow(p2, p3, p)
	end
}
BattleSkills.ElectromagneticParalysis = {
	onCollisionResolved = function(object, p, state, list, p2)
		local v = p.traits[p2] or {}
		p.traits[p2] = v
		local v2 = (v.hitCount or 0) + 1

		if math.max(1, (math.floor(object.config.traits[p2].hitCount or 3))) <= v2 then
			v.hitCount = 0
			state.electromagneticParalysisProgress = 0
			object:_applySlow(state, p2, p)
			table.insert(list, {
				type = "electromagnetic_paralysis_triggered",
				ballId = state.id,
				position = state.position
			})
		else
			v.hitCount = v2
			state.electromagneticParalysisProgress = v2
		end
	end
}
BattleSkills.DamageAmplification = {
	modifyGlobalOutgoingDamage = function(p, _, _, p2, p3)
		return p2 * (p.config.traits[p3].damageMultiplier or 1)
	end
}
BattleSkills.Knockback = {}
BattleSkills.StrongParalysis = {
	onCollisionResolved = function(object, p, p2, list, p3)
		object:_applySlow(p2, p3, p)
		table.insert(list, {
			type = "strong_paralysis_triggered",
			ballId = p2.id,
			position = p2.position
		})
	end
}
BattleSkills.Gravity = {
	initialize = function(_, p, p2)
		p.traits[p2] = {}
	end,
	updateFrame = function(p, p2, state, p3, _, p4)
		if not state or state.team == p2.team or state.hp <= 0 or state.hookCapturedByBallId then
			return
		end

		local v = p2.position - state.position

		if v.Magnitude <= 1e-6 then
			return
		end

		local trait = p.config.traits[p4]
		local gravityVelocity = (state.gravityVelocity or Vector2.zero) + v.Unit * (trait.pullAcceleration or 0) * p3
		local v3 = math.max(0, trait.maxPullSpeed or 1e999)

		if v3 < gravityVelocity.Magnitude then
			gravityVelocity = gravityVelocity.Unit * v3
		end

		state.gravityVelocity = gravityVelocity
	end
}
BattleSkills.LowHpArmor = {
	modifyIncomingDamage = function(p, p2, p3, p4)
		local trait = p.config.traits[p4]

		if (not (p2.maxHp > 0) and 0 or p2.hp / p2.maxHp) < (trait.hpThreshold or 0) then
			return p3 * (1 - (trait.damageReduction or 0))
		end

		return p3
	end
}
BattleSkills.GamblerStrike = {
	modifyOutgoingDamage = function(p, p2, _, p3, p4)
		local trait = p.config.traits[p4]

		if (not (p2.maxHp > 0) and 0 or p2.hp / p2.maxHp) < (trait.hpThreshold or 0) then
			return p3 * (1 + (trait.damageBonus or 0))
		end

		return p3
	end
}
BattleSkills.ArmorBreaker = {
	modifyOutgoingDamage = function(p, _, p2, p3, p4)
		local trait = p.config.traits[p4]

		if (not (p2.maxHp > 0) and 0 or p2.hp / p2.maxHp) > (trait.hpThreshold or 1) then
			return p3 * (1 + (trait.damageBonus or 0))
		end

		return p3
	end
}
BattleSkills.LuckyCrit = {
	modifyOutgoingDamage = function(p, _, _, p2, p3)
		local trait = p.config.traits[p3]

		if p.random:NextNumber(0, 1) < (trait.critChance or 0) then
			return p2 * (trait.critMultiplier or 1)
		end

		return p2
	end
}
BattleSkills.WallCharge = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			charged = false
		}
	end,
	onWallHit = function(_, p, _, _, p2)
		local trait = p.traits[p2]

		if trait then
			trait.charged = true
		end
	end,
	modifyOutgoingDamage = function(p, p2, _, p3, p4)
		local trait = p.config.traits[p4]
		local trait2 = p2.traits[p4]

		if trait2 and trait2.charged then
			trait2.charged = false
			return p3 * (trait.bonusMultiplier or 1)
		else
			return p3
		end
	end
}
BattleSkills.SprintStart = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			active = true
		}
	end,
	updateFrame = function(p, state, _, _, _, p2)
		local trait = p.config.traits[p2]
		local trait2 = state.traits[p2]
		local active = p.state.elapsed < (trait.duration or 0)

		if trait2 then
			trait2.active = active
		end

		if active then
			state.bonusSpeedMultiplier *= trait.speedMultiplier or 1
		end
	end
}
BattleSkills.BounceAccel = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			boostRemaining = 0
		}
	end,
	onWallHit = function(p, p2, _, _, p3)
		local trait = p.config.traits[p3]
		local trait2 = p2.traits[p3]

		if trait2 then
			trait2.boostRemaining = trait.duration or 0
		end
	end,
	updateFrame = function(p, state, _, p2, _, p3)
		local trait = p.config.traits[p3]
		local trait2 = state.traits[p3]

		if not trait2 then
			return
		end

		trait2.boostRemaining = math.max(0, trait2.boostRemaining - p2)

		if trait2.boostRemaining > 0 then
			state.bonusSpeedMultiplier *= trait.speedMultiplier or 1
		end
	end
}
BattleSkills.BallHitAccel = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			boostRemaining = 0
		}
	end,
	onCollisionResolved = function(p, p2, _, p3)
		local trait = p2.traits[p3]

		if trait then
			trait.boostRemaining = p.config.traits[p3].duration or 0
		end
	end,
	updateFrame = function(p, state, _, p2, _, p3)
		local trait = state.traits[p3]

		if not trait then
			return
		end

		trait.boostRemaining = math.max(0, trait.boostRemaining - p2)

		if trait.boostRemaining > 0 then
			state.bonusSpeedMultiplier *= p.config.traits[p3].speedMultiplier or 1
		end
	end
}
BattleSkills.ComboStrike = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			lastTargetId = nil,
			comboCount = 0,
			comboTimer = 0
		}
	end,
	updateFrame = function(_, p, _, p2, _, p3)
		local trait = p.traits[p3]

		if not trait then
			return
		end

		if trait.comboTimer > 0 then
			trait.comboTimer = math.max(0, trait.comboTimer - p2)

			if trait.comboTimer <= 0 then
				trait.comboCount = 0
				trait.lastTargetId = nil
			end
		end
	end,
	modifyGlobalOutgoingDamage = function(p, p2, p3, p4, p5)
		local trait = p2.traits[p5]

		if not trait or trait.lastTargetId ~= p3.id then
			return p4
		end

		local trait2 = p.config.traits[p5]
		return p4 * (1 + trait.comboCount * (trait2.bonusPerHit or 0))
	end,
	onDamageDealt = function(p, p2, p3, p4, _, p5)
		if p4 <= 0 then
			return
		end

		local trait = p.config.traits[p5]
		local trait2 = p2.traits[p5]

		if not trait2 then
			return
		end

		if trait2.lastTargetId == p3.id and trait2.comboTimer > 0 then
			trait2.comboCount = math.min(math.max(0, (trait.maxStacks or 1) - 1), trait2.comboCount + 1)
		else
			trait2.lastTargetId = p3.id
			trait2.comboCount = 0
		end

		trait2.comboTimer = trait.comboWindow or 0
	end
}
BattleSkills.Execute = {
	modifyGlobalOutgoingDamage = function(p, _, p2, p3, p4)
		local trait = p.config.traits[p4]

		if p2.maxHp <= 0 then
			return p3
		end

		if p2.hp / p2.maxHp < (trait.hpThreshold or 0) then
			return p3 * (trait.damageMultiplier or 1)
		end

		return p3
	end
}
BattleSkills.DiceBarrage = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			placeCooldown = 0,
			dice = {},
			nextDiceId = 1
		}
	end,
	updateFrame = function(p, data, _, p2, list, p3)
		local trait = p.config.traits[p3]
		local trait2 = data.traits[p3]

		if not trait2 then
			return
		end

		local v = math.max(trait.placeInterval or 0, 1e-6)
		trait2.placeCooldown -= p2

		while trait2.placeCooldown <= 0 do
			local v2 = {
				diceId = trait2.nextDiceId,
				position = data.position,
				topValue = p.random:NextInteger(1, 6),
				touchingByTarget = {}
			}
			table.insert(trait2.dice, v2)
			trait2.nextDiceId += 1
			trait2.placeCooldown += v
			table.insert(list, {
				type = "dice_created",
				ballId = data.id,
				diceId = v2.diceId,
				position = v2.position,
				topValue = v2.topValue
			})
		end
	end,
	collisionDamage = function()
		return 0, false
	end
}
BattleSkills.MachineGun = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			cooldown = trait.fireCooldown or 0,
			firingElapsed = 0,
			shotCooldown = 0,
			bullets = {},
			nextBulletId = 1
		}
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		for i = #trait2.bullets, 1, -1 do
			local bullet = trait2.bullets[i]
			local position = bullet.position
			bullet.position += bullet.direction * (trait.bulletSpeed or 0) * p
			local v = object.config.arena.size * 0.5

			if math.abs(bullet.position.X) > v.X or math.abs(bullet.position.Y) > v.Y then
				table.remove(trait2.bullets, i)
				table.insert(list, {
					type = "machine_gun_bullet_wall",
					ballId = data.id,
					position = bullet.position
				})
			else
				local v2 = nil

				for _, ball in object.state.balls do
					if ball.team == data.team then
						continue
					end

					local v4 = closestPointOnSegment(ball.position, position, bullet.position) -- equivalent call inferred; original call site unknown

					if not ((ball.position - v4).Magnitude <= ball.radius) then
						continue
					end

					v2 = ball
					break
				end

				if v2 then
					local _applyProjectileDamage = object:_applyProjectileDamage(data, v2, trait.bulletDamage or 0)

					if _applyProjectileDamage > 0 then
						v2.hp = math.max(0, v2.hp - _applyProjectileDamage)
						object:_onDamageDealt(data, v2, _applyProjectileDamage, list)

						if object.multiEntityMode then
							object:_resolveEntityDeath(v2, data, list)
						end
					end

					table.remove(trait2.bullets, i)
					table.insert(list, {
						type = "machine_gun_bullet_hit",
						ballId = v2.id,
						otherBallId = data.id,
						sourceBallId = data.id,
						targetBallId = v2.id,
						position = bullet.position,
						damage = _applyProjectileDamage
					})
				end
			end
		end

		if trait2.cooldown > 0 then
			trait2.cooldown = math.max(0, trait2.cooldown - p)

			if trait2.cooldown > 0 then
				return
			end

			trait2.firingElapsed = 0
			trait2.shotCooldown = 0
		end

		local v = math.max(0, trait.fireDuration or 0)

		if v <= 0 then
			trait2.cooldown = trait.fireCooldown or 0
			return
		end

		trait2.firingElapsed += p
		trait2.shotCooldown -= p

		while trait2.shotCooldown <= 0 and trait2.firingElapsed <= v do
			local v2 = 1e999
			local v3 = nil

			for _, ball in object.state.balls do
				if ball.team == data.team then
					continue
				end

				local magnitude = (ball.position - data.position).Magnitude

				if not (magnitude < v2) then
					continue
				end

				v3 = ball
				v2 = magnitude
			end

			if not v3 then
				break
			end

			local v4 = v3.position - data.position
			local unit = v4.Magnitude > 1e-6 and v4.Unit or data.direction
			local maxSpreadAngle = math.rad(trait.maxSpreadAngle or 0)
			local number = object.random:NextNumber(-maxSpreadAngle, maxSpreadAngle)
			local vector = Vector2.new(
				unit.X * math.cos(number) - unit.Y * math.sin(number),
				unit.X * math.sin(number) + unit.Y * math.cos(number)
			)
			table.insert(trait2.bullets, {
				bulletId = trait2.nextBulletId,
				position = data.position,
				direction = vector
			})
			trait2.nextBulletId += 1
			table.insert(list, {
				type = "machine_gun_fire",
				ballId = data.id,
				position = data.position
			})
			local v5 = math.clamp(trait2.firingElapsed / v, 0, 1)
			trait2.shotCooldown += (trait.initialBulletInterval or 1) + ((trait.finalBulletInterval or 1) - (trait.initialBulletInterval or 1)) * v5
		end

		if v <= trait2.firingElapsed then
			trait2.cooldown = trait.fireCooldown or 0
		end
	end
}
BattleSkills.AppleThrow = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			throwCooldown = trait.throwInterval or 0,
			apples = {},
			nextAppleId = 1
		}
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		for _, apple in trait2.apples do
			if apple.phase ~= "Flying" then
				continue
			end

			apple.position += apple.direction * (trait.appleSpeed or 0) * p
			apple.traveled += (trait.appleSpeed or 0) * p

			if not (apple.traveled >= apple.targetDistance) then
				continue
			end

			apple.phase = "Landed"
			apple.residueRemaining = trait.appleResidueDuration or 0
			table.insert(list, {
				type = "apple_landed",
				ballId = data.id,
				position = apple.position,
				appleId = apple.appleId
			})
		end

		for i = #trait2.apples, 1, -1 do
			local apple = trait2.apples[i]

			if apple.phase ~= "Landed" then
				continue
			end

			apple.residueRemaining -= p

			if apple.residueRemaining <= 0 then
				table.remove(trait2.apples, i)
			else
				for _, ball in object.state.balls do
					if not ((ball.position - apple.position).Magnitude <= ball.radius + (trait.appleContactRadius or 0)) then
						continue
					end

					local v2 = ball.team == apple.ownerTeam
					local heal = nil
					local damage = nil

					if v2 then
						heal = (trait.selfHealAmount or 0) * object:_healMultiplier(ball)
						ball.hp += heal
						object:_applyHaste(ball, p2)
					else
						damage = object:_applyDamageModifiers(data, ball, trait.enemyDamageAmount or 0)
						ball.hp = math.max(0, ball.hp - damage)
						object:_onDamageDealt(data, ball, damage, list)

						if object.multiEntityMode then
							object:_resolveEntityDeath(ball, data, list)
						end

						object:_applySlow(ball, p2, data)
					end

					table.insert(list, {
						type = "apple_eaten",
						ballId = ball.id,
						otherBallId = data.id,
						sourceBallId = data.id,
						targetBallId = ball.id,
						position = apple.position,
						isDamage = not v2,
						appleId = apple.appleId,
						damage = damage,
						heal = heal
					})
					table.remove(trait2.apples, i)
					break
				end
			end
		end

		trait2.throwCooldown -= p

		if trait2.throwCooldown <= 0 then
			local v = object.config.arena.size * 0.5 - Vector2.new(
				trait.appleContactRadius or 0,
				trait.appleContactRadius or 0
			)
			local minThrowDistance = trait.minThrowDistance or 0
			local maxThrowDistance = trait.maxThrowDistance or 1e999
			local position = data.position

			for _ = 1, 20 do
				position = Vector2.new(object.random:NextNumber(-v.X, v.X), object.random:NextNumber(-v.Y, v.Y))
				local magnitude = (position - data.position).Magnitude

				if minThrowDistance <= magnitude and magnitude <= maxThrowDistance then
					break
				end
			end

			local v2 = position - data.position
			local magnitude = v2.Magnitude
			local unit = magnitude > 1e-6 and v2.Unit or Vector2.new(1, 0)
			table.insert(trait2.apples, {
				appleId = trait2.nextAppleId,
				phase = "Flying",
				position = data.position,
				direction = unit,
				traveled = 0,
				targetDistance = magnitude,
				ownerTeam = data.team
			})
			trait2.nextAppleId += 1
			table.insert(list, {
				type = "apple_thrown",
				ballId = data.id,
				position = data.position,
				appleId = trait2.nextAppleId - 1
			})
			trait2.throwCooldown += trait.throwInterval or 0
		end
	end
}

local function acidApplyPoisonStack(object, ball, data, trait, list, dropletId: number)
	ball.acidPoisonStacks = ball.acidPoisonStacks or {}
	local v = math.max(1, (math.floor(trait.poisonTickCount or 1)))
	local poisonDuration = trait.poisonDuration or 0
	local v2 = poisonDuration / math.max(1, v - 1)
	local poisonTickDamage = math.round(trait.poisonTickDamage or 0)
	local _applyDamageModifiers = object:_applyDamageModifiers(data, ball, poisonTickDamage)

	if _applyDamageModifiers > 0 then
		ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
		object:_notifyDamageTaken(ball, data, _applyDamageModifiers, list)

		if object.multiEntityMode then
			object:_resolveEntityDeath(ball, data, list)
		end

		table.insert(list, {
			type = "acid_poison_tick",
			ballId = ball.id,
			otherBallId = data.id,
			sourceBallId = data.id,
			targetBallId = ball.id,
			position = ball.position,
			damage = _applyDamageModifiers,
			stackId = dropletId
		})
	end

	local ticksRemaining = v - 1

	if ticksRemaining <= 0 then
		return
	end

	table.insert(ball.acidPoisonStacks, {
		stackId = dropletId,
		ticksRemaining = ticksRemaining,
		tickCooldown = v2,
		tickInterval = v2,
		damage = poisonTickDamage,
		sourceBallId = data.id,
		slowElapsed = 0,
		slowDuration = poisonDuration,
		initialSlowMultiplier = trait.poisonInitialSlowMultiplier or 1
	})
end

BattleSkills.AcidSpit = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			spitCooldown = trait.spitInterval or 0,
			droplets = {},
			nextDropletId = 1
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(data, data2, _, p, list, p2)
		local trait = data.config.traits[p2]
		local trait2 = data2.traits[p2]

		if not trait2 then
			return
		end

		local dropletSpeed = trait.dropletSpeed or 0

		for _, droplet in trait2.droplets do
			if droplet.phase ~= "Flying" then
				continue
			end

			droplet.position += droplet.direction * dropletSpeed * p
			droplet.traveled += dropletSpeed * p

			if not (droplet.traveled >= droplet.targetDistance) then
				continue
			end

			droplet.phase = "Puddle"
			droplet.puddleResidueRemaining = trait.puddleResidueDuration or 0
			table.insert(list, {
				type = "acid_droplet_landed",
				ballId = data2.id,
				position = droplet.position,
				dropletId = droplet.dropletId
			})
		end

		for i = #trait2.droplets, 1, -1 do
			local droplet = trait2.droplets[i]

			if droplet.phase ~= "Puddle" then
				continue
			end

			droplet.puddleResidueRemaining -= p

			if droplet.puddleResidueRemaining <= 0 then
				table.remove(trait2.droplets, i)
			else
				for _, ball in data.state.balls do
					if not (ball.team ~= data2.team and ball.hp > 0 and (ball.position - droplet.position).Magnitude <= ball.radius + (droplet.puddleRadius or 0)) then
						continue
					end

					acidApplyPoisonStack(data, ball, data2, trait, list, droplet.dropletId)
					table.insert(list, {
						type = "acid_puddle_eaten",
						ballId = ball.id,
						otherBallId = data2.id,
						position = droplet.position,
						dropletId = droplet.dropletId
					})
					table.remove(trait2.droplets, i)
					break
				end
			end
		end

		trait2.spitCooldown -= p

		if trait2.spitCooldown <= 0 then
			local count = 0

			for _, droplet in trait2.droplets do
				if droplet.phase == "Puddle" then
					count += 1
				end
			end

			if count < (trait.maxActivePuddleCount or 1e999) then
				local number = data.random:NextNumber(0, 6.283185307179586)
				local vector = Vector2.new(math.cos(number), (math.sin(number)))
				local number2 = data.random:NextNumber(trait.minSpitDistance or 0, trait.maxSpitDistance or 0)
				local minPuddleRadius = trait.minPuddleRadius or 1
				local number3 = data.random:NextNumber(
					minPuddleRadius,
					(math.max(minPuddleRadius, trait.maxPuddleRadius or minPuddleRadius))
				)
				local v = number3 + (trait.arenaEdgePadding or 0)
				local v2 = data.config.arena.size * 0.5 - Vector2.new(v, v)
				local v3 = data2.position + vector * number2
				local v4 = Vector2.new(math.clamp(v3.X, -v2.X, v2.X), (math.clamp(v3.Y, -v2.Y, v2.Y))) - data2.position
				local magnitude = v4.Magnitude

				if magnitude > 1e-6 then
					vector = v4.Unit
				end

				table.insert(trait2.droplets, {
					dropletId = trait2.nextDropletId,
					phase = "Flying",
					position = data2.position,
					direction = vector,
					traveled = 0,
					targetDistance = magnitude,
					puddleRadius = number3
				})
				table.insert(list, {
					type = "acid_spit_release",
					ballId = data2.id,
					position = data2.position,
					dropletId = trait2.nextDropletId
				})
				trait2.nextDropletId += 1
			end

			trait2.spitCooldown += trait.spitInterval or 0
		end
	end
}

local function turretNormalFromEvent(object, p)
	local _ = object.config.arena.size * 0.5
	local position = p.position

	if math.abs(position.X) >= math.abs(position.Y) then
		return Vector2.new(position.X >= 0 and 1 or -1, 0)
	end

	return Vector2.new(0, position.Y >= 0 and 1 or -1)
end

BattleSkills.CannonTurret = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			turrets = {},
			nextTurretId = 1,
			bullets = {},
			nextBulletId = 1,
			lastSpawnPositionByWall = {}
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	onWallHit = function(object, p, p2, list, p3)
		if not p2.position then
			return
		end

		local trait = object.config.traits[p3]
		local trait2 = p.traits[p3]
		local _wallKeyFromEvent = object:_wallKeyFromEvent(p2)

		if _wallKeyFromEvent == nil then
			return
		end

		local v = trait2.lastSpawnPositionByWall[_wallKeyFromEvent]

		if v and (p2.position - v).Magnitude < (trait.minWallSpawnSpacing or 0) then
			return
		end

		local normal = turretNormalFromEvent(object, p2)
		table.insert(trait2.turrets, {
			turretId = trait2.nextTurretId,
			position = p2.position,
			normal = normal,
			residueRemaining = trait.turretResidueDuration or 0,
			fireCooldown = trait.turretFireInterval or 0,
			aimDirection = -normal,
			wallKey = _wallKeyFromEvent
		})
		trait2.nextTurretId += 1
		trait2.lastSpawnPositionByWall[_wallKeyFromEvent] = p2.position

		while #trait2.turrets > math.max(1, trait.maxTurretCount or 1) do
			local v3 = table.remove(trait2.turrets, 1)

			if v3 and trait2.lastSpawnPositionByWall[v3.wallKey] == v3.position then
				trait2.lastSpawnPositionByWall[v3.wallKey] = nil
			end
		end

		table.insert(list, {
			type = "cannon_turret_created",
			ballId = p.id,
			position = p2.position,
			turretId = trait2.nextTurretId - 1
		})
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		local v = object.config.arena.size * 0.5

		for i = #trait2.bullets, 1, -1 do
			local bullet = trait2.bullets[i]
			local position = bullet.position
			bullet.position += bullet.direction * (trait.bulletSpeed or 0) * p

			if math.abs(bullet.position.X) > v.X or math.abs(bullet.position.Y) > v.Y then
				table.remove(trait2.bullets, i)
				table.insert(list, {
					type = "cannon_bullet_wall",
					ballId = data.id,
					position = bullet.position,
					bulletId = bullet.bulletId
				})
			else
				local v2 = nil

				for _, ball in object.state.balls do
					if ball.team == data.team then
						continue
					end

					local v4 = closestPointOnSegment(ball.position, position, bullet.position) -- equivalent call inferred; original call site unknown

					if not ((ball.position - v4).Magnitude <= ball.radius) then
						continue
					end

					v2 = ball
					break
				end

				if v2 then
					local _applyProjectileDamage = object:_applyProjectileDamage(data, v2, trait.bulletDamage or 0)

					if _applyProjectileDamage > 0 then
						v2.hp = math.max(0, v2.hp - _applyProjectileDamage)
						object:_onDamageDealt(data, v2, _applyProjectileDamage, list)

						if object.multiEntityMode then
							object:_resolveEntityDeath(v2, data, list)
						end
					end

					table.remove(trait2.bullets, i)
					table.insert(list, {
						type = "cannon_bullet_hit",
						ballId = v2.id,
						otherBallId = data.id,
						sourceBallId = data.id,
						targetBallId = v2.id,
						position = bullet.position,
						damage = _applyProjectileDamage,
						bulletId = bullet.bulletId
					})
				end
			end
		end

		for i = #trait2.turrets, 1, -1 do
			local turret = trait2.turrets[i]
			turret.residueRemaining -= p

			if turret.residueRemaining <= 0 then
				table.remove(trait2.turrets, i)

				if trait2.lastSpawnPositionByWall[turret.wallKey] == turret.position then
					trait2.lastSpawnPositionByWall[turret.wallKey] = nil
				end
			else
				local turretRange = trait.turretRange or 1e999
				local v2 = nil

				for _, ball in object.state.balls do
					if ball.team == data.team then
						continue
					end

					local magnitude = (ball.position - turret.position).Magnitude

					if not (magnitude <= turretRange) then
						continue
					end

					v2 = ball
					turretRange = magnitude
				end

				if v2 then
					local v3 = v2.position - turret.position
					local aimDirection

					if v3.Magnitude > 1e-6 then
						aimDirection = v3.Unit
					else
						aimDirection = turret.aimDirection
					end

					turret.aimDirection = aimDirection
				end

				turret.fireCooldown -= p

				if turret.fireCooldown <= 0 and v2 then
					table.insert(trait2.bullets, {
						bulletId = trait2.nextBulletId,
						position = turret.position,
						direction = turret.aimDirection
					})
					trait2.nextBulletId += 1
					table.insert(list, {
						type = "cannon_turret_fire",
						ballId = data.id,
						position = turret.position,
						turretId = turret.turretId
					})
					turret.fireCooldown += trait.turretFireInterval or 0
				end
			end
		end
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function boardLengthAlongNormal(object, normal)
	local size = object.config.arena.size

	if normal.X == 0 then
		return size.Y
	end

	return size.X
end

BattleSkills.LaserTurretV3 = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			turrets = {},
			nextTurretId = 1,
			lastSpawnPositionByWall = {}
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	onWallHit = function(object, p, p2, list, p3)
		if not p2.position then
			return
		end

		local trait = object.config.traits[p3]
		local trait2 = p.traits[p3]

		if not trait2 then
			return
		end

		local _wallKeyFromEvent = object:_wallKeyFromEvent(p2)

		if _wallKeyFromEvent == nil then
			return
		end

		local v2 = trait2.lastSpawnPositionByWall[_wallKeyFromEvent]

		if v2 and (p2.position - v2).Magnitude < (trait.minWallSpawnSpacing or 0) then
			return
		end

		local normal = turretNormalFromEvent(object, p2)
		table.insert(trait2.turrets, {
			turretId = trait2.nextTurretId,
			position = p2.position,
			normal = normal,
			aimDirection = -normal,
			residueRemaining = trait.turretResidueDuration or 0,
			fireCooldown = trait.laserFireInterval or 0,
			flashRemaining = 0,
			wallKey = _wallKeyFromEvent
		})
		trait2.nextTurretId += 1
		trait2.lastSpawnPositionByWall[_wallKeyFromEvent] = p2.position
		table.insert(list, {
			type = "laser_turret_v3_created",
			ballId = p.id,
			position = p2.position,
			turretId = trait2.nextTurretId - 1
		})
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		local _getEffectCollisionThickness = object:_getEffectCollisionThickness(object.config.visual.laserTurretV3BeamTemplateName)

		for i = #trait2.turrets, 1, -1 do
			local turret = trait2.turrets[i]

			if turret.flashRemaining > 0 then
				turret.flashRemaining = math.max(0, turret.flashRemaining - p)
			end

			turret.residueRemaining -= p

			if turret.residueRemaining <= 0 then
				table.remove(trait2.turrets, i)

				if trait2.lastSpawnPositionByWall[turret.wallKey] == turret.position then
					trait2.lastSpawnPositionByWall[turret.wallKey] = nil
				end
			else
				turret.fireCooldown -= p

				if turret.fireCooldown <= 0 then
					local v2 = boardLengthAlongNormal(object, turret.normal) -- equivalent call inferred; original call site unknown
					local position = turret.position
					local endPosition = turret.position + turret.aimDirection * v2

					for _, ball in object.state.balls do
						if ball.team == data.team then
							continue
						end

						local position2 = closestPointOnSegment(ball.position, position, endPosition) -- equivalent call inferred; original call site unknown

						if not ((ball.position - position2).Magnitude <= ball.radius + _getEffectCollisionThickness * 0.5) then
							continue
						end

						local _applyDamageModifiers = object:_applyDamageModifiers(
							data,
							ball,
							(math.round(trait.laserDamage or 0))
						)

						if _applyDamageModifiers > 0 then
							ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
							object:_onDamageDealt(data, ball, _applyDamageModifiers, list)

							if object.multiEntityMode then
								object:_resolveEntityDeath(ball, data, list)
							end
						end

						table.insert(list, {
							type = "laser_turret_v3_hit",
							ballId = ball.id,
							otherBallId = data.id,
							sourceBallId = data.id,
							targetBallId = ball.id,
							position = position2,
							damage = _applyDamageModifiers,
							turretId = turret.turretId
						})
					end

					turret.flashRemaining = trait.laserFlashDuration or 0
					turret.fireCooldown += trait.laserFireInterval or 0
					table.insert(list, {
						type = "laser_turret_v3_fire",
						ballId = data.id,
						position = position,
						turretId = turret.turretId,
						startPosition = position,
						endPosition = endPosition
					})
				end
			end
		end
	end
}

local function buildShockEdges(trait, trait2)
	local nodes = trait.nodes
	local v3 = math.max(0, (math.round(trait2.nearestNeighborCount or 0)))

	if v3 <= 0 or #nodes < 2 then
		return {}
	end

	local v4 = {}

	for i = 1, #nodes - 1 do
		for i2 = i + 1, #nodes do
			local node = nodes[i]
			local node2 = nodes[i2]
			table.insert(v4, {
				nodeA = node,
				nodeB = node2,
				distance = (node.position - node2.position).Magnitude
			})
		end
	end

	table.sort(v4, function(a, b)
		return a.distance > b.distance
	end)
	local v5 = {}
	local result = {}

	for _, v6 in v4 do
		local v7 = v5[v6.nodeA.nodeId] or 0
		local v8 = v5[v6.nodeB.nodeId] or 0

		if not (v7 < v3 and v8 < v3) then
			continue
		end

		v5[v6.nodeA.nodeId] = v7 + 1
		v5[v6.nodeB.nodeId] = v8 + 1
		table.insert(result, {
			edgeIndex = #result + 1,
			startPosition = v6.nodeA.position,
			endPosition = v6.nodeB.position
		})
	end

	return result
end

BattleSkills.ElectroKingGrid = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			nodes = {},
			nextNodeId = 1,
			edges = {},
			lastSpawnPositionByWall = {},
			shockCooldown = trait.shockInterval or 0,
			shockActiveRemaining = 0,
			shockTickCooldownByTarget = {}
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	onWallHit = function(object, p, p2, list, p3)
		if not p2.position then
			return
		end

		local trait = object.config.traits[p3]
		local trait2 = p.traits[p3]
		local _wallKeyFromEvent = object:_wallKeyFromEvent(p2)

		if _wallKeyFromEvent == nil then
			return
		end

		local v3 = trait2.lastSpawnPositionByWall[_wallKeyFromEvent]

		if v3 and (p2.position - v3).Magnitude < (trait.minWallSpawnSpacing or 0) or #trait2.nodes >= math.max(
			1,
			trait.maxNodeCount or 32
		) then
			return
		end

		local v4 = {
			nodeId = trait2.nextNodeId,
			position = p2.position,
			residueRemaining = trait.nodeResidueDuration or 0,
			wallKey = _wallKeyFromEvent
		}
		trait2.nextNodeId += 1
		table.insert(trait2.nodes, v4)
		trait2.lastSpawnPositionByWall[_wallKeyFromEvent] = p2.position
		table.insert(list, {
			type = "electro_node_created",
			ballId = p.id,
			position = p2.position,
			nodeId = v4.nodeId
		})
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		for i = #trait2.nodes, 1, -1 do
			local node = trait2.nodes[i]
			node.residueRemaining -= p

			if not (node.residueRemaining <= 0) then
				continue
			end

			table.remove(trait2.nodes, i)

			if trait2.lastSpawnPositionByWall[node.wallKey] == node.position then
				trait2.lastSpawnPositionByWall[node.wallKey] = nil
			end
		end

		if trait2.shockActiveRemaining > 0 then
			trait2.shockActiveRemaining -= p

			for k, edge in trait2.edges do
				local v3 = trait2.shockTickCooldownByTarget[k] or {}
				trait2.shockTickCooldownByTarget[k] = v3

				for _, ball in object.state.balls do
					if ball.team == data.team then
						continue
					end

					local position = ball.position
					local startPosition = edge.startPosition
					local vector = edge.endPosition - startPosition
					local dot = vector:Dot(vector)

					if not (dot <= 1e-6) then
						startPosition += vector * math.clamp((position - startPosition):Dot(vector) / dot, 0, 1)
					end

					if ball.radius + object:_getEffectCollisionThickness(object.config.visual.electroKingTemplateName) * 0.5 >= (ball.position - startPosition).Magnitude then
						local v4 = (v3[ball.id] or 0) - p

						if v4 <= 0 then
							local _applyDamageModifiers = object:_applyDamageModifiers(
								data,
								ball,
								(math.round(trait.shockDamagePerTick or 0))
							)

							if _applyDamageModifiers > 0 then
								ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
								object:_onDamageDealt(data, ball, _applyDamageModifiers, list)

								if object.multiEntityMode then
									object:_resolveEntityDeath(ball, data, list)
								end
							end

							table.insert(list, {
								type = "electro_shock_tick",
								ballId = ball.id,
								otherBallId = data.id,
								sourceBallId = data.id,
								targetBallId = ball.id,
								position = startPosition,
								damage = _applyDamageModifiers,
								edgeIndex = k
							})
							v4 += trait.shockTickInterval or 0.5
						end

						v3[ball.id] = v4
					else
						v3[ball.id] = nil
					end
				end
			end

			if trait2.shockActiveRemaining <= 0 then
				trait2.shockActiveRemaining = 0
				trait2.shockTickCooldownByTarget = {}
				table.insert(list, {
					type = "electro_shock_end",
					ballId = data.id,
					position = data.position
				})
			end
		else
			trait2.shockCooldown -= p

			if trait2.shockCooldown <= 0 then
				trait2.shockCooldown += trait.shockInterval or 0

				if #trait2.nodes >= 2 then
					trait2.edges = buildShockEdges(trait2, trait)
					trait2.shockActiveRemaining = trait.shockActiveDuration or 0
					trait2.shockTickCooldownByTarget = {}
					table.insert(list, {
						type = "electro_shock_start",
						ballId = data.id,
						position = data.position
					})
				end
			end
		end
	end
}
BattleSkills.ExpandingAura = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			currentRadius = trait.initialRadius or 0,
			tickCooldownByTarget = {}
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		for _, ball in object.state.balls do
			if not (ball.team ~= data.team and ball.hp > 0) then
				continue
			end

			if (ball.position - data.position).Magnitude <= trait2.currentRadius + ball.radius then
				local v3 = (trait2.tickCooldownByTarget[ball.id] or 0) - p

				if v3 <= 0 then
					v3 += trait.attackInterval or 1
					local _applyDamageModifiers = object:_applyDamageModifiers(
						data,
						ball,
						(math.round(trait.attackDamagePerTick or 0))
					)

					if _applyDamageModifiers > 0 then
						ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
						object:_onDamageDealt(data, ball, _applyDamageModifiers, list)

						if object.multiEntityMode then
							object:_resolveEntityDeath(ball, data, list)
						end

						trait2.currentRadius = math.min(
							trait.maxRadius or trait2.currentRadius,
							trait2.currentRadius + (trait.radiusGrowthPerTick or 0)
						)
					end

					table.insert(list, {
						type = "aura_tick",
						ballId = ball.id,
						otherBallId = data.id,
						sourceBallId = data.id,
						targetBallId = ball.id,
						damage = _applyDamageModifiers,
						radius = trait2.currentRadius,
						position = ball.position
					})
				end

				trait2.tickCooldownByTarget[ball.id] = v3
			else
				trait2.tickCooldownByTarget[ball.id] = nil
			end
		end
	end
}
BattleSkills.FrostTrail = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			spawnCooldown = trait.trailSpawnInterval or 0,
			trail = {},
			nextTrailId = 1
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		trait2.spawnCooldown -= p

		if trait2.spawnCooldown <= 0 then
			trait2.spawnCooldown += trait.trailSpawnInterval or 0

			if #trait2.trail < math.max(1, trait.maxTrailCount or 40) then
				table.insert(trait2.trail, {
					trailId = trait2.nextTrailId,
					position = data.position,
					residueRemaining = trait.trailDuration or 0
				})
				trait2.nextTrailId += 1
			end
		end

		for i = #trait2.trail, 1, -1 do
			local v3 = trait2.trail[i]
			v3.residueRemaining -= p

			if v3.residueRemaining <= 0 then
				table.remove(trait2.trail, i)
			end
		end

		local frostTrailFootprint, v3 = object._geometry:getFrostTrailFootprint()
		local v4 = math.max(frostTrailFootprint, v3) * 0.5

		for _, ball in object.state.balls do
			if not (ball.team ~= data.team and ball.hp > 0) then
				continue
			end

			local flag = false

			for _, v6 in trait2.trail do
				if not ((ball.position - v6.position).Magnitude <= ball.radius + v4) then
					continue
				end

				flag = true
				break
			end

			if flag then
				object:_applySlow(ball, p2, data)

				if ball.frostProcessedAt ~= object.state.elapsed then
					ball.frostProcessedAt = object.state.elapsed
					ball.frostLevel = math.min(
						trait.frostMaxLevel or 10,
						(ball.frostLevel or 0) + (trait.frostChargeRate or 0) * p
					)
					local frostLevel = ball.frostLevel
					local frostTier3TickInterval = nil
					local frostTier3Damage = nil

					if (trait.frostTier3Threshold or 1e999) <= frostLevel then
						frostTier3TickInterval = trait.frostTier3TickInterval
						frostTier3Damage = trait.frostTier3Damage
					elseif (trait.frostTier2Threshold or 1e999) <= frostLevel then
						frostTier3TickInterval = trait.frostTier2TickInterval
						frostTier3Damage = trait.frostTier2Damage
					elseif (trait.frostTier1Threshold or 1e999) <= frostLevel then
						frostTier3TickInterval = trait.frostTier1TickInterval
						frostTier3Damage = trait.frostTier1Damage
					end

					if frostTier3TickInterval then
						ball.frostTickCooldown = (ball.frostTickCooldown or 0) - p

						if ball.frostTickCooldown <= 0 then
							ball.frostTickCooldown = frostTier3TickInterval
							local _applyDamageModifiers = object:_applyDamageModifiers(
								data,
								ball,
								(math.round(frostTier3Damage or 0))
							)

							if _applyDamageModifiers > 0 then
								ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
								object:_onDamageDealt(data, ball, _applyDamageModifiers, list)

								if object.multiEntityMode then
									object:_resolveEntityDeath(ball, data, list)
								end
							end

							table.insert(list, {
								type = "frost_tick",
								ballId = ball.id,
								otherBallId = data.id,
								sourceBallId = data.id,
								targetBallId = ball.id,
								damage = _applyDamageModifiers,
								level = frostLevel,
								position = ball.position
							})
						end
					else
						ball.frostTickCooldown = 0
					end
				end
			else
				local flag2 = false

				for _, ball2 in object.state.balls do
					if ball2.team ~= ball.team and ball2.hp > 0 then
						local frostTrail = ball2.traits and ball2.traits.FrostTrail

						if frostTrail then
							for _, v8 in frostTrail.trail do
								if not ((ball.position - v8.position).Magnitude <= ball.radius + v4) then
									continue
								end

								flag2 = true
								break
							end
						end
					end

					if flag2 then
						break
					end
				end

				if not flag2 then
					ball.frostLevel = 0
					ball.frostTickCooldown = 0
				end
			end
		end
	end
}
BattleSkills.AlchemistGasTrail = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			spawnCooldown = trait.trailSpawnInterval or 0,
			trail = {},
			nextTrailId = 1
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(object, data, _, p, _, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		trait2.spawnCooldown -= p

		if trait2.spawnCooldown <= 0 then
			trait2.spawnCooldown += trait.trailSpawnInterval or 0

			if #trait2.trail < math.max(1, trait.maxTrailCount or 40) then
				table.insert(trait2.trail, {
					trailId = trait2.nextTrailId,
					position = data.position,
					residueRemaining = trait.trailDuration or 0
				})
				trait2.nextTrailId += 1
			end
		end

		for i = #trait2.trail, 1, -1 do
			local v3 = trait2.trail[i]
			v3.residueRemaining -= p

			if v3.residueRemaining <= 0 then
				table.remove(trait2.trail, i)
			end
		end

		local alchemistGasTrailFootprint, v3 = object._geometry:getAlchemistGasTrailFootprint()
		local v4 = math.max(alchemistGasTrailFootprint, v3) * 0.5

		for _, ball in object.state.balls do
			if not (ball.team ~= data.team and ball.hp > 0) then
				continue
			end

			local v5

			if (ball.poisonRemaining or 0) > 0 then
				v5 = ball.poisonedByTraitId == p2
			else
				v5 = false
			end

			if v5 then
				continue
			end

			for _, v7 in trait2.trail do
				if not ((ball.position - v7.position).Magnitude <= ball.radius + v4) then
					continue
				end

				object:_applyPoison(ball, data, p2)
				break
			end
		end
	end
}

local function bowNearestEnemy(object, state)
	local v3 = 1e999
	local v4 = nil

	for _, ball in object.state.balls do
		if ball.team == state.team then
			continue
		end

		local magnitude = (ball.position - state.position).Magnitude

		if not (magnitude < v3) then
			continue
		end

		v4 = ball
		v3 = magnitude
	end

	return v4
end

local function bowReleaseArrow(_, p, trait, trait2, list)
	local v3 = not ((trait2.chargeDuration or 0) > 0) and 1 or math.clamp(
		trait.chargeElapsed / trait2.chargeDuration,
		0,
		1
	) or 1
	local minChargeDamageRatio = trait2.minChargeDamageRatio or 0
	local damage = math.ceil((trait2.arrowDamage or 0) * (minChargeDamageRatio + (1 - minChargeDamageRatio) * v3))
	table.insert(trait.arrows, {
		arrowId = trait.nextArrowId,
		position = p.position,
		direction = trait.aimDirection,
		bouncesRemaining = trait2.arrowBounceCount or 0,
		lifetimeRemaining = trait2.arrowLifetime or 0,
		damage = damage
	})
	trait.nextArrowId += 1
	table.insert(list, {
		type = "bow_arrow_release",
		ballId = p.id,
		position = p.position,
		damage = damage
	})
	trait.phase = "Moving"
	trait.moveCooldown = trait2.moveIntervalBeforeCharge or 0
	trait.chargeElapsed = 0
end

BattleSkills.ChargedBow = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			phase = "Moving",
			moveCooldown = trait.moveIntervalBeforeCharge or 0,
			chargeElapsed = 0,
			aimDirection = p2.direction,
			arrows = {},
			nextArrowId = 1
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	onDamageTaken = function(p, data, _, _, list, p2)
		local trait = data.traits[p2]

		if trait and trait.phase == "Charging" then
			bowReleaseArrow(p, data, trait, p.config.traits[p2], list)
			table.insert(list, {
				type = "bow_charge_interrupted",
				ballId = data.id,
				position = data.position
			})
		end
	end,
	updateFrame = function(object, state, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = state.traits[p2]

		if not trait2 then
			return
		end

		local v3 = object.config.arena.size * 0.5

		for i = #trait2.arrows, 1, -1 do
			local arrow = trait2.arrows[i]
			arrow.lifetimeRemaining -= p

			if arrow.lifetimeRemaining <= 0 then
				table.remove(trait2.arrows, i)
			else
				local position = arrow.position
				arrow.position += arrow.direction * (trait.arrowSpeed or 0) * p
				local flag

				if math.abs(arrow.position.X) > v3.X then
					if arrow.bouncesRemaining <= 0 then
						table.remove(trait2.arrows, i)
						table.insert(list, {
							type = "bow_arrow_expired",
							ballId = state.id,
							position = arrow.position,
							arrowId = arrow.arrowId
						})
						continue
					else
						arrow.direction = Vector2.new(-arrow.direction.X, arrow.direction.Y)
						arrow.position = Vector2.new(math.clamp(arrow.position.X, -v3.X, v3.X), arrow.position.Y)
						arrow.bouncesRemaining -= 1
						flag = true
					end
				else
					flag = false
				end

				if math.abs(arrow.position.Y) > v3.Y then
					if arrow.bouncesRemaining <= 0 then
						table.remove(trait2.arrows, i)
						table.insert(list, {
							type = "bow_arrow_expired",
							ballId = state.id,
							position = arrow.position,
							arrowId = arrow.arrowId
						})
						continue
					else
						arrow.direction = Vector2.new(arrow.direction.X, -arrow.direction.Y)
						arrow.position = Vector2.new(arrow.position.X, (math.clamp(arrow.position.Y, -v3.Y, v3.Y)))
						arrow.bouncesRemaining -= 1
						flag = true
					end
				end

				if flag then
					table.insert(list, {
						type = "bow_arrow_bounce",
						ballId = state.id,
						position = arrow.position,
						arrowId = arrow.arrowId
					})
				else
					local v4 = nil

					for _, ball in object.state.balls do
						if ball.team == state.team then
							continue
						end

						local v6 = closestPointOnSegment(ball.position, position, arrow.position) -- equivalent call inferred; original call site unknown

						if not ((ball.position - v6).Magnitude <= ball.radius) then
							continue
						end

						v4 = ball
						break
					end

					if v4 then
						local _applyProjectileDamage = object:_applyProjectileDamage(
							state,
							v4,
							arrow.damage or trait.arrowDamage or 0
						)

						if _applyProjectileDamage > 0 then
							v4.hp = math.max(0, v4.hp - _applyProjectileDamage)
							object:_onDamageDealt(state, v4, _applyProjectileDamage, list)

							if object.multiEntityMode then
								object:_resolveEntityDeath(v4, state, list)
							end
						end

						table.remove(trait2.arrows, i)
						table.insert(list, {
							type = "bow_arrow_hit",
							ballId = v4.id,
							otherBallId = state.id,
							sourceBallId = state.id,
							targetBallId = v4.id,
							position = arrow.position,
							damage = _applyProjectileDamage,
							arrowId = arrow.arrowId
						})
					end
				end
			end
		end

		if trait2.phase == "Moving" then
			trait2.moveCooldown -= p

			if trait2.moveCooldown <= 0 then
				trait2.phase = "Charging"
				trait2.chargeElapsed = 0
				trait2.aimDirection = state.direction
				table.insert(list, {
					type = "bow_draw_started",
					ballId = state.id,
					position = state.position
				})
			end
		else
			state.bonusSpeedMultiplier = 0
			local v4 = bowNearestEnemy(object, state)

			if v4 then
				local v5 = v4.position - state.position
				local aimDirection

				if v5.Magnitude > 1e-6 then
					aimDirection = v5.Unit
				else
					aimDirection = trait2.aimDirection
				end

				trait2.aimDirection = aimDirection
			end

			trait2.chargeElapsed = math.min(trait.chargeDuration or 0, trait2.chargeElapsed + p)

			if trait2.chargeElapsed >= (trait.chargeDuration or 0) then
				bowReleaseArrow(object, state, trait2, trait, list)
			end
		end
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function harpoonRandomDirection(object)
	local number = object.random:NextNumber(0, 6.283185307179586)
	return Vector2.new(math.cos(number), (math.sin(number)))
end

local function harpoonRelease(object, state, trait, trait2, list)
	if trait.capturedTargetId then
		local _ballById = object:_ballById(trait.capturedTargetId)

		if _ballById and _ballById.harpoonCapturedByBallId == state.id then
			_ballById.harpoonCapturedByBallId = nil
			table.insert(list, {
				type = "harpoon_capture_end",
				ballId = _ballById.id,
				otherBallId = state.id,
				sourceBallId = state.id,
				targetBallId = _ballById.id,
				position = _ballById.position
			})
		end
	end

	trait.phase = "Idle"
	trait.capturedTargetId = nil
	trait.pathPoints = {}
	trait.pullSegmentIndex = 0
	trait.pullSegmentProgress = 0
	trait.pullTickCooldown = 0
	trait.throwCooldown = trait2.throwInterval or 0
end

BattleSkills.Harpoon = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			phase = "Idle",
			throwCooldown = trait.throwInterval or 0,
			direction = Vector2.new(1, 0),
			position = p2.position,
			pathPoints = {},
			bounceCount = 0,
			capturedTargetId = nil,
			pullSegmentIndex = 0,
			pullSegmentProgress = 0,
			pullTickCooldown = 0
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(object, state, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = state.traits[p2]

		if not trait2 then
			return
		end

		if trait2.phase == "Idle" then
			trait2.throwCooldown -= p

			if trait2.throwCooldown <= 0 then
				trait2.phase = "Flying"
				trait2.direction = harpoonRandomDirection(object)
				trait2.position = state.position
				trait2.pathPoints = { trait2.position }
				trait2.bounceCount = 0
				table.insert(list, {
					type = "harpoon_launch",
					ballId = state.id,
					position = trait2.position
				})
			end
		else
			state.bonusSpeedMultiplier = 0

			if trait2.phase == "Flying" then
				local position = trait2.position
				trait2.position += trait2.direction * (trait.harpoonSpeed or 0) * p
				local v4 = nil

				for _, ball in object.state.balls do
					if ball.team == state.team or not (ball.hp > 0) or (ball.harpoonCapturedByBallId or object:isGrabImmune(ball)) then
						continue
					end

					local v6 = closestPointOnSegment(ball.position, position, trait2.position) -- equivalent call inferred; original call site unknown

					if not ((ball.position - v6).Magnitude <= ball.radius + (trait.hitRadius or 0)) then
						continue
					end

					v4 = ball
					break
				end

				if v4 then
					table.insert(trait2.pathPoints, v4.position)
					trait2.phase = "Pulling"
					trait2.capturedTargetId = v4.id
					v4.harpoonCapturedByBallId = state.id
					trait2.pullSegmentIndex = #trait2.pathPoints
					trait2.pullSegmentProgress = 0
					trait2.pullTickCooldown = trait.captureTickInterval or 0
					table.insert(list, {
						type = "harpoon_impact",
						ballId = v4.id,
						otherBallId = state.id,
						sourceBallId = state.id,
						targetBallId = v4.id,
						position = v4.position,
						isEnemyHit = true
					})
				else
					local v6 = object.config.arena.size * 0.5
					local flag

					if trait2.position.X < -v6.X or trait2.position.X > v6.X then
						trait2.direction = Vector2.new(-trait2.direction.X, trait2.direction.Y)
						trait2.position = Vector2.new(math.clamp(trait2.position.X, -v6.X, v6.X), trait2.position.Y)
						flag = true
					else
						flag = false
					end

					if trait2.position.Y < -v6.Y or trait2.position.Y > v6.Y then
						trait2.direction = Vector2.new(trait2.direction.X, -trait2.direction.Y)
						trait2.position = Vector2.new(trait2.position.X, (math.clamp(trait2.position.Y, -v6.Y, v6.Y)))
						flag = true
					end

					if flag then
						trait2.bounceCount += 1

						if trait2.bounceCount > (trait.maxBounceCount or 6) then
							table.insert(list, {
								type = "harpoon_expired",
								ballId = state.id,
								position = trait2.position
							})
							trait2.phase = "Idle"
							trait2.pathPoints = {}
							trait2.pullSegmentIndex = 0
							trait2.throwCooldown = trait.throwInterval or 0
						else
							table.insert(trait2.pathPoints, trait2.position)
							table.insert(list, {
								type = "harpoon_impact",
								ballId = state.id,
								otherBallId = state.id,
								sourceBallId = state.id,
								position = trait2.position,
								isEnemyHit = false
							})
						end
					end
				end
			else
				local _ballById = object:_ballById(trait2.capturedTargetId)

				if not _ballById or _ballById.harpoonCapturedByBallId ~= state.id then
					harpoonRelease(object, state, trait2, trait, list)
					return
				end

				local v4 = (trait.pullSpeed or 0) * p

				while v4 > 0 and trait2.pullSegmentIndex > 1 do
					local pathPoint = trait2.pathPoints[trait2.pullSegmentIndex]
					local pathPoint2 = trait2.pathPoints[trait2.pullSegmentIndex - 1]
					local v5 = pathPoint2 - pathPoint
					local magnitude = v5.Magnitude

					if magnitude <= 1e-6 then
						trait2.pullSegmentIndex -= 1
						trait2.pullSegmentProgress = 0
					else
						local v6 = magnitude - trait2.pullSegmentProgress

						if v6 <= v4 then
							v4 -= v6
							trait2.pullSegmentIndex -= 1
							trait2.pullSegmentProgress = 0
							_ballById.position = pathPoint2
						else
							trait2.pullSegmentProgress += v4
							_ballById.position = pathPoint + v5.Unit * trait2.pullSegmentProgress
							v4 = 0
						end
					end
				end

				trait2.pullTickCooldown -= p

				if trait2.pullTickCooldown <= 0 then
					local _applyDamageModifiers = object:_applyDamageModifiers(
						state,
						_ballById,
						trait.captureTickDamage or 0
					)

					if _applyDamageModifiers > 0 then
						_ballById.hp = math.max(0, _ballById.hp - _applyDamageModifiers)
						object:_onDamageDealt(state, _ballById, _applyDamageModifiers, list)

						if object.multiEntityMode then
							object:_resolveEntityDeath(_ballById, state, list)
						end

						table.insert(list, {
							type = "harpoon_capture_tick",
							ballId = _ballById.id,
							otherBallId = state.id,
							sourceBallId = state.id,
							targetBallId = _ballById.id,
							position = _ballById.position,
							damage = _applyDamageModifiers
						})
					end

					trait2.pullTickCooldown += trait.captureTickInterval or 0
				end

				if trait2.pullSegmentIndex <= 1 then
					harpoonRelease(object, state, trait2, trait, list)
				end
			end
		end
	end
}

local function hiveRandomDirection(p)
	local number = p.random:NextNumber(0, 6.283185307179586)
	return Vector2.new(math.cos(number), (math.sin(number)))
end

local function hiveNearestEnemy(p, p2, position: Vector2)
	local v5 = 1e999
	local v6 = nil

	for _, ball in p.state.balls do
		if not (ball.team ~= p2.team and ball.hp > 0) then
			continue
		end

		local magnitude = (ball.position - position).Magnitude

		if not (magnitude < v5) then
			continue
		end

		v6 = ball
		v5 = magnitude
	end

	return v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rotateTowards(direction: Vector2, unit: Vector2, max: number)
	local v5 = math.atan2(direction.Y, direction.X)
	local v6 = v5 + math.clamp(
		(math.atan2(unit.Y, unit.X) - v5 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793,
		-max,
		max
	)
	return Vector2.new(math.cos(v6), (math.sin(v6)))
end

local function hiveSpawnBee(p, data, trait, trait2, list)
	if #trait.bees >= (trait2.maxActiveBees or 1e999) then
		table.remove(trait.bees, 1)
	end

	local nextBeeId = trait.nextBeeId
	trait.nextBeeId += 1
	local v5 = {
		beeId = nextBeeId,
		phase = "Flying",
		position = data.position,
		direction = 0,
		lifetimeRemaining = 0,
		decelElapsed = 0,
		deathInitialSpeed = 0,
		fadeAlpha = 0
	}
	local number = p.random:NextNumber(0, 6.283185307179586)
	v5.direction = Vector2.new(math.cos(number), (math.sin(number)))
	v5.lifetimeRemaining = trait2.beeLifetime or 0
	table.insert(trait.bees, v5)
	table.insert(list, {
		type = "hive_bee_launch",
		ballId = data.id,
		position = v5.position,
		beeId = nextBeeId
	})
end

local function hiveApplyPoisonStack(object, state, data, trait, list, beeId: number)
	state.hiveVenomStacks = state.hiveVenomStacks or {}
	local poisonTickInterval = trait.poisonTickInterval or 0.4
	local poisonTickDamage = math.round(trait.poisonTickDamage or 0)
	local poisonTickCount = trait.poisonTickCount or 0

	if poisonTickCount <= 0 then
		return
	end

	local _applyDamageModifiers = object:_applyDamageModifiers(data, state, poisonTickDamage)

	if _applyDamageModifiers > 0 then
		state.hp = math.max(0, state.hp - _applyDamageModifiers)
		object:_notifyDamageTaken(state, data, _applyDamageModifiers, list)

		if object.multiEntityMode then
			object:_resolveEntityDeath(state, data, list)
		end

		table.insert(list, {
			type = "hive_venom_tick",
			ballId = state.id,
			otherBallId = data.id,
			sourceBallId = data.id,
			targetBallId = state.id,
			position = state.position,
			damage = _applyDamageModifiers,
			stackId = beeId
		})
	end

	local ticksRemaining = poisonTickCount - 1

	if ticksRemaining <= 0 then
		return
	end

	if #state.hiveVenomStacks >= (trait.maxPoisonStacksPerTarget or 1e999) then
		table.remove(state.hiveVenomStacks, 1)
	end

	table.insert(state.hiveVenomStacks, {
		stackId = beeId,
		ticksRemaining = ticksRemaining,
		tickCooldown = poisonTickInterval,
		tickInterval = poisonTickInterval,
		damage = poisonTickDamage,
		sourceBallId = data.id
	})
end

BattleSkills.HiveSwarm = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			waveCooldown = trait.emitInterval or 0,
			waveCount = 0,
			pendingSpawns = {},
			bees = {},
			nextBeeId = 1
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(p, data, _, p2, list, p3)
		local trait = p.config.traits[p3]
		local trait2 = data.traits[p3]

		if not trait2 then
			return
		end

		for i = #trait2.pendingSpawns, 1, -1 do
			local pendingSpawn = trait2.pendingSpawns[i]
			pendingSpawn.delay -= p2

			if not (pendingSpawn.delay <= 0) then
				continue
			end

			hiveSpawnBee(p, data, trait2, trait, list)
			table.remove(trait2.pendingSpawns, i)
		end

		trait2.waveCooldown -= p2

		if trait2.waveCooldown <= 0 then
			trait2.waveCooldown += trait.emitInterval or 0
			trait2.waveCount += 1
			local v5 = math.min(trait2.waveCount, trait.maxBeesPerWave or 1)
			local v6 = math.max(trait.waveMinReleaseInterval or 0, (trait.waveReleaseBaseInterval or 0) / v5)

			for i = 1, v5 do
				table.insert(trait2.pendingSpawns, {
					delay = (i - 1) * v6
				})
			end
		end

		local v5 = p.config.arena.size * 0.5

		for i = #trait2.bees, 1, -1 do
			local bee = trait2.bees[i]
			bee.lifetimeRemaining -= p2

			if bee.phase == "Dying" then
				bee.decelElapsed += p2
				local v6 = math.clamp(bee.decelElapsed / (trait.deathDecelDuration or 1), 0, 1)
				bee.position += bee.direction * bee.deathInitialSpeed * (1 - v6) * p2

				if v6 >= 0.5 then
					bee.fadeAlpha = (v6 - 0.5) / 0.5
				end

				if v6 >= 1 or bee.lifetimeRemaining <= 0 then
					table.remove(trait2.bees, i)
				end
			elseif bee.lifetimeRemaining <= 0 then
				table.remove(trait2.bees, i)
				table.insert(list, {
					type = "hive_bee_expired",
					ballId = data.id,
					position = bee.position,
					beeId = bee.beeId
				})
			else
				local v6 = hiveNearestEnemy(p, data, bee.position)

				if v6 then
					local v7 = v6.position - bee.position

					if v7.Magnitude > 1e-6 then
						bee.direction = rotateTowards(
							bee.direction,
							v7.Unit,
							math.rad(trait.beeTurnRateDegrees or 0) * p2
						)
					end
				end

				local position = bee.position
				bee.position += bee.direction * (trait.beeSpeed or 0) * p2
				local v7 = nil

				for _, ball in p.state.balls do
					if not (ball.team ~= data.team and ball.hp > 0) then
						continue
					end

					local v9 = closestPointOnSegment(ball.position, position, bee.position) -- equivalent call inferred; original call site unknown

					if not ((ball.position - v9).Magnitude <= ball.radius + (trait.beeHitRadius or 0)) then
						continue
					end

					v7 = ball
					break
				end

				if v7 then
					hiveApplyPoisonStack(p, v7, data, trait, list, bee.beeId)
					local v9 = bee.position - v7.position
					local unit

					if v9.Magnitude > 1e-6 then
						unit = v9.Unit
					else
						unit = bee.direction
					end

					bee.direction -= 2 * bee.direction:Dot(unit) * unit
					bee.phase = "Dying"
					bee.decelElapsed = 0
					bee.deathInitialSpeed = trait.beeSpeed or 0
					bee.fadeAlpha = 0
					table.insert(list, {
						type = "hive_bee_hit",
						ballId = v7.id,
						otherBallId = data.id,
						sourceBallId = data.id,
						targetBallId = v7.id,
						position = bee.position,
						beeId = bee.beeId
					})
				else
					local flag

					if bee.position.X < -v5.X or bee.position.X > v5.X then
						bee.direction = Vector2.new(-bee.direction.X, bee.direction.Y)
						bee.position = Vector2.new(math.clamp(bee.position.X, -v5.X, v5.X), bee.position.Y)
						flag = true
					else
						flag = false
					end

					if bee.position.Y < -v5.Y or bee.position.Y > v5.Y then
						bee.direction = Vector2.new(bee.direction.X, -bee.direction.Y)
						bee.position = Vector2.new(bee.position.X, (math.clamp(bee.position.Y, -v5.Y, v5.Y)))
						flag = true
					end

					if flag then
						table.insert(list, {
							type = "hive_bee_wall_bounce",
							ballId = data.id,
							position = bee.position,
							beeId = bee.beeId
						})
					end
				end
			end
		end
	end
}

local function shurikenRandomDirection(p)
	local number = p.random:NextNumber(0, 6.283185307179586)
	return Vector2.new(math.cos(number), (math.sin(number)))
end

local function shurikenSpawn(object, data, trait, trait2, list)
	if #trait.shurikens >= (trait2.maxActiveShurikens or 1e999) then
		table.remove(trait.shurikens, 1)
	end

	local nextShurikenId = trait.nextShurikenId
	trait.nextShurikenId += 1
	local v6 = {
		shurikenId = nextShurikenId,
		position = data.position,
		direction = 0,
		elapsed = 0,
		lifetimeRemaining = 0
	}
	local number = object.random:NextNumber(0, 6.283185307179586)
	v6.direction = Vector2.new(math.cos(number), (math.sin(number)))
	v6.lifetimeRemaining = trait2.maxLifetime or 0
	table.insert(trait.shurikens, v6)
	table.insert(list, {
		type = "shuriken_launch",
		ballId = data.id,
		position = v6.position,
		shurikenId = nextShurikenId
	})
end

BattleSkills.Shuriken = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			waveCooldown = trait.emitInterval or 0,
			waveCount = 0,
			pendingSpawns = {},
			shurikens = {},
			nextShurikenId = 1
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		for i = #trait2.pendingSpawns, 1, -1 do
			local pendingSpawn = trait2.pendingSpawns[i]
			pendingSpawn.delay -= p

			if not (pendingSpawn.delay <= 0) then
				continue
			end

			shurikenSpawn(object, data, trait2, trait, list)
			table.remove(trait2.pendingSpawns, i)
		end

		trait2.waveCooldown -= p

		if trait2.waveCooldown <= 0 then
			trait2.waveCooldown += trait.emitInterval or 0
			trait2.waveCount += 1
			local v6 = math.min(trait2.waveCount, trait.maxPerWave or 1)
			local v7 = math.max(trait.waveMinReleaseInterval or 0, (trait.waveReleaseBaseInterval or 0) / v6)

			for i = 1, v6 do
				table.insert(trait2.pendingSpawns, {
					delay = (i - 1) * v7
				})
			end
		end

		local v6 = object.config.arena.size * 0.5

		for i = #trait2.shurikens, 1, -1 do
			local shuriken = trait2.shurikens[i]
			shuriken.elapsed += p
			shuriken.lifetimeRemaining -= p

			if shuriken.lifetimeRemaining <= 0 then
				table.remove(trait2.shurikens, i)
				table.insert(list, {
					type = "shuriken_expired",
					ballId = data.id,
					position = shuriken.position,
					shurikenId = shuriken.shurikenId
				})
			else
				local position = shuriken.position
				shuriken.position += shuriken.direction * (trait.shurikenSpeed or 0) * p
				local v7 = nil

				for _, ball in object.state.balls do
					if not (ball.team ~= data.team and ball.hp > 0) then
						continue
					end

					local v9 = closestPointOnSegment(ball.position, position, shuriken.position) -- equivalent call inferred; original call site unknown

					if not ((ball.position - v9).Magnitude <= ball.radius + (trait.hitRadius or 0)) then
						continue
					end

					v7 = ball
					break
				end

				if v7 then
					local _applyDamageModifiers = object:_applyDamageModifiers(
						data,
						v7,
						(math.round(trait.hitDamage or 0))
					)

					if _applyDamageModifiers > 0 then
						v7.hp = math.max(0, v7.hp - _applyDamageModifiers)
						object:_onDamageDealt(data, v7, _applyDamageModifiers, list)

						if object.multiEntityMode then
							object:_resolveEntityDeath(v7, data, list)
						end
					end

					table.remove(trait2.shurikens, i)
					table.insert(list, {
						type = "shuriken_hit",
						ballId = v7.id,
						otherBallId = data.id,
						sourceBallId = data.id,
						targetBallId = v7.id,
						position = shuriken.position,
						damage = _applyDamageModifiers,
						shurikenId = shuriken.shurikenId
					})
				else
					local flag

					if shuriken.position.X < -v6.X or shuriken.position.X > v6.X then
						shuriken.direction = Vector2.new(-shuriken.direction.X, shuriken.direction.Y)
						shuriken.position = Vector2.new(
							math.clamp(shuriken.position.X, -v6.X, v6.X),
							shuriken.position.Y
						)
						flag = true
					else
						flag = false
					end

					if shuriken.position.Y < -v6.Y or shuriken.position.Y > v6.Y then
						shuriken.direction = Vector2.new(shuriken.direction.X, -shuriken.direction.Y)
						shuriken.position = Vector2.new(
							shuriken.position.X,
							(math.clamp(shuriken.position.Y, -v6.Y, v6.Y))
						)
						flag = true
					end

					if flag then
						table.insert(list, {
							type = "shuriken_wall_bounce",
							ballId = data.id,
							position = shuriken.position,
							shurikenId = shuriken.shurikenId
						})
					end
				end
			end
		end
	end
}
local v7 = {
	Vector2.new(1, 0),
	Vector2.new(-1, 0),
	Vector2.new(0, 1),
	Vector2.new(0, -1)
}

local function medicSpawn(data, trait, trait2, direction)
	if #trait.bullets >= (trait2.maxActiveBullets or 1e999) then
		table.remove(trait.bullets, 1)
	end

	local nextBulletId = trait.nextBulletId
	trait.nextBulletId += 1
	table.insert(trait.bullets, {
		bulletId = nextBulletId,
		position = data.position,
		direction = direction,
		bounceCount = 0
	})
end

BattleSkills.MedicBarrage = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			emitCooldown = trait.emitInterval or 0,
			bullets = {},
			nextBulletId = 1
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		trait2.emitCooldown -= p

		if trait2.emitCooldown <= 0 then
			trait2.emitCooldown += trait.emitInterval or 0

			for _, v8 in v7 do
				medicSpawn(data, trait2, trait, v8)
			end

			table.insert(list, {
				type = "medic_launch",
				ballId = data.id,
				position = data.position
			})
		end

		local v8 = object.config.arena.size * 0.5
		local maxBounces = trait.maxBounces or 0

		for i = #trait2.bullets, 1, -1 do
			local bullet = trait2.bullets[i]
			local position = bullet.position
			bullet.position += bullet.direction * (trait.bulletSpeed or 0) * p
			local v9 = nil

			for _, ball in object.state.balls do
				if ball.hp <= 0 or not (ball ~= data or not (bullet.bounceCount < 1)) then
					continue
				end

				local v11 = closestPointOnSegment(ball.position, position, bullet.position) -- equivalent call inferred; original call site unknown

				if not ((ball.position - v11).Magnitude <= ball.radius + (trait.hitRadius or 0)) then
					continue
				end

				v9 = ball
				break
			end

			if v9 then
				local v11 = v9.team == data.team
				local heal = nil
				local damage = nil

				if v11 then
					heal = (trait.allyHeal or 0) * object:_healMultiplier(v9)
					v9.hp += heal
				else
					damage = object:_applyDamageModifiers(data, v9, (math.round(trait.enemyDamage or 0)))

					if damage > 0 then
						v9.hp = math.max(0, v9.hp - damage)
						object:_onDamageDealt(data, v9, damage, list)

						if object.multiEntityMode then
							object:_resolveEntityDeath(v9, data, list)
						end
					end
				end

				table.remove(trait2.bullets, i)
				table.insert(list, {
					type = "medic_bullet_hit",
					ballId = v9.id,
					otherBallId = data.id,
					sourceBallId = data.id,
					targetBallId = v9.id,
					position = bullet.position,
					isDamage = not v11,
					damage = damage,
					heal = heal,
					bulletId = bullet.bulletId
				})
			else
				local flag

				if bullet.position.X < -v8.X or bullet.position.X > v8.X then
					bullet.direction = Vector2.new(-bullet.direction.X, bullet.direction.Y)
					bullet.position = Vector2.new(math.clamp(bullet.position.X, -v8.X, v8.X), bullet.position.Y)
					flag = true
				else
					flag = false
				end

				if bullet.position.Y < -v8.Y or bullet.position.Y > v8.Y then
					bullet.direction = Vector2.new(bullet.direction.X, -bullet.direction.Y)
					bullet.position = Vector2.new(bullet.position.X, (math.clamp(bullet.position.Y, -v8.Y, v8.Y)))
					flag = true
				end

				if flag then
					if maxBounces <= bullet.bounceCount then
						table.remove(trait2.bullets, i)
						table.insert(list, {
							type = "medic_bullet_expired",
							ballId = data.id,
							position = bullet.position,
							bulletId = bullet.bulletId
						})
					else
						bullet.bounceCount += 1
						table.insert(list, {
							type = "medic_bullet_wall_bounce",
							ballId = data.id,
							position = bullet.position,
							bulletId = bullet.bulletId
						})
					end
				end
			end
		end
	end
}

local function mathGenerateEquation(object, trait)
	local v9 = object.random:NextNumber() < (trait.multiplyChance or 0)
	local mulOperandMin

	if v9 then
		mulOperandMin = trait.mulOperandMin
	else
		mulOperandMin = trait.addOperandMin
	end

	local mulOperandMax

	if v9 then
		mulOperandMax = trait.mulOperandMax
	else
		mulOperandMax = trait.addOperandMax
	end

	local v10 = math.floor((math.min(mulOperandMin or 1, mulOperandMax or 1)))
	local v11 = math.floor((math.max(mulOperandMin or 1, mulOperandMax or 1)))
	local v12 = math.max(v10, 0)
	local v13 = math.max(v11, v12)
	local integer = object.random:NextInteger(v12, v13)
	local integer2 = object.random:NextInteger(v12, v13)
	local v14 = {
		a = integer,
		b = integer2,
		operator = v9 and "x" or "+",
		result = 0
	}
	local v15

	if v9 then
		v15 = integer * integer2
	else
		v15 = integer + integer2
	end

	v14.result = v15
	return v14
end

local function mathFireBullet(object, data, trait, trait2, list)
	local v9 = hiveNearestEnemy(object, data, data.position)
	local v10 = v9 and v9.position - data.position
	local unit

	if v10 and v10.Magnitude > 1e-6 then
		unit = v10.Unit
	else
		local number = object.random:NextNumber(0, 6.283185307179586)
		unit = Vector2.new(math.cos(number), (math.sin(number)))
	end

	if #trait.bullets >= (trait2.maxActiveBullets or 1e999) then
		table.remove(trait.bullets, 1)
	end

	local nextBulletId = trait.nextBulletId
	trait.nextBulletId += 1
	local damage = not trait.equation and 0 or trait.equation.result
	table.insert(trait.bullets, {
		bulletId = nextBulletId,
		position = data.position,
		direction = unit,
		damage = damage,
		lifetimeRemaining = trait2.bulletLifetime or 0
	})
	table.insert(list, {
		type = "math_bullet_launch",
		ballId = data.id,
		position = data.position,
		bulletId = nextBulletId,
		damage = damage
	})
end

BattleSkills.MathEquation = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			phase = "Charging",
			phaseElapsed = 0,
			calcSerial = 0,
			equation = nil,
			bullets = {},
			nextBulletId = 1
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		local v9 = object.config.arena.size * 0.5
		local v10 = math.rad(trait.bulletTurnRateDegrees or 0) * p

		for i = #trait2.bullets, 1, -1 do
			local bullet = trait2.bullets[i]
			bullet.lifetimeRemaining -= p

			if bullet.lifetimeRemaining <= 0 then
				table.remove(trait2.bullets, i)
				table.insert(list, {
					type = "math_bullet_expired",
					ballId = data.id,
					position = bullet.position,
					bulletId = bullet.bulletId
				})
			else
				local v11 = hiveNearestEnemy(object, data, bullet.position)

				if v11 then
					local v12 = v11.position - bullet.position

					if v12.Magnitude > 1e-6 then
						bullet.direction = rotateTowards(bullet.direction, v12.Unit, v10)
					end
				end

				local position = bullet.position
				bullet.position += bullet.direction * (trait.bulletSpeed or 0) * p
				local v12 = nil

				for _, ball in object.state.balls do
					if not (ball.team ~= data.team and ball.hp > 0) then
						continue
					end

					local v14 = closestPointOnSegment(ball.position, position, bullet.position) -- equivalent call inferred; original call site unknown

					if not ((ball.position - v14).Magnitude <= ball.radius + (trait.bulletHitRadius or 0)) then
						continue
					end

					v12 = ball
					break
				end

				if v12 then
					local _applyDamageModifiers = object:_applyDamageModifiers(data, v12, bullet.damage)

					if _applyDamageModifiers > 0 then
						v12.hp = math.max(0, v12.hp - _applyDamageModifiers)
						object:_onDamageDealt(data, v12, _applyDamageModifiers, list)

						if object.multiEntityMode then
							object:_resolveEntityDeath(v12, data, list)
						end
					end

					table.remove(trait2.bullets, i)
					table.insert(list, {
						type = "math_bullet_hit",
						ballId = v12.id,
						otherBallId = data.id,
						sourceBallId = data.id,
						targetBallId = v12.id,
						position = bullet.position,
						damage = _applyDamageModifiers,
						bulletId = bullet.bulletId
					})
				elseif math.abs(bullet.position.X) > v9.X or math.abs(bullet.position.Y) > v9.Y then
					local vector = Vector2.new(
						math.clamp(bullet.position.X, -v9.X, v9.X),
						(math.clamp(bullet.position.Y, -v9.Y, v9.Y))
					)
					table.remove(trait2.bullets, i)
					table.insert(list, {
						type = "math_bullet_wall",
						ballId = data.id,
						position = vector,
						bulletId = bullet.bulletId
					})
				end
			end
		end

		trait2.phaseElapsed += p

		if trait2.phase == "Charging" then
			local v11 = math.max(trait.chargeDuration or 0, 0)

			if v11 <= trait2.phaseElapsed then
				trait2.phaseElapsed -= v11
				trait2.phase = "Calculating"
				trait2.calcSerial += 1
				trait2.equation = mathGenerateEquation(object, trait)
			end
		end

		if trait2.phase == "Calculating" then
			local duration = MathEquationTiming.calculateDuration(trait)

			if duration <= trait2.phaseElapsed then
				trait2.phaseElapsed -= duration
				mathFireBullet(object, data, trait2, trait, list)
				trait2.phase = "Charging"
				trait2.equation = nil
			end
		end
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function snakeTailFullScale(p, p2: number)
	local v10 = math.max(1, (math.floor(p.maxTailSegments or 1)))
	local tailEndFullScale = p.tailEndFullScale or 0.5
	local v11 = (p2 - 1) / math.max(1, v10 - 1)
	return 1 + (tailEndFullScale - 1) * v11
end

local function snakeTailSegment(p, p2, p3: number, isFullyGrown: boolean, growthAlpha: number)
	local fullScale = snakeTailFullScale(p2, p3) -- equivalent call inferred; original call site unknown
	local incompleteMinScale = p2.incompleteMinScale or 0.25
	local scale = fullScale * (isFullyGrown and 1 or incompleteMinScale + (1 - incompleteMinScale) * growthAlpha)
	return {
		tailId = p.nextTailId,
		index = p3,
		position = Vector2.zero,
		direction = nil,
		fullScale = fullScale,
		scale = scale,
		radius = 0,
		growthAlpha = growthAlpha,
		isFullyGrown = isFullyGrown,
		hitCooldownByTarget = {}
	}
end

local snakeTail = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		local v10 = {
			tailSegments = {},
			nextTailId = 1,
			growthCharge = 0,
			growthThreshold = math.max(1, trait.initialGrowthThreshold or 1),
			waveElapsed = 0,
			headHitCooldownByTarget = {}
		}

		for i = 1, math.clamp(
			math.floor(trait.startingFullyGrownSegments or 0),
			0,
			(math.max(1, (math.floor(trait.maxTailSegments or 1))))
		) do
			local v11 = snakeTailSegment(v10, trait, i, true, 1)
			table.insert(v10.tailSegments, v11)
			v10.nextTailId += 1
		end

		p2.traits[p3] = v10
	end,
	updateFrame = function(_, p, _, p2, _, p3)
		local trait = p.traits[p3]

		if not trait then
			return
		end

		if p.currentSpeed > 0.001 then
			trait.waveElapsed += p2
		end

		for k, v10 in trait.headHitCooldownByTarget do
			local v11 = math.max(0, v10 - p2)

			if v11 <= 0 then
				trait.headHitCooldownByTarget[k] = nil
			else
				trait.headHitCooldownByTarget[k] = v11
			end
		end

		for _, tailSegment in trait.tailSegments do
			for k, v10 in tailSegment.hitCooldownByTarget do
				local v11 = math.max(0, v10 - p2)

				if v11 <= 0 then
					tailSegment.hitCooldownByTarget[k] = nil
				else
					tailSegment.hitCooldownByTarget[k] = v11
				end
			end
		end
	end
}

local function snakeTailAddGrowth(object, data, trait, trait2, _, list)
	local v10 = math.max(1, (math.floor(trait2.maxTailSegments or 1)))
	local tailSegments = trait.tailSegments
	local tailSegment = tailSegments[#tailSegments]

	if v10 <= #tailSegments and tailSegment and tailSegment.isFullyGrown then
		return
	end

	trait.growthCharge += 1

	if not tailSegment or tailSegment.isFullyGrown then
		tailSegment = snakeTailSegment(trait, trait2, #tailSegments + 1, false, 0)
		table.insert(tailSegments, tailSegment)
		trait.nextTailId += 1
	end

	tailSegment.growthAlpha = math.clamp(trait.growthCharge / math.max(1, trait.growthThreshold), 0, 1)

	if trait.growthCharge < trait.growthThreshold then
		object:_refreshSnakeTail(data)
		return
	end

	tailSegment.growthAlpha = 1
	tailSegment.isFullyGrown = true
	trait.growthCharge = 0
	trait.growthThreshold += math.max(0, trait2.growthThresholdIncrement or 0)
	object:_refreshSnakeTail(data)
	table.insert(list, {
		type = "snake_tail_grown",
		ballId = data.id,
		tailId = tailSegment.tailId,
		tailIndex = tailSegment.index,
		position = tailSegment.position
	})
end

function snakeTail.weaponHits(object, data, state, list, p)
	local trait = data.traits[p]
	local trait2 = object.config.traits[p]

	if not trait or object.state.balls[state.id] ~= state then
		return
	end

	local v10 = {}

	if data.position and data.radius and (trait.headHitCooldownByTarget[state.id] or 0) <= 0 and (state.position - data.position).Magnitude <= data.radius + state.radius then
		table.insert(v10, {
			tailId = 0,
			index = 0,
			position = data.position,
			radius = data.radius,
			hitCooldownByTarget = trait.headHitCooldownByTarget
		})
	end

	for _, tailSegment in trait.tailSegments do
		if not ((tailSegment.hitCooldownByTarget[state.id] or 0) <= 0 and (state.position - tailSegment.position).Magnitude <= (tailSegment.radius or 0) + state.radius) then
			continue
		end

		table.insert(v10, tailSegment)
	end

	for _, v11 in v10 do
		v11.hitCooldownByTarget[state.id] = math.max(0, trait2.tailHitCooldown or 0)
		local _applyDamageModifiers = object:_applyDamageModifiers(data, state, trait2.tailBaseDamage or 0)
		object:_pushBallAwayFromEffect(state, v11.position, v11.radius or 0, -data.direction)
		object:_refreshSnakeTail(state)

		if not (_applyDamageModifiers > 0) then
			continue
		end

		state.hp = math.max(0, state.hp - _applyDamageModifiers)
		object:_onDamageDealt(data, state, _applyDamageModifiers, list)
		table.insert(list, {
			type = "snake_tail_hit",
			ballId = state.id,
			otherBallId = data.id,
			sourceBallId = data.id,
			targetBallId = state.id,
			tailId = v11.tailId,
			tailIndex = v11.index,
			position = v11.position,
			damage = _applyDamageModifiers
		})
		snakeTailAddGrowth(object, data, trait, trait2, v11, list)

		if not object.multiEntityMode then
			continue
		end

		object:_resolveEntityDeath(state, data, list)

		if object.state.balls[state.id] ~= state then
			break
		end
	end
end

BattleSkills.SnakeTail = snakeTail

-- equivalent calls inferred from this helper; original call sites unknown
local function thiefRageRatio(p, data)
	local v11 = not (p.maxHp > 0) and 0 or p.hp / p.maxHp
	local lowHealthThreshold = data.lowHealthThreshold or 0.2
	return (math.clamp((1 - v11) / math.max(1 - lowHealthThreshold, 1e-6), 0, 1))
end

local function thiefRoundPlan(p, trait)
	local v11 = thiefRageRatio(p, trait) -- equivalent call inferred; original call site unknown
	local fullHealthKnifeCount = trait.fullHealthKnifeCount or 3
	local lowHealthKnifeCount = trait.lowHealthKnifeCount or 8
	local v12 = math.clamp(
		math.round(fullHealthKnifeCount + (lowHealthKnifeCount - fullHealthKnifeCount) * v11),
		math.min(fullHealthKnifeCount, lowHealthKnifeCount),
		(math.max(fullHealthKnifeCount, lowHealthKnifeCount))
	)
	local fullHealthChargeDuration = trait.fullHealthChargeDuration or 2.4
	local fullHealthThrowInterval = trait.fullHealthThrowInterval or 0.28
	local v13 = fullHealthChargeDuration + ((trait.lowHealthChargeDuration or 0.9) - fullHealthChargeDuration) * v11
	local v14 = fullHealthThrowInterval + ((trait.lowHealthThrowInterval or 0.12) - fullHealthThrowInterval) * v11
	return v12, math.max(v13, 1e-6), (math.max(v14, 0))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function thiefFanAngle(p: number, plannedKnifeCount: number, value: number)
	if plannedKnifeCount <= 1 then
		return 0
	end

	local v11 = math.rad(value or 0)
	return -v11 * 0.5 + v11 * ((p - 1) / (plannedKnifeCount - 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function thiefRotate(point: Vector2, p: number)
	local v11 = math.cos(p)
	local v12 = math.sin(p)
	return Vector2.new(point.X * v11 - point.Y * v12, point.X * v12 + point.Y * v11)
end

local function thiefNearestEnemy(object, data)
	local v11 = 1e999
	local v12 = nil

	for _, ball in object.state.balls do
		if ball.team == data.team then
			continue
		end

		local magnitude = (ball.position - data.position).Magnitude

		if not (magnitude < v11) then
			continue
		end

		v12 = ball
		v11 = magnitude
	end

	return v12
end

local function thiefRefreshHeldKnives(trait, data, lockedAimDirection: Vector2, p: number, fanTotalAngle: number)
	for _, heldKnive in trait.heldKnives do
		local angle = thiefFanAngle(heldKnive.index, trait.plannedKnifeCount, fanTotalAngle) -- equivalent call inferred; original call site unknown
		heldKnive.angle = angle
		heldKnive.direction = thiefRotate(lockedAimDirection, heldKnive.angle)
		heldKnive.position = data.position + heldKnive.direction * p
	end
end

BattleSkills.ThiefKnives = {
	initialize = function(p, p2, p3)
		local plannedKnifeCount, chargeDuration, throwInterval = thiefRoundPlan(p2, p.config.traits[p3])
		p2.traits[p3] = {
			phase = "Charging",
			chargeElapsed = 0,
			chargeDuration = chargeDuration,
			plannedKnifeCount = plannedKnifeCount,
			lockedTargetId = nil,
			lockedAimDirection = p2.direction,
			throwInterval = throwInterval,
			throwCooldown = 0,
			nextKnifeIndex = 1,
			heldKnives = {},
			projectiles = {},
			nextProjectileId = 1
		}
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		local assetName = trait.assetName
		local v11

		if type(assetName) == "string" then
			v11 = assetName ~= ""
		else
			v11 = false
		end

		assert(v11, "BattleConfig.traits.ThiefKnives.assetName is missing")
		local _getEffectCollisionRadius = object:_getEffectCollisionRadius(assetName)
		local v12 = object.config.arena.size * 0.5

		for i = #trait2.projectiles, 1, -1 do
			local projectile = trait2.projectiles[i]
			local position = projectile.position
			projectile.position += projectile.direction * (trait.knifeSpeed or 0) * p

			if math.abs(projectile.position.X) > v12.X or math.abs(projectile.position.Y) > v12.Y then
				table.remove(trait2.projectiles, i)
				table.insert(list, {
					type = "thief_knife_wall",
					ballId = data.id,
					position = projectile.position,
					projectileId = projectile.projectileId
				})
			else
				local v13 = nil

				for _, ball in object.state.balls do
					if ball.team == data.team then
						continue
					end

					local v15 = closestPointOnSegment(ball.position, position, projectile.position) -- equivalent call inferred; original call site unknown

					if not ((ball.position - v15).Magnitude <= ball.radius + _getEffectCollisionRadius) then
						continue
					end

					v13 = ball
					break
				end

				if v13 then
					local _applyProjectileDamage = object:_applyProjectileDamage(data, v13, trait.knifeDamage or 0)

					if _applyProjectileDamage > 0 then
						v13.hp = math.max(0, v13.hp - _applyProjectileDamage)
						object:_onDamageDealt(data, v13, _applyProjectileDamage, list)

						if object.multiEntityMode then
							object:_resolveEntityDeath(v13, data, list)
						end
					end

					table.remove(trait2.projectiles, i)
					table.insert(list, {
						type = "thief_knife_hit",
						ballId = v13.id,
						otherBallId = data.id,
						sourceBallId = data.id,
						targetBallId = v13.id,
						position = projectile.position,
						damage = _applyProjectileDamage,
						projectileId = projectile.projectileId
					})
				end
			end
		end

		local v13 = data.radius + _getEffectCollisionRadius
		local fanTotalAngle = trait.fanTotalAngle or 24

		if trait2.phase == "Charging" then
			local v14 = thiefNearestEnemy(object, data)
			local lockedAimDirection = trait2.lockedAimDirection or data.direction

			if v14 then
				local v15 = v14.position - data.position

				if v15.Magnitude > 1e-6 then
					lockedAimDirection = v15.Unit
				else
					lockedAimDirection = data.direction
				end
			end

			trait2.lockedAimDirection = lockedAimDirection
			trait2.chargeElapsed = math.min(trait2.chargeDuration, trait2.chargeElapsed + p)
			local v15 = math.clamp(trait2.chargeElapsed / trait2.chargeDuration, 0, 1)
			local v16 = math.min(trait2.plannedKnifeCount, (math.floor(v15 * trait2.plannedKnifeCount)))

			while #trait2.heldKnives < v16 do
				local count = #trait2.heldKnives + 1
				table.insert(trait2.heldKnives, {
					index = count,
					angle = 0,
					direction = lockedAimDirection,
					position = data.position
				})
				table.insert(list, {
					type = "thief_knife_charge_gain",
					ballId = data.id,
					position = data.position,
					count = count
				})
			end

			thiefRefreshHeldKnives(trait2, data, lockedAimDirection, v13, fanTotalAngle)

			if trait2.chargeElapsed >= trait2.chargeDuration and v14 then
				local _, _, v17 = thiefRoundPlan(data, trait)
				trait2.phase = "Throwing"
				trait2.lockedTargetId = v14.id
				trait2.throwInterval = v17
				trait2.throwCooldown = v17
				trait2.nextKnifeIndex = 1
				table.insert(list, {
					type = "thief_knife_charge_complete",
					ballId = data.id,
					position = data.position,
					count = trait2.plannedKnifeCount
				})
			end
		else
			local v14 = trait2.lockedTargetId and object:_ballById(trait2.lockedTargetId) or thiefNearestEnemy(
				object,
				data
			)

			if v14 then
				local v15 = v14.position - data.position

				if v15.Magnitude > 1e-6 then
					trait2.lockedAimDirection = v15.Unit
				end
			end

			local lockedAimDirection = trait2.lockedAimDirection or data.direction
			thiefRefreshHeldKnives(trait2, data, lockedAimDirection, v13, fanTotalAngle)
			trait2.throwCooldown -= p

			while trait2.throwCooldown <= 0 and trait2.nextKnifeIndex <= trait2.plannedKnifeCount do
				local v15 = thiefFanAngle(trait2.nextKnifeIndex, trait2.plannedKnifeCount, fanTotalAngle) -- equivalent call inferred; original call site unknown
				local direction = thiefRotate(lockedAimDirection, v15) -- equivalent call inferred; original call site unknown
				local position = data.position + direction * v13
				table.insert(trait2.projectiles, {
					projectileId = trait2.nextProjectileId,
					position = position,
					direction = direction
				})
				trait2.nextProjectileId += 1
				table.remove(trait2.heldKnives, 1)
				table.insert(list, {
					type = "thief_knife_throw",
					ballId = data.id,
					position = position,
					index = trait2.nextKnifeIndex,
					count = trait2.plannedKnifeCount
				})
				trait2.nextKnifeIndex += 1
				trait2.throwCooldown += math.max(trait2.throwInterval, 1e-6)
			end

			if trait2.nextKnifeIndex > trait2.plannedKnifeCount then
				local plannedKnifeCount, chargeDuration = thiefRoundPlan(data, trait)
				trait2.phase = "Charging"
				trait2.chargeElapsed = 0
				trait2.chargeDuration = chargeDuration
				trait2.plannedKnifeCount = plannedKnifeCount
				trait2.lockedTargetId = nil
				trait2.heldKnives = {}
			end
		end
	end
}
BattleSkills.IceConeTrail = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			placeCooldown = 0,
			bombs = {},
			nextBombId = 1,
			iceCones = {},
			nextProjectileId = 1
		}
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		local v11 = object.config.arena.size * 0.5
		local _getEffectCollisionRadius = object:_getEffectCollisionRadius(object.config.visual.iceConeTemplateName)

		for i = #trait2.iceCones, 1, -1 do
			local iceCone = trait2.iceCones[i]
			iceCone.previousPosition = iceCone.position
			local v12 = math.min(
				(trait.iceConeSpeed or 0) * p,
				(math.max(0, (trait.iceConeMaxDistance or 0) - iceCone.distanceTravelled))
			)
			iceCone.position += iceCone.direction * v12
			iceCone.distanceTravelled += v12
			local v13 = nil

			for _, ball in object.state.balls do
				if ball.team == data.team then
					continue
				end

				local position = ball.position
				local previousPosition = iceCone.previousPosition
				local vector = iceCone.position - previousPosition
				local dot = vector:Dot(vector)

				if not (dot <= 1e-6) then
					previousPosition += vector * math.clamp((position - previousPosition):Dot(vector) / dot, 0, 1)
				end

				if not ((ball.position - previousPosition).Magnitude <= ball.radius + _getEffectCollisionRadius) then
					continue
				end

				v13 = ball
				break
			end

			if v13 then
				local _applyProjectileDamage = object:_applyProjectileDamage(data, v13, trait.iceConeDamage or 0)

				if _applyProjectileDamage > 0 then
					v13.hp = math.max(0, v13.hp - _applyProjectileDamage)
					object:_onDamageDealt(data, v13, _applyProjectileDamage, list)

					if object.multiEntityMode then
						object:_resolveEntityDeath(v13, data, list)
					end
				end

				table.remove(trait2.iceCones, i)
				table.insert(list, {
					type = "ice_cone_hit",
					ballId = v13.id,
					otherBallId = data.id,
					sourceBallId = data.id,
					targetBallId = v13.id,
					position = iceCone.position,
					damage = _applyProjectileDamage,
					projectileId = iceCone.projectileId
				})
			elseif math.abs(iceCone.position.X) > v11.X or math.abs(iceCone.position.Y) > v11.Y then
				table.remove(trait2.iceCones, i)
				table.insert(list, {
					type = "ice_cone_wall",
					ballId = data.id,
					position = iceCone.position,
					projectileId = iceCone.projectileId
				})
			elseif iceCone.distanceTravelled >= (trait.iceConeMaxDistance or 0) then
				table.remove(trait2.iceCones, i)
			end
		end

		for i = #trait2.bombs, 1, -1 do
			local bomb = trait2.bombs[i]
			bomb.fuseElapsed += p

			if not (bomb.fuseElapsed >= (trait.bombFuseDuration or 0)) then
				continue
			end

			table.remove(trait2.bombs, i)
			table.insert(list, {
				type = "ice_cone_bomb_explode",
				ballId = data.id,
				position = bomb.position,
				bombId = bomb.bombId
			})
			local v12 = math.max(1, (math.floor(trait.iceConeCount or 1)))

			for i2 = 0, v12 - 1 do
				local v13 = i2 * 3.141592653589793 * 2 / v12
				local vector = Vector2.new(math.cos(v13), (math.sin(v13)))
				local v14 = {
					projectileId = trait2.nextProjectileId,
					position = bomb.position,
					previousPosition = bomb.position,
					direction = vector,
					distanceTravelled = 0
				}
				trait2.nextProjectileId += 1
				table.insert(trait2.iceCones, v14)
				table.insert(list, {
					type = "ice_cone_spawn",
					ballId = data.id,
					position = bomb.position,
					projectileId = v14.projectileId,
					direction = vector
				})
			end
		end

		local placeInterval = trait.placeInterval or 0

		if placeInterval <= 0 then
			return
		end

		trait2.placeCooldown -= p

		while trait2.placeCooldown <= 0 do
			if #trait2.bombs < math.max(1, (math.floor(trait.maxBombCount or 1))) then
				local v12 = {
					bombId = trait2.nextBombId,
					position = data.position,
					fuseElapsed = 0
				}
				trait2.nextBombId += 1
				table.insert(trait2.bombs, v12)
				table.insert(list, {
					type = "ice_cone_bomb_place",
					ballId = data.id,
					position = v12.position,
					bombId = v12.bombId
				})
			end

			trait2.placeCooldown += placeInterval
		end
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function bombNormalizeOrFallback(point: Vector2, dashDirection: Vector2)
	if point.Magnitude < 0.001 then
		return dashDirection
	end

	return point.Unit
end

BattleSkills.TimeBomb = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			placeCooldown = 0,
			bombs = {},
			nextBombId = 1
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		local _getEffectCollisionRadius = object:_getEffectCollisionRadius(object.config.visual.bombExplosionTemplateName)

		for i = #trait2.bombs, 1, -1 do
			local bomb = trait2.bombs[i]
			bomb.fuseElapsed += p

			if not (bomb.fuseElapsed >= (trait.bombFuseDuration or 0)) then
				continue
			end

			table.remove(trait2.bombs, i)
			table.insert(list, {
				type = "time_bomb_explode",
				ballId = data.id,
				position = bomb.position,
				bombId = bomb.bombId
			})

			for _, ball in object.state.balls do
				if not (ball.team ~= data.team and ball.hp > 0 and (ball.position - bomb.position).Magnitude <= ball.radius + _getEffectCollisionRadius) then
					continue
				end

				local _applyDamageModifiers = object:_applyDamageModifiers(data, ball, trait.explosionDamage or 0)

				if _applyDamageModifiers > 0 then
					ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
					object:_onDamageDealt(data, ball, _applyDamageModifiers, list)
					object:_notifyDamageTaken(ball, data, _applyDamageModifiers, list)

					if object.multiEntityMode then
						object:_resolveEntityDeath(ball, data, list)
					end
				end

				local v11 = ball.position - bomb.position
				local direction = ball.direction

				if not (v11.Magnitude < 0.001) then
					direction = v11.Unit
				end

				ball.direction = direction
				ball.explosionImpulseDirection = direction
				ball.explosionImpulsePeakSpeed = trait.explosionImpulseSpeed or 0
				ball.explosionImpulseRemaining = trait.explosionImpulseDuration or 0
				ball.explosionImpulseDuration = trait.explosionImpulseDuration or 0
				table.insert(list, {
					type = "time_bomb_explode_hit",
					ballId = ball.id,
					otherBallId = data.id,
					sourceBallId = data.id,
					targetBallId = ball.id,
					position = ball.position,
					damage = _applyDamageModifiers
				})
			end
		end

		local placeInterval = trait.placeInterval or 0

		if placeInterval <= 0 then
			return
		end

		trait2.placeCooldown -= p

		while trait2.placeCooldown <= 0 do
			if #trait2.bombs < math.max(1, (math.floor(trait.maxBombCount or 1))) then
				local v11 = {
					bombId = trait2.nextBombId,
					position = data.position,
					fuseElapsed = 0
				}
				trait2.nextBombId += 1
				table.insert(trait2.bombs, v11)
				table.insert(list, {
					type = "time_bomb_place",
					ballId = data.id,
					position = v11.position,
					bombId = v11.bombId
				})
			end

			trait2.placeCooldown += placeInterval
		end
	end
}
local v12 = {
	Red = "potionRedRegionTemplateName",
	Green = "potionGreenRegionTemplateName",
	Blue = "potionBlueRegionTemplateName"
}
local v13 = { "Red", "Green", "Blue" }

-- equivalent calls inferred from this helper; original call sites unknown
local function potionRegionDurationFor(data, potionType)
	if potionType == "Red" then
		return data.redRegionDuration
	elseif potionType == "Green" then
		return data.greenRegionDuration
	end

	return data.blueRegionDuration
end

local function updatePotionRegions(object, p, trait, trait2, p2, list, p3)
	for i = #trait.potions, 1, -1 do
		local potion = trait.potions[i]
		potion.elapsed += p2
		local elapsed = potion.elapsed
		local v14 = potionRegionDurationFor(trait2, potion.potionType) -- equivalent call inferred; original call site unknown

		if (v14 or 0) <= elapsed then
			table.remove(trait.potions, i)
		else
			local _getEffectCollisionRadius = object:_getEffectCollisionRadius(object.config.visual[v12[potion.potionType]])

			for _, ball in object.state.balls do
				if not (ball.team ~= p.team and ball.hp > 0) then
					continue
				end

				local v15 = (ball.position - potion.position).Magnitude <= ball.radius + _getEffectCollisionRadius

				if potion.potionType == "Red" then
					if v15 then
						local v16 = (potion.tickCooldownByTarget[ball.id] or 0) - p2

						if v16 <= 0 then
							v16 += trait2.redTickInterval or 1
							local _applyDamageModifiers = object:_applyDamageModifiers(
								p,
								ball,
								(math.round(trait2.redTickDamage or 0))
							)

							if _applyDamageModifiers > 0 then
								ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
								object:_onDamageDealt(p, ball, _applyDamageModifiers, list)

								if object.multiEntityMode then
									object:_resolveEntityDeath(ball, p, list)
								end
							end

							table.insert(list, {
								type = "potion_red_tick",
								ballId = ball.id,
								otherBallId = p.id,
								sourceBallId = p.id,
								targetBallId = ball.id,
								damage = _applyDamageModifiers,
								position = ball.position
							})
						end

						potion.tickCooldownByTarget[ball.id] = v16
					else
						potion.tickCooldownByTarget[ball.id] = nil
					end
				elseif potion.potionType == "Green" then
					if v15 then
						local v16 = (potion.tickCooldownByTarget[ball.id] or 0) - p2

						if v16 <= 0 then
							v16 += trait2.greenReapplyInterval or 1
							object:_applyPoison(ball, p, p3)
						end

						potion.tickCooldownByTarget[ball.id] = v16
					else
						potion.tickCooldownByTarget[ball.id] = nil
					end
				end
			end
		end
	end
end

local function updateBlueFrost(object, p, trait, trait2, p2, list, p3)
	for _, ball in object.state.balls do
		if not (ball.team ~= p.team and ball.hp > 0) then
			continue
		end

		local flag = false

		for _, potion in trait.potions do
			if potion.potionType ~= "Blue" then
				continue
			end

			local _getEffectCollisionRadius = object:_getEffectCollisionRadius(object.config.visual.potionBlueRegionTemplateName)

			if not ((ball.position - potion.position).Magnitude <= ball.radius + _getEffectCollisionRadius) then
				continue
			end

			flag = true
			break
		end

		if flag then
			object:_applySlow(ball, p3, p)
			ball.potionFrostLevel = math.min(
				trait2.potionFrostMaxLevel or 10,
				(ball.potionFrostLevel or 0) + (trait2.potionFrostChargeRate or 0) * p2
			)
			local potionFrostLevel = ball.potionFrostLevel
			local potionFrostTier3TickInterval = nil
			local potionFrostTier3Damage = nil

			if (trait2.potionFrostTier3Threshold or 1e999) <= potionFrostLevel then
				potionFrostTier3TickInterval = trait2.potionFrostTier3TickInterval
				potionFrostTier3Damage = trait2.potionFrostTier3Damage
			elseif (trait2.potionFrostTier2Threshold or 1e999) <= potionFrostLevel then
				potionFrostTier3TickInterval = trait2.potionFrostTier2TickInterval
				potionFrostTier3Damage = trait2.potionFrostTier2Damage
			elseif (trait2.potionFrostTier1Threshold or 1e999) <= potionFrostLevel then
				potionFrostTier3TickInterval = trait2.potionFrostTier1TickInterval
				potionFrostTier3Damage = trait2.potionFrostTier1Damage
			end

			if potionFrostTier3TickInterval then
				ball.potionFrostTickCooldown = (ball.potionFrostTickCooldown or 0) - p2

				if ball.potionFrostTickCooldown <= 0 then
					ball.potionFrostTickCooldown = potionFrostTier3TickInterval
					local _applyDamageModifiers = object:_applyDamageModifiers(
						p,
						ball,
						(math.round(potionFrostTier3Damage or 0))
					)

					if _applyDamageModifiers > 0 then
						ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
						object:_onDamageDealt(p, ball, _applyDamageModifiers, list)

						if object.multiEntityMode then
							object:_resolveEntityDeath(ball, p, list)
						end
					end

					table.insert(list, {
						type = "potion_blue_tick",
						ballId = ball.id,
						otherBallId = p.id,
						sourceBallId = p.id,
						targetBallId = ball.id,
						damage = _applyDamageModifiers,
						level = potionFrostLevel,
						position = ball.position
					})
				end
			else
				ball.potionFrostTickCooldown = 0
			end
		else
			ball.potionFrostLevel = 0
			ball.potionFrostTickCooldown = 0
		end
	end
end

local function updateThrowCycle(object, p, trait, trait2, p2, _, _)
	if trait.isFlying then
		trait.flightElapsed += p2

		if trait.flightElapsed >= (trait2.flightDuration or 0) then
			trait.isFlying = false

			if #trait.potions < math.max(1, (math.floor(trait2.maxActivePotionCount or 1))) then
				table.insert(trait.potions, {
					potionId = trait.nextPotionId,
					potionType = trait.pendingType,
					position = trait.flightTargetPosition,
					elapsed = 0,
					tickCooldownByTarget = {}
				})
				trait.nextPotionId += 1
			end

			trait.pendingType = nil
		end
	elseif trait.isWindingUp then
		trait.windupElapsed += p2

		if trait.windupElapsed >= (trait2.windupDuration or 0) then
			trait.isWindingUp = false
			trait.isFlying = true
			trait.flightElapsed = 0
			trait.flightStartPosition = p.position
		end
	else
		trait.cooldown -= p2

		if trait.cooldown <= 0 then
			trait.cooldown += trait2.throwInterval or 1

			if #trait.potions < math.max(1, (math.floor(trait2.maxActivePotionCount or 1))) then
				local pendingType = v13[object.random:NextInteger(1, 3)]
				local _getEffectCollisionRadius = object:_getEffectCollisionRadius(object.config.visual[v12[pendingType]])
				local v15 = object.config.arena.size * 0.5
				local v16 = math.max(0, v15.X - _getEffectCollisionRadius - (trait2.arenaEdgePadding or 0))
				local v17 = math.max(0, v15.Y - _getEffectCollisionRadius - (trait2.arenaEdgePadding or 0))
				trait.pendingType = pendingType
				trait.flightTargetPosition = Vector2.new(
					object.random:NextNumber(-v16, v16),
					object.random:NextNumber(-v17, v17)
				)
				trait.isWindingUp = true
				trait.windupElapsed = 0
			end
		end
	end
end

BattleSkills.PotionThrow = {
	initialize = function(p, p2, p3)
		p2.traits[p3] = {
			cooldown = p.config.traits[p3].throwInterval or 0,
			isWindingUp = false,
			windupElapsed = 0,
			isFlying = false,
			flightElapsed = 0,
			pendingType = nil,
			flightStartPosition = nil,
			flightTargetPosition = nil,
			potions = {},
			nextPotionId = 1
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(p, p2, _, p3, p4, p5)
		local trait = p.config.traits[p5]
		local trait2 = p2.traits[p5]

		if not trait2 then
			return
		end

		updatePotionRegions(p, p2, trait2, trait, p3, p4, p5)
		updateBlueFrost(p, p2, trait2, trait, p3, p4, p5)
		updateThrowCycle(p, p2, trait2, trait, p3, p4, p5)
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function cactusNormalizeOrFallback(direction: Vector2, unit: Vector2)
	if direction.Magnitude > 0.0001 then
		return direction.Unit
	end

	return unit
end

local function cactusReflectIfApproaching(vector: Vector2, point: Vector2)
	local dot = vector:Dot(point)

	if dot >= 0 then
		return vector
	end

	return vector - point * (2 * dot)
end

local function cactusIgnoresTarget(object, p)
	if object:isRouteLocked(p) or (p.hookCapturedByBallId or p.harpoonCapturedByBallId) then
		return true
	end

	return object:_isVoltaicShockControlled(p)
end

local function updateCacti(object, p, trait, trait2, p2, list)
	local _getEffectCollisionRadius = object:_getEffectCollisionRadius(trait2.assetName)
	local hitCooldown = trait2.hitCooldown or 0.3
	local v15 = {}

	for k in object.state.balls do
		table.insert(v15, k)
	end

	for i = #trait.cacti, 1, -1 do
		local v16 = trait.cacti[i]
		v16.elapsed += p2

		for k, v17 in v16.hitCooldownByTarget do
			local v18 = v17 - p2
			local hitCooldownByTarget = v16.hitCooldownByTarget

			if not (v18 > 0) then
				v18 = nil
			end

			hitCooldownByTarget[k] = v18
		end

		if v16.elapsed >= (trait2.cactusDuration or 0) then
			table.remove(trait.cacti, i)
		else
			for _, v17 in v15 do
				local ball = object.state.balls[v17]

				if not (ball and ball.team ~= p.team) then
					continue
				end

				if ball.hp <= 0 or (object:isRouteLocked(ball) or ball.hookCapturedByBallId or ball.harpoonCapturedByBallId or object:_isVoltaicShockControlled(ball)) then
					continue
				end

				local v18 = ball.position - v16.position

				if v18.Magnitude > ball.radius + _getEffectCollisionRadius then
					continue
				end

				local unit = -ball.direction

				if v18.Magnitude > 0.0001 then
					unit = v18.Unit
				end

				local direction = ball.direction
				local dot = direction:Dot(unit)

				if not (dot >= 0) then
					direction -= unit * (2 * dot)
				end

				local direction2 = cactusNormalizeOrFallback(direction, unit) -- equivalent call inferred; original call site unknown
				ball.direction = direction2
				local gravityVelocity = ball.gravityVelocity
				local dot2 = gravityVelocity:Dot(unit)

				if not (dot2 >= 0) then
					gravityVelocity -= unit * (2 * dot2)
				end

				ball.gravityVelocity = gravityVelocity
				local explosionImpulseDirection = ball.explosionImpulseDirection
				local dot3 = explosionImpulseDirection:Dot(unit)

				if not (dot3 >= 0) then
					explosionImpulseDirection -= unit * (2 * dot3)
				end

				ball.explosionImpulseDirection = explosionImpulseDirection
				ball.position = v16.position + unit * (_getEffectCollisionRadius + ball.radius + 0.01)

				if v16.hitCooldownByTarget[ball.id] then
					continue
				end

				v16.hitCooldownByTarget[ball.id] = hitCooldown
				local _applyDamageModifiers = object:_applyDamageModifiers(
					p,
					ball,
					(math.round(trait2.touchDamage or 0))
				)

				if _applyDamageModifiers > 0 then
					ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
					object:_onDamageDealt(p, ball, _applyDamageModifiers, list)
				end

				table.insert(list, {
					type = "cactus_hit",
					ballId = ball.id,
					otherBallId = p.id,
					sourceBallId = p.id,
					targetBallId = ball.id,
					cactusId = v16.cactusId,
					damage = _applyDamageModifiers,
					position = v16.position + unit * _getEffectCollisionRadius
				})

				if _applyDamageModifiers > 0 and object.multiEntityMode then
					object:_resolveEntityDeath(ball, p, list)
				end
			end
		end
	end
end

local function pickCactusLandingTargets(object, data, cacti, _getEffectCollisionRadius: number)
	local v15 = object.config.arena.size * 0.5
	local v16 = math.max(0, v15.X - _getEffectCollisionRadius - (data.arenaEdgePadding or 0))
	local v17 = math.max(0, v15.Y - _getEffectCollisionRadius - (data.arenaEdgePadding or 0))
	local minCactusSpacing = data.minCactusSpacing or 0
	local vectors = {}

	local function farEnough(vector: Vector2)
		for _, item in cacti do
			if (vector - item.position).Magnitude < minCactusSpacing then
				return false
			end
		end

		for _, v18 in vectors do
			if (vector - v18).Magnitude < minCactusSpacing then
				return false
			end
		end

		return true
	end

	for _ = 1, math.max(0, (math.floor(data.cactusCount or 0))) do
		for _ = 1, 20 do
			local vector = Vector2.new(object.random:NextNumber(-v16, v16), object.random:NextNumber(-v17, v17))

			if not farEnough(vector) then
				continue
			end

			table.insert(vectors, vector)
			break
		end
	end

	return vectors
end

local function updateCactusThrowCycle(object, p, trait, trait2, p2)
	if trait.isFlying then
		trait.flightElapsed += p2

		if trait.flightElapsed >= (trait2.flightDuration or 0) then
			trait.isFlying = false

			for _, position in trait.pendingTargets or {} do
				table.insert(trait.cacti, {
					cactusId = trait.nextCactusId,
					position = position,
					elapsed = 0,
					hitCooldownByTarget = {}
				})
				trait.nextCactusId += 1
			end

			trait.pendingTargets = nil
		end
	else
		trait.cooldown -= p2

		if trait.cooldown > 0 then
			return
		end

		trait.cooldown += math.max(trait2.throwInterval or 1, 0.001)
		local v15 = math.max(0, (math.floor(trait2.cactusCount or 0)))

		if #trait.cacti + v15 > math.max(0, (math.floor(trait2.maxActiveCactusCount or 0))) then
			return
		end

		local _getEffectCollisionRadius = object:_getEffectCollisionRadius(trait2.assetName)
		local pendingTargets = pickCactusLandingTargets(object, trait2, trait.cacti, _getEffectCollisionRadius)

		if #pendingTargets > 0 then
			trait.pendingTargets = pendingTargets
			trait.isFlying = true
			trait.flightElapsed = 0
			trait.flightStartPosition = p.position
		end
	end
end

BattleSkills.CactusThrow = {
	initialize = function(p, p2, p3)
		p2.traits[p3] = {
			cooldown = p.config.traits[p3].throwInterval or 0,
			isFlying = false,
			flightElapsed = 0,
			flightStartPosition = nil,
			pendingTargets = nil,
			cacti = {},
			nextCactusId = 1
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(p, p2, _, p3, p4, p5)
		local trait = p.config.traits[p5]
		local trait2 = p2.traits[p5]

		if not trait2 then
			return
		end

		updateCacti(p, p2, trait2, trait, p3, p4)
		updateCactusThrowCycle(p, p2, trait2, trait, p3)
	end
}

local function trapReflectIfLeaving(vector: Vector2, point: Vector2)
	local dot = vector:Dot(point)

	if dot <= 0 then
		return vector
	end

	return vector - point * (2 * dot)
end

local function trapHoldsTargetElsewhere(object, trap, id)
	for _, ball in object.state.balls do
		local trapRelease = ball.traits and ball.traits.TrapRelease

		if not trapRelease then
			continue
		end

		for _, trap2 in trapRelease.traps do
			if trap2 ~= trap and trap2.trappedTargets[id] then
				return true
			end
		end
	end

	return false
end

local function updateTraps(object, p, trait, trait2, p2, list)
	local _getEffectCollisionRadius = object:_getEffectCollisionRadius(trait2.assetName)
	local bounceCooldown = trait2.bounceCooldown or 0.15
	local v16 = {}

	for k in object.state.balls do
		table.insert(v16, k)
	end

	for i = #trait.traps, 1, -1 do
		local trap = trait.traps[i]
		trap.elapsed += p2

		for k, v17 in trap.hitCooldownByTarget do
			local v18 = v17 - p2
			local hitCooldownByTarget = trap.hitCooldownByTarget

			if not (v18 > 0) then
				v18 = nil
			end

			hitCooldownByTarget[k] = v18
		end

		if trap.elapsed >= (trait2.trapDuration or 0) then
			table.remove(trait.traps, i)
		else
			local trappedTargets = {}
			local count = 0

			for _, v18 in v16 do
				local ball = object.state.balls[v18]

				if not (ball and ball.team ~= p.team) then
					continue
				end

				if ball.hp <= 0 or _getEffectCollisionRadius <= ball.radius or (object:isRouteLocked(ball) or ball.hookCapturedByBallId or ball.harpoonCapturedByBallId or object:_isVoltaicShockControlled(ball)) then
					continue
				end

				local v19 = ball.position - trap.position
				local magnitude = v19.Magnitude

				if not (trap.trappedTargets[ball.id] or not (_getEffectCollisionRadius < magnitude + ball.radius or trapHoldsTargetElsewhere(
					object,
					trap,
					ball.id
				))) then
					continue
				end

				trappedTargets[ball.id] = true
				count += 1

				if magnitude + ball.radius < _getEffectCollisionRadius then
					continue
				end

				local direction = ball.direction

				if v19.Magnitude > 0.0001 then
					direction = v19.Unit
				end

				local v20 = ball.direction:Dot(direction) > 0
				local direction2 = ball.direction
				local dot = direction2:Dot(direction)

				if not (dot <= 0) then
					direction2 -= direction * (2 * dot)
				end

				local unit = -direction

				if direction2.Magnitude > 0.0001 then
					unit = direction2.Unit
				end

				ball.direction = unit
				local gravityVelocity = ball.gravityVelocity
				local dot2 = gravityVelocity:Dot(direction)

				if not (dot2 <= 0) then
					gravityVelocity -= direction * (2 * dot2)
				end

				ball.gravityVelocity = gravityVelocity
				local explosionImpulseDirection = ball.explosionImpulseDirection
				local dot3 = explosionImpulseDirection:Dot(direction)

				if not (dot3 <= 0) then
					explosionImpulseDirection -= direction * (2 * dot3)
				end

				ball.explosionImpulseDirection = explosionImpulseDirection
				ball.position = trap.position + direction * (_getEffectCollisionRadius - ball.radius - 0.01)

				if not v20 or trap.hitCooldownByTarget[ball.id] then
					continue
				end

				trap.hitCooldownByTarget[ball.id] = bounceCooldown
				local _applyDamageModifiers = object:_applyDamageModifiers(
					p,
					ball,
					(math.round(trait2.bounceDamage or 0))
				)

				if _applyDamageModifiers > 0 then
					ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
					object:_onDamageDealt(p, ball, _applyDamageModifiers, list)
				end

				table.insert(list, {
					type = "trap_bounce",
					ballId = ball.id,
					otherBallId = p.id,
					sourceBallId = p.id,
					targetBallId = ball.id,
					trapId = trap.trapId,
					damage = _applyDamageModifiers,
					position = trap.position + direction * _getEffectCollisionRadius
				})

				if _applyDamageModifiers > 0 and object.multiEntityMode then
					object:_resolveEntityDeath(ball, p, list)
				end
			end

			trap.trappedTargets = trappedTargets
			trap.isActive = count > 0
		end
	end
end

local function pickTrapSpawnTargets(object, p, data, traps, _getEffectCollisionRadius: number)
	local v16 = object.config.arena.size * 0.5
	local v17 = math.max(0, v16.X - _getEffectCollisionRadius - (data.arenaEdgePadding or 0))
	local v18 = math.max(0, v16.Y - _getEffectCollisionRadius - (data.arenaEdgePadding or 0))
	local minTrapSpacing = data.minTrapSpacing or 0
	local spawnRadius = data.spawnRadius or 0
	local vectors = {}

	local function farEnough(vector: Vector2)
		for _, item in traps do
			if (vector - item.position).Magnitude < minTrapSpacing then
				return false
			end
		end

		for _, v19 in vectors do
			if (vector - v19).Magnitude < minTrapSpacing then
				return false
			end
		end

		return true
	end

	for _ = 1, math.max(0, (math.floor(data.trapCount or 0))) do
		for _ = 1, 20 do
			local number = object.random:NextNumber(0, 6.283185307179586)
			local v19 = spawnRadius * math.sqrt((object.random:NextNumber()))
			local v20 = p.position + Vector2.new(math.cos(number), (math.sin(number))) * v19
			local vector = Vector2.new(math.clamp(v20.X, -v17, v17), (math.clamp(v20.Y, -v18, v18)))

			if not farEnough(vector) then
				continue
			end

			table.insert(vectors, vector)
			break
		end
	end

	return vectors
end

local function updateTrapReleaseCycle(object, p, trait, trait2)
	if trait.cooldown > 0 then
		return
	end

	trait.cooldown += math.max(trait2.releaseInterval or 1, 0.001)
	local v16 = math.max(0, (math.floor(trait2.trapCount or 0)))

	if #trait.traps + v16 > math.max(0, (math.floor(trait2.maxActiveTrapCount or 0))) then
		return
	end

	local _getEffectCollisionRadius = object:_getEffectCollisionRadius(trait2.assetName)

	for _, position in pickTrapSpawnTargets(object, p, trait2, trait.traps, _getEffectCollisionRadius) do
		table.insert(trait.traps, {
			trapId = trait.nextTrapId,
			position = position,
			elapsed = 0,
			isActive = false,
			hitCooldownByTarget = {},
			trappedTargets = {}
		})
		trait.nextTrapId += 1
	end
end

BattleSkills.TrapRelease = {
	initialize = function(p, p2, p3)
		p2.traits[p3] = {
			cooldown = p.config.traits[p3].releaseInterval or 0,
			traps = {},
			nextTrapId = 1
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(p, p2, _, p3, p4, p5)
		local trait = p.config.traits[p5]
		local trait2 = p2.traits[p5]

		if not trait2 then
			return
		end

		updateTraps(p, p2, trait2, trait, p3, p4)
		trait2.cooldown -= p3
		updateTrapReleaseCycle(p, p2, trait2, trait)
	end
}
BattleSkills.SelfRepair = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			tickCooldown = trait.tickInterval or 0
		}
	end,
	updateFrame = function(object, state, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = state.traits[p2]

		if not trait2 then
			return
		end

		local tickInterval = trait.tickInterval or 0

		if tickInterval <= 0 then
			return
		end

		trait2.tickCooldown -= p

		while trait2.tickCooldown <= 0 do
			trait2.tickCooldown += tickInterval
			local heal = math.round((trait.healAmount or 0) * object:_healMultiplier(state))

			if not (heal > 0 and state.hp < state.maxHp) then
				continue
			end

			state.hp = math.min(state.maxHp, state.hp + heal)
			table.insert(list, {
				type = "self_repair_tick",
				ballId = state.id,
				position = state.position,
				heal = heal
			})
		end
	end
}
BattleSkills.Shield = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			remainingCharges = math.max(0, (math.floor(trait.charges or 0)))
		}
	end,
	modifyIncomingDamage = function(_, p, p2, p3)
		local trait = p.traits[p3]

		if trait and p2 > 0 and (trait.remainingCharges or 0) > 0 then
			trait.remainingCharges -= 1
			return 0
		else
			return p2
		end
	end
}
BattleSkills.AntiFreeze = {
	modifySlowDuration = function(p, _, p2, p3)
		return p2 * (1 - (p.config.traits[p3].slowDurationReduction or 0))
	end
}
local fireproof = {
	modifyPoisonDuration = function(p, _, p2, p3)
		return p2 * (1 - (p.config.traits[p3].poisonDurationReduction or 0))
	end
}

function fireproof.modifyBurnDuration(p, p2, p3, p4)
	return fireproof.modifyPoisonDuration(p, p2, p3, p4)
end

BattleSkills.Fireproof = fireproof
BattleSkills.GrievousWounds = {
	onDamageDealt = function(object, p, p2, _, _, p3)
		object:_applyHealReduction(p2, p3, p)
	end
}
BattleSkills.ThomasUpgrade = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			thomas = nil
		}
	end,
	onWallHit = function(object, p, p2, p3, p4)
		local trait = p.traits[p4]

		if trait and not trait.thomas then
			object:_spawnThomas(p, p2, p4, p3)
		end
	end
}
BattleSkills.GlassShards = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			shards = {},
			nextShardId = 1,
			wallCooldown = 0,
			collisionCooldown = 0,
			damageCooldown = 0
		}
	end,
	updateFrame = function(_, p, _, p2, _, p3)
		local trait = p.traits[p3]

		if not trait then
			return
		end

		trait.wallCooldown = math.max(0, trait.wallCooldown - p2)
		trait.collisionCooldown = math.max(0, trait.collisionCooldown - p2)
		trait.damageCooldown = math.max(0, trait.damageCooldown - p2)
	end,
	collisionDamage = function()
		return 0, false
	end,
	onWallHit = function(object, p, p2, p3, p4)
		local trait = p.traits[p4]
		local trait2 = object.config.traits[p4]

		if trait and trait.wallCooldown <= 0 and p2.position then
			if object.random:NextNumber(0, 1) < (trait2.dropChance or 1) then
				object:_createGlassShard(p, p4, p2.position, p2.axis, p3)
			end

			trait.wallCooldown = trait2.wallShardCooldown or 0
		end
	end,
	onEnemyCollision = function(object, p, _, p2, p3)
		local trait = p.traits[p3]
		local trait2 = object.config.traits[p3]

		if trait and trait.collisionCooldown <= 0 then
			if object.random:NextNumber(0, 1) < (trait2.dropChance or 1) then
				object:_createGlassShard(p, p3, nil, nil, p2)
			end

			trait.collisionCooldown = trait2.enemyCollisionShardCooldown or 0
		end
	end,
	onDamageTaken = function(object, p, _, p2, p3, p4)
		local trait = p.traits[p4]
		local trait2 = object.config.traits[p4]

		if trait and p2 > 0 and trait.damageCooldown <= 0 then
			if object.random:NextNumber(0, 1) < (trait2.dropChance or 1) then
				object:_createGlassShard(p, p4, nil, nil, p3)
			end

			trait.damageCooldown = trait2.damageShardCooldown or 0
		end
	end,
	weaponHits = function(object, p, state, list, p2)
		local trait = p.traits[p2]
		local trait2 = object.config.traits[p2]

		if not trait then
			return
		end

		local _getEffectCollisionRadius = object:_getEffectCollisionRadius(object.config.visual.glassShardTemplateName)

		for i = #trait.shards, 1, -1 do
			local shard = trait.shards[i]

			if not ((state.position - shard.position).Magnitude <= state.radius + _getEffectCollisionRadius) then
				continue
			end

			table.remove(trait.shards, i)
			local _applyDamageModifiers = object:_applyDamageModifiers(p, state, trait2.shardDamage or 0)

			if _applyDamageModifiers > 0 then
				state.hp = math.max(0, state.hp - _applyDamageModifiers)
				object:_onDamageDealt(p, state, _applyDamageModifiers, list)
			end

			table.insert(list, {
				type = "glass_shard_hit",
				ballId = state.id,
				otherBallId = p.id,
				sourceBallId = p.id,
				targetBallId = state.id,
				position = shard.position,
				damage = _applyDamageModifiers,
				shardId = shard.shardId
			})
			break
		end
	end
}
BattleSkills.OnHit = {
	collisionDamage = function(_, state)
		local attack = math.round(state.attack)
		local nextHitBonusReady = state.nextHitBonusReady

		if state.nextHitBonusReady then
			attack = math.round(attack * state.skill.multiplier)
		end

		state.nextHitBonusReady = true
		return attack, nextHitBonusReady
	end
}
BattleSkills.CollisionHeal = {
	onEnemyCollision = function(object, state, _, list, p)
		local heal = math.round((object.config.traits[p].healAmount or 0) * object:_healMultiplier(state))

		if heal > 0 and state.hp < state.maxHp then
			state.hp = math.min(state.maxHp, state.hp + heal)
			table.insert(list, {
				type = "self_repair_tick",
				ballId = state.id,
				position = state.position,
				heal = heal
			})
		end
	end
}

local function chessClosestPoint(point: Vector2, point2: Vector2, point3: Vector2)
	local vector = point3 - point2
	local dot = vector:Dot(vector)

	if dot <= 1e-6 then
		return point2
	end

	return point2 + vector * math.clamp((point - point2):Dot(vector) / dot, 0, 1)
end

local function buildChessRoutes(object, data, selectedPiece: string, edgePadding: number)
	local v18 = object.config.arena.size * 0.5
	local v19 = math.max(0, v18.X - data.radius - edgePadding)
	local v20 = math.max(0, v18.Y - data.radius - edgePadding)
	local zero = Vector2.zero
	local result = {}

	if selectedPiece == "Rook" then
		for _, v21 in {
			Vector2.new(v19, 0),
			Vector2.new(-v19, 0),
			Vector2.new(0, v20),
			Vector2.new(0, -v20)
		} do
			table.insert(result, { zero, v21, zero })
		end

		return result
	elseif selectedPiece == "Bishop" then
		for _, v21 in {
			Vector2.new(v19, v20),
			Vector2.new(-v19, v20),
			Vector2.new(-v19, -v20),
			Vector2.new(v19, -v20)
		} do
			table.insert(result, { zero, v21, zero })
		end

		return result
	else
		local v21 = math.min(v19, v20) / 2.4

		for _, v22 in {
			{ Vector2.new(v21, 0), Vector2.new(v21, v21 * 2) },
			{ Vector2.new(-v21 * 2, 0), Vector2.new(-v21 * 2, v21) },
			{ Vector2.new(-v21, 0), Vector2.new(-v21, -v21 * 2) },
			{ Vector2.new(v21 * 2, 0), Vector2.new(v21 * 2, -v21) }
		} do
			table.insert(result, {
				zero,
				v22[1],
				v22[2],
				v22[1],
				zero
			})
		end

		return result
	end
end

BattleSkills.ChessPath = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			cooldown = trait.interval or 5,
			phase = "idle",
			selectedPiece = nil,
			routeGroups = {},
			routeGroupIndex = 1,
			waypointIndex = 1,
			previousPosition = p2.position,
			targetHitCooldowns = {},
			isActive = false,
			phaseElapsed = 0
		}
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = data.traits[p2]
		local trait2 = object.config.traits[p2]

		if not trait then
			return
		end

		for k, targetHitCooldown in trait.targetHitCooldowns do
			local ball = object.state.balls[k]

			if ball and not (ball.hp <= 0) then
				trait.targetHitCooldowns[k] = math.max(0, targetHitCooldown - p)
			else
				trait.targetHitCooldowns[k] = nil
			end
		end

		if trait.isActive then
			return
		end

		trait.cooldown -= p

		if trait.cooldown > 0 or object:_isVoltaicShockControlled(data) or data.hookCapturedByBallId or data.vampireAttachedTargetId then
			return
		end

		trait.selectedPiece = ({ "Rook", "Bishop", "Knight" })[object.random:NextInteger(1, 3)]
		trait.routeGroups = buildChessRoutes(object, data, trait.selectedPiece, trait2.edgePadding or 0)
		trait.routeGroupIndex = 1
		trait.waypointIndex = 1
		trait.phase = "enter"
		trait.isActive = true
		trait.phaseElapsed = 0
		trait.previousPosition = data.position
		table.insert(list, {
			type = "chess_path_start",
			ballId = data.id,
			position = data.position,
			selectedPiece = trait.selectedPiece
		})
	end,
	modifyIncomingDamage = function(_, p, p2, p3)
		local trait = p.traits[p3]

		if trait and trait.isActive then
			return 0
		end

		return p2
	end,
	moveOverride = function(object, state, p, list, p2)
		local trait = state.traits[p2]
		local trait2 = object.config.traits[p2]

		if not (trait and trait.isActive) then
			return false
		end

		trait.phaseElapsed += p

		if trait.phase == "enter" then
			local v18 = Vector2.zero - state.position
			local magnitude = v18.Magnitude
			local v19 = (trait2.centerEntrySpeed or 0) * p
			trait.previousPosition = state.position

			if magnitude <= v19 + 1e-6 then
				state.position = Vector2.zero
				trait.phase = "preview"
				trait.phaseElapsed = 0
			else
				state.direction = v18.Unit
				state.position += state.direction * v19
			end

			return true
		elseif trait.phase == "preview" then
			if trait.phaseElapsed >= (trait2.previewDuration or 0) then
				trait.phase = "path"
				trait.phaseElapsed = 0
			end

			return true
		else
			local v18 = (trait2.pathSpeed or 0) * p

			while v18 > 1e-6 and trait.routeGroupIndex <= #trait.routeGroups do
				local position2 = trait.routeGroups[trait.routeGroupIndex][trait.waypointIndex + 1]

				if position2 then
					local v20 = position2 - state.position
					local magnitude = v20.Magnitude

					if magnitude <= 1e-6 then
						state.position = position2
						trait.waypointIndex += 1
					else
						local v21 = math.min(v18, magnitude)
						local position = state.position
						state.direction = v20.Unit
						state.position += state.direction * v21
						trait.previousPosition = position
						object:_resolveChessPathSegmentHit(state, position, state.position, trait, trait2, list)
						v18 -= v21

						if magnitude - 1e-6 <= v21 then
							trait.waypointIndex += 1
						end
					end
				else
					trait.routeGroupIndex += 1
					trait.waypointIndex = 1
					state.position = Vector2.zero
				end
			end

			if trait.routeGroupIndex > #trait.routeGroups then
				state.position = Vector2.zero
				local interval = trait2.interval or 5
				trait.phase = "idle"
				trait.isActive = false
				trait.cooldown = interval
				table.insert(list, {
					type = "chess_path_end",
					ballId = state.id,
					position = state.position,
					selectedPiece = trait.selectedPiece
				})
			end

			return true
		end
	end,
	collisionDamage = function(_, p)
		return math.round(p.attack), false
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function punchRollCooldown(p, p2)
	local cooldownMin = p2.cooldownMin or 0
	local cooldownMax = p2.cooldownMax or 0
	local v19 = math.max(0, (math.min(cooldownMin, cooldownMax)))
	local v20 = math.max(0, (math.max(cooldownMin, cooldownMax)))
	return v19 + p.random:NextNumber() * (v20 - v19)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function punchIsControlled(object, data)
	return object:_isVoltaicShockControlled(data) or data.hookCapturedByBallId ~= nil or data.harpoonCapturedByBallId ~= nil or data.vampireAttachedTargetId ~= nil or data.vampireVictimSourceId ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function punchDashTimeout(p, p2)
	return p.config.arena.size.Magnitude / math.max(p2.dashSpeed or 0, 0.001) * (p2.dashTimeoutScale or 1.5)
end

local function punchEndDash(p, state, p2, p3, list, reason: string)
	p2.phase = "Idle"
	p2.phaseElapsed = 0
	local zero = Vector2.zero
	p2.targetId = nil
	p2.dashDirection = zero
	p2.cooldown = punchRollCooldown(p, p3)
	table.insert(list, {
		type = "one_punch_dash_end",
		ballId = state.id,
		position = state.position,
		reason = reason
	})
end

local function punchResolveHit(object, state, state2, point: Vector2, trait, trait2, list)
	local v19 = math.max(0, trait2.missWeight or 0)
	local v20 = math.max(0, trait2.normalWeight or 0)
	local v21 = math.max(0, trait2.killWeight or 0)
	local v22 = v19 + v20 + v21
	local v23 = object.random:NextNumber() * v22
	local v24 = math.floor((math.min(trait2.normalDamageMin or 0, trait2.normalDamageMax or 0)))
	local v25 = math.floor((math.max(trait2.normalDamageMin or 0, trait2.normalDamageMax or 0)))
	local v26 = math.max(v24, 0)
	local v27 = math.max(v25, v26)
	local killDamage = object.random:NextInteger(v26, v27)
	local tier = not (v22 > 0 and v19 <= v23) and 1 or v23 < v19 + v20 and 2 or 3
	local dashDirection = trait.dashDirection
	local damage

	if tier >= 2 then
		if tier ~= 2 then
			killDamage = trait2.killDamage or 999
		end

		damage = object:_applyDamageModifiers(state, state2, killDamage)

		if damage > 0 then
			state2.hp = math.max(0, state2.hp - damage)
			object:_onDamageDealt(state, state2, damage, list)
		end

		if not object:isRouteLocked(state2) then
			local v31 = bombNormalizeOrFallback(state2.position - point, dashDirection) -- equivalent call inferred; original call site unknown
			local knockbackDuration = trait2.knockbackDuration or 0
			local v32 = math.clamp(trait2.knockbackMinRatio or 0, 0, 1)
			local v33 = math.clamp(killDamage / math.max(v27, 1), 0, 1)
			local v34 = v32 + (1 - v32) * v33
			state2.direction = v31
			state2.explosionImpulseDirection = v31
			state2.explosionImpulsePeakSpeed = (trait2.dashSpeed or 0) * (trait2.knockbackSpeedScale or 0) * v34
			state2.explosionImpulseDuration = knockbackDuration
			state2.explosionImpulseRemaining = knockbackDuration
			object:_refreshSnakeTail(state2)
		end
	else
		damage = 0
	end

	local position = state2.position
	local radius = state2.radius
	table.insert(list, {
		type = "one_punch_hit",
		ballId = state2.id,
		otherBallId = state.id,
		sourceBallId = state.id,
		targetBallId = state2.id,
		position = point,
		direction = dashDirection,
		tier = tier,
		damage = damage
	})

	if object.multiEntityMode then
		object:_resolveEntityDeath(state2, state, list)
	end

	state.position = position - dashDirection * (state.radius + radius + 0.01)
	state.direction = -dashDirection
	punchEndDash(object, state, trait, trait2, list, "hit")
end

BattleSkills.OnePunch = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		local traits = p2.traits
		traits[p3] = {
			phase = "Idle",
			phaseElapsed = 0,
			cooldown = punchRollCooldown(p, trait),
			targetId = nil,
			dashDirection = Vector2.zero,
			punchSerial = 0
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	modifyIncomingDamage = function(_, p, p2, p3)
		local trait = p.traits[p3]

		if trait and trait.phase == "Dash" then
			return 0
		end

		return p2
	end,
	updateFrame = function(object, state, _, p, list, p2)
		local trait = state.traits[p2]
		local trait2 = object.config.traits[p2]

		if not trait or trait.phase == "Dash" then
			return
		end

		if punchIsControlled(object, state) then
			if trait.phase == "Windup" then
				state.bonusSpeedMultiplier = 0
			end
		else
			if trait.phase == "Idle" then
				trait.cooldown -= p

				if trait.cooldown > 0 then
					return
				end

				local v19 = hiveNearestEnemy(object, state, state.position)

				if not v19 then
					trait.cooldown = 0
					return
				end

				local id = v19.id
				trait.phase = "Windup"
				trait.phaseElapsed = 0
				trait.targetId = id
				table.insert(list, {
					type = "one_punch_windup",
					ballId = state.id,
					position = state.position,
					targetBallId = v19.id
				})
			end

			if trait.phase == "Windup" then
				state.bonusSpeedMultiplier = 0
				trait.phaseElapsed += p

				if trait.phaseElapsed < (trait2.windupDuration or 0) then
					return
				end

				local ball = object.state.balls[trait.targetId]

				if not ball or ball.hp <= 0 then
					ball = hiveNearestEnemy(object, state, state.position)
				end

				if not ball then
					punchEndDash(object, state, trait, trait2, list, "noTarget")
					return
				end

				local v19 = ball.position - state.position
				trait.targetId = ball.id
				local dashDirection

				if v19.Magnitude > 1e-6 then
					dashDirection = v19.Unit
				else
					dashDirection = state.direction
				end

				trait.dashDirection = dashDirection
				trait.phase = "Dash"
				trait.phaseElapsed = 0
				trait.punchSerial += 1
				table.insert(list, {
					type = "one_punch_dash_start",
					ballId = state.id,
					position = state.position,
					targetBallId = ball.id
				})
			end
		end
	end,
	moveOverride = function(p, state, p2, p3, p4)
		local trait = state.traits[p4]
		local trait2 = p.config.traits[p4]

		if not trait or trait.phase ~= "Dash" then
			return false
		end

		trait.phaseElapsed += p2

		if trait.phaseElapsed > punchDashTimeout(p, trait2) then
			punchEndDash(p, state, trait, trait2, p3, "timeout")
			return true
		end

		local ball = p.state.balls[trait.targetId]

		if not ball or ball.hp <= 0 then
			ball = hiveNearestEnemy(p, state, state.position)

			if ball then
				trait.targetId = ball.id
			else
				punchEndDash(p, state, trait, trait2, p3, "noTarget")
				return true
			end
		end

		local v19 = ball.position - state.position

		if v19.Magnitude > 1e-6 then
			trait.dashDirection = v19.Unit
		end

		local position = state.position
		state.position += trait.dashDirection * (trait2.dashSpeed or 0) * p2
		state.direction = trait.dashDirection
		local vector = state.position - position
		local dot = vector:Dot(vector)
		local v20 = 1e999
		local v21 = nil
		local position2 = nil

		for _, ball2 in p.state.balls do
			if not (ball2.team ~= state.team and ball2.hp > 0) then
				continue
			end

			local v23 = dot <= 1e-6 and 0 or math.clamp((ball2.position - position):Dot(vector) / dot, 0, 1)
			local v24 = position + vector * v23

			if not ((ball2.position - v24).Magnitude <= state.radius + ball2.radius and v23 < v20) then
				continue
			end

			position2 = v24
			v21 = ball2
			v20 = v23
		end

		if not v21 then
			return true
		end

		state.position = position2
		local v23 = v21.position - position2
		local dashDirection = trait.dashDirection

		if not (v23.Magnitude < 0.001) then
			dashDirection = v23.Unit
		end

		punchResolveHit(p, state, v21, position2 + dashDirection * state.radius, trait, trait2, p3)
		return true
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function trainHeadTemplateName(p)
	local assetName = p.assetName

	if type(assetName) == "string" and assetName ~= "" then
		return assetName
	end

	return "火车头"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function appendTrackPoint(p, point: Vector2)
	local count = #p.trackPoints

	if count == 0 then
		p.trackPoints[1] = point
		p.cumulativeLengths[1] = 0
	else
		local trackPoint = p.trackPoints[count]
		p.trackPoints[count + 1] = point
		p.cumulativeLengths[count + 1] = p.cumulativeLengths[count] + (point - trackPoint).Magnitude
	end
end

local function sampleTrack(p, p2: number)
	return TrainTrackGeometry.sample(p.trackPoints, p.cumulativeLengths, p2)
end

local function replaceTrack(trait, items)
	trait.trackPoints = {}
	trait.cumulativeLengths = {}

	for _, item in items do
		appendTrackPoint(trait, item) -- equivalent call inferred; original call site unknown
	end
end

local function trainCarSizes(object, p)
	local v20 = trainHeadTemplateName(p) -- equivalent call inferred; original call site unknown
	return
		object:_getEffectCollisionLength(v20),
		object:_getEffectCollisionThickness(v20),
		object:_getEffectCollisionLength("火车身"),
		object:_getEffectCollisionThickness("火车身")
end

local function refreshCars(trait, trait2, _getEffectCollisionLength: number, _getEffectCollisionLength2: number)
	local v20 = trait.cumulativeLengths[#trait.cumulativeLengths] or 0
	local carSpacing = trait2.carSpacing or 0
	local total = 0

	for k, car in trait.cars do
		if k > 1 then
			local v21

			if k == 2 then
				v21 = _getEffectCollisionLength
			else
				v21 = _getEffectCollisionLength2
			end

			total += v21 * 0.5 + carSpacing + _getEffectCollisionLength2 * 0.5
		end

		local mileage = trait.trainHeadDistance - total
		car.mileage = mileage
		local sample, direction = TrainTrackGeometry.sample(trait.trackPoints, trait.cumulativeLengths, mileage)
		car.position = sample
		car.direction = direction
		car.isVisible = mileage >= 0 and mileage <= v20
	end
end

local function carHitsTarget(car, p: number, p2: number, ball)
	local vector = ball.position - car.position
	local direction = car.direction
	local vector2 = Vector2.new(-direction.Y, direction.X)
	local v20 = math.clamp(vector:Dot(direction), -p * 0.5, p * 0.5)
	local v21 = math.clamp(vector:Dot(vector2), -p2 * 0.5, p2 * 0.5)
	local v22 = car.position + direction * v20 + vector2 * v21
	return (ball.position - v22).Magnitude <= ball.radius
end

BattleSkills.TrainTrack = {
	initialize = function(p, p2, p3)
		local _ = p.config.traits[p3]
		p2.traits[p3] = {
			phase = "idle",
			cooldown = 0,
			trackPoints = {},
			cumulativeLengths = {},
			nodeIndices = {},
			lastNodePosition = nil,
			waitRemaining = 0,
			trainHeadDistance = 0,
			cars = {},
			targetHitCooldowns = {}
		}
	end,
	onWallHit = function(p, data, p2, list, p3)
		if not p2.position then
			return
		end

		local trait = p.config.traits[p3]
		local trait2 = data.traits[p3]

		if not trait2 or trait2.phase ~= "idle" and trait2.phase ~= "laying" or trait2.phase == "idle" and trait2.cooldown > 0 then
			return
		end

		if trait2.phase == "idle" then
			trait2.trackPoints = {}
			trait2.cumulativeLengths = {}
			trait2.nodeIndices = {}
			appendTrackPoint(trait2, p2.position) -- equivalent call inferred; original call site unknown
			trait2.nodeIndices[1] = 1
			trait2.phase = "laying"
			trait2.lastNodePosition = p2.position
			table.insert(list, {
				type = "train_track_start",
				ballId = data.id,
				position = p2.position
			})
		else
			local trackPoint = trait2.trackPoints[#trait2.trackPoints]

			if #trait2.trackPoints < math.max(1, trait.maxTrackPointCount or 1) and (not trackPoint or (data.position - trackPoint).Magnitude > 0.0001) then
				appendTrackPoint(trait2, data.position) -- equivalent call inferred; original call site unknown
			end

			if trait2.lastNodePosition and (p2.position - trait2.lastNodePosition).Magnitude < (trait.minNodeSpacing or 0) then
				return
			end

			trait2.nodeIndices[#trait2.nodeIndices + 1] = #trait2.trackPoints
			trait2.lastNodePosition = p2.position
			table.insert(list, {
				type = "train_track_node",
				ballId = data.id,
				position = data.position,
				nodeIndex = #trait2.nodeIndices
			})
		end

		if #trait2.nodeIndices >= math.max(1, (math.round(trait.nodeCount or 1))) then
			local position = p2.position

			if #trait2.trackPoints < math.max(1, trait.maxTrackPointCount or 1) and (position - trait2.trackPoints[#trait2.trackPoints]).Magnitude > 0.0001 then
				appendTrackPoint(trait2, position) -- equivalent call inferred; original call site unknown
			end

			local clone = table.clone(trait2.trackPoints)
			local v20 = table.remove(clone)
			local downsampleCorners = TrainTrackGeometry.downsampleCorners(clone, trait.railAngleThresholdDeg or 5)
			table.insert(downsampleCorners, v20)
			replaceTrack(
				trait2,
				TrainTrackGeometry.roundCorners(
					downsampleCorners,
					trait.railCornerRadius or 0,
					(math.max(1, (math.round(trait.railCornerSegments or 1))))
				)
			)
			trait2.phase = "waiting"
			trait2.waitRemaining = trait.trainSpawnDelay or 0
			table.insert(list, {
				type = "train_track_ready",
				ballId = data.id,
				position = data.position
			})
		end
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		if trait2.phase == "idle" then
			trait2.cooldown -= p
		elseif trait2.phase == "laying" then
			local trackPoint = trait2.trackPoints[#trait2.trackPoints]

			if trackPoint and (data.position - trackPoint).Magnitude >= (trait.trackSampleSpacing or 0.5) and #trait2.trackPoints < math.max(
				1,
				trait.maxTrackPointCount or 1
			) then
				appendTrackPoint(trait2, data.position) -- equivalent call inferred; original call site unknown
			end
		else
			local v20 = trainHeadTemplateName(trait) -- equivalent call inferred; original call site unknown
			local _getEffectCollisionLength = object:_getEffectCollisionLength(v20)
			local _getEffectCollisionThickness = object:_getEffectCollisionThickness(v20)
			local _getEffectCollisionLength2 = object:_getEffectCollisionLength("火车身")
			local _getEffectCollisionThickness2 = object:_getEffectCollisionThickness("火车身")

			if trait2.phase == "waiting" then
				trait2.waitRemaining -= p

				if trait2.waitRemaining > 0 then
					return
				end

				trait2.waitRemaining = 0
				trait2.phase = "running"
				trait2.trainHeadDistance = 0
				trait2.targetHitCooldowns = {}
				trait2.cars = {}

				for i = 1, math.max(0, (math.round(trait.bodyCarCount or 0))) + 1 do
					trait2.cars[i] = {
						carIndex = i,
						isHead = i == 1,
						position = Vector2.zero,
						direction = Vector2.new(1, 0),
						mileage = 0,
						isVisible = false
					}
				end

				refreshCars(trait2, trait, _getEffectCollisionLength, _getEffectCollisionLength2)
				table.insert(list, {
					type = "train_spawn",
					ballId = data.id,
					position = trait2.cars[1].position
				})
			else
				trait2.trainHeadDistance += (trait.trainSpeed or 0) * p
				refreshCars(trait2, trait, _getEffectCollisionLength, _getEffectCollisionLength2)

				for _, targetHitCooldown in trait2.targetHitCooldowns do
					for k, v21 in targetHitCooldown do
						local ball = object.state.balls[k]

						if ball and not (ball.hp <= 0) then
							targetHitCooldown[k] = math.max(0, v21 - p)
						else
							targetHitCooldown[k] = nil
						end
					end
				end

				for _, car in trait2.cars do
					if not car.isVisible then
						continue
					end

					local v21

					if car.isHead then
						v21 = _getEffectCollisionLength
					else
						v21 = _getEffectCollisionLength2
					end

					local v22

					if car.isHead then
						v22 = _getEffectCollisionThickness
					else
						v22 = _getEffectCollisionThickness2
					end

					local targetHitCooldownsById = trait2.targetHitCooldowns[car.carIndex] or {}
					trait2.targetHitCooldowns[car.carIndex] = targetHitCooldownsById

					for _, ball in object.state.balls do
						if not (ball.team ~= data.team and ball.hp > 0 and (targetHitCooldownsById[ball.id] or 0) <= 0 and carHitsTarget(
							car,
							v21,
							v22,
							ball
						)) then
							continue
						end

						local _applyDamageModifiers = object:_applyDamageModifiers(
							data,
							ball,
							(math.round(trait.trainDamage or 0))
						)

						if _applyDamageModifiers > 0 then
							ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
							object:_onDamageDealt(data, ball, _applyDamageModifiers, list)
						end

						targetHitCooldownsById[ball.id] = trait.targetHitCooldown or 0
						object:_pushBallAwayFromEffect(ball, car.position, math.max(v21, v22) * 0.5, car.direction)
						object:_applyKnockback(data, ball, trait.trainSpeed)
						object:_refreshSnakeTail(ball)
						table.insert(list, {
							type = "train_hit",
							ballId = ball.id,
							otherBallId = data.id,
							sourceBallId = data.id,
							targetBallId = ball.id,
							position = car.position,
							damage = _applyDamageModifiers,
							carIndex = car.carIndex
						})

						if object.multiEntityMode then
							object:_resolveEntityDeath(ball, data, list)
						end
					end
				end

				local v21 = trait2.cumulativeLengths[#trait2.cumulativeLengths] or 0
				local car = trait2.cars[#trait2.cars]

				if #trait2.cars <= 1 then
					_getEffectCollisionLength2 = _getEffectCollisionLength
				end

				if not car or v21 < car.mileage - _getEffectCollisionLength2 * 0.5 then
					trait2.phase = "idle"
					trait2.cooldown = trait.interval or 0
					trait2.trainHeadDistance = 0
					trait2.lastNodePosition = nil
					trait2.trackPoints = {}
					trait2.cumulativeLengths = {}
					trait2.nodeIndices = {}
					trait2.cars = {}
					trait2.targetHitCooldowns = {}
					table.insert(list, {
						type = "train_despawn",
						ballId = data.id,
						position = data.position
					})
				end
			end
		end
	end
}

local function buildWdcCellWeightTable(minCellValue: number, maxCellValue: number, weightDecayExponent: number)
	local total = 0
	local result = {}

	for i = minCellValue, maxCellValue do
		total += i ^ (-weightDecayExponent)
		result[i - minCellValue + 1] = total
	end

	return result, total
end

local function drawWdcWeightedCellValue(p, list, p2, p3: number)
	local v21 = p.random:NextNumber() * p2

	for k, v22 in list do
		if v21 <= v22 then
			return p3 + k - 1
		end
	end

	return p3 + #list - 1
end

local function resolveWdcCellIndex(p, data)
	local v21 = p.config.arena.size * 0.5
	local v22 = math.clamp(math.floor((-data.position.X + v21.X) / (p.config.arena.size.X / 3)), 0, 2)
	return math.clamp(math.floor((-data.position.Y + v21.Y) / (p.config.arena.size.Y / 3)), 0, 2) * 3 + v22 + 1
end

BattleSkills.WDC = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			phase = "idle",
			phaseElapsed = 0,
			cooldown = trait.interval or 5,
			cells = nil,
			currentCellIndex = nil
		}
	end,
	updateFrame = function(p, data, _, p2, list, p3)
		local trait = data.traits[p3]
		local trait2 = p.config.traits[p3]

		if not trait then
			return
		end

		if trait.phase == "idle" then
			trait.cooldown -= p2

			if trait.cooldown <= 0 then
				local wdcCellWeightTable, v21 = buildWdcCellWeightTable(
					trait2.minCellValue or 1,
					trait2.maxCellValue or 100,
					trait2.weightDecayExponent or 1
				)
				trait.cells = {}

				for i = 1, 9 do
					local cells = trait.cells
					local minCellValue = trait2.minCellValue or 1
					local v22 = p.random:NextNumber() * v21
					local v23 = {
						value = 0
					}
					local flag = true
					local v24

					for k, v25 in wdcCellWeightTable do
						if not (v22 <= v25) then
							continue
						end

						v24 = minCellValue + k - 1
						flag = false
						break
					end

					if flag then
						v24 = minCellValue + #wdcCellWeightTable - 1
					end

					v23.value = v24
					cells[i] = v23
				end

				trait.phase = "active"
				trait.phaseElapsed = 0
				table.insert(list, {
					type = "wdc_active_start",
					ballId = data.id,
					position = data.position
				})
			end
		else
			trait.phaseElapsed += p2
			trait.currentCellIndex = resolveWdcCellIndex(p, data)

			if trait.phaseElapsed >= (trait2.duration or 0) then
				trait.phase = "idle"
				trait.phaseElapsed = 0
				trait.cooldown = trait2.interval or 5
				trait.cells = nil
				trait.currentCellIndex = nil
				table.insert(list, {
					type = "wdc_active_end",
					ballId = data.id,
					position = data.position
				})
			end
		end
	end,
	collisionDamage = function(_, p, p2)
		local trait = p.traits[p2]

		if trait and trait.phase == "active" and trait.currentCellIndex and trait.cells then
			return trait.cells[trait.currentCellIndex].value, true
		end

		return math.round(p.attack), false
	end,
	onCollisionResolved = function(_, data, _, list, p)
		local trait = data.traits[p]

		if trait and trait.phase == "active" and trait.currentCellIndex then
			table.insert(list, {
				type = "wdc_cell_hit",
				ballId = data.id,
				position = data.position,
				cellIndex = trait.currentCellIndex,
				value = trait.cells[trait.currentCellIndex].value
			})
		end
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function dogCannonTurnPeriod(trait)
	local beamTurnPeriod = trait.beamTurnPeriod

	if type(beamTurnPeriod) == "number" and beamTurnPeriod > 0 then
		return beamTurnPeriod
	end

	return 8
end

local function rotateTowards2(aimDirection: Vector2, unit: Vector2, p: number)
	local v22 = math.atan2(aimDirection.X * unit.Y - aimDirection.Y * unit.X, (aimDirection:Dot(unit)))

	if math.abs(v22) <= p then
		return unit
	end

	return (thiefRotate(aimDirection, math.sign(v22) * p)).Unit
end

local function dogCannonNearestEnemy(p, p2)
	local v22 = 1e999
	local v23 = nil

	for _, ball in p.state.balls do
		if ball.team == p2.team then
			continue
		end

		local magnitude = (ball.position - p2.position).Magnitude

		if not (magnitude < v22) then
			continue
		end

		v23 = ball
		v22 = magnitude
	end

	return v23
end

local function dogCannonResolveAimDirection(p, p2, p3)
	local v22 = dogCannonNearestEnemy(p, p2)

	if v22 then
		local v23 = v22.position - p2.position

		if v23.Magnitude > 1e-6 then
			return v23.Unit
		end
	end

	return p3.aimDirection or p2.direction
end

BattleSkills.DogCannon = {
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		local beamTurnPeriod = trait.beamTurnPeriod

		if type(beamTurnPeriod) ~= "number" or not (beamTurnPeriod > 0) then
			warn(string.format("[DogCannon] 光束转一圈秒数配置非法(%s)，回退默认 %d", tostring(beamTurnPeriod), 8))
		end

		p2.traits[p3] = {
			phase = "Charging",
			chargeElapsed = 0,
			particleCooldown = trait.particleIntervalStart or 0.6,
			beamElapsed = 0,
			aimDirection = p2.direction,
			hitTickCooldownByTarget = {}
		}
	end,
	collisionDamage = function(_, _)
		return 0, false
	end,
	updateFrame = function(object, data, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = data.traits[p2]

		if not trait2 then
			return
		end

		if trait2.phase == "Charging" then
			local v22 = dogCannonNearestEnemy(object, data)
			local unit

			if v22 then
				local v23 = v22.position - data.position

				if v23.Magnitude > 1e-6 then
					unit = v23.Unit
				else
					unit = trait2.aimDirection or data.direction
				end
			else
				unit = trait2.aimDirection or data.direction
			end

			trait2.aimDirection = unit
			trait2.chargeElapsed = math.min(trait.chargeDuration or 0, trait2.chargeElapsed + p)
			trait2.particleCooldown -= p

			if trait2.particleCooldown <= 0 then
				local v23 = math.clamp(trait2.chargeElapsed / math.max(trait.chargeDuration or 1e-6, 1e-6), 0, 1)
				local v24 = (trait.particleIntervalStart or 0.6) + ((trait.particleIntervalEnd or 0.12) - (trait.particleIntervalStart or 0.6)) * v23
				trait2.particleCooldown += math.max(v24, 1e-6)
				table.insert(list, {
					type = "dog_cannon_charge_pulse",
					ballId = data.id,
					position = data.position
				})
			end

			if not (trait2.chargeElapsed >= (trait.chargeDuration or 0)) then
				return
			end

			trait2.phase = "Beam"
			trait2.beamElapsed = 0
			trait2.hitTickCooldownByTarget = {}
			table.insert(list, {
				type = "dog_cannon_beam_start",
				ballId = data.id,
				position = data.position
			})
		end

		if trait2.beamElapsed > 0 then
			local v22 = dogCannonNearestEnemy(object, data)
			local unit

			if v22 then
				local v23 = v22.position - data.position

				if v23.Magnitude > 1e-6 then
					unit = v23.Unit
				else
					unit = trait2.aimDirection or data.direction
				end
			else
				unit = trait2.aimDirection or data.direction
			end

			local v23 = 6.283185307179586 / dogCannonTurnPeriod(trait) * p
			trait2.aimDirection = rotateTowards2(trait2.aimDirection, unit, v23)
		end

		local dogCannonTemplateName = object.config.visual.dogCannonTemplateName
		local _getEffectCollisionThickness = object:_getEffectCollisionThickness(dogCannonTemplateName)
		local _getEffectCollisionLength = object:_getEffectCollisionLength(dogCannonTemplateName)
		local beamStart = data.position + trait2.aimDirection * data.radius
		local beamEnd = beamStart + trait2.aimDirection * _getEffectCollisionLength
		trait2.beamStart = beamStart
		trait2.beamEnd = beamEnd

		for _, ball in object.state.balls do
			if ball.team == data.team then
				continue
			end

			local position = ball.position
			local vector = beamEnd - beamStart
			local dot = vector:Dot(vector)
			local position2

			if dot <= 1e-6 then
				position2 = beamStart
			else
				position2 = beamStart + vector * math.clamp((position - beamStart):Dot(vector) / dot, 0, 1)
			end

			local v25 = (ball.position - position2).Magnitude <= ball.radius + _getEffectCollisionThickness * 0.5
			local v26 = (trait2.hitTickCooldownByTarget[ball.id] or 0) - p

			if v25 then
				if v26 <= 0 then
					local _applyDamageModifiers = object:_applyDamageModifiers(
						data,
						ball,
						(math.round(trait.beamDamagePerTick or 0))
					)

					if _applyDamageModifiers > 0 then
						ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
						object:_onDamageDealt(data, ball, _applyDamageModifiers, list)

						if object.multiEntityMode then
							object:_resolveEntityDeath(ball, data, list)
						end
					end

					v26 += math.max(trait.beamTickInterval or 0, 1e-6)
					table.insert(list, {
						type = "dog_cannon_beam_tick",
						ballId = ball.id,
						otherBallId = data.id,
						sourceBallId = data.id,
						targetBallId = ball.id,
						position = position2,
						damage = _applyDamageModifiers
					})
				end

				trait2.hitTickCooldownByTarget[ball.id] = v26
			else
				trait2.hitTickCooldownByTarget[ball.id] = nil
			end
		end

		trait2.beamElapsed += p

		if trait2.beamElapsed >= (trait.beamDuration or 0) then
			trait2.phase = "Charging"
			trait2.chargeElapsed = 0
			trait2.particleCooldown = trait.particleIntervalStart or 0.6
			table.insert(list, {
				type = "dog_cannon_beam_end",
				ballId = data.id,
				position = data.position
			})
		end
	end
}

local function spearFindNearestEnemy(object, state)
	local v23 = 1e999
	local v24 = nil

	for _, ball in object.state.balls do
		if not (ball.team ~= state.team and ball.hp > 0) then
			continue
		end

		local vector = ball.position - state.position
		local dot = vector:Dot(vector)

		if not (dot < v23) then
			continue
		end

		v24 = ball
		v23 = dot
	end

	return v24
end

BattleSkills.SpearThrust = {
	initialize = function(_, p, p2)
		p.traits[p2] = {
			speedBonus = 0,
			poseProgress = 0,
			isThrusting = false,
			targetHitCooldowns = {}
		}
	end,
	collisionDamage = function(_, _, _)
		return 0, false
	end,
	updateFrame = function(object, state, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = state.traits[p2]

		if not trait2 then
			return
		end

		local baseSpeed = state.baseSpeed
		trait2.speedBonus = math.min(
			math.max(0, (trait.maxSpeed or baseSpeed) - baseSpeed),
			trait2.speedBonus + (trait.speedGrowthPerSecond or 0) * p
		)

		if baseSpeed > 0.0001 then
			state.bonusSpeedMultiplier *= (baseSpeed + trait2.speedBonus) / baseSpeed
		end

		local unit

		if state.direction.Magnitude > 0.0001 then
			unit = state.direction.Unit
		end

		local v23 = "Sheathed"
		local v24 = spearFindNearestEnemy(object, state)

		if v24 and unit then
			local v25 = v24.position - state.position
			v23 = v25.Magnitude > 0.0001 and v25.Unit:Dot(unit) > (trait.readyDotThreshold or 0.5) and "Ready" or v23
		end

		local v25 = p / math.max(trait.poseTransitionDuration or 0, 0.01)
		trait2.isThrusting = v23 == "Ready"

		if trait2.isThrusting then
			trait2.poseProgress = math.min(1, trait2.poseProgress + v25)
		else
			trait2.poseProgress = math.max(0, trait2.poseProgress - v25)
		end

		for k, targetHitCooldown in trait2.targetHitCooldowns do
			local v26 = targetHitCooldown - p
			local targetHitCooldowns = trait2.targetHitCooldowns

			if not (v26 > 0) then
				v26 = nil
			end

			targetHitCooldowns[k] = v26
		end

		if not (trait2.isThrusting and unit) then
			return
		end

		local _getEffectCollisionLength = object:_getEffectCollisionLength(trait.assetName)
		local _getEffectCollisionThickness = object:_getEffectCollisionThickness(trait.assetName)
		local v26 = _getEffectCollisionThickness * 0.5
		local segment, v27 = SpearThrustGeometry.resolveSegment(
			state.position,
			unit,
			state.radius,
			_getEffectCollisionLength,
			_getEffectCollisionThickness,
			trait2.poseProgress
		)
		local v28 = {}

		for k in object.state.balls do
			table.insert(v28, k)
		end

		for _, v29 in v28 do
			local ball = object.state.balls[v29]

			if not ball or ball.team == state.team or (ball.hp <= 0 or trait2.targetHitCooldowns[ball.id]) then
				continue
			end

			local position = ball.position
			local vector = v27 - segment
			local dot = vector:Dot(vector)
			local position2

			if dot <= 1e-6 then
				position2 = segment
			else
				position2 = segment + vector * math.clamp((position - segment):Dot(vector) / dot, 0, 1)
			end

			if (ball.position - position2).Magnitude > ball.radius + v26 then
				continue
			end

			trait2.targetHitCooldowns[ball.id] = trait.spearHitCooldown or 0.3
			local _applyDamageModifiers = object:_applyDamageModifiers(
				state,
				ball,
				(math.round(trait.spearBaseDamage or 0))
			)

			if _applyDamageModifiers > 0 then
				ball.hp = math.max(0, ball.hp - _applyDamageModifiers)
				object:_onDamageDealt(state, ball, _applyDamageModifiers, list)
			end

			object:_pushBallAwayFromEffect(ball, position2, v26, unit)
			object:_applyKnockback(state, ball, state.currentSpeed)
			object:_refreshSnakeTail(ball)
			table.insert(list, {
				type = "spear_thrust_hit",
				ballId = ball.id,
				otherBallId = state.id,
				sourceBallId = state.id,
				targetBallId = ball.id,
				position = position2,
				damage = _applyDamageModifiers
			})

			if _applyDamageModifiers > 0 and object.multiEntityMode then
				object:_resolveEntityDeath(ball, state, list)
			end
		end
	end
}

local function fibonacciClosedForm(p: number)
	return (math.round((1.618033988749895 ^ p - (-0.6180339887498949) ^ p) / 2.23606797749979))
end

BattleSkills.Fibonacci = {
	closedForm = fibonacciClosedForm,
	initialize = function(_, p, p2)
		p.traits[p2] = {
			hitIndex = 0,
			impactPending = false
		}
	end,
	collisionDamage = function(p, p2, p3)
		local trait = p2.traits[p3]
		local maxHitIndex = p.config.traits[p3].maxHitIndex or 15
		trait.hitIndex = math.min((trait.hitIndex or 0) + 1, maxHitIndex)
		trait.impactPending = true
		local v23 = trait.hitIndex + 1
		return math.round((1.618033988749895 ^ v23 - (-0.6180339887498949) ^ v23) / 2.23606797749979), false
	end,
	onDamageDealt = function(_, data, data2, p, list, p2)
		local trait = data.traits[p2]

		if not trait or not trait.impactPending or p <= 0 then
			return
		end

		trait.impactPending = false
		local v23 = data2.position - data.position
		local v24 = (data.radius or 0) + (data2.radius or 0)
		local position = data.position

		if v23.Magnitude > 1e-6 and v24 > 0 then
			position = data.position + v23 * ((data.radius or 0) / v24)
		end

		table.insert(list, {
			type = "fibonacci_impact",
			ballId = data.id,
			targetBallId = data2.id,
			position = position,
			hitIndex = trait.hitIndex
		})
	end,
	onCollisionResolved = function(_, p, _, _, p2)
		local trait = p.traits[p2]

		if trait then
			trait.impactPending = false
		end
	end
}

local function volcanoDistanceToArenaEdge(point: Vector2, direction: Vector2, p: number, p2: number)
	local v24 = 1e999

	if direction.X > 1e-6 then
		v24 = math.min(v24, (p - point.X) / direction.X)
	elseif direction.X < -1e-6 then
		v24 = math.min(v24, (-p - point.X) / direction.X)
	end

	if direction.Y > 1e-6 then
		v24 = math.min(v24, (p2 - point.Y) / direction.Y)
	elseif direction.Y < -1e-6 then
		v24 = math.min(v24, (-p2 - point.Y) / direction.Y)
	end

	if v24 == 1e999 then
		return 0
	end

	return (math.max(0, v24))
end

local function volcanoRotate(point: Vector2, p: number)
	local v24 = math.cos(p)
	local v25 = math.sin(p)
	return Vector2.new(point.X * v24 - point.Y * v25, point.X * v25 + point.Y * v24)
end

local function volcanoRefreshFlameExtents(object, state, trait)
	local v24 = object.config.arena.size.X * 0.5
	local v25 = object.config.arena.size.Y * 0.5

	for _, flame in trait.flames do
		flame.maxLength = volcanoDistanceToArenaEdge(
			state.position + flame.direction * state.radius,
			flame.direction,
			v24,
			v25
		)
		flame.length = math.min(flame.length, flame.maxLength)
	end
end

local function volcanoNearestEnemy(p, p2)
	local v24 = 1e999
	local v25 = nil

	for _, ball in p.state.balls do
		if not (ball.team ~= p2.team and ball.hp > 0) then
			continue
		end

		local magnitude = (ball.position - p2.position).Magnitude

		if not (magnitude < v24) then
			continue
		end

		v25 = ball
		v24 = magnitude
	end

	return v25
end

local function volcanoBeginWindup(object, state, trait, trait2, list)
	local v24 = volcanoNearestEnemy(object, state)
	local aimDirection = trait.aimDirection

	if v24 then
		local v25 = v24.position - state.position

		if v25.Magnitude > 1e-6 then
			aimDirection = v25.Unit
		end
	end

	trait.aimDirection = aimDirection
	local v25 = math.max(1, (math.floor(trait2.flameCountMin or 3)))
	local v26 = math.max(v25, (math.floor(trait2.flameCountMax or 6)))
	local integer = object.random:NextInteger(v25, v26)
	local fanAngleDegrees = math.rad(trait2.fanAngleDegrees or 180)
	trait.flames = {}

	for i = 1, integer do
		local angleOffset = -fanAngleDegrees / 2 + (i - 0.5) * fanAngleDegrees / integer
		local flames = trait.flames
		local v28 = {
			flameId = trait.nextFlameId,
			angleOffset = angleOffset,
			direction = 0,
			length = 0,
			maxLength = 0
		}
		local v29 = math.cos(angleOffset)
		local v30 = math.sin(angleOffset)
		v28.direction = Vector2.new(
			aimDirection.X * v29 - aimDirection.Y * v30,
			aimDirection.X * v30 + aimDirection.Y * v29
		)
		table.insert(flames, v28)
		trait.nextFlameId += 1
	end

	trait.phase = "Windup"
	trait.phaseRemaining = trait2.windupDuration or 0.8
	table.insert(list, {
		type = "volcano_windup_start",
		ballId = state.id,
		position = state.position,
		flameCount = integer
	})
end

BattleSkills.VolcanoEruption = {
	collisionDamage = function()
		return 0, false
	end,
	initialize = function(p, p2, p3)
		local trait = p.config.traits[p3]
		p2.traits[p3] = {
			phase = "Moving",
			phaseRemaining = trait.moveDuration or 3,
			aimDirection = p2.direction,
			flames = {},
			nextFlameId = 1
		}
	end,
	updateFrame = function(object, state, _, p, list, p2)
		local trait = object.config.traits[p2]
		local trait2 = state.traits[p2]

		if not trait2 then
			return
		end

		if trait2.phase == "Moving" then
			trait2.phaseRemaining -= p

			if trait2.phaseRemaining > 0 then
				return
			else
				volcanoBeginWindup(object, state, trait2, trait, list)
			end
		end

		state.bonusSpeedMultiplier = 0

		if trait2.phase == "Windup" then
			volcanoRefreshFlameExtents(object, state, trait2)
			trait2.phaseRemaining -= p

			if trait2.phaseRemaining > 0 then
				return
			end

			trait2.phase = "Erupting"
			trait2.phaseRemaining = trait.eruptDuration or 2
			table.insert(list, {
				type = "volcano_erupt_start",
				ballId = state.id,
				position = state.position
			})
		end

		volcanoRefreshFlameExtents(object, state, trait2)
		local _getEffectCollisionThickness = object:_getEffectCollisionThickness(trait.assetName)
		local flameGrowSpeed = trait.flameGrowSpeed or 40

		for _, flame in trait2.flames do
			flame.length = math.min(flame.length + flameGrowSpeed * p, flame.maxLength)

			if not (flame.length > 0) then
				continue
			end

			local v24 = state.position + flame.direction * state.radius
			local v25 = v24 + flame.direction * flame.length

			for _, ball in object.state.balls do
				if not (ball.team ~= state.team and ball.hp > 0) then
					continue
				end

				local position = ball.position
				local vector = v25 - v24
				local dot = vector:Dot(vector)
				local v26

				if dot <= 1e-6 then
					v26 = v24
				else
					v26 = v24 + vector * math.clamp((position - v24):Dot(vector) / dot, 0, 1)
				end

				if (ball.position - v26).Magnitude <= ball.radius + _getEffectCollisionThickness * 0.5 then
					object:_applyBurn(ball, state, p2)
				end
			end
		end

		trait2.phaseRemaining -= p

		if trait2.phaseRemaining <= 0 then
			trait2.phase = "Moving"
			trait2.phaseRemaining = trait.moveDuration or 3
			trait2.flames = {}
			table.insert(list, {
				type = "volcano_erupt_end",
				ballId = state.id,
				position = state.position
			})
		end
	end
}
return BattleSkills