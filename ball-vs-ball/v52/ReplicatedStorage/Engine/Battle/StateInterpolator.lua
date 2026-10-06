local StateInterpolator = {}
local v = {
	id = true,
	roleId = true,
	displayName = true,
	color = true,
	highlightColor = true,
	team = true,
	slotDisplayName = true,
	maxHp = true,
	attack = true,
	baseSpeed = true,
	baseRadius = true,
	skill = true
}
local v2 = {
	teams = true,
	traits = true,
	spiderWebs = true,
	vampireWebs = true,
	laserSegments = true,
	poisonSpikes = true,
	zoneRegions = true,
	routeGroups = true,
	hitCooldowns = true,
	hitCooldownByTarget = true,
	touchingByTarget = true,
	targetHitCooldowns = true,
	edges = true
}
local v3 = {
	index = true,
	level = true,
	topValue = true,
	phase = true,
	selectedPiece = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isDiscreteKey(value)
	if typeof(value) ~= "string" then
		return false
	end

	if v3[value] then
		return true
	end

	return value:sub(-2) == "Id" or value:sub(-5) == "Index" or value:sub(-5) == "Count"
end

local v4 = {
	"projectileId",
	"bulletId",
	"tailId",
	"diceId",
	"bombId",
	"shardId",
	"regionId",
	"appleId",
	"turretId",
	"arrowId",
	"nodeId",
	"trailId",
	"potionId",
	"beeId",
	"cactusId",
	"trapId",
	"shurikenId",
	"dropletId",
	"flameId",
	"id",
	"index"
}
local v5 = {
	direction = true,
	lockedAimDirection = true,
	vampireAttachOffsetDirection = true
}

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function nearest(list, list2, p: number)
	if p < 0.5 then
		if list == nil then
			return list2
		end

		return list
	elseif list2 == nil then
		return list
	else
		return list2
	end
end

local lerpValue

local function resolveIdKey(p)
	if typeof(p) ~= "table" then
		return nil
	end

	for _, v6 in v4 do
		if p[v6] ~= nil then
			return v6
		end
	end

	return nil
end

local function lerpArray(list, list2, p: number, value)
	local v6 = list[1]
	local v7

	if typeof(v6) == "table" then
		for _, v9 in v4 do
			if v6[v9] == nil then
				continue
			end

			v7 = v9
			break
		end
	end

	if not v7 then
		local v8 = list2[1]

		if typeof(v8) == "table" then
			for _, v10 in v4 do
				if v8[v10] == nil then
					continue
				end

				v7 = v10
				break
			end
		else
			v7 = nil
		end
	end

	if v7 == nil then
		local result = {}

		for i = 1, math.max(#list, #list2) do
			result[i] = lerpValue(list[i], list2[i], p, value)
		end

		return result
	else
		local v8 = {}

		for _, v9 in list2 do
			v8[v9[v7]] = v9
		end

		local v9 = {}
		local result = {}

		for _, v10 in list do
			local v11 = v10[v7]
			v9[v11] = true
			local v12 = v8[v11]

			if v12 then
				table.insert(result, lerpValue(v10, v12, p, value))
			elseif p < 1 then
				table.insert(result, v10)
			end
		end

		for _, v10 in list2 do
			if v9[v10[v7]] or not (p > 0) then
				continue
			end

			table.insert(result, v10)
		end

		return result
	end
end

lerpValue = function(list, list2, p: number, value)
	if list == nil then
		return list2
	end

	if list2 == nil then
		if p < 1 then
			return list
		end

		return nil
	else
		if typeof(value) == "string" and v[value] then
			return list2
		end

		local typeName = typeof(list)

		if typeName ~= typeof(list2) then
			return nearest(list, list2, p)
		end

		if typeName == "number" then
			-- equivalent call inferred; original call site unknown
			if not isDiscreteKey(value) then
				return list + (list2 - list) * p
			end

			return nearest(list, list2, p)
		elseif typeName == "Vector2" then
			local lerped = list:Lerp(list2, p)

			if typeof(value) ~= "string" or not v5[value] then
				return lerped
			end

			if lerped.Magnitude < 0.001 then
				return list
			end

			return lerped.Unit
		elseif typeName == "table" and (typeof(value) ~= "string" or not v2[value]) then
			if #list > 0 or #list2 > 0 then
				return (lerpArray(list, list2, p, value))
			end

			local result = {}

			for k, v6 in list do
				result[k] = lerpValue(v6, list2[k], p, k)
			end

			for k, v6 in list2 do
				if result[k] == nil then
					result[k] = lerpValue(list[k], v6, p, k)
				end
			end

			return result
		end

		return nearest(list, list2, p)
	end
end

local function snapVerityForms(p, p2, p3)
	if not (p and p2 and p3) then
		return p
	end

	local clone = p
	local v6 = false

	for k, ball in p3.balls do
		local ball2 = p2.balls[k]
		local verityForms = ball2 and ball2.traits and ball2.traits.VerityForms
		local verityForms2 = ball.traits and ball.traits.VerityForms

		if not (verityForms and verityForms2 and verityForms.stage ~= verityForms2.stage and p.balls[k]) then
			continue
		end

		if not v6 then
			clone = table.clone(p)
			clone.balls = table.clone(p.balls)
			v6 = true
		end

		local clone2 = table.clone(p.balls[k])
		clone2.traits = table.clone(clone2.traits)
		clone2.traits.VerityForms = verityForms2
		local radius = ball.radius
		local baseRadius = ball.baseRadius
		clone2.radius = radius
		clone2.baseRadius = baseRadius
		local attack = ball.attack
		local hp = ball.hp
		clone2.attack = attack
		clone2.hp = hp
		clone2.position = ball.position
		clone.balls[k] = clone2
	end

	return clone
end

local function smoothRobux(p, p2, p3, p4)
	local clone = p
	local v6 = false

	for k, ball in p3.balls do
		local ball2 = p2.balls[k]
		local robuxBarrage = ball2 and ball2.traits and ball2.traits.RobuxBarrage
		local robuxBarrage2 = ball.traits and ball.traits.RobuxBarrage

		if not (robuxBarrage and robuxBarrage2 and p.balls[k]) then
			continue
		end

		if not v6 then
			clone = table.clone(p)
			clone.balls = table.clone(p.balls)
			v6 = true
		end

		local clone2 = table.clone(p.balls[k])
		clone2.traits = table.clone(clone2.traits)
		local clone3 = table.clone(robuxBarrage)
		clone3.projectiles = {}
		local projectilesByProjectileId = {}

		for _, projectile in robuxBarrage2.projectiles do
			projectilesByProjectileId[projectile.projectileId] = projectile
		end

		for _, projectile in robuxBarrage.projectiles do
			local v7 = projectilesByProjectileId[projectile.projectileId]
			local clone4 = table.clone(projectile)

			if v7 and projectile.direction:Dot(v7.direction) > 0.99999 then
				clone4.position = projectile.position:Lerp(v7.position, p4)
			end

			table.insert(clone3.projectiles, clone4)
		end

		clone2.traits.RobuxBarrage = clone3
		clone.balls[k] = clone2
	end

	return clone
end

function StateInterpolator.interpolate(p, p2, p3: number)
	if p == nil then
		return p2
	end

	if p2 == nil or p3 >= 1 then
		return p2 or p
	end

	local v6

	if p3 <= 0 then
		v6 = p
	else
		v6 = lerpValue(p, p2, p3, nil)
	end

	if p3 > 0 then
		v6 = smoothRobux(v6, p, p2, p3)
	end

	return (snapVerityForms(v6, p, p2))
end

return StateInterpolator