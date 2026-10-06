local function circleHit(p, vector, vector2, radius)
	local vector3 = p - vector2
	local v = vector3:Dot(vector3) - radius * radius

	if v <= 0 then
		return 0
	end

	local dot = vector:Dot(vector)

	if dot <= 9.999999999999998e-15 then
		return nil
	end

	local dot2 = vector3:Dot(vector)
	local v2 = dot2 * dot2 - dot * v

	if v2 < 0 then
		return nil
	end

	local v3 = (-dot2 - math.sqrt(v2)) / dot

	if v3 >= 0 and v3 <= 1 then
		return v3
	end

	return nil
end

local function boxHit(p, p2, p3, p4)
	local v = p3.position - p
	local v2 = -p2
	local v3 = p4.hitboxSize.X * 0.5
	local v4 = p4.hitboxSize.Y * 0.5
	local radius = p3.radius
	local vector = v - Vector2.new(math.clamp(v.X, -v3, v3), (math.clamp(v.Y, -v4, v4)))

	if vector:Dot(vector) <= radius * radius then
		return 0
	end

	local v5 = 1e999

	local function consider(p5)
		if p5 and p5 >= 0 and p5 <= 1 and p5 < v5 then
			v5 = p5
		end
	end

	if math.abs(v2.X) > 1e-7 then
		for _, v6 in { -1, 1 } do
			local v7 = (v6 * (v3 + radius) - v.X) / v2.X

			if not (v7 >= 0 and v7 <= 1 and math.abs(v.Y + v2.Y * v7) <= v4 and v7) then
				continue
			end

			if not (v7 >= 0 and v7 <= 1 and v7 < v5) then
				continue
			end

			v5 = v7
		end
	end

	if math.abs(v2.Y) > 1e-7 then
		for _, v6 in { -1, 1 } do
			local v7 = (v6 * (v4 + radius) - v.Y) / v2.Y

			if not (v7 >= 0 and v7 <= 1 and math.abs(v.X + v2.X * v7) <= v3 and v7) then
				continue
			end

			if not (v7 >= 0 and v7 <= 1 and v7 < v5) then
				continue
			end

			v5 = v7
		end
	end

	for _, v6 in { -1, 1 } do
		for _, v7 in { -1, 1 } do
			local v8 = circleHit(v, v2, Vector2.new(v6 * v3, v7 * v4), radius)

			if not v8 then
				continue
			end

			local v9 = v + v2 * v8

			if not (v3 <= v6 * v9.X and v4 <= v7 * v9.Y and v8 and v8 >= 0) then
				continue
			end

			if not (v8 <= 1 and v8 < v5) then
				continue
			end

			v5 = v8
		end
	end

	if v5 < 1e999 then
		return v5
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function emitEvent(list, p, p2, p3, soundPlaybackSpeed)
	table.insert(list, {
		type = p,
		ballId = p2.id,
		projectileId = p3.projectileId,
		position = p3.position,
		soundPlaybackSpeed = soundPlaybackSpeed
	})
end

local function blockingFraction(object, p, position, p2)
	local v = p.hitboxSize.X * 0.5
	local v2 = p.hitboxSize.Y * 0.5
	local v3 = object.config.arena.size * 0.5
	local v4 = v3.X - v
	local v5 = v3.Y - v2
	local v6 = 1e999

	if v4 <= 0 or v5 <= 0 then
		return 0
	end

	local X = math.abs(position.X)

	if v4 + 1e-7 < X then
		return 0
	end

	local Y = math.abs(position.Y)

	if v5 + 1e-7 < Y then
		return 0
	end

	if math.abs(p2.X) > 1e-7 then
		if not (p2.X > 0) then
			v4 = -v4
		end

		local v7 = (v4 - position.X) / p2.X

		if v7 >= 0 then
			v6 = math.min(v6, v7)
		end
	end

	if math.abs(p2.Y) > 1e-7 then
		if not (p2.Y > 0) then
			v5 = -v5
		end

		local v7 = (v5 - position.Y) / p2.Y

		if v7 >= 0 then
			v6 = math.min(v6, v7)
		end
	end

	local cactusThrow = object.config.traits.CactusThrow

	if not cactusThrow then
		return v6
	end

	local radius = nil

	for _, ball in object.state.balls do
		local cactusThrow2 = ball.traits and ball.traits.CactusThrow

		if not cactusThrow2 then
			continue
		end

		radius = radius or object:_getEffectCollisionRadius(cactusThrow.assetName)

		for _, v8 in cactusThrow2.cacti or {} do
			local v9 = boxHit(position, p2, {
				position = v8.position,
				radius = radius
			}, p)

			if v9 then
				v6 = math.min(v6, v9)
			end
		end
	end

	return v6
end

local function chooseDirection(p, data, trait)
	local v = trait.projectileSpeed * trait.maxLifetime
	local v2 = -1
	local v3 = nil

	for _ = 1, 8 do
		local number = p.random:NextNumber(0, 6.283185307179586)
		local vector = Vector2.new(math.cos(number), (math.sin(number)))
		local v4 = math.min(1, (blockingFraction(p, trait, data.position, vector * v))) * v

		if not (v2 + 1e-7 < v4) then
			continue
		end

		v3 = vector
		v2 = v4
	end

	return v3
end

