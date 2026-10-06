local AuditService = require(script.Parent.AuditService)
local Config = require(script.Parent.Config)
local CurrencyService = require(script.Parent.CurrencyService)
local ItemService = require(script.Parent.ItemService)
local GachaService = require(script.Parent.GachaService)
local PlayerData = require(script.Parent.PlayerData)
local server = PlayerData.server
local BoostService = require(script.Parent.BoostService)
local v = {
	["金币"] = CurrencyService.ref.Coins,
	["钻石"] = CurrencyService.ref.Diamonds
}

local function grantCurrency(p, itemId: string, count: number, p2: string)
	local v2 = v[itemId]

	if not v2 then
		warn((`[RewardItemService] 未知货币名: {itemId}（奖励id={p2}）`))
		return {
			ok = false,
			reason = "invalid_currency"
		}
	end

	if CurrencyService.server.give(p, v2, count, {
		type = "reward",
		arg = p2
	}, {
		transactionType = Enum.AnalyticsEconomyTransactionType.Gameplay.Name,
		sku = "奖励:" .. p2,
		channel = "通用奖励",
		mode = "通用"
	}) then
		return {
			ok = true
		}
	end

	return {
		ok = false,
		reason = "error"
	}
end

local function hasExtraFlag(p, p2: string)
	return p ~= nil and p[p2] == true
end

local function grantBall(p, itemId: string, count: number, extraArgs, source: string)
	if not Config.ball.byCnId[itemId] then
		warn((`[RewardItemService] 未知小球cnId: {itemId}（奖励id={source}）`))
		return {
			ok = false,
			reason = "invalid_ball"
		}
	end

	local v3 = extraArgs == nil or extraArgs["不可交易"] ~= true
	local results = {}

	for _ = 1, count do
		local grant = ItemService.server.grant
		local v6 = {
			tradable = v3,
			canFusion = v3,
			source = source,
			useCounter = extraArgs ~= nil and extraArgs["唯一编号"] == true,
			killTracking = extraArgs ~= nil and extraArgs["击杀统计"] == true
		}
		table.insert(results, (grant(p, "Ball", itemId, v6)))
	end

	return {
		ok = true,
		results = results
	}
end

local function grantVoucher(p, itemId: string, count: number, source: string)
	if itemId == "钻石奖池券" then
		local DiamondDrawService = require(script.Parent.DiamondDrawService)
		DiamondDrawService.server.addTickets(p, count)
		return {
			ok = true
		}
	else
		local after = server[p].vouchers[itemId](function(value)
			return (typeof(value) ~= "number" and 0 or value) + count
		end)
		AuditService.record(p, {
			assetType = "voucher",
			assetId = itemId,
			action = "grant",
			delta = count,
			before = after - count,
			after = after,
			source = source
		})
		return {
			ok = true
		}
	end
end

local function grantCrate(p, itemId: string, count: number, p2: string)
	local v2 = GachaService.server.grantConfiguredFreeChest(p, {
		["箱子id"] = itemId,
		["数量"] = count
	}, p2)

	if v2.ok then
		return {
			ok = true,
			results = v2.results
		}
	end

	warn((`[RewardItemService] 免费开箱失败: {itemId}（奖励id={p2}, reason={v2.reason}）`))
	return {
		ok = false,
		reason = v2.reason
	}
end

local function grantSkin(p, itemId: string, count: number, extraArgs, source: string)
	local v2 = Config.skin.byCnId[itemId]

	if not v2 then
		warn((`[RewardItemService] 未知皮肤cnId: {itemId}（奖励id={source}）`))
		return {
			ok = false,
			reason = "invalid_skin"
		}
	end

	local v4 = extraArgs == nil or extraArgs["不可交易"] ~= true
	local results = {}

	for _ = 1, count do
		local grant = ItemService.server.grant
		local skinType = v2.skinType
		local v6 = {
			tradable = v4,
			canFusion = v4,
			source = source,
			useCounter = extraArgs ~= nil and extraArgs["唯一编号"] == true,
			killTracking = extraArgs ~= nil and extraArgs["击杀统计"] == true
		}
		table.insert(results, (grant(p, skinType, itemId, v6)))
	end

	return {
		ok = true,
		results = results
	}
end

local definitions = BoostService.definitions

