local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local TimeService = require(ReplicatedStorage.Engine.Service.TimeService)
local GachaPool = {}
local v = {
	["小球"] = "Ball"
}

function GachaPool.toEngineItemType(value: string?)
	if typeof(value) == "string" then
		return v[value] or value
	end

	return "Ball"
end

function GachaPool.getDefinition(p)
	if typeof(p) ~= "table" or typeof(p.targetId) ~= "string" then
		return nil
	end

	if p.itemType == "小球" then
		return Config.ball.byCnId[p.targetId]
	end

	return Config.skin.byCnId[p.targetId]
end

function GachaPool.getRating(p)
	local definition = GachaPool.getDefinition(p)
	return definition and definition.rating
end

function GachaPool.ownedKey(p: string, p2: string)
	return p .. ":" .. p2
end

function GachaPool.isUnlocked(p, p2: number?)
	return p.unlockAt == nil or (p2 or TimeService.now()) >= p.unlockAt
end

local function isValidWeight(value)
	return typeof(value) == "number" and value == value and value >= 0 and value < 1e999
end

local function normalizeTargets(items)
	local result = {}

	local function add(value)
		if typeof(value) ~= "string" then
			return
		end

		for k in string.gmatch(string.gsub(value, "，", ","), "[^,]+") do
			local v2 = string.match(k, "^%s*(.-)%s*$")

			if v2 and v2 ~= "" then
				table.insert(result, v2)
			end
		end
	end

	if typeof(items) ~= "table" then
		add(items)
		return result
	end

	for _, item in items do
		add(item)
	end

	return result
end

