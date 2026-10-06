local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage.Packages.Net)
local PlayerData = require(script.Parent.PlayerData)
local TimeService = require(script.Parent.TimeService)
local EmoteWheelLoadoutService = require(script.Parent.EmoteWheelLoadoutService)
local AuditService = require(script.Parent.AuditService)
local BallCopySelection = require(script.Parent.BallCopySelection)
local v = {
	Ball = true,
	["爆炸特效"] = true,
	["飞行器"] = true
}
local remoteFunction = Net:RemoteFunction("ItemEquipRequest")

local function referencedItemId(value)
	if typeof(value) == "string" then
		return value
	end

	if typeof(value) == "table" and value.kind == "flyer" and typeof(value.id) == "string" then
		return value.id
	end

	return nil
end

local dataStore

if RunService:IsServer() then
	dataStore = DataStoreService:GetDataStore("ItemSerialCounter")
else
	dataStore = nil
end

local SerialRegistryService = require(script.Parent.SerialRegistryService)

-- equivalent calls inferred from this helper; original call sites unknown
local function serialCounterKey(p: string)
	return SerialRegistryService.counterKey(p)
end

local function allocateSerialRange(p: string, p2: number, p3: number)
	local v2 = serialCounterKey(p) -- equivalent call inferred; original call site unknown
	local v3 = 1

	for i = 1, p3 do
		local success, result = pcall(function()
			return dataStore:UpdateAsync(v2, function(value)
				return (value or 0) + p2
			end)
		end)

		if success and typeof(result) == "number" then
			return result - p2 + 1
		end

		warn(string.format("[ItemService] 分配唯一编号失败(%s x%d，第%d/%d次): %s", p, p2, i, p3, (tostring(result))))

		if not (i < p3) then
			continue
		end

		task.wait(v3)
		v3 *= 2
	end

	return nil
end

local function allocateSerial(p: string)
	return (allocateSerialRange(p, 1, 5))
end

local function autoEquipAcquiredSkins(p, list)
	assert(RunService:IsServer(), "ItemService.autoEquipAcquiredSkins 只能在服务器调用")
	local Config = require(script.Parent.Config)
	local v2 = PlayerData.server[p]
	local items = v2.items()
	local v3 = {}

	for _, v4 in ipairs(list) do
		v3[v4] = true
	end

	local v4 = {}

	for k, item in items do
		if v3[k] or typeof(item) ~= "table" or item.ownerUserId ~= p.UserId or not (item.itemType == "飞行器" or item.itemType == "爆炸特效") then
			continue
		end

		v4[item.itemType] = v4[item.itemType] or {}
		v4[item.itemType][item.itemId] = true
	end

	local flag = false
	v2.equipment(function(p2)
		local result = typeof(p2) ~= "table" and {} or table.clone(p2)

		for _, v5 in ipairs(list) do
			local item = items[v5]

			if not (typeof(item) == "table" and item.ownerUserId == p.UserId and (item.itemType == "飞行器" or item.itemType == "爆炸特效")) then
				continue
			end

			if next(item.locks or {}) ~= nil then
				continue
			end

			local v6 = v4[item.itemType] or {}
			v4[item.itemType] = v6

			if v6[item.itemId] then
				continue
			end

			v6[item.itemId] = true
			local v7 = Config.skin.byCnId[item.itemId]

			if not (v7 and v7.skinType == item.itemType and typeof(v7.rating) == "number") then
				continue
			end

			local v8 = result[item.itemType]
			local v9

			if typeof(v8) == "string" then
				v9 = items[v8]
			end

			local v10

			if typeof(v9) == "table" and v9.ownerUserId == p.UserId then
				v10 = v9.itemType == item.itemType
			else
				v10 = false
			end

			local v11

			if v10 then
				v11 = Config.skin.byCnId[v9.itemId]
			end

			local v12 = not v10

			if not v12 then
				if v11 == nil or v11.skinType ~= item.itemType or typeof(v11.rating) ~= "number" then
					v12 = false
				else
					v12 = v7.rating >= v11.rating
				end
			end

			if not (v12 and v8 ~= v5) then
				continue
			end

			result[item.itemType] = v5
			flag = true
		end

		if flag then
			return result
		end

		return p2
	end)
	return flag
end

local function hasPendingSerialLock(p)
	return typeof(p) == "table" and typeof(p.locks) == "table" and p.locks.serialPending ~= nil
end

local v2 = {}

