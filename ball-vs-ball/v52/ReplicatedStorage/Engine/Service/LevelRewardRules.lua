local LevelRewardRules = {
	normalizeState = function(p)
		local v = {
			randomByLevel = {},
			grantedRandom = {},
			grantedRewards = {}
		}

		if typeof(p) ~= "table" then
			return v
		end

		for _, v2 in { "randomByLevel", "grantedRandom", "grantedRewards" } do
			if typeof(p[v2]) ~= "table" then
				continue
			end

			for k, v3 in p[v2] do
				if not (typeof(k) == "string" and typeof(v3) == "string") then
					continue
				end

				v[v2][k] = v3
			end
		end

		return v
	end,
	buildEntries = function(items, p, p2)
		local v = {}
		local result = {}

		for _, item in items do
			local v2

			if typeof(item.lvl) == "number" and item.lvl >= 1 then
				v2 = item.lvl % 1 == 0
			else
				v2 = false
			end

			assert(v2, "等级配置非法")
			assert(not v[item.lvl], "重复等级：" .. tostring(item.lvl))
			v[item.lvl] = true
			local rewardBalls = {}
			local v3 = {}
			local rewardBalls2 = item.rewardBalls

			if rewardBalls2 ~= nil and rewardBalls2 ~= "x" then
				assert(typeof(rewardBalls2) == "table", "rewardBalls 必须为数组，等级：" .. tostring(item.lvl))

				for _, rewardBall in rewardBalls2 do
					if not (rewardBall ~= "x" and rewardBall ~= "") then
						continue
					end

					local v4

					if typeof(rewardBall) == "string" then
						v4 = p[rewardBall] ~= nil
					else
						v4 = false
					end

					assert(v4, "未知奖励球：" .. tostring(rewardBall))

					if v3[rewardBall] then
						continue
					end

					v3[rewardBall] = true
					table.insert(rewardBalls, rewardBall)
				end
			end

			local rewardId = item.rewardId

			if rewardId == "" or rewardId == "x" then
				rewardId = nil
			end

			if rewardId ~= nil then
				local v4 = "，等级：" .. tostring(item.lvl) .. "，奖励：" .. tostring(rewardId)
				assert(typeof(rewardId) == "string", "rewardId 必须为字符串" .. v4)
				assert(#rewardBalls == 0, "rewardBalls 与 rewardId 不能同时配置" .. v4)
				local v5 = p2 and p2[rewardId]
				local v6

				if typeof(v5) == "table" then
					v6 = #v5 == 1
				else
					v6 = false
				end

				assert(v6, "每个等级奖励必须且只能对应一条 Config.reward 配置" .. v4)
				local v7

				if typeof(v5[1].count) == "number" and v5[1].count >= 1 then
					v7 = v5[1].count % 1 == 0
				else
					v7 = false
				end

				assert(v7, "奖励数量非法" .. v4)
				assert(not (v5[1].extraArgs and v5[1].extraArgs["动态数量"]), "等级奖励不支持动态数量" .. v4)
			end

			table.insert(result, {
				level = item.lvl,
				pool = rewardBalls,
				rewardId = rewardId
			})
		end

		table.sort(result, function(a, b)
			return a.level < b.level
		end)
		return result
	end,
	ownedUntradable = function(items)
		local result = {}

		for _, item in items do
			if item.itemType == "Ball" and item.tradable == false then
				result[item.itemId] = true
			end
		end

		return result
	end
}

function LevelRewardRules.fill(items, p, p2, object)
	local state = LevelRewardRules.normalizeState(p)
	local clone = table.clone(p2)

	for _, item in items do
		if #item.pool == 1 then
			clone[item.pool[1]] = true
		end
	end

	for _, v in state.randomByLevel do
		clone[v] = true
	end

	for _, v in state.grantedRandom do
		clone[v] = true
	end

	for _, item in items do
		local level = tostring(item.level)

		if not (#item.pool > 1 and state.randomByLevel[level] == nil) then
			continue
		end

		local v = {}

		for _, v2 in item.pool do
			if not clone[v2] then
				table.insert(v, v2)
			end
		end

		if not (#v > 0) then
			continue
		end

		local v2 = v[object:NextInteger(1, #v)]
		state.randomByLevel[level] = v2
		clone[v2] = true
	end

	return state
end

function LevelRewardRules.pending(items, data, p, p2: number)
	local clone = table.clone(p)
	local result = {}

	for _, item in items do
		if p2 < item.level then
			break
		end

		local level = tostring(item.level)

		if item.rewardId then
			if data.grantedRewards[level] == nil then
				table.insert(result, {
					level = item.level,
					rewardId = item.rewardId
				})
			end
		else
			local fixed = #item.pool == 1
			local cnId

			if fixed then
				cnId = item.pool[1]
			elseif #item.pool > 1 then
				cnId = data.randomByLevel[level]
			end

			if cnId and not clone[cnId] and (fixed or data.grantedRandom[level] ~= cnId) then
				table.insert(result, {
					level = item.level,
					cnId = cnId,
					fixed = fixed
				})
				clone[cnId] = true
			end
		end
	end

	return result
end

function LevelRewardRules.describe(data, p, data2)
	local cnId

	if #data.pool == 1 then
		cnId = data.pool[1]
	elseif #data.pool > 1 then
		cnId = p.randomByLevel[tostring(data.level)]
	end

	local v2 = cnId and data2.ball.byCnId[cnId]

	if v2 then
		return {
			name = v2.displayName,
			image = v2.image,
			cnId = cnId,
			rating = v2.rating
		}
	end

	if not data.rewardId then
		return nil
	end

	local v3 = data2.reward.byCnId[data.rewardId]
	local v4 = v3 and v3[1]

	if not v4 then
		return nil
	end

	local v5 = data2.asset.byCnId[v4.assetCnId]
	local txt

	if v5 and typeof(v5.txt) == "string" then
		txt = v5.txt
	else
		txt = v4.itemId
	end

	local v6

	if v4.itemType == "头衔" then
		v6 = data2.playerTitle.byCnId[v4.itemId]
	end

	local displayName

	if v6 then
		displayName = v6.displayName
	else
		displayName = v4.itemId
	end

	local v7 = string.gsub(txt, "%%d", function()
		return (tostring(v4.count))
	end)
	return {
		name = string.gsub(v7, "%%s", function()
			return displayName
		end),
		image = (not v5 or typeof(v5.image) ~= "string" or not string.match(v5.image, "^%a+://")) and "" or v5.image,
		rewardId = data.rewardId,
		rating = v4.rating
	}
end

return LevelRewardRules