function GachaPool.buildUnlockContext(level: number, p2, flag: boolean, items)
	local rewardBalls = {}

	for _, v3 in Config.lvl.list do
		local targets = normalizeTargets(v3.rewardBalls)

		if not (typeof(v3.lvl) == "number" and v3.lvl <= level and #targets == 1 and targets[1] ~= "x") then
			continue
		end

		rewardBalls[targets[1]] = true
	end

	local randomByLevel

	if typeof(p2) == "table" then
		randomByLevel = p2.randomByLevel
	else
		randomByLevel = false
	end

	if typeof(randomByLevel) == "table" then
		for k, v3 in randomByLevel do
			local v4 = tonumber(k)

			if not (v4 and v4 >= 1 and v4 % 1 == 0 and v4 <= level) then
				continue
			end

			if typeof(v3) ~= "string" then
				continue
			end

			rewardBalls[v3] = true
		end
	end

	if typeof(items) == "table" then
		for _, item in items do
			if not (typeof(item) == "table" and item.itemType == "Ball" and typeof(item.itemId) == "string") then
				continue
			end

			rewardBalls[item.itemId] = true
		end
	end

	return {
		level = level,
		rewardBalls = rewardBalls,
		starterPackPurchased = flag == true
	}
end

function GachaPool.getPlayerContext(p)
	local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
	local ExperienceService = require(ReplicatedStorage.Engine.Service.ExperienceService)
	local client

	if RunService:IsServer() then
		client = PlayerData.server[assert(p, "Missing gacha player")]
	else
		client = PlayerData.client
	end

	local exp = client.exp()
	local starterPack = client.starterPack()
	return GachaPool.buildUnlockContext(
		ExperienceService.getLevelInfo(exp.total).level,
		client.levelRewards(),
		starterPack.purchased,
		client.items()
	)
end

function GachaPool.getLockReason(p, p2, p3: number?)
	if not GachaPool.isUnlocked(p, p3) then
		return "日期"
	end

	local unlockCondition = p.unlockCondition

	if unlockCondition == nil or unlockCondition == "" or unlockCondition == "x" then
		return nil
	end

	if unlockCondition == "等级奖励获得" then
		if p2 and p2.rewardBalls[p.targetId] then
			return nil
		end
	else
		if unlockCondition ~= "购买新手礼包" then
			return unlockCondition
		end

		if p2 and p2.starterPackPurchased then
			return nil
		end
	end

	return unlockCondition
end

function GachaPool.observeLocalUnlocks(callback)
	assert(RunService:IsClient(), "Client only")
	local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
	local client = PlayerData.client
	local flag = true
	local v2 = false

	local function changed()
		if flag and not v2 then
			v2 = true
			task.defer(function()
				v2 = false

				if flag then
					callback()
				end
			end)
		end
	end

	local v3 = {
		client.exp.Changed(changed),
		client.levelRewards.Changed(changed),
		client.items.Changed(changed),
		client.starterPack.purchased.Changed(changed)
	}
	return function()
		flag = false

		for _, v4 in v3 do
			v4()
		end
	end
end

local function parseUnlockAt(p)
	if p == nil or p == "" then
		return nil, true
	end

	local configDateToDayKey = TimeService.configDateToDayKey(p)

	if configDateToDayKey then
		return configDateToDayKey * 86400, true
	end

	return nil, false
end

local function buildPool(cnId: string, items)
	local gachaMethod2 = nil

	for _, item in items do
		local gachaMethod = item.row.gachaMethod

		if gachaMethod ~= "权重" and gachaMethod ~= "同等级同权重" then
			warn((`[GachaPool] 抽奖表 {cnId} 第 {item.index} 行 gachaMethod 非法（{tostring(gachaMethod)}），整个奖池已禁用`))
			return nil
		end

		if gachaMethod2 and gachaMethod ~= gachaMethod2 then
			warn((`[GachaPool] 抽奖表 {cnId} 混用了抽奖方式（{gachaMethod2} / {gachaMethod}），整个奖池已禁用`))
			return nil
		else
			gachaMethod2 = gachaMethod
		end
	end

	local v3 = gachaMethod2 == "同等级同权重"
	local weights = {}
	local v4 = {}
	local result = {}

	for _, item in items do
		local row = item.row
		local index = item.index
		local targets = normalizeTargets(row.targetId)
		local unlockDate = row.unlockDate
		local flag, unlockAt

		if unlockDate == nil or unlockDate == "" then
			flag = true
		else
			local configDateToDayKey = TimeService.configDateToDayKey(unlockDate)

			if configDateToDayKey then
				unlockAt = configDateToDayKey * 86400
				flag = true
			else
				flag = false
			end
		end

		local unlockCondition = row.unlockCondition or "x"
		local unlockCondition2 = unlockCondition == "" and "x" or unlockCondition
		local formatted = `抽奖表 {cnId} 第 {index} 行（{table.concat(targets, ",")}）`

		if unlockCondition2 == "x" or unlockCondition2 == "等级奖励获得" or unlockCondition2 == "购买新手礼包" then
			local weight = row.weight
			local v7

			if typeof(weight) == "number" and weight == weight and weight >= 0 then
				v7 = weight < 1e999
			else
				v7 = false
			end

			if v7 then
				if #targets == 0 then
					warn((`[GachaPool] {formatted} targetId 为空，已跳过`))
				elseif flag then
					local tierKey

					if v3 then
						if typeof(row.rating) ~= "number" then
							warn((`[GachaPool] {formatted} rating 非法（{tostring(row.rating)}），已跳过`))
							continue
						end

						local formatted2 = `{tostring(row.itemType)}:{row.rating}`
						local v9 = weights[formatted2]

						if v9 and v9 ~= row.weight then
							warn((`[GachaPool] 抽奖表 {cnId} 的 {tostring(row.itemType)} 品质 {row.rating} 拆成多行但 weight 不一致（{v9} / {row.weight}），整个奖池已禁用`))
							return nil
						else
							weights[formatted2] = row.weight
							tierKey = cnId .. ":" .. formatted2
						end
					end

					for _, target in targets do
						local v9 = {
							cnId = cnId,
							targetId = target,
							itemType = row.itemType,
							allowTrade = row.allowTrade,
							useCounter = row.useCounter,
							canFusion = row.canFusion,
							weight = row.weight,
							gachaMethod = gachaMethod2,
							unlockDate = row.unlockDate,
							unlockAt = unlockAt,
							unlockCondition = unlockCondition2,
							tierKey = tierKey
						}
						local definition = GachaPool.getDefinition(v9)

						if definition then
							if v3 and definition.rating ~= row.rating then
								warn((`[GachaPool] {formatted} 的 {target} 实际品质 {tostring(definition.rating)} 与行品质 {row.rating} 不符，已跳过`))
							else
								v9.rating = definition.rating
								local ownedKey = GachaPool.ownedKey(GachaPool.toEngineItemType(v9.itemType), target)

								if v3 and v4[ownedKey] then
									warn((`[GachaPool] 抽奖表 {cnId} 中 {target} 重复出现，整个奖池已禁用`))
									return nil
								else
									v4[ownedKey] = true
									table.insert(result, v9)
								end
							end
						else
							warn((`[GachaPool] {formatted} 的 {target}（{tostring(row.itemType)}）找不到对应物品配置，已跳过`))
						end
					end
				else
					warn((`[GachaPool] {formatted} unlockDate 无法解析（{tostring(row.unlockDate)}），已跳过`))
				end
			else
				warn((`[GachaPool] {formatted} weight 非法（{tostring(row.weight)}），已跳过`))
			end
		else
			warn((`[GachaPool] {formatted} unlockCondition 非法（{tostring(unlockCondition2)}），已跳过`))
		end
	end

	return result
end

local v2 = {}
local cnIds = {}
local pools = {}

for k, row in Config.gacha.list do
	local cnId = row.cnId

	if typeof(cnId) == "string" then
		if not v2[cnId] then
			v2[cnId] = {}
			table.insert(cnIds, cnId)
		end

		table.insert(v2[cnId], {
			index = k,
			row = row
		})
	else
		warn((`[GachaPool] 抽奖表第 {k} 行缺少 cnId，已跳过`))
	end
end

for _, v3 in cnIds do
	local pool = buildPool(v3, v2[v3])

	if pool and #pool > 0 then
		pools[v3] = pool
	end
end

local v3 = Config.crate.byCnId["金币小球箱子单抽"]
local v4 = v3 and pools[v3.gachaCnId]
local clones = {}

if v4 then
	for _, v5 in v4 do
		if not (v5.itemType == "小球" and v5.rating == 3 and v5.weight > 0) then
			continue
		end

		local clone = table.clone(v5)
		clone.cnId = "首充小球奖池"
		clone.weight = 1
		clone.gachaMethod = "同等级同权重"
		clone.tierKey = clone.cnId .. ":小球:" .. clone.targetId
		table.insert(clones, clone)
	end
else
	warn("[GachaPool] 首充小球奖池缺少金币小球箱子奖池配置")
end

if not (#clones > 0) then
	clones = nil
end

pools["首充小球奖池"] = clones

function GachaPool.getPool(p: string)
	return pools[p]
end

function GachaPool.getAllEntries()
	local v5 = {}

	for _, v6 in pools do
		table.move(v6, 1, #v6, #v5 + 1, v5)
	end

	return v5
end

local function effectiveWeights(list, callback)
	local v5 = table.create(#list)
	local v6 = {}

	for k, v7 in list do
		local v8 = not callback and 1 or callback(v7)
		local v9 = (typeof(v8) ~= "number" or v8 ~= v8 or v8 < 0 or v8 == 1e999) and 1 or v8
		v5[k] = v9

		if v7.tierKey then
			v6[v7.tierKey] = (v6[v7.tierKey] or 0) + v9
		end
	end

	local result = table.create(#list)

	for k, v7 in list do
		if v7.tierKey then
			local v8 = v6[v7.tierKey]
			result[k] = not (v8 > 0) and 0 or v7.weight * v5[k] / v8
		else
			result[k] = v7.weight * v5[k]
		end
	end

	return result
end

local function weightedPick(list, list2, object)
	local total = 0

	for _, v5 in list2 do
		total += v5
	end

	if total <= 0 then
		return nil
	end

	local number = object:NextNumber(0, total)
	local total2 = 0

	for k, v5 in list do
		total2 += list2[k]

		if list2[k] > 0 and number < total2 then
			return v5
		end
	end

	for i = #list, 1, -1 do
		if list2[i] > 0 then
			return list[i]
		end
	end

	return nil
end

function GachaPool.pick(items, p, data)
	local now = TimeService.now()
	local v5 = {}

	for _, item in items do
		if not (GachaPool.getLockReason(item, data and data.context, now) == nil and (not data or not data.filter or data.filter(item))) then
			continue
		end

		table.insert(v5, item)
	end

	if data and data.exclude then
		local v6 = {}

		for _, v7 in v5 do
			if data.exclude[GachaPool.ownedKey(GachaPool.toEngineItemType(v7.itemType), v7.targetId)] then
				continue
			end

			table.insert(v6, v7)
		end

		if #v6 > 0 then
			v5 = v6
		end
	end

	return (weightedPick(v5, effectiveWeights(v5, data and data.multiplier), p))
end

function GachaPool.getChances(p: string, p2)
	if p2 == nil and RunService:IsClient() then
		p2 = GachaPool.getPlayerContext()
	end

	local v5 = pools[p] or {}
	local now = TimeService.now()
	local v6 = {}

	for _, v7 in v5 do
		if GachaPool.getLockReason(v7, p2, now) == nil then
			table.insert(v6, v7)
		end
	end

	local v7 = {}

	for k, v8 in effectiveWeights(v6) do
		v7[v6[k]] = v8
	end

	local v8 = {}
	local total = 0
	local result = {}

	for _, row in v5 do
		local v10 = v7[row]
		local v11 = v10 == nil

		if not (row.weight > 0) then
			continue
		end

		local v12 = row.itemType .. ":" .. row.targetId
		local v13 = v8[v12]

		if v13 then
			if v11 and v13.unlockAt and row.unlockAt then
				v13.unlockAt = math.min(v13.unlockAt, row.unlockAt)
			end
		else
			v13 = {
				row = row,
				definition = GachaPool.getDefinition(row),
				weight = 0,
				tradable = row.allowTrade == true,
				key = v12,
				unlockAt = 0,
				lockReason = 0
			}
			local unlockAt

			if not GachaPool.isUnlocked(row, now) then
				unlockAt = row.unlockAt
			end

			v13.unlockAt = unlockAt
			v13.lockReason = GachaPool.getLockReason(row, p2, now)
			v8[v12] = v13
			table.insert(result, v13)
		end

		if not v11 then
			v13.unlockAt = nil
			v13.lockReason = nil
			v13.weight += v10
			total += v10
		end

		v13.tradable = v13.tradable and row.allowTrade == true
	end

	return result, total
end

return GachaPool