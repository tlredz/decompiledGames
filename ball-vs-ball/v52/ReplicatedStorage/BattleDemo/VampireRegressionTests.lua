local createVector = vector.create
local CellBattleSimulation = require(script.Parent:WaitForChild("CellBattleSimulation"))
local RenderMath = require(script.Parent:WaitForChild("BattleRenderer"):WaitForChild("RenderMath"))

local function simulationConfig()
	local vampireAttach = {
		trigger = "VampireAttach",
		duration = 1.5,
		tickInterval = 0.5,
		drainDamage = 5,
		healPerTick = 5,
		slowMultiplier = 0.5,
		attachPadding = -0.12
	}
	local deathSplit = {
		trigger = "DeathSplit",
		growthTime = 3,
		growthScale = 1.5,
		splitCount = 3,
		maxTotalSplitCount = 20,
		spawnProtectionDuration = 0.2
	}

	local function role(p, maxHp, speed, skill)
		return {
			roleId = p,
			displayName = p,
			color = Color3.new(1, 1, 1),
			highlightColor = Color3.new(1, 1, 1),
			radius = 1,
			maxHp = maxHp,
			attack = 0,
			speed = speed,
			skill = skill
		}
	end

	return {
		roles = {
			Vampire = role("Vampire", 30, 10, vampireAttach),
			Cell = role("Cell", 5, 10, deathSplit)
		},
		traits = {
			VampireAttach = vampireAttach,
			DeathSplit = deathSplit
		},
		tournament_upgrade = {
			basicStats = {
				speed = {
					amount = 0
				},
				hp = {
					amount = 0
				},
				attack = {
					amount = 0
				}
			}
		},
		battle = {
			rolePool = { "Vampire", "Cell" },
			contactCooldown = 0.1
		},
		arena = {
			size = Vector2.new(100, 100)
		},
		slots = {
			Blue = {
				spawnPosition = Vector2.new(-2, 0)
			},
			Yellow = {
				spawnPosition = Vector2.new(2, 0)
			}
		}
	}
end

local function testNearestTargetFacing()
	local cframe = CFrame.Angles(0, 1.5707963267948966, 0)
	local identity = CFrame.identity
	local v = {
		Vampire = {
			forwardOffset = cframe
		},
		MachineGun = {
			forwardOffset = cframe
		},
		Snake = {
			forwardOffset = cframe
		},
		Plain = {
			forwardOffset = cframe
		}
	}

	local function makeBall(id, roleId, team, position, trigger, direction)
		return {
			id = id,
			roleId = roleId,
			team = team,
			position = position,
			direction = direction,
			skill = {
				trigger = trigger
			},
			traits = {}
		}
	end

	local ball = makeBall("Vampire", "Vampire", "Blue", Vector2.zero, "VampireAttach")
	local ball2 = makeBall("Near", "Plain", "Yellow", Vector2.new(3, 0), "None")
	local v2 = {
		Vampire = ball,
		Near = ball2,
		Far = makeBall("Far", "Plain", "Yellow", Vector2.new(9, 0), "None")
	}
	assert(RenderMath.findNearestEnemy(v2, ball) == ball2, "必须选择最近的敌方实体作为朝向目标")
	assert(RenderMath.findNearestEnemy({
		Vampire = ball
	}, ball) == nil, "场上没有敌人时不得选出朝向目标")
	assert(RenderMath.findNearestEnemy(v2, ball2) == ball, "敌我必须按 team 判定，而不是固定槽位")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function markerLookVector(ball3, ball4)
		local worldFromArena = RenderMath.worldFromArena(identity, 1, ball3.position, 0)
		return (RenderMath.resolveBallCFrame(identity, 1, v, ball3, ball4, worldFromArena) * cframe).LookVector
	end

	assert((markerLookVector(ball, ball2)):Dot(createVector(1, 0, 0)) > 0.99, "吸血鬼球朝向标记必须朝向目标")
	local ball3 = makeBall("MachineGun", "MachineGun", "Blue", Vector2.zero, "MachineGun")
	assert((markerLookVector(ball3, ball2)):Dot(createVector(1, 0, 0)) > 0.99, "机枪球朝向标记必须朝向目标")
	local ball4 = makeBall("Snake", "Snake", "Blue", Vector2.zero, "SnakeTail", Vector2.new(0, -1))
	assert((markerLookVector(ball4, ball2)):Dot(createVector(0, -1, 0)) > 0.99, "蛇球必须朝自身运动方向，不得被最近目标带偏")
	local ball5 = makeBall("Plain", "Plain", "Blue", Vector2.zero, "Passive", Vector2.new(1, 0))
	assert((markerLookVector(ball5, ball2)):Dot(identity.UpVector) > 0.99, "未登记朝向策略的球必须保持棋盘默认朝向")
end

