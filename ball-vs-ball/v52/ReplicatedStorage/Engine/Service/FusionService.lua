local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = require(ReplicatedStorage.Packages.Net)
local Config = require(script.Parent.Config)
local PlayerData = require(script.Parent.PlayerData)
local ItemService = require(script.Parent.ItemService)
local GachaPool = require(script.Parent.GachaPool)
local TimeService = require(script.Parent.TimeService)
local BallUpgradeRules = require(script.Parent.BallUpgradeRules)
local remoteFunction = Net:RemoteFunction("FusionRequest")
local random = Random.new()
local v = {}
local v2 = {
	Ball = "小球",
	["爆炸特效"] = "爆炸特效",
	["飞行器"] = "飞行器"
}

local function isSupportedItemType(value)
	return typeof(value) == "string" and v2[value] ~= nil
end

local function getRequiredCount()
	return 10
end

local function getDefinition(p: string, p2: string)
	if p == "Ball" then
		return Config.ball.byCnId[p2]
	end

	local v3 = Config.skin.byCnId[p2]

	if v3 and v3.skinType == p then
		return v3
	end

	return nil
end

local function getRating(p: string, p2: string)
	local v3

	if p == "Ball" then
		v3 = Config.ball.byCnId[p2]
	else
		v3 = Config.skin.byCnId[p2]

		if not v3 or v3.skinType ~= p then
			v3 = nil
		end
	end

	if v3 and typeof(v3.rating) == "number" then
		return v3.rating
	end

	return nil
end

local function buildCandidates(itemType: string, p: number, _: boolean)
	local v3 = v2[itemType]
	local result = {}
	local v4 = {}

	if not v3 then
		return result
	end

	local now = TimeService.now()

	for _, v5 in GachaPool.getAllEntries() do
		if not (v5.itemType == v3 and GachaPool.isUnlocked(v5, now) and v5.canFusion == true) then
			continue
		end

		local targetId = v5.targetId
		local v6

		if itemType == "Ball" then
			v6 = Config.ball.byCnId[targetId]
		else
			v6 = Config.skin.byCnId[targetId]

			if not v6 or v6.skinType ~= itemType then
				v6 = nil
			end
		end

		local v7

		if v6 and typeof(v6.rating) == "number" then
			v7 = v6.rating
		end

		if v7 ~= p then
			continue
		end

		local v8 = v4[v5.targetId]

		if not v8 then
			v8 = {
				targetId = v5.targetId,
				rows = {}
			}
			v4[v5.targetId] = v8
			table.insert(result, v8)
		end

		table.insert(v8.rows, v5)
	end

	return result
end

local function fuse(p, list)
	if typeof(list) ~= "table" then
		return {
			ok = false,
			reason = "invalid_materials"
		}
	end

	local count = 0
	local v3 = 10

	for k in pairs(list) do
		count += 1

		if typeof(k) ~= "number" or k % 1 ~= 0 or k < 1 or v3 < k then
			return {
				ok = false,
				reason = "invalid_count"
			}
		end
	end

	if not (count == v3 and #list == v3) then
		return {
			ok = false,
			reason = "invalid_count"
		}
	end

	local v4 = {}
	local itemType = nil
	local materialRating = nil
	local v6 = nil

	for _, v7 in ipairs(list) do
		if typeof(v7) ~= "string" or v4[v7] then
			return {
				ok = false,
				reason = "invalid_materials"
			}
		end

		v4[v7] = true
		local v8 = PlayerData.server[p].items()[v7]

		if typeof(v8) == "table" and v8.ownerUserId == p.UserId then
			local itemType2 = v8.itemType
			local v9

			if typeof(itemType2) == "string" then
				v9 = v2[itemType2] ~= nil
			else
				v9 = false
			end

			if v9 and v8.canFusion == true and (v8.itemType ~= "Ball" or BallUpgradeRules.kind(v8) == "Classic") and next(v8.locks or {}) == nil and typeof(v8.itemId) == "string" then
				local itemType3 = v8.itemType
				local itemId = v8.itemId
				local v10

				if itemType3 == "Ball" then
					v10 = Config.ball.byCnId[itemId]
				else
					v10 = Config.skin.byCnId[itemId]

					if not v10 or v10.skinType ~= itemType3 then
						v10 = nil
					end
				end

				local rating

				if v10 and typeof(v10.rating) == "number" then
					rating = v10.rating
				end

				if not rating then
					return {
						ok = false,
						reason = "invalid_materials"
					}
				end

				local tradable = v8.tradable == true

				if itemType == nil then
					itemType = v8.itemType
					materialRating = rating
					v6 = tradable
				elseif v8.itemType ~= itemType or rating ~= materialRating then
					return {
						ok = false,
						reason = "mismatch"
					}
				end

				v6 = v6 and tradable
				continue
			end
		end

		return {
			ok = false,
			reason = "invalid_materials"
		}
	end

	if not itemType or not materialRating or v6 == nil then
		return {
			ok = false,
			reason = "invalid_materials"
		}
	end

	local candidates = buildCandidates(itemType, materialRating + 1, v6)

	if #candidates == 0 then
		return {
			ok = false,
			reason = "no_next_rarity"
		}
	end

	local candidate = candidates[random:NextInteger(1, #candidates)]
	local row = candidate.rows[random:NextInteger(1, #candidate.rows)]
	local instanceId, serial = ItemService.server.consumeAndGrantFusion(p, list, {
		itemType = itemType,
		itemId = row.targetId,
		tradable = v6 and row.allowTrade ~= false,
		canFusion = row.canFusion == true,
		useCounter = itemType ~= "Ball" and row.useCounter == true,
		source = "合成",
		materialRating = materialRating
	})

	if instanceId then
		return {
			ok = true,
			cnId = row.targetId,
			itemType = itemType,
			instanceId = instanceId,
			serial = serial
		}
	end

	return {
		ok = false,
		reason = "stale"
	}
end

local v3 = {
	invalid_materials = "材料无效：格式错误、重复、物品不存在、归属不符、不支持的类型、不可合成、已锁定或缺少品质配置",
	invalid_count = "材料数量不符合合成要求",
	mismatch = "材料类型、品质或可交易状态不一致",
	no_next_rarity = "配表中没有同可交易状态且可合成的下一品质物品",
	stale = "材料状态已变化，消耗材料或发放结果失败",
	busy = "上一笔合成请求仍在处理中",
	error = "合成执行异常"
}

local function logFailure(p, list, p2: string, value)
	local v4

	if typeof(list) == "table" then
		v4 = tostring(#list)
	else
		v4 = typeof(list)
	end

	warn(("[FusionService] 合成失败或拒绝: player=%s(%d), reason=%s, 原因=%s, 材料数量=%s, 要求数量=%d, detail=%s"):format(
		p.Name,
		p.UserId,
		p2,
		v3[p2] or "未知原因",
		v4,
		10,
		(tostring(value or ""))
	))
end

if RunService:IsServer() then
	remoteFunction.OnServerInvoke = function(p, p2)
		if v[p] then
			logFailure(p, p2, "busy")
			return {
				ok = false,
				reason = "busy"
			}
		end

		v[p] = true
		local success, result = pcall(fuse, p, p2)
		v[p] = nil

		if not success then
			logFailure(p, p2, "error", result)
			return {
				ok = false,
				reason = "error"
			}
		end

		if result.ok ~= true then
			logFailure(p, p2, result.reason)
		end

		return result
	end

	Players.PlayerRemoving:Connect(function(player)
		v[player] = nil
	end)
end

return {}