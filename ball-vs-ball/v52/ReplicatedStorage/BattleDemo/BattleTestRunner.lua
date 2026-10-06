local ReplicatedStorage = game:GetService("ReplicatedStorage")
local battleDemo = ReplicatedStorage:WaitForChild("BattleDemo")
local BattleConfig = require(battleDemo:WaitForChild("BattleConfig"))
local BattleReplayBuilder = require(battleDemo:WaitForChild("BattleReplayBuilder"))
local v = { "Blue", "Yellow" }

local function newSideStat()
	return {
		hitCount = 0,
		damageDealt = 0,
		eventCounts = {},
		eventDamage = {}
	}
end

local function summarizeEvents(events)
	local v2 = {
		Blue = newSideStat(),
		Yellow = newSideStat()
	}

	for _, v3 in ipairs(events) do
		local damage = v3.damage
		local sourceBallId = v3.sourceBallId or v3.otherBallId

		if not (typeof(damage) == "number" and damage > 0 and v2[sourceBallId]) then
			continue
		end

		local v4 = v2[sourceBallId]
		v4.hitCount += 1
		v4.damageDealt += damage
		v4.eventCounts[v3.type] = (v4.eventCounts[v3.type] or 0) + 1
		v4.eventDamage[v3.type] = (v4.eventDamage[v3.type] or 0) + damage
	end

	return v2
end

local function formatEventBreakdown(p)
	local v2 = {}

	for k, eventCount in p.eventCounts do
		table.insert(v2, string.format("%s x%d(%d伤害)", k, eventCount, p.eventDamage[k]))
	end

	table.sort(v2)

	if #v2 == 0 then
		return "无"
	end

	return table.concat(v2, "，")
end

return {
	runScenario = function(blue: string, yellow: string, options)
		local v2 = options or {}
		local seed = v2.seed or BattleConfig.seed.value
		local v3 = {
			fixedDt = BattleConfig.replay.fixedDt,
			snapshotInterval = BattleConfig.replay.snapshotInterval,
			maxDuration = BattleConfig.replay.maxDuration,
			selectedRoles = {
				Blue = blue,
				Yellow = yellow
			},
			statLevels = v2.statLevels,
			selectedSecondaryTraits = v2.selectedSecondaryTraits
		}
		local replay = BattleReplayBuilder.buildReplay(BattleConfig, seed, v3)
		local stats = summarizeEvents(replay.events)
		local state = replay.snapshots[#replay.snapshots].state
		print(string.format("========== BattleTestRunner：%s(Blue) vs %s(Yellow)，seed=%d ==========", blue, yellow, seed))
		print(string.format("结果：%s 获胜，时长=%.2fs", replay.winner, replay.duration))

		for _, v5 in ipairs(v) do
			local ball = state.balls[v5]
			local v6 = stats[v5]
			print(string.format(
				"  [%s] 角色=%s 剩余HP=%d/%d 造成总伤害=%d 出手次数=%d 明细：%s",
				v5,
				ball.roleId,
				ball.hp,
				ball.maxHp,
				v6.damageDealt,
				v6.hitCount,
				formatEventBreakdown(v6)
			))
		end

		print("==========================================")
		return {
			winner = replay.winner,
			duration = replay.duration,
			seed = seed,
			finalHp = {
				Blue = state.balls.Blue.hp,
				Yellow = state.balls.Yellow.hp
			},
			stats = stats,
			replay = replay
		}
	end
}