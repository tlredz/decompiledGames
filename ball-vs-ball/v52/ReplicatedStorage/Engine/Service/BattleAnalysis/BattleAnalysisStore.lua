local DataStoreService = game:GetService("DataStoreService")
local BattleAnalysisTypes = require(script.Parent.BattleAnalysisTypes)
local BattleAnalysisStore = {}
local v = {
	displayName = true,
	displayNameCN = true,
	templateName = true,
	assetName = true,
	color = true,
	highlightColor = true,
	name = true
}
local v2 = nil
local flag = false
local v3 = true

local function getDatastore()
	if flag then
		return v2
	end

	flag = true
	local success, result = pcall(function()
		return DataStoreService:GetDataStore("BattleAnalysisV1")
	end)

	if success then
		v2 = result
	else
		warn("[对局分析] DataStore 不可用，降级为纯内存模式：", result)
		v2 = nil
	end

	return v2
end

function BattleAnalysisStore.isPersistent()
	if flag then
		return v2 ~= nil
	end

	flag = true
	local success, result = pcall(function()
		return DataStoreService:GetDataStore("BattleAnalysisV1")
	end)

	if success then
		v2 = result
	else
		warn("[对局分析] DataStore 不可用，降级为纯内存模式：", result)
		v2 = nil
	end

	return v2 ~= nil
end

local serializeValue

serializeValue = function(items, p: number)
	local typeName = typeof(items)

	if typeName == "number" then
		return string.format("%.6g", items)
	elseif typeName == "string" then
		return items
	end

	if typeName == "boolean" then
		if items then
			return "T"
		end

		return "F"
	else
		if typeName ~= "table" or not (p < 6) then
			return nil
		end

		local v4 = {}

		for k in items do
			if typeof(k) == "string" and not v[k] then
				table.insert(v4, k)
			elseif typeof(k) == "number" then
				table.insert(v4, k)
			end
		end

		table.sort(v4, function(a, b)
			return tostring(a) < tostring(b)
		end)
		local v5 = {}

		for _, v6 in ipairs(v4) do
			local v7 = serializeValue(items[v6], p + 1)

			if v7 ~= nil then
				table.insert(v5, tostring(v6) .. "=" .. v7)
			end
		end

		return "{" .. table.concat(v5, ";") .. "}"
	end
end

local function serializeBattleConfig(data)
	local v4 = {}
	local v5 = {}
	local v6 = {}

	for _, v7 in ipairs(data.battle.analyzeRolePool) do
		if not data.roles[v7] or v4[v7] then
			continue
		end

		v4[v7] = true
		table.insert(v5, v7)
	end

	table.sort(v5)

	for _, v7 in ipairs(v5) do
		local role = data.roles[v7]
		table.insert(v6, string.format("role:%s=%s", v7, serializeValue({
			maxHp = role.maxHp,
			attack = role.attack,
			speed = role.speed,
			radius = role.radius,
			skill = role.skill
		}, 0) or ""))
	end

	table.insert(v6, "traits=" .. (serializeValue(data.traits, 0) or ""))
	table.insert(v6, "upgrade=" .. (serializeValue(data.tournament_upgrade, 0) or ""))
	table.insert(v6, string.format("contactCooldown=%.6g", data.battle.contactCooldown))
	table.insert(v6, string.format("fixedDt=%.9g", data.replay.fixedDt))
	table.insert(v6, string.format("maxDuration=%.6g", data.replay.maxDuration))
	table.insert(v6, string.format("arena=%.6gx%.6g", data.arena.size.X, data.arena.size.Y))
	return table.concat(v6, "\n")
end

local function fnv1a32(value: string)
	local v4 = 2166136261

	for i = 1, #value do
		local v5 = bit32.bxor(v4, string.byte(value, i))
		v4 = bit32.band(bit32.lshift(v5, 24) + bit32.lshift(v5, 8) + bit32.band(v5 * 147, 4294967295), 4294967295)
	end

	return v4
