local BattleSkillVerityForms = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function finiteNonnegative(value, p: string)
	local v

	if type(value) == "number" and value == value and value < 1e999 then
		v = value >= 0
	else
		v = false
	end

	assert(v, "[VerityForms] 非法配置: " .. p)
end

function BattleSkillVerityForms.validate(p)
	local upgradeCooldown = p.upgradeCooldown
	local v

	if type(upgradeCooldown) == "number" and upgradeCooldown == upgradeCooldown and upgradeCooldown < 1e999 then
		v = upgradeCooldown >= 0
	else
		v = false
	end

	assert(v, "[VerityForms] 非法配置: upgradeCooldown")

	for _, v2 in { "stage1Damage", "stage2Damage", "stage3Damage" } do
		finiteNonnegative(p[v2], v2) -- equivalent call inferred; original call site unknown
	end

	for _, v2 in { "stage2Speed", "stage3Speed" } do
		finiteNonnegative(p[v2], v2) -- equivalent call inferred; original call site unknown
		assert(p[v2] > 0, "[VerityForms] 阶段移速必须大于 0: " .. v2)
	end

	for _, v2 in { "stage2Chance", "stage3Chance" } do
		finiteNonnegative(p[v2], v2) -- equivalent call inferred; original call site unknown
		assert(p[v2] <= 1, "[VerityForms] 升级概率必须在 0 到 1 之间: " .. v2)
	end

	for _, v2 in {
		"stage2Model",
		"stage3Model",
		"stage2Effect",
		"stage3Effect"
	} do
		local v3

		if type(p[v2]) == "string" then
			v3 = p[v2]:match("%S")
		else
			v3 = false
		end

		assert(v3, "[VerityForms] 缺少素材配置: " .. v2)
	end
end

local function radiusOf(vector: Vector3)
	local v

	if vector.X > 0 then
		v = math.abs(vector.X - vector.Z) <= 0.001
	else
		v = false
	end

	assert(v, "[VerityForms] 球体碰撞箱必须是水平正方形")
	return vector.X * 0.5
end

function BattleSkillVerityForms:initialize(state, p)
	local trait = self.config.traits[p]
	BattleSkillVerityForms.validate(trait)
	local role = self.config.roles[state.roleId]
	local size = self._geometry:getBallCollisionBox(role.templateName).Size
	local v

	if size.X > 0 then
		v = math.abs(size.X - size.Z) <= 0.001
	else
		v = false
	end

	assert(v, "[VerityForms] 球体碰撞箱必须是水平正方形")
	local v2 = size.X * 0.5
	local size2 = self._geometry:getEffectCollisionBox(trait.stage2Model).Size
	local v3

	if size2.X > 0 then
		v3 = math.abs(size2.X - size2.Z) <= 0.001
	else
		v3 = false
	end

	assert(v3, "[VerityForms] 球体碰撞箱必须是水平正方形")
	local stage2Radius = size2.X * 0.5
	local size3 = self._geometry:getEffectCollisionBox(trait.stage3Model).Size
	local v5

	if size3.X > 0 then
		v5 = math.abs(size3.X - size3.Z) <= 0.001
	else
		v5 = false
	end

	assert(v5, "[VerityForms] 球体碰撞箱必须是水平正方形")
	local stage3Radius = size3.X * 0.5
	local v7 = self.config.arena.size * 0.5
	assert(math.max(v2, stage2Radius, stage3Radius) < math.min(v7.X, v7.Y), "[VerityForms] 阶段碰撞箱大于棋盘")
	local v8 = self.statLevels[state.team] or {}
	local attackMultiplier = 1 + self.config.tournament_upgrade.basicStats.attack.amount * (v8.attack or 0)

	if (v8.allIn or 0) > 0 then
		attackMultiplier *= 1 + self.config.traits.AllIn.attackBonus * v8.allIn
	end

	local speedMultiplier = 1 + self.config.tournament_upgrade.basicStats.speed.amount * (v8.speed or 0)

	if (v8.allIn or 0) > 0 then
		speedMultiplier *= 1 + self.config.traits.AllIn.speedBonus * v8.allIn
	end

	state.traits[p] = {
		stage = 1,
		started = false,
		nextUpgradeAt = 0,
		attackMultiplier = attackMultiplier,
		speedMultiplier = speedMultiplier,
		stage1Radius = v2,
		stage2Radius = stage2Radius,
		stage3Radius = stage3Radius
	}
	state.radius = v2
	state.baseRadius = v2
	state.attack = trait.stage1Damage * attackMultiplier
end

function BattleSkillVerityForms.onDamageTaken(data, state, _, p, list, p2)
	local trait = state.traits[p2]

	if not trait or state.hp <= 0 or p <= 0 or trait.stage >= 3 then
		return
	end

	local trait2 = data.config.traits[p2]

	if data.state.elapsed < trait.nextUpgradeAt then
		return
	end

	local stage = trait.stage + 1
	local v2 = trait2["stage" .. stage .. "Chance"]

	if v2 <= 0 or v2 < 1 and v2 <= data.random:NextNumber() then
		return
	end

	trait.stage = stage
	trait.nextUpgradeAt = data.state.elapsed + trait2.upgradeCooldown
	local v3 = trait["stage" .. stage .. "Radius"]
	state.radius = v3
	state.baseRadius = v3
	state.attack = trait2["stage" .. stage .. "Damage"] * trait.attackMultiplier
	local v4 = not (state.baseSpeed > 0) and 1 or state.currentSpeed / state.baseSpeed
	state.baseSpeed = trait2["stage" .. stage .. "Speed"] * trait.speedMultiplier
	state.currentSpeed = state.baseSpeed * v4
	local v5 = data.config.arena.size * 0.5
	state.position = Vector2.new(
		math.clamp(state.position.X, -v5.X + v3, v5.X - v3),
		(math.clamp(state.position.Y, -v5.Y + v3, v5.Y - v3))
	)

	if state.voltaicShockAnchorPosition then
		state.voltaicShockAnchorPosition = state.position
	end

	table.insert(list, {
		type = "verity_transform",
		ballId = state.id,
		position = state.position,
		stage = stage,
		effectName = trait2["stage" .. stage .. "Effect"]
	})
end

function BattleSkillVerityForms.updateFrame(_, data, _, _, list, p)
	local trait = data.traits[p]

	if not trait.started then
		trait.started = true
		table.insert(list, {
			type = "verity_start",
			ballId = data.id,
			roleId = data.roleId,
			position = data.position
		})
	end
end

function BattleSkillVerityForms.collisionDamage(_, p, _)
	return p.attack, false
end

return BattleSkillVerityForms