local function testAttachedPairMovement()
	local v = CellBattleSimulation.new(simulationConfig(), 1, {
		Blue = "Vampire",
		Yellow = "Cell"
	})
	local state = v:getState()
	local blue = state.balls.Blue
	local yellow = state.balls.Yellow
	v:_startVampireAttach(blue, yellow, {})
	v:step(0)
	local position = blue.position
	local position2 = yellow.position
	v:step(0.1)
	local v2 = blue.position - position
	local v3 = yellow.position - position2
	assert(math.abs(yellow.currentSpeed - 5) < 0.001, "贴附目标必须按 50% 速度移动")
	assert(v3.Magnitude > 0.001, "贴附目标必须继续移动")
	assert((v2 - v3).Magnitude < 0.001, "吸血鬼球必须与目标以相同位移一起移动")
end

local function testVampireKillDeathSplit()
	local v = CellBattleSimulation.new(simulationConfig(), 1, {
		Blue = "Vampire",
		Yellow = "Cell"
	})
	local state = v:getState()
	local blue = state.balls.Blue
	local yellow = state.balls.Yellow
	yellow.traits.DeathSplit.grown = true
	local v2 = {}
	v:_startVampireAttach(blue, yellow, v2)
	v:_updateVampireAttach(blue, yellow, 0.5, v2)
	local v3

	if blue.vampireAttachedTargetId == nil then
		v3 = blue.vampireStateRemaining == 0
	else
		v3 = false
	end

	assert(v3, "击杀目标后必须解除贴附")
	local v4

	if state.balls.Yellow == nil then
		v4 = #state.teams.Yellow == 3
	else
		v4 = false
	end

	assert(v4, "成长细胞球死亡后必须立即分裂为子球")
	v:_updateWinner(v2)
	assert(not state.finished, "敌方子球仍存活时不得提前结束对局")
	local position = blue.position
	v:_updateBallSkill(blue, state.balls[state.teams.Yellow[1]], 0.1, v2)
	v:_moveBall(blue, 0.1)
	assert((blue.position - position).Magnitude > 0.001, "解除贴附后吸血鬼球必须继续移动")
end

local function testVampireDamagesSecondCellAfterSplit()
	local v = CellBattleSimulation.new(simulationConfig(), 1, {
		Blue = "Vampire",
		Yellow = "Cell"
	})
	local state = v:getState()
	local blue = state.balls.Blue
	local yellow = state.balls.Yellow
	yellow.traits.DeathSplit.grown = true
	local v2 = {}
	v:_startVampireAttach(blue, yellow, v2)
	v:_updateVampireAttach(blue, yellow, 0.5, v2)
	local ball = state.balls[state.teams.Yellow[1]]
	assert(ball ~= nil, "细胞球分裂后必须存在可作为第二目标的子球")
	ball.spawnProtectedUntil = 0
	v:_startVampireAttach(blue, ball, v2)
	v:step(0.5)
	assert(state.balls[ball.id] == nil, "第二次贴附子球必须正常造成吸血伤害")
	assert(blue.vampireAttachedTargetId == nil, "第二个目标死亡后必须解除贴附")
end

local function testVampireAttachedDeathByThirdParty()
	local v = CellBattleSimulation.new(simulationConfig(), 1, {
		Blue = "Vampire",
		Yellow = "Cell"
	})
	local state = v:getState()
	local blue = state.balls.Blue
	local yellow = state.balls.Yellow
	yellow.traits.DeathSplit.grown = true
	local v2 = {}
	v:_startVampireAttach(blue, yellow, v2)
	v:_updateVampireAttach(blue, yellow, 0.5, v2)
	assert(#state.teams.Yellow == 3, "成长细胞球死亡后必须立即分裂为子球")
	local ball = state.balls[state.teams.Yellow[1]]
	local ball2 = state.balls[state.teams.Yellow[2]]
	ball.spawnProtectedUntil = 0
	ball2.spawnProtectedUntil = 0
	v:_startVampireAttach(blue, ball, v2)
	assert(blue.vampireAttachedTargetId == ball.id, "吸血鬼球必须已贴附到新目标")
	assert(ball.vampireVictimSourceId == blue.id, "新目标必须记录被贴附来源")
	local hp = blue.hp
	assert(v:_damage(blue, ball2, blue.hp + 999, v2), "吸血鬼球贴附期间必须正常受到第三方伤害（不再完全无敌）")
	assert(hp > 0, "测试前提：吸血鬼球生命值必须大于 0")
	assert(state.balls[blue.id] == nil, "被第三方打死的吸血鬼球必须正常从场上摘除")
	assert(ball.vampireVictimSourceId == nil, "吸血鬼球暴毙后必须清空目标身上残留的 vampireVictimSourceId")
end

return {
	run = function()
		testNearestTargetFacing()
		testAttachedPairMovement()
		testVampireKillDeathSplit()
		testVampireDamagesSecondCellAfterSplit()
		testVampireAttachedDeathByThirdParty()
		return "VampireRegressionTests: PASS"
	end
}