end

local function djb2(value: string)
	local v4 = 5381

	for i = 1, #value do
		v4 = bit32.band(v4 * 33 + string.byte(value, i), 4294967295)
	end

	return v4
end

function BattleAnalysisStore.computeVersionKey(p)
	local v4 = serializeBattleConfig(p)
	local v5 = fnv1a32(v4)
	local v6 = 5381

	for i = 1, #v4 do
		v6 = bit32.band(v6 * 33 + string.byte(v4, i), 4294967295)
	end

	return string.format("%08x%08x", v5, v6)
end

function BattleAnalysisStore.buildBallConfigSnapshot(p)
	local result = {}

	for _, roleId in ipairs(p.battle.analyzeRolePool) do
		local role = p.roles[roleId]

		if role then
			result[roleId] = {
				roleId = roleId,
				displayName = role.displayName,
				displayNameCN = role.displayNameCN,
				maxHp = role.maxHp,
				attack = role.attack,
				speed = role.speed,
				traitName = role.skill and role.skill.trigger
			}
		end
	end

	return result
end

local function newAggregate(versionKey: string, ballConfigSnapshot)
	return {
		versionKey = versionKey,
		startedAt = os.time(),
		ballConfigSnapshot = ballConfigSnapshot,
		pairs = {}
	}
end

local function normalizeAggregate(data, versionKey: string, ballConfigSnapshot)
	if typeof(data) ~= "table" or typeof(data.pairs) ~= "table" then
		return (newAggregate(versionKey, ballConfigSnapshot))
	end

	local pairs = {}

	for k, pair in data.pairs do
		if typeof(k) == "string" then
			pairs[k] = BattleAnalysisTypes.normalizePairStat(pair)
		end
	end

	if typeof(data.versionKey) == "string" then
		versionKey = data.versionKey
	end

	local startedAt

	if typeof(data.startedAt) == "number" then
		startedAt = data.startedAt
	else
		startedAt = os.time()
	end

	if typeof(data.ballConfigSnapshot) == "table" then
		ballConfigSnapshot = data.ballConfigSnapshot
	end

	return {
		versionKey = versionKey,
		startedAt = startedAt,
		ballConfigSnapshot = ballConfigSnapshot,
		pairs = pairs
	}
end

function BattleAnalysisStore.totalMatches(p)
	local total = 0

	for _, pair in p.pairs do
		total += pair.matches
	end

	return total
end

local function normalizeMeta(data, currentVersionKey: string)
	if typeof(data) ~= "table" then
		return {
			currentVersionKey = currentVersionKey,
			currentStartedAt = os.time(),
			archives = {}
		}
	end

	local archives = {}

	if typeof(data.archives) == "table" then
		for _, archive in ipairs(data.archives) do
			if not (typeof(archive) == "table" and typeof(archive.dataKey) == "string") then
				continue
			end

			table.insert(archives, {
				versionKey = tostring(archive.versionKey),
				archivedAt = typeof(archive.archivedAt) ~= "number" and 0 or archive.archivedAt,
				dataKey = archive.dataKey,
				matches = typeof(archive.matches) ~= "number" and 0 or archive.matches
			})
		end
	end

	if typeof(data.currentVersionKey) == "string" then
		currentVersionKey = data.currentVersionKey
	end

	local currentStartedAt

	if typeof(data.currentStartedAt) == "number" then
		currentStartedAt = data.currentStartedAt
	else
		currentStartedAt = os.time()
	end

	return {
		currentVersionKey = currentVersionKey,
		currentStartedAt = currentStartedAt,
		archives = archives
	}
end

local function safeGet(p: string)
	if not flag then
		flag = true
		local success, result = pcall(function()
			return DataStoreService:GetDataStore("BattleAnalysisV1")
		end)

		if success then
			v2 = result
		else
			warn("[对局分析] DataStore 不可用，降级为纯内存模式：", result)
			v2 = nil
		end
	end

	local v4 = v2

	if not v4 then
		return false, nil
	end

	local success, result = pcall(function()
		return v4:GetAsync(p)
	end)

	if success then
		return true, result
	end

	warn(string.format("[对局分析] 读取 %s 失败：%s", p, (tostring(result))))
	return false, nil