local function grantBoost(p, itemId: string, count: number, extraArgs, p2: string, p3: string?)
	local v2 = BoostService
	local rewardArgs, v3 = v2.parseRewardArgs(extraArgs, count)

	if rewardArgs and v3 then
		v2.server.addBoost(p, itemId, rewardArgs, v3, p2, p3)
		return {
			ok = true
		}
	else
		return {
			ok = false,
			reason = "invalid_config"
		}
	end
end

local function grantTitle(p, itemId: string, p2: string)
	local PlayerTitleService = require(script.Parent.PlayerTitleService)

	if PlayerTitleService.server.grant(p, itemId) then
		return {
			ok = true
		}
	end

	warn((`[RewardItemService] 头衔发放失败: {itemId}（奖励id={p2}）`))
	return {
		ok = false,
		reason = "invalid_title"
	}
end

local function isDynamicCount(p)
	return typeof(p.extraArgs) == "table" and p.extraArgs["动态数量"] == true
end

local function validateReward(data, count: number?)
	local v2

	if typeof(data.extraArgs) == "table" then
		v2 = data.extraArgs["动态数量"] == true
	else
		v2 = false
	end

	if v2 ~= (count ~= nil) then
		return "dynamic_count_mismatch"
	end

	if not v2 then
		count = data.count
	end

	if typeof(count) ~= "number" or count < 1 or count % 1 ~= 0 then
		return "invalid_config"
	end

	if data.itemType == "货币" then
		if v[data.itemId] then
			return nil
		end

		return "invalid_currency"
	elseif data.itemType == "小球" then
		if Config.ball.byCnId[data.itemId] then
			return nil
		end

		return "invalid_ball"
	elseif data.itemType == "皮肤" then
		if Config.skin.byCnId[data.itemId] then
			return nil
		end

		return "invalid_skin"
	elseif data.itemType == "加成" then
		if not definitions[data.itemId] then
			return "invalid_boost"
		end

		if BoostService.parseRewardArgs(data.extraArgs, count) then
			return nil
		end

		return "invalid_config"
	else
		if data.itemType == "券" or data.itemType == "箱子" then
			return nil
		end

		if data.itemType ~= "头衔" then
			return "invalid_item_type"
		end

		if Config.playerTitle.byCnId[data.itemId] then
			return nil
		end

		return "invalid_title"
	end
end

return {
	grant = function(p, source: string, p3: number?, p4: string?)
		local v2 = Config.reward.byCnId[source]

		if not v2 or #v2 == 0 then
			warn((`[RewardItemService] 未知奖励id: {source}`))
			return {
				ok = false,
				reason = "invalid_reward"
			}
		end

		if p3 ~= nil and #v2 ~= 1 then
			warn((`[RewardItemService] 动态数量奖励只能配置一条: {source}`))
			return {
				ok = false,
				reason = "invalid_config"
			}
		end

		for _, v3 in v2 do
			local reason = validateReward(v3, p3)

			if not reason then
				continue
			end

			warn((`[RewardItemService] 奖励配置非法: {source}（itemType={v3.itemType}, itemId={v3.itemId}, reason={reason}）`))
			return {
				ok = false,
				reason = reason
			}
		end

		local results = {}

		for _, v3 in v2 do
			local count

			if p3 == nil then
				count = v3.count
			else
				count = p3
			end

			local v4

			if v3.itemType == "货币" then
				v4 = grantCurrency(p, v3.itemId, count, source)
			elseif v3.itemType == "小球" then
				v4 = grantBall(p, v3.itemId, count, v3.extraArgs, source)
			elseif v3.itemType == "皮肤" then
				v4 = grantSkin(p, v3.itemId, count, v3.extraArgs, source)
			elseif v3.itemType == "券" then
				v4 = grantVoucher(p, v3.itemId, count, source)
			elseif v3.itemType == "箱子" then
				v4 = grantCrate(p, v3.itemId, count, source)
			elseif v3.itemType == "加成" then
				v4 = grantBoost(p, v3.itemId, count, v3.extraArgs, source, p4)
			elseif v3.itemType == "头衔" then
				v4 = grantTitle(p, v3.itemId, source)
			else
				warn((`[RewardItemService] 未知物品类型: {v3.itemType}（奖励id={source}）`))
				v4 = {
					ok = false,
					reason = "invalid_item_type"
				}
			end

			if not v4.ok then
				return v4
			end

			table.insert(results, v4.results)
		end

		return {
			ok = true,
			results = results
		}
	end
}