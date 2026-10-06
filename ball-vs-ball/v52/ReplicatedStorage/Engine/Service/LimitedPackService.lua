local ReplicatedStorage = game:GetService("ReplicatedStorage")
local engine = ReplicatedStorage:WaitForChild("Engine")
local Config = require(engine:WaitForChild("Service"):WaitForChild("Config"))
local TimeService = require(engine:WaitForChild("Service"):WaitForChild("TimeService"))
local LimitedPackService = {
	server = {}
}
local RunService = game:GetService("RunService")
local group = nil
local switchAt = 0
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function updateTest()
	if not RunService:IsClient() then
		return
	end

	local v2 = v

	if v2 and os.clock() >= v2.switchAt then
		group = v2.group
		switchAt = v2.switchAt
		v = nil
	end
end

local configDateToDayKey = TimeService.configDateToDayKey

local function allPacks()
	local limitedPack = Config.limitedPack

	if limitedPack and limitedPack.list then
		return limitedPack.list
	end

	return {}
end

function LimitedPackService.startSwitchTest(group2: string, p2: number?)
	if not RunService:IsClient() then
		return false, "只能在客户端执行"
	end

	local v2 = p2 == nil and 30 or p2

	if v2 ~= v2 or v2 < 0 or v2 == 1e999 then
		return false, "倒计时必须是有限的非负秒数"
	end

	local limitedPack = Config.limitedPack
	local v3 = false
	local v4 = false

	for _, v5 in not (limitedPack and limitedPack.list) and {} or limitedPack.list do
		if v5.group ~= group2 then
			continue
		end

		v3 = true
		local v6 = configDateToDayKey(v5.startDate)
		local v7 = configDateToDayKey(v5.endDate)

		if not v6 or not v7 or v7 <= v6 then
			return false, "目标包组的日期配置无效"
		end

		if v5.type == "全套" and v5.isForSale then
			v4 = true
		end
	end

	if not v3 then
		return false, "找不到目标包组"
	end

	if not v4 then
		return false, "目标包组没有可售全套"
	end

	updateTest() -- equivalent call inferred; original call site unknown
	v = {
		group = group2,
		switchAt = os.clock() + v2
	}
	updateTest() -- equivalent call inferred; original call site unknown
	return true, nil
end

function LimitedPackService.endSwitchTest()
	if not RunService:IsClient() then
		return
	end

	v = nil
	group = nil
end

function LimitedPackService.getPack(p: string)
	local limitedPack = Config.limitedPack

	for _, v2 in not (limitedPack and limitedPack.list) and {} or limitedPack.list do
		if v2.cnId == p then
			return v2
		end
	end

	return nil
end

function LimitedPackService.isActive(data)
	updateTest() -- equivalent call inferred; original call site unknown

	if group then
		return data.group == group and LimitedPackService.getRemainingSeconds(data) > 0
	else
		local v2 = configDateToDayKey(data.startDate)
		local v3 = configDateToDayKey(data.endDate)

		if not (v2 and v3) then
			return false
		end

		local dayKey = TimeService.getDayKey(0)
		return v2 <= dayKey and dayKey < v3
	end
end

function LimitedPackService.getRemainingSeconds(data)
	updateTest() -- equivalent call inferred; original call site unknown
	local v2 = v

	if v2 then
		return (math.max(0, v2.switchAt - os.clock()))
	end

	if group then
		if data.group ~= group then
			return 0
		end

		local v3 = configDateToDayKey(data.startDate)
		local v4 = configDateToDayKey(data.endDate)

		if v3 and v4 then
			return (math.max(0, (v4 - v3) * 86400 - (os.clock() - switchAt)))
		end

		return 0
	else
		local v3 = configDateToDayKey(data.endDate)

		if v3 then
			return (math.max(0, v3 * 86400 - TimeService.now()))
		end

		return 0
	end
end

function LimitedPackService.isOnSale(p)
	return p.isForSale == true and LimitedPackService.isActive(p)
end

function LimitedPackService.getActiveGroups()
	local limitedPack = Config.limitedPack
	local v2 = {}
	local v3 = {}
	local v4 = {}

	for _, v5 in not (limitedPack and limitedPack.list) and {} or limitedPack.list do
		if not LimitedPackService.isActive(v5) then
			continue
		end

		local v6 = v2[v5.group]

		if not v6 then
			v6 = {
				group = v5.group,
				packs = {}
			}
			v2[v5.group] = v6
			table.insert(v4, v6)
		end

		table.insert(v6.packs, v5)

		if v5.isForSale == true then
			v3[v5.group] = true
		end
	end

	local result = {}

	for _, v5 in v4 do
		if v3[v5.group] then
			table.insert(result, v5)
		end
	end

	return result
end

function LimitedPackService.getGroupRemainingSeconds(p)
	local v2 = 1e999

	for _, pack in p.packs do
		v2 = math.min(v2, LimitedPackService.getRemainingSeconds(pack))
	end

	if v2 == 1e999 then
		return 0
	end

	return v2
end

function LimitedPackService.getGroupContents(p)
	local v2 = nil
	local result = {}

	for _, pack in p.packs do
		if pack.type ~= "全套" then
			continue
		end

		if v2 then
			warn((`[LimitedPackService] 包组 {p.group} 有多行全套，取第一行 {v2.cnId}`))
			break
		else
			v2 = pack
		end
	end

	if not v2 then
		warn((`[LimitedPackService] 包组 {p.group} 没有 type=全套 的行`))
		return result
	end

	for _, v3 in Config.reward.byCnId[v2.rewardId] or {} do
		if v3.itemType == "小球" then
			result.ball = v3.itemId
		elseif v3.itemType == "皮肤" then
			local v4 = Config.skin.byCnId[v3.itemId]

			if v4 and v4.skinType == "飞行器" then
				result.flyer = v4.assetName
			elseif v4 and v4.skinType == "爆炸特效" then
				result.explosion = v4.cnId
			end
		end
	end

	return result
end

local flag = false

local function init()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local DevProductService = require(engine:WaitForChild("Market"):WaitForChild("DevProductService"))
		local RewardItemService = require(engine:WaitForChild("Service"):WaitForChild("RewardItemService"))
		local limitedPack = Config.limitedPack
		local v2 = {}

		for _, v3 in not (limitedPack and limitedPack.list) and {} or limitedPack.list do
			local productKey = v3.productKey

			if typeof(productKey) ~= "string" or productKey == "" or v2[productKey] then
				continue
			end

			v2[productKey] = true
			local rewardId = v3.rewardId
			local productKey2 = productKey
			local success, result = pcall(DevProductService.server.bindProduct, productKey, function(p)
				local v6 = RewardItemService.grant(p.plr, rewardId)

				if not v6.ok then
					error((`[LimitedPackService] {productKey2} 发放 {rewardId} 失败：{v6.reason}`))
				end
			end)

			if not success then
				warn((`[LimitedPackService] 绑定开发者商品 {productKey} 失败：{result}`))
			end
		end
	end)
end

LimitedPackService.server.init = init
return LimitedPackService