end

local function safeSet(p: string, p2)
	if not flag then
		flag = true
		local success, result = pcall(function()
			return DataStoreService:GetDataStore("BattleAnalysisV1")
		end)

		if success then
			v2 = result
		else
			warn("[对局分析] DataStore 不可用，降级为纯内存模式：", result)
			v2 = nil
		end
	end

	local v4 = v2

	if not v4 then
		return false
	end

	local success, result = pcall(function()
		v4:SetAsync(p, p2)
	end)

	if not success then
		warn(string.format("[对局分析] 写入 %s 失败：%s", p, (tostring(result))))
	end

	return success
end

local function safeRemove(p: string)
	if not flag then
		flag = true
		local success, result = pcall(function()
			return DataStoreService:GetDataStore("BattleAnalysisV1")
		end)

		if success then
			v2 = result
		else
			warn("[对局分析] DataStore 不可用，降级为纯内存模式：", result)
			v2 = nil
		end
	end

	local v4 = v2

	if not v4 then
		return false
	end

	local success, result = pcall(function()
		v4:RemoveAsync(p)
	end)

	if not success then
		warn(string.format("[对局分析] 删除 %s 失败：%s", p, (tostring(result))))
	end

	return success
end

local count = 0

local function archiveCurrent(meta, p, p2: string)
	local totalMatches = BattleAnalysisStore.totalMatches(p)

	if totalMatches <= 0 then
		return meta.archives
	end

	local versionKey = tostring(p.versionKey)
	count += 1
	local dataKey = string.format("archive_%s_%d_%d", string.sub(versionKey, 1, 8), os.time(), count % 1000)

	if not safeSet(dataKey, p) then
		warn("[对局分析] 归档写入失败，旧数据将被丢弃")
		return meta.archives
	end

	table.insert(meta.archives, {
		versionKey = versionKey,
		archivedAt = os.time(),
		dataKey = dataKey,
		matches = totalMatches
	})

	while #meta.archives > 10 do
		local v5 = table.remove(meta.archives, 1)

		if not v5 then
			continue
		end

		safeRemove(v5.dataKey)
		print(string.format("[对局分析] 存档已满 %d 份，淘汰最旧存档：%s", 10, v5.dataKey))
	end

	print(string.format("[对局分析] %s，已归档 %d 场样本 → %s", p2, totalMatches, dataKey))
	return meta.archives
end

function BattleAnalysisStore.load(currentVersionKey: string, ballConfigSnapshot)
	local v4, v5 = safeGet("meta")
	local v6, v7 = safeGet("current")

	if not v4 and BattleAnalysisStore.isPersistent() then
		v3 = false
		warn("[对局分析] meta 读取失败，本会话不再回写 meta，避免覆盖存档索引（重启 Play 后恢复）")
	end

	local meta = normalizeMeta(v5, currentVersionKey)
	local aggregate = normalizeAggregate(v7, currentVersionKey, ballConfigSnapshot)

	if aggregate.versionKey == currentVersionKey or not (v6 and v3) then
		if aggregate.versionKey == currentVersionKey then
			aggregate.ballConfigSnapshot = ballConfigSnapshot

			if meta.currentVersionKey ~= currentVersionKey and v3 then
				meta.currentVersionKey = currentVersionKey
				meta.currentStartedAt = aggregate.startedAt
				safeSet("meta", meta)
			end
		else
			warn("[对局分析] 版本不符但 DataStore 读取不可信，本次跳过自动归档")
			aggregate = newAggregate(currentVersionKey, ballConfigSnapshot)
		end
	else
		meta.archives = archiveCurrent(meta, aggregate, "配置版本变化")
		aggregate = newAggregate(currentVersionKey, ballConfigSnapshot)
		meta.currentVersionKey = currentVersionKey
		meta.currentStartedAt = aggregate.startedAt
		safeSet("current", aggregate)
		safeSet("meta", meta)
	end

	return aggregate, meta
