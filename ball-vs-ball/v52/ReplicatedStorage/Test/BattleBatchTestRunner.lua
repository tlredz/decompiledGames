local ReplicatedStorage = game:GetService("ReplicatedStorage")
local battleDemo = ReplicatedStorage:WaitForChild("BattleDemo")
local BattleConfig = require(battleDemo:WaitForChild("BattleConfig"))
local BattleReplayBuilder = require(battleDemo:WaitForChild("BattleReplayBuilder"))
local v = {
	101,
	202,
	303,
	404,
	505
}

local function sortedRoleIds(roleIds)
	local result = {}

	if roleIds then
		for _, v2 in ipairs(roleIds) do
			assert(BattleConfig.roles[v2], string.format("未知球角色: %s", (tostring(v2))))
			table.insert(result, v2)
		end
	else
		for k in BattleConfig.roles do
			table.insert(result, k)
		end
	end

	table.sort(result)
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function newRoleSummary()
	return {
		games = 0,
		wins = 0,
		losses = 0,
		draws = 0,
		eventCounts = {}
	}
end

local function recordEvents(role, result, p)
	for _, event in ipairs(result.events) do
		if (event.sourceBallId or event.otherBallId) == p then
			role.eventCounts[event.type] = (role.eventCounts[event.type] or 0) + 1
		end
	end
end

return {
	runAll = function(options)
		local v2 = options or {}
		local v3 = sortedRoleIds(v2.roleIds)
		local seeds = v2.seeds or v
		local includeMirror = v2.includeMirror == true
		local v4 = math.max(1, (math.floor(v2.yieldEvery or 1)))
		local v5 = math.max(1, (math.floor(v2.progressEvery or 20)))
		local v6 = (includeMirror and #v3 * #v3 or #v3 * math.max(0, #v3 - 1)) * #seeds
		print(string.format("[BattleBatchTestRunner] 开始：%d 个球、每组 %d 个 seed、计划 %d 场（不播放回放）", #v3, #seeds, v6))
		local result = {
			total = 0,
			passed = 0,
			failed = 0,
			failures = {},
			roles = {}
		}

		for _, v7 in ipairs(v3) do
			result.roles[v7] = newRoleSummary()
		end

		for i, blue in ipairs(v3) do
			for i2, yellow in ipairs(v3) do
				if not (includeMirror or i ~= i2) then
					continue
				end

				for _, seed in ipairs(seeds) do
					result.total += 1
					local success, result2 = pcall(BattleReplayBuilder.buildReplay, BattleConfig, seed, {
						selectedRoles = {
							Blue = blue,
							Yellow = yellow
						}
					})

					if success then
						local winner = result2.winner

						if winner == "Blue" or winner == "Yellow" or winner == "Draw" then
							result.passed += 1
							local role = result.roles[blue]
							local role2 = result.roles[yellow]
							role.games += 1
							role2.games += 1

							if winner == "Blue" then
								role.wins += 1
								role2.losses += 1
							elseif winner == "Yellow" then
								role2.wins += 1
								role.losses += 1
							else
								role.draws += 1
								role2.draws += 1
							end

							recordEvents(role, result2, "Blue")
							recordEvents(role2, result2, "Yellow")
						else
							result.failed += 1
							table.insert(result.failures, {
								blue = blue,
								yellow = yellow,
								seed = seed,
								reason = "无效胜者: " .. tostring(winner)
							})
						end
					else
						result.failed += 1
						table.insert(result.failures, {
							blue = blue,
							yellow = yellow,
							seed = seed,
							reason = tostring(result2)
						})
					end

					if result.total % v5 == 0 or result.total == v6 then
						print(string.format(
							"[BattleBatchTestRunner] 进度：%d/%d 场，成功 %d，失败 %d",
							result.total,
							v6,
							result.passed,
							result.failed
						))
					end

					if result.total % v4 == 0 then
						task.wait()
					end
				end
			end
		end

		print(string.format("[BattleBatchTestRunner] 完成：%d 场，成功 %d，失败 %d", result.total, result.passed, result.failed))

		for _, v7 in ipairs(v3) do
			local role = result.roles[v7]
			print(string.format("  %s：%d 场，胜 %d / 负 %d / 平 %d", v7, role.games, role.wins, role.losses, role.draws))
		end

		for _, failure in ipairs(result.failures) do
			warn(string.format(
				"  FAIL %s vs %s (seed=%d)：%s",
				failure.blue,
				failure.yellow,
				failure.seed,
				failure.reason
			))
		end

		return result
	end
}