local function assignPendingSerials(p, list, p2: number)
	local result = {}
	local v3 = PlayerData.server[p]

	if not v3 then
		return result
	end

	local items = v3.items()
	local v4 = {}
	local v5 = {}
	local itemIds = {}

	for _, v6 in ipairs(list) do
		local item = items[v6]

		if v2[v6] then
			continue
		end

		local v7

		if typeof(item) == "table" and typeof(item.locks) == "table" then
			v7 = item.locks.serialPending ~= nil
		else
			v7 = false
		end

		if not (v7 and item.serial == nil) then
			continue
		end

		v2[v6] = true
		table.insert(v4, v6)
		local v8 = v5[item.itemId]

		if not v8 then
			v8 = {}
			v5[item.itemId] = v8
			table.insert(itemIds, item.itemId)
		end

		table.insert(v8, v6)
	end

	local success, result2 = pcall(function()
		for _, v6 in ipairs(itemIds) do
			if not PlayerData.server[p] then
				break
			end

			local v7 = v5[v6]
			local v8 = allocateSerialRange(v6, #v7, p2)

			if not v8 then
				continue
			end

			local v9 = {}

			for i, v10 in ipairs(v7) do
				v9[v10] = v8 + i - 1
			end

			local v10 = PlayerData.server[p]

			if v10 then
				local v11 = v9
				v10.items(function(p3)
					local clones = nil

					for k, serial in v11 do
						local v13 = p3[k]
						local v14

						if typeof(v13) == "table" and typeof(v13.locks) == "table" then
							v14 = v13.locks.serialPending ~= nil
						else
							v14 = false
						end

						if not (v14 and v13.serial == nil) then
							continue
						end

						clones = clones or table.clone(p3)
						local clone = table.clone(v13)
						clone.locks = table.clone(v13.locks)
						clone.locks.serialPending = nil
						clone.serial = serial
						local itemId = v13.itemId
						clone.serialKey = SerialRegistryService.counterKey(itemId)
						clones[k] = clone
						result[k] = serial
					end

					return clones or p3
				end)
			end

			for k, v11 in v9 do
				if result[k] == nil then
					warn(string.format("[ItemService] 编号 %s #%d 已申请但未写入（物品 %s），该号作废", v6, v11, k))
				end
			end

			local v11 = PlayerData.server[p]

			if not v11 then
				continue
			end

			local items2 = v11.items()

			for k in v9 do
				if result[k] ~= nil then
					SerialRegistryService.mint(p, items2[k])
				end
			end
		end
	end)

	for _, v6 in ipairs(v4) do
		v2[v6] = nil
	end

	if not success then
		warn("[ItemService] 补发编号异常: " .. tostring(result2))
	end

	return result
end

local function collectPendingSerialIds(p)
	local result = {}
	local v3 = PlayerData.server[p]

	if not v3 then
		return result
	end

	local items = v3.items()

	for k, item in items do
		local v4

		if typeof(item) == "table" and typeof(item.locks) == "table" then
			v4 = item.locks.serialPending ~= nil
		else
			v4 = false
		end

		if v4 and item.serial == nil then
			table.insert(result, k)
		end
	end

	table.sort(result, function(a, b)
		local obtainedAt = tonumber(items[a].obtainedAt) or 0
		local obtainedAt2 = tonumber(items[b].obtainedAt) or 0

		if obtainedAt == obtainedAt2 then
			return a < b
		end

		return obtainedAt < obtainedAt2
	end)
	return result
end

local v3 = {}

local function scheduleSerialBackfill(p, p2: number)
	if v3[p] then
		return
	end

	v3[p] = true
	task.spawn(function()
		local v4 = p2

		for _ = 1, 10 do
			if v4 > 0 then
				task.wait(v4)
			end

			v4 = 30

			if p.Parent ~= Players or not PlayerData.server[p] then
				break
			end

			local v5 = collectPendingSerialIds(p)

			if #v5 == 0 then
				break
			end

			local granted = assignPendingSerials(p, v5, 1)

			if next(granted) == nil then
				continue
			end

			local count = 0

			for _ in granted do
				count += 1
			end

			print(string.format("[ItemService] 玩家 %d 补发编号 %d 个，剩余待补 %d 个", p.UserId, count, #v5 - count))
			AuditService.record(p, {
				assetType = "item",
				action = "serial_backfill",
				source = "补发编号",
				operationId = "item:serialBackfill:" .. HttpService:GenerateGUID(false),
				at = TimeService.now(),
				granted = granted
			})
		end

		v3[p] = nil
	end)
end

local function canTrade(p, p2: string, p3: string?)
	local v4 = PlayerData.server[p].items[p2]()

	if typeof(v4) ~= "table" or v4.ownerUserId ~= p.UserId or not v[v4.itemType] or v4.tradable ~= true then
		return false
	end

	local locks = v4.locks or {}

	if not p3 then
		return next(locks) == nil
	end

	if locks.trade ~= p3 then
		return false
	end

	for k in locks do
		if k ~= "trade" then
			return false
		end
	end

	return true
end

local function findKillTrackedItem(p, p2: string, p3: string)
	local items = PlayerData.server[p].items()

	if p2 == "Ball" then
		local resolved = BallCopySelection.resolve(items, PlayerData.server[p].equipment(), p3)
		local v4 = resolved and items[resolved]
		local killCount

		if v4 then
			if typeof(v4.metadata) == "table" then
				killCount = v4.metadata.killCount
			else
				killCount = false
			end
		else
			killCount = v4
		end

		if v4 and BallCopySelection.available(v4) and typeof(killCount) == "number" then
			return resolved, killCount
		end

		return nil, nil
	else
		local v4 = -1
		local v5 = 1e999
		local v6 = nil

		for k, v7 in items or {} do
			local killCount

			if typeof(v7.metadata) == "table" then
				killCount = v7.metadata.killCount
			end

			if not (v7.itemType == p2 and v7.itemId == p3 and typeof(killCount) == "number") then
				continue
			end

			local v8 = typeof(v7.obtainedAt) ~= "number" and 1e999 or v7.obtainedAt

			if not (v4 < killCount or killCount == v4 and v8 < v5) then
				continue
			end

			v6 = k
			v5 = v8
			v4 = killCount
		end

		if v6 then
			return v6, v4
		end

		return v6, nil
	end
end

local function equip(p, value: string, value2: string?, value3: string?)
	assert(RunService:IsServer(), "ItemService.equip 只能在服务器调用")
	local v4

	if value2 ~= nil then
		v4 = PlayerData.server[p].items()[value2]
	end

	if value2 ~= nil and (not v4 or v4.ownerUserId ~= p.UserId or v4.itemType ~= value or next(v4.locks or {}) ~= nil) then
		return false
	end

	local v5 = value3 or value

	if value == "Ball" then
		if not v4 then
			return false
		end

		v5 = BallCopySelection.slotKey(v4.itemId)
	elseif string.sub(v5, 1, 9) == "BallCopy:" then
		return false
	end

	PlayerData.server[p].equipment(function(p2)
		local selected = typeof(p2) ~= "table" and {} or table.clone(p2)
		selected[v5] = value2
		return selected
	end)
	return true
end

if RunService:IsServer() then
	remoteFunction.OnServerInvoke = function(p, value: string, value2: string?, value3: string?)
		if typeof(value) ~= "string" or value2 ~= nil and typeof(value2) ~= "string" or value3 ~= nil and typeof(value3) ~= "string" then
			return false
		end

		return not (value3 and string.match(value3, "^表情轮盘_")) and equip(p, value, value2, value3)
	end

	local function onPlayerAdded(p)
		task.spawn(function()
			PlayerData.server.Service:waitForData(p)

			if p.Parent == Players then
				local v4 = p

				if v3[v4] then
					return
				end

				v3[v4] = true
				local v5 = 0
				task.spawn(function()
					local v6 = v5

					for _ = 1, 10 do
						if v6 > 0 then
							task.wait(v6)
						end

						v6 = 30

						if v4.Parent ~= Players or not PlayerData.server[v4] then
							break
						end

						local v7 = collectPendingSerialIds(v4)

						if #v7 == 0 then
							break
						end

						local granted = assignPendingSerials(v4, v7, 1)

						if next(granted) == nil then
							continue
						end

						local count = 0

						for _ in granted do
							count += 1
						end

						print(string.format("[ItemService] 玩家 %d 补发编号 %d 个，剩余待补 %d 个", v4.UserId, count, #v7 - count))
						AuditService.record(v4, {
							assetType = "item",
							action = "serial_backfill",
							source = "补发编号",
							operationId = "item:serialBackfill:" .. HttpService:GenerateGUID(false),
							at = TimeService.now(),
							granted = granted
						})
					end

					v3[v4] = nil
				end)
			end
		end)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)

	for _, v4 in Players:GetPlayers() do
		local v5 = v4
		task.spawn(function()
			PlayerData.server.Service:waitForData(v5)

			if v5.Parent == Players then
				local v6 = v5

				if v3[v6] then
					return
				end

				v3[v6] = true
				local v7 = 0
				task.spawn(function()
					local v8 = v7

					for i = 1, 10 do
						if v8 > 0 then
							task.wait(v8)
						end

						v8 = 30

						if v6.Parent ~= Players or not PlayerData.server[v6] then
							break
						end

						local v9 = collectPendingSerialIds(v6)

						if #v9 == 0 then
							break
						end

						local granted = assignPendingSerials(v6, v9, 1)

						if next(granted) == nil then
							continue
						end

						local count = 0

						for k in granted do
							count += 1
						end

						print(string.format("[ItemService] 玩家 %d 补发编号 %d 个，剩余待补 %d 个", v6.UserId, count, #v9 - count))
						AuditService.record(v6, {
							assetType = "item",
							action = "serial_backfill",
							source = "补发编号",
							operationId = "item:serialBackfill:" .. HttpService:GenerateGUID(false),
							at = TimeService.now(),
							granted = granted
						})
					end

					v3[v6] = nil
				end)
			end
		end)
	end
end

local v4 = {}
local GameFlags = require(ReplicatedStorage.GameFlags)
local v5 = GameFlags.feature["小球合成"] == true
local validate

if v5 then
	local BallUpgradeRules = require(script.Parent.BallUpgradeRules)
	validate = BallUpgradeRules.validate
else
	validate = nil
end

local function performBallUpgrade(p, p2, p3)
	if not validate then
		return {
			ok = false,
			reason = "feature_disabled"
		}
	end

	if p.Parent == nil then
		return {
			ok = false,
			reason = "player_left"
		}
	end

	local profile = PlayerData.server.Service:getProfile(p)

	if not profile then
		return {
			ok = false,
			reason = "data_unavailable"
		}
	end

	local v6 = PlayerData.server[p]
	local v7, reason = validate(v6.items(), p.UserId, p2, p3)

	if not v7 then
		return {
			ok = false,
			reason = reason
		}
	end

	local clone = table.clone(p3)
	local serial

	if v7.feature == "serial" then
		serial = allocateSerialRange(v7.main.itemId, 1, 5)

		if serial == nil then
			return {
				ok = false,
				reason = "serial_unavailable"
			}
		end
	else
		serial = nil
	end

	if p.Parent == nil or PlayerData.server.Service:getProfile(p) ~= profile then
		return {
			ok = false,
			reason = "player_left"
		}
	end

	local v10 = v7.main.itemId .. "_" .. HttpService:GenerateGUID(false)
	local v11 = nil
	local consumed = nil
	local materials = {}
	local now = TimeService.now()
	local success, result = pcall(function()
		v6.items(function(p4)
			local v13, v14 = validate(p4, p.UserId, p2, clone)

			if not v13 then
				reason = v14
				return p4
			end

			if v13.main.itemId ~= v7.main.itemId or v13.feature ~= v7.feature or v13.main.serial ~= v7.main.serial then
				reason = "stale"
				return p4
			end

			local clone2 = table.clone(v13.main)
			clone2.instanceId = v10
			clone2.ownerUserId = p.UserId
			clone2.obtainedAt = now
			clone2.source = "小球功能升级"
			clone2.tradable = v13.tradable
			clone2.locks = {}
			clone2.serial = serial
			clone2.metadata = table.clone(v13.main.metadata or {})
			clone2.metadata.killCount = v13.feature == "killTracking" and 0 or v13.killCount
			clone2.killCount = nil
			local v15 = {}

			for k in v13.consumed do
				table.insert(v15, p4[k])
			end

			if v13.feature == "killTracking" then
				clone2.metadata.origin = SerialRegistryService.originOf(p.UserId, now, v15)
			else
				local itemId = v7.main.itemId
				clone2.serialKey = SerialRegistryService.counterKey(itemId)
				clone2.metadata.origin = {
					at = now,
					by = p.UserId,
					via = "合成"
				}
				clone2.metadata.registryTrade = nil
				clone2.metadata.registryVerified = nil
				clone2.metadata.registryFailed = nil
				materials = {}

				for _, v16 in v15 do
					table.insert(materials, SerialRegistryService.materialDetail(v16))
				end
			end

			local clone3 = table.clone(p4)

			for k in v13.consumed do
				clone3[k] = nil
			end

			clone3[v10] = clone2
			consumed = v13.consumed
			v11 = {
				ok = true,
				instanceId = v10,
				unlockedFeature = v13.feature,
				killCount = clone2.metadata.killCount,
				serial = serial,
				tradable = clone2.tradable
			}
			return clone3
		end)
	end)

	if v6.items()[v10] ~= nil then
		if not success then
			warn("[BallUpgrade] 库存已提交，通知异常: " .. tostring(result))
		end

		local success2, result2 = pcall(function()
			v6.equipment(function(options)
				local clone2 = table.clone(options or {})

				for k, id in clone2 do
					if typeof(id) ~= "string" then
						if typeof(id) == "table" and id.kind == "flyer" and typeof(id.id) == "string" then
							id = id.id
						else
							id = nil
						end
					end

					if id == p2 then
						clone2[k] = v10
					elseif id and consumed[id] then
						clone2[k] = nil
					end
				end

				return clone2
			end)
		end)

		if not success2 then
			warn("[BallUpgrade] 装备引用更新异常: " .. tostring(result2))
		end

		local consumed2 = { p2 }

		for _, v14 in clone do
			table.insert(consumed2, v14)
		end

		local success3, result3 = pcall(AuditService.record, p, {
			assetType = "item",
			source = "小球功能升级",
			operationId = "item:ballUpgrade:" .. v10,
			at = now,
			action = "ball_upgrade",
			consumed = consumed2,
			granted = v10,
			itemType = "Ball",
			itemId = v7.main.itemId,
			unlockedFeature = v7.feature
		})

		if not success3 then
			warn("[BallUpgrade] 流水记录异常: " .. tostring(result3))
		end

		if v7.feature == "serial" and serial then
			SerialRegistryService.mint(p, v6.items()[v10], {
				via = "合成",
				materials = materials
			})
		end

		if v7.feature == "serial" and serial then
			local success4, result4 = pcall(function()
				local FusionAnnouncementService = require(script.Parent.FusionAnnouncementService)
				FusionAnnouncementService.enqueue(p, v7.main.itemId, serial)
			end)

			if not success4 then
				warn("[FusionAnnouncement] Enqueue failed: " .. tostring(result4))
			end
		end

		return v11
	else
		if not success then
			warn("[BallUpgrade] 库存提交失败: " .. tostring(result))
		end

		return {
			ok = false,
			reason = success and (reason or "stale") or "error"
		}
	end
end

return {
	server = {
		autoEquipAcquiredSkins = autoEquipAcquiredSkins,
		grant = function(p, itemType: string, itemId: string, data)
			assert(RunService:IsServer(), "ItemService.grant 只能在服务器调用")
			local v4 = itemId .. "_" .. HttpService:GenerateGUID(false)
			local v5

			if data == nil then
				v5 = false
			else
				v5 = data.useCounter == true
			end

			local metadata = {
				tradeCount = 0,
				lastTradedAt = nil
			}

			if data and data.killTracking == true then
				metadata.killCount = 0
			end

			local v7 = {
				instanceId = v4,
				ownerUserId = p.UserId,
				itemType = itemType,
				itemId = itemId,
				tradable = not data or data.tradable ~= false,
				source = not (data and data.source) and "未知来源" or data.source,
				canFusion = data ~= nil and data.canFusion == true,
				sourceCrateCnId = 0,
				obtainedAt = 0,
				locks = 0,
				metadata = 0,
				serial = nil
			}
			local sourceCrateCnId

			if data and typeof(data.sourceCrateCnId) == "string" then
				sourceCrateCnId = data.sourceCrateCnId
			end

			v7.sourceCrateCnId = sourceCrateCnId
			v7.obtainedAt = TimeService.now()
			v7.locks = v5 and {
				serialPending = "pending"
			} or {}
			v7.metadata = metadata
			PlayerData.server[p].items[v4](v7)
			local record = AuditService.record
			local operationId

			if data and data.transactionId then
				operationId = data.transactionId
			else
				operationId = "item:grant:" .. HttpService:GenerateGUID(false)
			end

			record(p, {
				assetType = "item",
				operationId = operationId,
				at = v7.obtainedAt,
				action = "grant",
				itemInstanceId = v4,
				itemType = itemType,
				itemId = itemId,
				toUserId = p.UserId,
				source = v7.source
			})
			local v12

			if v5 then
				v12 = assignPendingSerials(p, { v4 }, 3)[v4]

				if v12 == nil and not v3[p] then
					v3[p] = true
					local v13 = 30
					task.spawn(function()
						local v14 = v13

						for _ = 1, 10 do
							if v14 > 0 then
								task.wait(v14)
							end

							v14 = 30

							if p.Parent ~= Players or not PlayerData.server[p] then
								break
							end

							local v15 = collectPendingSerialIds(p)

							if #v15 == 0 then
								break
							end

							local granted = assignPendingSerials(p, v15, 1)

							if next(granted) == nil then
								continue
							end

							local count = 0

							for _ in granted do
								count += 1
							end

							print(string.format(
								"[ItemService] 玩家 %d 补发编号 %d 个，剩余待补 %d 个",
								p.UserId,
								count,
								#v15 - count
							))
							AuditService.record(p, {
								assetType = "item",
								action = "serial_backfill",
								source = "补发编号",
								operationId = "item:serialBackfill:" .. HttpService:GenerateGUID(false),
								at = TimeService.now(),
								granted = granted
							})
						end

						v3[p] = nil
					end)
				end

				if not PlayerData.server[p] then
					return v4, v12
				end
			end

			autoEquipAcquiredSkins(p, { v4 })

			if itemType == "飞行器" then
				EmoteWheelLoadoutService.server.autoEquipFlyer(p, v4)
			end

			return v4, v12
		end,
		purchaseBatch = function(p, list, p2: string, p3: string, p4: number, data)
			local source = not data and "商店购买" or data.source or "商店购买"
			local sku = data and data.sku or "开箱:" .. p2
			local channel = data and data.channel or "开箱"
			local CurrencyService = require(script.Parent.CurrencyService)
			PlayerData.server.Service:waitForData(p)
			local v5 = {}
			local v6 = {}
			local v7 = {}

			for _, v8 in ipairs(list) do
				local itemType = v8.itemType == "小球" and "Ball" or v8.itemType
				local instanceId = v8.targetId .. "_" .. HttpService:GenerateGUID(false)
				local useCounter = v8.useCounter == true
				v5[instanceId] = {
					instanceId = instanceId,
					ownerUserId = p.UserId,
					itemType = itemType,
					itemId = v8.targetId,
					tradable = v8.allowTrade ~= false,
					canFusion = v8.canFusion == true,
					source = source,
					sourceCrateCnId = p2,
					obtainedAt = TimeService.now(),
					locks = useCounter and {
						serialPending = "pending"
					} or {},
					metadata = {
						tradeCount = 0
					},
					serial = nil
				}

				if useCounter then
					table.insert(v6, instanceId)
				end

				table.insert(v7, {
					ok = true,
					cnId = v8.targetId,
					instanceId = instanceId,
					itemType = itemType,
					serial = nil,
					crateCnId = p2
				})
			end

			if p.Parent == nil then
				return {
					ok = false,
					reason = "player_left"
				}
			end

			if not CurrencyService.server.trySpend(p, p3, p4, {
				transactionType = Enum.AnalyticsEconomyTransactionType.Shop.Name,
				sku = sku,
				channel = channel,
				mode = "通用"
			}) then
				return {
					ok = false,
					reason = "insufficient"
				}
			end

			local v8 = false
			local success, result = pcall(function()
				PlayerData.server[p].items(function(p5)
					local clone = table.clone(p5)

					for k, v9 in v5 do
						clone[k] = v9
					end

					return clone
				end)
				v8 = true
			end)

			if not success then
				local items = PlayerData.server[p].items()
				v8 = true

				for k in v5 do
					if items[k] then
						continue
					end

					v8 = false
					break
				end

				if not v8 then
					CurrencyService.server.give(p, p3, p4)
					warn("[ItemService] 批量开箱失败，已退款: " .. tostring(result))
					return {
						ok = false,
						reason = "error"
					}
				end
			end

			if #v6 > 0 then
				local v9 = assignPendingSerials(p, v6, 3)
				local count = 0

				for _, v10 in ipairs(v6) do
					if v9[v10] == nil then
						count += 1
					end
				end

				for _, v10 in ipairs(v7) do
					v10.serial = v9[v10.instanceId]
				end

				if count > 0 then
					warn(string.format("[ItemService] 玩家 %d 本次开箱有 %d 件编号物品暂未拿到编号，已转后台补号", p.UserId, count))

					if not v3[p] then
						v3[p] = true
						local v10 = 30
						task.spawn(function()
							local v11 = v10

							for _ = 1, 10 do
								if v11 > 0 then
									task.wait(v11)
								end

								v11 = 30

								if p.Parent ~= Players or not PlayerData.server[p] then
									break
								end

								local v12 = collectPendingSerialIds(p)

								if #v12 == 0 then
									break
								end

								local granted = assignPendingSerials(p, v12, 1)

								if next(granted) == nil then
									continue
								end

								local count2 = 0

								for _ in granted do
									count2 += 1
								end

								print(string.format(
									"[ItemService] 玩家 %d 补发编号 %d 个，剩余待补 %d 个",
									p.UserId,
									count2,
									#v12 - count2
								))
								AuditService.record(p, {
									assetType = "item",
									action = "serial_backfill",
									source = "补发编号",
									operationId = "item:serialBackfill:" .. HttpService:GenerateGUID(false),
									at = TimeService.now(),
									granted = granted
								})
							end

							v3[p] = nil
						end)
					end
				end

				if not PlayerData.server[p] then
					return {
						ok = true,
						results = v7
					}
				end
			end

			AuditService.record(p, {
				assetType = "item",
				operationId = "item:gacha:" .. HttpService:GenerateGUID(false),
				at = TimeService.now(),
				action = "gacha",
				crateCnId = p2,
				granted = v7,
				count = #v7,
				source = source
			})
			local instanceIds = {}

			for _, v9 in ipairs(v7) do
				table.insert(instanceIds, v9.instanceId)
			end

			autoEquipAcquiredSkins(p, instanceIds)

			for _, v9 in ipairs(v7) do
				if v9.itemType == "飞行器" then
					EmoteWheelLoadoutService.server.autoEquipFlyer(p, v9.instanceId)
				end
			end

			return {
				ok = true,
				results = v7
			}
		end,
		consumeAndGrantFusion = function(p, list, data)
			assert(RunService:IsServer(), "ItemService.consumeAndGrantFusion 只能在服务器调用")

			if typeof(data.itemType) ~= "string" or typeof(data.itemId) ~= "string" then
				return nil, nil
			end

			local v4 = {}

			for _, v5 in ipairs(list) do
				if typeof(v5) ~= "string" or v4[v5] then
					return nil, nil
				end

				v4[v5] = true
			end

			local v5 = data.itemId .. "_" .. HttpService:GenerateGUID(false)
			local serial

			if data.useCounter == true then
				serial = allocateSerialRange(data.itemId, 1, 5)

				if serial == nil then
					return nil, nil
				end
			else
				serial = nil
			end

			local now = TimeService.now()
			local v7 = false
			local v8 = {}
			local BallUpgradeRules = require(script.Parent.BallUpgradeRules)
			PlayerData.server[p].items(function(p2)
				local result = typeof(p2) ~= "table" and {} or table.clone(p2)
				local Config = require(script.Parent.Config)

				for _, v9 in ipairs(list) do
					local v10 = result[v9]

					if typeof(v10) ~= "table" or v10.ownerUserId ~= p.UserId or v10.canFusion ~= true or v10.itemType ~= data.itemType or v10.itemType == "Ball" and BallUpgradeRules.kind(v10) ~= "Classic" or next(v10.locks or {}) ~= nil then
						return p2
					end

					local v11

					if v10.itemType == "Ball" then
						v11 = Config.ball.byCnId[v10.itemId]
					else
						v11 = Config.skin.byCnId[v10.itemId]
					end

					if not v11 or v11.rating ~= data.materialRating then
						return p2
					end
				end

				local tradable = data.tradable ~= false

				for _, v9 in ipairs(list) do
					tradable = tradable and result[v9].tradable == true
				end

				v8 = {}

				for _, v9 in ipairs(list) do
					table.insert(v8, result[v9])
					result[v9] = nil
				end

				local v10 = {
					instanceId = v5,
					ownerUserId = p.UserId,
					itemType = data.itemType,
					itemId = data.itemId,
					tradable = tradable,
					canFusion = data.canFusion == true,
					source = typeof(data.source) ~= "string" and "合成" or data.source,
					obtainedAt = now,
					locks = {},
					metadata = {
						tradeCount = 0,
						lastTradedAt = nil
					},
					serial = serial,
					serialKey = 0
				}
				local serialKey

				if serial ~= nil then
					local itemId = data.itemId
					serialKey = SerialRegistryService.counterKey(itemId)
				end

				v10.serialKey = serialKey
				result[v5] = v10
				v7 = true
				return result
			end)

			if not v7 then
				return nil, nil
			end

			if serial ~= nil then
				local materials = {}

				for _, v10 in v8 do
					table.insert(materials, SerialRegistryService.materialDetail(v10))
				end

				SerialRegistryService.mint(p, PlayerData.server[p].items()[v5], {
					via = "合成",
					materials = materials
				})
			end

			for _, v9 in v8 do
				if v9.serial ~= nil then
					SerialRegistryService.destroy(p, v9, "合成材料", v5)
				end
			end

			PlayerData.server[p].equipment(function(p2)
				local result = typeof(p2) ~= "table" and {} or table.clone(p2)

				for k, id in result do
					if typeof(id) ~= "string" then
						if typeof(id) == "table" and id.kind == "flyer" and typeof(id.id) == "string" then
							id = id.id
						else
							id = nil
						end
					end

					if id and v4[id] then
						result[k] = nil
					end
				end

				return result
			end)
			AuditService.record(p, {
				assetType = "item",
				source = data.source or "Fusion",
				operationId = "item:fusion:" .. HttpService:GenerateGUID(false),
				at = now,
				action = "fusion",
				consumed = table.clone(list),
				granted = v5,
				itemType = data.itemType,
				itemId = data.itemId
			})
			autoEquipAcquiredSkins(p, { v5 })

			if data.itemType == "飞行器" then
				EmoteWheelLoadoutService.server.autoEquipFlyer(p, v5)
			end

			return v5, serial
		end,
		consumeAndGrantBallUpgrade = function(p, p2, p3)
			assert(RunService:IsServer(), "小球升级只能在服务端调用")

			if not v5 then
				return {
					ok = false,
					reason = "feature_disabled"
				}
			end

			if v4[p] then
				return {
					ok = false,
					reason = "busy"
				}
			end

			v4[p] = true
			local success, result = pcall(performBallUpgrade, p, p2, p3)
			v4[p] = nil

			if success then
				return result
			end

			warn("[BallUpgrade] 升级异常: " .. tostring(result))
			return {
				ok = false,
				reason = "error"
			}
		end,
		setLock = function(p, p2: string, p3: string, p4: string?)
			assert(RunService:IsServer(), "ItemService.setLock 只能在服务器调用")
			local v4 = false
			local v5 = p4 or p3
			PlayerData.server[p].items[p2](function(p5)
				if not p5 or p5.locks and p5.locks[p3] == v5 then
					return p5
				end

				local clone = table.clone(p5)
				clone.locks = table.clone(p5.locks or {})
				clone.locks[p3] = v5
				v4 = true
				return clone
			end)
			return v4
		end,
		clearLock = function(p, p2: string, p3: string)
			assert(RunService:IsServer(), "ItemService.clearLock 只能在服务器调用")
			local v4 = false
			PlayerData.server[p].items[p2](function(p4)
				if not p4 or not p4.locks or p4.locks[p3] == nil then
					return p4
				end

				local clone = table.clone(p4)
				clone.locks = table.clone(p4.locks)
				clone.locks[p3] = nil
				v4 = true
				return clone
			end)
			return v4
		end,
		canTrade = canTrade,
		transferBatch = function(p, list, p2, list2, p3: string, p4)
			assert(RunService:IsServer(), "ItemService.transferBatch 只能在服务器调用")

			for _, v4 in ipairs(list) do
				if not canTrade(p, v4, p3) then
					return false
				end
			end

			for _, v4 in ipairs(list2) do
				if not canTrade(p2, v4, p3) then
					return false
				end
			end

			local now = TimeService.now()

			local function move(p5, p6, list3)
				local clones = {}

				for _, v4 in ipairs(list3) do
					local v5 = PlayerData.server[p5].items[v4]()
					local clone = table.clone(v5)
					clone.ownerUserId = p6.UserId
					clone.locks = {}
					clone.metadata = table.clone(v5.metadata or {})
					clone.metadata.tradeCount = (tonumber(clone.metadata.tradeCount) or 0) + 1
					clone.metadata.lastTradedAt = now
					clones[v4] = clone
				end

				PlayerData.server[p5].items(function(options)
					local clone = table.clone(options or {})

					for k in clones do
						clone[k] = nil
					end

					return clone
				end)
				PlayerData.server[p6].items(function(options)
					local clone = table.clone(options or {})

					for k, v4 in clones do
						clone[k] = v4
					end

					return clone
				end)
				PlayerData.server[p5].equipment(function(options)
					local clone = table.clone(options or {})

					for k, id in clone do
						if typeof(id) ~= "string" then
							if typeof(id) == "table" and id.kind == "flyer" and typeof(id.id) == "string" then
								id = id.id
							else
								id = nil
							end
						end

						if id and clones[id] then
							clone[k] = nil
						end
					end

					return clone
				end)
			end

			move(p, p2, list)
			move(p2, p, list2)
			autoEquipAcquiredSkins(p, list2)
			autoEquipAcquiredSkins(p2, list)
			AuditService.record(p, {
				assetType = "item",
				source = "Trade",
				operationId = p3,
				at = now,
				action = "trade",
				withUserId = p2.UserId,
				sent = list,
				received = list2
			})
			AuditService.record(p2, {
				assetType = "item",
				source = "Trade",
				operationId = p3,
				at = now,
				action = "trade",
				withUserId = p.UserId,
				sent = list2,
				received = list
			})
			local diamonds = (not p4 or typeof(p4.diamondsA) ~= "number") and 0 or p4.diamondsA
			local diamonds2 = (not p4 or typeof(p4.diamondsB) ~= "number") and 0 or p4.diamondsB
			SerialRegistryService.transfer(p, p2, list, {
				t = "交易",
				txn = p3,
				give = {
					diamonds = diamonds2,
					items = #list2
				}
			})
			SerialRegistryService.transfer(p2, p, list2, {
				t = "交易",
				txn = p3,
				give = {
					diamonds = diamonds,
					items = #list
				}
			})
			return true
		end,
		equip = equip,
		addKill = function(p, p2: string, p3: string)
			assert(RunService:IsServer(), "ItemService.addKill 只能在服务器调用")
			local killTrackedItem = findKillTrackedItem(p, p2, p3)

			if not killTrackedItem then
				return nil
			end

			PlayerData.server[p].items[killTrackedItem](function(p4)
				if typeof(p4) ~= "table" then
					return p4
				end

				local clone = table.clone(p4)
				clone.metadata = table.clone(p4.metadata or {})
				clone.metadata.killCount = (tonumber(clone.metadata.killCount) or 0) + 1
				return clone
			end)
			return killTrackedItem
		end,
		getKillCount = function(p, p2: string, p3: string)
			assert(RunService:IsServer(), "ItemService.getKillCount 只能在服务器调用")
			local _, v4 = findKillTrackedItem(p, p2, p3)
			return v4
		end,
		retryPendingSerials = function(p)
			return (assignPendingSerials(p, collectPendingSerialIds(p), 1))
		end
	},
	client = {
		equip = function(p: string, p2: string?, p3: string?)
			return (remoteFunction:InvokeServer(p, p2, p3))
		end
	}
}