end

function BattleAnalysisStore.flush(p: string, ballConfigSnapshot, items)
	if not flag then
		flag = true
		local success, result = pcall(function()
			return DataStoreService:GetDataStore("BattleAnalysisV1")
		end)

		if success then
			v2 = result
		else
			warn("[对局分析] DataStore 不可用，降级为纯内存模式：", result)
			v2 = nil
		end
	end

	local v4 = v2

	if not v4 then
		return nil
	end

	local v5 = nil
	local success, result = pcall(function()
		v4:UpdateAsync("current", function(p2)
			local aggregate = normalizeAggregate(p2, p, ballConfigSnapshot)

			if aggregate.versionKey ~= p then
				warn(string.format("[对局分析] flush 时发现存档版本 %s 与当前 %s 不符，以当前版本重建", tostring(aggregate.versionKey), p))
				aggregate = newAggregate(p, ballConfigSnapshot)
			end

			for k, item in items do
				local pair = aggregate.pairs[k]

				if not pair then
					pair = BattleAnalysisTypes.newPairStat()
					aggregate.pairs[k] = pair
				end

				BattleAnalysisTypes.mergePairStat(pair, item)
			end

			aggregate.ballConfigSnapshot = ballConfigSnapshot
			v5 = aggregate
			return aggregate
		end)
	end)

	if success then
		return v5
	end

	warn("[对局分析] flush 失败，增量保留到下次重试：", (tostring(result)))
	return nil
end

function BattleAnalysisStore.archiveNow(p, currentVersionKey: string, ballConfigSnapshot)
	local v4, v5 = safeGet("meta")

	if not (v4 and v3) then
		warn("[对局分析] meta 不可读，本次归档已取消（数据未动），稍后重试")
		return p, normalizeMeta(v5, currentVersionKey), false
	end

	local meta = normalizeMeta(v5, currentVersionKey)
	meta.archives = archiveCurrent(meta, p, "手动归档")
	local v6 = newAggregate(currentVersionKey, ballConfigSnapshot)
	meta.currentVersionKey = currentVersionKey
	meta.currentStartedAt = v6.startedAt
	safeSet("current", v6)
	safeSet("meta", meta)
	return v6, meta, true
end

function BattleAnalysisStore.loadMeta(p: string)
	local _, v4 = safeGet("meta")
	return (normalizeMeta(v4, p))
end

function BattleAnalysisStore.loadArchive(p: string)
	local v4, v5 = safeGet(p)

	if v4 and typeof(v5) == "table" then
		return (normalizeAggregate(v5, tostring(v5.versionKey), v5.ballConfigSnapshot))
	end

	return nil
end

function BattleAnalysisStore.deleteArchive(p: string, p2: string)
	if not flag then
		flag = true
		local success, result = pcall(function()
			return DataStoreService:GetDataStore("BattleAnalysisV1")
		end)

		if success then
			v2 = result
		else
			warn("[对局分析] DataStore 不可用，降级为纯内存模式：", result)
			v2 = nil
		end
	end

	local v4 = v2

	if not v4 then
		return false
	end

	safeRemove(p)
	local success, result = pcall(function()
		v4:UpdateAsync("meta", function(p3)
			local meta = normalizeMeta(p3, p2)

			for i = #meta.archives, 1, -1 do
				if meta.archives[i].dataKey == p then
					table.remove(meta.archives, i)
				end
			end

			return meta
		end)
	end)

	if not success then
		warn("[对局分析] 删除存档后更新 meta 失败：", (tostring(result)))
	end

	return success
end

BattleAnalysisStore.MAX_ARCHIVES = 10
BattleAnalysisStore.STORE_NAME = "BattleAnalysisV1"
return BattleAnalysisStore