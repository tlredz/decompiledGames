local CellBattleSimulation = require(script.Parent:WaitForChild("CellBattleSimulation"))

local function config()
	local v = {
		trigger = "DeathSplit",
		growthTime = 3,
		growthScale = 1.5,
		attack = 5,
		splitCount = 3,
		maxTotalSplitCount = 20,
		spawnProtectionDuration = 0.2
	}
	return {
		roles = {
			["细胞球"] = {
				roleId = "细胞球",
				displayName = "Cell",
				color = Color3.new(1, 1, 1),
				highlightColor = Color3.new(1, 1, 1),
				radius = 1,
				maxHp = 20,
				attack = 5,
				speed = 12,
				skill = v
			},
			Enemy = {
				roleId = "Enemy",
				displayName = "Enemy",
				color = Color3.new(1, 1, 0),
				highlightColor = Color3.new(1, 1, 0),
				radius = 1,
				maxHp = 100,
				attack = 5,
				speed = 0,
				skill = {
					trigger = "None"
				}
			}
		},
		traits = {
			DeathSplit = v
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
			rolePool = { "细胞球", "Enemy" },
			contactCooldown = 0.1
		},
		arena = {
			size = Vector2.new(100, 100)
		},
		slots = {
			Blue = {
				spawnPosition = Vector2.new(-10, 0)
			},
			Yellow = {
				spawnPosition = Vector2.new(10, 0)
			}
		}
	}
end

return {
	run = function()
		local v = CellBattleSimulation.new(config(), 1, {
			Blue = "细胞球",
			Yellow = "Enemy"
		})
		v:_damage(v:getState().balls.Blue, nil, 20, {})
		assert(#v:getState().teams.Blue == 0, "成长前死亡必须直接移除")
		local v2 = CellBattleSimulation.new(config(), 1, {
			Blue = "细胞球",
			Yellow = "Enemy"
		})
		v2:step(3)
		local blue = v2:getState().balls.Blue
		assert(blue.traits.DeathSplit.grown and blue.radius == 1.5, "3 秒后必须成长到 150%")
		v2:_damage(blue, v2:getState().balls.Yellow, 20, {})
		assert(#v2:getState().teams.Blue == 3, "成长后死亡必须分裂三个子球")
		local ball = v2:getState().balls[v2:getState().teams.Blue[1]]
		local v3

		if ball.hp == 20 and ball.radius == 1 then
			v3 = not ball.traits.DeathSplit.grown
		else
			v3 = false
		end

		assert(v3, "子球必须是默认生命、默认大小且重新计时")
		v2:step(0.21)
		v2:step(3)
		v2:_damage(ball, v2:getState().balls.Yellow, 20, {})
		assert(#v2:getState().teams.Blue == 5, "子球成长后必须能够递归分裂")
		local state = v2:getState()
		local v4 = v2.config.roles["细胞球"]
		state.cellSplitCounts.Blue = 17
		local _spawn = v2:_spawn("Blue", v4, Vector2.zero, Vector2.new(1, 0), false)
		_spawn.traits.DeathSplit.grown = true
		local v5 = #state.teams.Blue
		v2:_damage(_spawn, state.balls.Yellow, 20, {})
		assert(#state.teams.Blue == v5 - 1 + 3, "累计计数器=17 时，17+3<=20，应允许分裂并新增3个子球")
		assert(state.cellSplitCounts.Blue == 20, "分裂成功后累计计数器应变为 20")
		state.cellSplitCounts.Blue = 18
		local _spawn2 = v2:_spawn("Blue", v4, Vector2.new(5, 0), Vector2.new(1, 0), false)
		_spawn2.traits.DeathSplit.grown = true
		local v6 = #state.teams.Blue
		v2:_damage(_spawn2, state.balls.Yellow, 20, {})
		assert(#state.teams.Blue == v6 - 1, "累计计数器=18 时，18+3>20，不得继续分裂")
		assert(state.cellSplitCounts.Blue == 18, "分裂被拒绝时累计计数器不应变化")
		return "CellBattleSimulationTests: PASS"
	end
}