local function advance(object, data, trait, state, p, list)
	local v = math.min(p, state.lifetimeRemaining)
	local v2 = state.direction * trait.projectileSpeed * v
	local v3 = blockingFraction(object, trait, state.position, v2)
	local v4 = 1e999
	local v5 = nil

	for _, ball in object.state.balls do
		if not (ball.team ~= data.team and ball.hp > 0) then
			continue
		end

		local v6 = boxHit(state.position, v2, ball, trait)

		if not (v6 and (v6 < v4 or v6 == v4 and v5 and tostring(ball.id) < tostring(v5.id))) then
			continue
		end

		v5 = ball
		v4 = v6
	end

	if v5 and v4 <= 1 and v4 <= v3 then
		state.position += v2 * v4
		local _applyProjectileDamage = object:_applyProjectileDamage(data, v5, trait.bulletDamage)

		if _applyProjectileDamage > 0 then
			v5.hp = math.max(0, v5.hp - _applyProjectileDamage)
			object:_onDamageDealt(data, v5, _applyProjectileDamage, list)

			if object.multiEntityMode then
				object:_resolveEntityDeath(v5, data, list)
			end
		end

		table.insert(list, {
			type = "robux_hit",
			ballId = v5.id,
			otherBallId = data.id,
			sourceBallId = data.id,
			targetBallId = v5.id,
			damage = _applyProjectileDamage,
			position = state.position,
			projectileId = state.projectileId
		})
		return false
	elseif v3 <= 1 then
		state.position += v2 * math.max(0, v3)
		emitEvent(list, "robux_wall_hit", data, state, nil) -- equivalent call inferred; original call site unknown
		return false
	else
		state.position += v2
		state.lifetimeRemaining = math.max(0, state.lifetimeRemaining - p)

		if state.lifetimeRemaining <= 1e-7 then
			emitEvent(list, "robux_expired", data, state, nil) -- equivalent call inferred; original call site unknown
			return false
		else
			return true
		end
	end
end

local BattleSkillRobuxBarrage = {}

function BattleSkillRobuxBarrage.validate(data)
	local function positive(p)
		local v = data[p]
		local v2

		if type(v) == "number" and v == v and v > 0 then
			v2 = v < 1e999
		else
			v2 = false
		end

		assert(v2, "RobuxBarrage 配置必须是有限正数: " .. p)
		return v
	end

	local fullHealthShotInterval = data.fullHealthShotInterval
	local v

	if type(fullHealthShotInterval) == "number" and fullHealthShotInterval == fullHealthShotInterval and fullHealthShotInterval > 0 then
		v = fullHealthShotInterval < 1e999
	else
		v = false
	end

	assert(v, "RobuxBarrage 配置必须是有限正数: fullHealthShotInterval")
	local lowHealthShotInterval = data.lowHealthShotInterval
	local v2

	if type(lowHealthShotInterval) == "number" and lowHealthShotInterval == lowHealthShotInterval and lowHealthShotInterval > 0 then
		v2 = lowHealthShotInterval < 1e999
	else
		v2 = false
	end

	assert(v2, "RobuxBarrage 配置必须是有限正数: lowHealthShotInterval")
	assert(lowHealthShotInterval <= fullHealthShotInterval, "RobuxBarrage 残血射击间隔不能大于满血间隔")

	for _, v3 in { "projectileSpeed", "maxLifetime" } do
		local v4 = data[v3]
		local v5

		if type(v4) == "number" and v4 == v4 and v4 > 0 then
			v5 = v4 < 1e999
		else
			v5 = false
		end

		assert(v5, "RobuxBarrage 配置必须是有限正数: " .. v3)
	end

	local v3

	if type(data.bulletDamage) == "number" and data.bulletDamage >= 0 then
		v3 = data.bulletDamage < 1e999
	else
		v3 = false
	end

	assert(v3, "RobuxBarrage 基础伤害必须是非负有限数")
	local v4

	if typeof(data.hitboxSize) == "Vector2" and data.hitboxSize.X > 0 then
		v4 = data.hitboxSize.Y > 0
	else
		v4 = false
	end

	assert(v4, "RobuxBarrage 碰撞箱尺寸必须来自素材 BasePart")
end

function BattleSkillRobuxBarrage.initialize(_, p, p2)
	p.traits[p2] = {
		time = 0,
		shotProgress = 0,
		projectiles = {},
		nextProjectileId = 1
	}
end

function BattleSkillRobuxBarrage.collisionDamage(_, _)
	return 0, false
end

function BattleSkillRobuxBarrage.updateFrame(p, data, _, p2, list, p3)
	local trait = p.config.traits[p3]
	local trait2 = data.traits[p3]

	if not trait2 then
		return
	end

	local time = trait2.time + p2

	for i = #trait2.projectiles, 1, -1 do
		if not advance(p, data, trait, trait2.projectiles[i], p2, list) then
			table.remove(trait2.projectiles, i)
		end
	end

	if data.hp <= 0 then
		trait2.time = time
		return
	end

	local v2 = math.clamp(1 - data.hp / math.max(data.maxHp, 1e-7), 0, 1)
	local v3 = trait.fullHealthShotInterval + (trait.lowHealthShotInterval - trait.fullHealthShotInterval) * v2
	local v4 = math.max(0, (1 - trait2.shotProgress) * v3)
	trait2.shotProgress += p2 / v3

	while trait2.shotProgress >= 0.9999999 do
		local v5 = {
			projectileId = trait2.nextProjectileId,
			position = data.position,
			direction = chooseDirection(p, data, trait),
			lifetimeRemaining = trait.maxLifetime
		}
		trait2.nextProjectileId += 1
		emitEvent(list, "robux_launch", data, v5, v2 * 0.5 + 1) -- equivalent call inferred; original call site unknown

		if advance(p, data, trait, v5, math.max(0, p2 - v4), list) then
			table.insert(trait2.projectiles, v5)
		end

		trait2.shotProgress -= 1
		v4 += v3
	end

	trait2.time = time
end

return BattleSkillRobuxBarrage