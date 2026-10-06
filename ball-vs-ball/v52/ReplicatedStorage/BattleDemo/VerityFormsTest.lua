local BattleSimulation = require(script.Parent.BattleSimulation)
local BattleReplayBuilder = require(script.Parent.BattleReplayBuilder)
local GeometryProvider = require(script.Parent.GeometryProvider)
local BattleSkill_VerityForms = require(script.Parent.BattleSkill_VerityForms)
local SkillFeatureParser = require(script.Parent.SkillFeatureParser)
local RoleBuilder = require(script.Parent.RoleBuilder)
require(script.Parent.DamageResolution)
local VerityFormsTest = {}
local copy

copy = function(items)
	if type(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in items do
		result[k] = copy(item)
	end

	return result
end

local same

same = function(items, items2)
	if typeof(items) ~= typeof(items2) then
		return false
	end

	if type(items) ~= "table" then
		return items == items2
	end

	for k, item in items do
		if not same(item, items2[k]) then
			return false
		end
	end

	for k in items2 do
		if items[k] == nil then
			return false
		end
	end

	return true
end

function VerityFormsTest.fixture(p)
	local v = copy(p)
	v.arena.size = Vector2.new(25, 25)
	v.slots.Blue.spawnPosition = Vector2.new(-6, 0)
	v.slots.Yellow.spawnPosition = Vector2.new(6, 0)
	v.battle.allowMirrorMatch = true
	v.traits.VerityForms.attack = v.traits.VerityForms.stage1Damage
	local battle = v.battle
	local roles, rolePool = RoleBuilder.build(v.traits, {
		list = {
			{
				cnId = "Verity球",
				displayName = "Verity Ball",
				displayNameCN = "Verity球",
				skills = { "Verity变身" },
				maxHp = 100,
				speed = 10.5,
				assetName = "Verity球"
			},
			{
				cnId = "爆发球",
				displayName = "Burst Ball",
				displayNameCN = "爆发球",
				skills = { "爆发冲刺" },
				maxHp = 100,
				speed = 10.5,
				assetName = "爆发球"
			}
		}
	})
	v.roles = roles
	battle.rolePool = rolePool
	return v
end

function VerityFormsTest.run(p, _)
	local fixture = VerityFormsTest.fixture(p)
	local results = {}

	local function check(name, callback)
		local passed, error = xpcall(callback, debug.traceback)

		if passed then
			error = nil
		end

		table.insert(results, {
			name = name,
			passed = passed,
			error = error
		})
	end

	local function new(p2)
		local v2 = copy(fixture)
		v2.traits.VerityForms.upgradeCooldown = 0
		v2.traits.VerityForms.stage2Chance = p2
		v2.traits.VerityForms.stage3Chance = p2
		return BattleSimulation.new(v2, 42, {
			Blue = "Verity球",
			Yellow = "爆发球"
		})
	end

	local passed2, error2 = xpcall(function()
		local v4 = new(1)
		local blue = v4.state.balls.Blue
		local yellow = v4.state.balls.Yellow
		local v5 = {}
		v4:_damage(blue, yellow, 1, v5)
		assert(blue.traits.VerityForms.stage == 2)
		assert(blue.baseSpeed == v4.config.traits.VerityForms.stage2Speed)
		v4:_damage(blue, yellow, 1, v5)
		assert(blue.traits.VerityForms.stage == 3)
		assert(blue.baseSpeed == v4.config.traits.VerityForms.stage3Speed)
		v4:_damage(blue, yellow, 1, v5)
		local count = 0

		for _, v6 in v5 do
			if v6.type == "verity_transform" then
				count += 1
			end
		end

		assert(count == 2)
	end, debug.traceback)

	if passed2 then
		error2 = nil
	end

	table.insert(results, {
		name = "single hit advances exactly one stage; next hit advances to cap",
		passed = passed2,
		error = error2
	})
	local passed3, error3 = xpcall(function()
		local v7 = new(0)
		local blue = v7.state.balls.Blue
		v7:_damage(blue, v7.state.balls.Yellow, 90, {})
		assert(blue.traits.VerityForms.stage == 1)
		local v8 = new(1)
		local blue2 = v8.state.balls.Blue
		v8:_damage(blue2, v8.state.balls.Yellow, 100, {})
		assert(blue2.traits.VerityForms.stage == 1)
	end, debug.traceback)

	if passed3 then
		error3 = nil
	end

	table.insert(results, {
		name = "zero chance and lethal damage never transform",
		passed = passed3,
		error = error3
	})
	local passed4, error4 = xpcall(function()
		local v10 = new(0.2)
		local blue = v10.state.balls.Blue
		local yellow = v10.state.balls.Yellow
		local count = 0
		local v11 = 0.9
		v10.random = {
			NextNumber = function()
				count += 1
				return v11
			end
		}
		v10:_damage(blue, yellow, 0, {})
		assert(count == 0)
		v10:_damage(blue, yellow, 1, {})
		local v12

		if count == 1 then
			v12 = blue.traits.VerityForms.stage == 1
		else
			v12 = false
		end

		assert(v12)
		v11 = 0.1
		v10:_damage(blue, yellow, 1, {})
		local v13

		if count == 2 then
			v13 = blue.traits.VerityForms.stage == 2
		else
			v13 = false
		end

		assert(v13)
	end, debug.traceback)

	if passed4 then
		error4 = nil
	end

	table.insert(results, {
		name = "zero damage does not roll; failure rolls once; success rolls once",
		passed = passed4,
		error = error4
	})

	local function fn()
		local v11 = new(1)
		local blue = v11.state.balls.Blue
		local yellow = v11.state.balls.Yellow
		v11.config.traits.VerityForms.upgradeCooldown = 1
		v11:_damage(blue, yellow, 1, {})
		assert(blue.traits.VerityForms.stage == 2)
		v11.config.traits.VerityForms.stage3Chance = 0.2
		local count = 0
		v11.random = {
			NextNumber = function()
				count += 1
				return 0.1
			end
		}
		v11:_damage(blue, yellow, 1, {})
		local v12

		if blue.traits.VerityForms.stage == 2 then
			v12 = count == 0
		else
			v12 = false
		end

		assert(v12)
		v11.state.elapsed = 0.999
		v11:_damage(blue, yellow, 1, {})
		local v13

		if blue.traits.VerityForms.stage == 2 then
			v13 = count == 0
		else
			v13 = false
		end

		assert(v13)
		v11.state.elapsed = 1
		v11:_damage(blue, yellow, 1, {})
		local v14

		if blue.traits.VerityForms.stage == 3 then
			v14 = count == 1
		else
			v14 = false
		end

		assert(v14)
		assert(SkillFeatureParser.parse("升级冷却秒数:1", SkillFeatureParser.FEATURE_KEY_MAP.VerityForms).upgradeCooldown == 1)
		local v15 = copy(fixture.traits.VerityForms)
		v15.upgradeCooldown = -1
		assert(not pcall(BattleSkill_VerityForms.validate, v15))
	end

	local passed5, error5 = xpcall(fn, debug.traceback)

	if passed5 then
		error5 = nil
	end

	table.insert(results, {
		name = "upgrade cooldown uses simulation time and skips random rolls",
		passed = passed5,
		error = error5
	})

	local function fn2()
		local parsed = SkillFeatureParser.parse("升二阶段概率:20%,升三阶段概率:35%", SkillFeatureParser.FEATURE_KEY_MAP.VerityForms)
		local v14

		if parsed.stage2Chance == 0.2 then
			v14 = parsed.stage3Chance == 0.35
		else
			v14 = false
		end

		assert(v14)
		local v15 = copy(fixture.traits.VerityForms)
		v15.stage2Chance = 0
		v15.stage3Chance = 1
		BattleSkill_VerityForms.validate(v15)
		v15.stage2Chance = 1.1
		assert(not pcall(BattleSkill_VerityForms.validate, v15))
	end

	local passed6, error6 = xpcall(fn2, debug.traceback)

	if passed6 then
		error6 = nil
	end

	table.insert(results, {
		name = "probability parser and bounds",
		passed = passed6,
		error = error6
	})
	local passed7, error7 = xpcall(function()
		local v19 = new(1)
		local blue = v19.state.balls.Blue
		local yellow = v19.state.balls.Yellow
		local direction = blue.direction
		blue.currentSpeed = blue.baseSpeed * 0.5
		v19:_damage(blue, yellow, 1, {})
		local v20

		if blue.currentSpeed == blue.baseSpeed * 0.5 then
			v20 = blue.direction == direction
		else
			v20 = false
		end

		assert(v20)
		v19:_damage(blue, yellow, 1, {})
		local v21

		if blue.radius == blue.traits.VerityForms.stage3Radius then
			v21 = blue.baseRadius == blue.radius
		else
			v21 = false
		end

		assert(v21)
	end, debug.traceback)

	if passed7 then
		error7 = nil
	end

	table.insert(results, {
		name = "slow multiplier, direction and actual hitbox survive transforms",
		passed = passed7,
		error = error7
	})

	local function fn3()
		local captureSnapshot = GeometryProvider.captureSnapshot(game.ReplicatedStorage)
		local v20 = {
			selectedRoles = {
				Blue = "Verity球",
				Yellow = "爆发球"
			},
			fixedDt = 0.016666666666666666,
			maxDuration = 60,
			snapshotInterval = 0.05
		}

		for _, v21 in { 17, 20260911, 98231 } do
			BattleSimulation.setDefaultGeometry(nil)
			local replay = BattleReplayBuilder.buildReplay(fixture, v21, v20)
			BattleSimulation.setDefaultGeometry(GeometryProvider.fromSnapshot(captureSnapshot))
			local v22 = BattleSimulation.new(fixture, v21, v20.selectedRoles)

			for _ = 1, 3600 do
				if v22.state.finished then
					break
				else
					v22:step(0.016666666666666666)
				end
			end

			if not v22.state.finished then
				local state = v22.state
				local state2 = v22.state
				state.finished = true
				state2.winner = "Draw"
			end

			assert(
				same(replay.snapshots[#replay.snapshots].state, BattleReplayBuilder.cloneState(v22.state)),
				"parity seed=" .. v21
			)
		end

		BattleSimulation.setDefaultGeometry(nil)
	end

	local passed8, error8 = xpcall(fn3, debug.traceback)

	if passed8 then
		error8 = nil
	end

	table.insert(results, {
		name = "replay, lockstep and snapshot geometry deterministic parity",
		passed = passed8,
		error = error8
	})
	BattleSimulation.setDefaultGeometry(nil)
	local count = 0

	for _, v23 in results do
		if v23.passed then
			count += 1
		end
	end

	return {
		total = #results,
		passed = count,
		failed = #results - count,
		results = results
	}
end

return VerityFormsTest