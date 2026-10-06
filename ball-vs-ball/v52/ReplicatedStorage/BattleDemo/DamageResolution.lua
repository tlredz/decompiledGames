local DamageResolution = {
	isFriendlyFire = function(p, p2)
		if p and p2 then
			return p.team ~= nil and p2.team ~= nil and p.team == p2.team
		else
			return false
		end
	end,
	notifyDamageTaken = function(p, p2, p3, p4: number, p5, callback, callback2)
		if p4 <= 0 then
			return
		end

		for _, v in callback2(p2) do
			local v2 = callback(v)

			if v2.onDamageTaken then
				v2.onDamageTaken(p, p2, p3, p4, p5, v)
			end
		end
	end
}

function DamageResolution.onDamageDealt(p, p2, p3, p4: number, p5, callback, callback2)
	if p4 <= 0 then
		return
	end

	DamageResolution.notifyDamageTaken(p, p3, p2, p4, p5, callback, callback2)

	for _, v in callback2(p2) do
		local v2 = callback(v)

		if v2.onDamageDealt then
			v2.onDamageDealt(p, p2, p3, p4, p5, v)
		end
	end
end

function DamageResolution.collisionDamage(p, p2, callback)
	local trigger = p2.skill.trigger
	local v = callback(trigger)

	if v.collisionDamage then
		return v.collisionDamage(p, p2, trigger)
	end

	return math.round(p2.attack), false
end

local function applyIncomingDamageStep(p, state, p2: number, callback, callback2, flag: boolean)
	if p2 <= 0 then
		return 0
	end

	local v = p2 * (1 - math.clamp(state.activeDamageReduction or 0, 0, 0.95))

	for _, v2 in callback2(state) do
		local v3 = callback(v2)

		if v3.modifyIncomingDamage then
			v = v3.modifyIncomingDamage(p, state, v, v2)
		end
	end

	if flag then
		return (math.max(0, (math.round(v))))
	end

	return (math.max(0, v))
end

DamageResolution.applyIncomingDamage = applyIncomingDamageStep

function DamageResolution.resolve(p, data, state, p2: number, callback, callback2, list, options)
	local v = options or {}

	if not v.allowFriendlyFire and DamageResolution.isFriendlyFire(data, state) or v.eventType == "ball_hit" and p2 <= 0 and data and (data.skill.trigger == "VerityForms" or data.skill.trigger == "VolcanoEruption") then
		return 0
	end

	local applyCollisionOutgoingBonus

	if v.applyCollisionOutgoingBonus == nil then
		applyCollisionOutgoingBonus = v.applyOutgoingBonus == nil or v.applyOutgoingBonus
	else
		applyCollisionOutgoingBonus = v.applyCollisionOutgoingBonus
	end

	local applyGlobalOutgoingBonus

	if v.applyGlobalOutgoingBonus == nil then
		applyGlobalOutgoingBonus = data ~= nil
	else
		applyGlobalOutgoingBonus = v.applyGlobalOutgoingBonus
	end

	local v2 = v.roundToInteger == nil or v.roundToInteger
	local v3 = v.applyToDefender == nil or v.applyToDefender

	if applyCollisionOutgoingBonus then
		for _, v4 in callback2(data) do
			local v5 = callback(v4)

			if v5.modifyOutgoingDamage then
				p2 = v5.modifyOutgoingDamage(p, data, state, p2, v4)
			end
		end
	end

	if applyGlobalOutgoingBonus then
		for _, v4 in callback2(data) do
			local v5 = callback(v4)

			if v5.modifyGlobalOutgoingDamage then
				p2 = v5.modifyGlobalOutgoingDamage(p, data, state, p2, v4)
			end
		end
	end

	if v2 then
		p2 = math.round(p2)
	end

	local damage = applyIncomingDamageStep(p, state, p2, callback, callback2, v2)

	if damage <= 0 then
		return 0
	end

	if not v3 then
		return damage
	end

	state.hp = math.max(0, state.hp - damage)

	if v.eventType then
		table.insert(list, {
			type = v.eventType,
			ballId = state.id,
			otherBallId = data.id,
			startPosition = state.position,
			endPosition = data.position,
			position = (state.position + data.position) * 0.5,
			damage = damage,
			usedBonus = v.usedBonus,
			speedSum = (data.currentSpeed or 0) + (state.currentSpeed or 0)
		})
	end

	DamageResolution.onDamageDealt(p, data, state, damage, list, callback, callback2)
	return damage
end

return DamageResolution