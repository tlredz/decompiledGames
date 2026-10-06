local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(script.Parent.Config)
local TimeService = require(script.Parent.TimeService)
local DailyDiamondDealService = {
	server = {}
}
local flag = false

local function cleanProgress(p)
	if typeof(p) ~= "table" then
		return {
			lastDayKey = 0,
			streak = 0
		}
	end

	local lastDayKey = typeof(p.lastDayKey) ~= "number" and 0 or math.floor(p.lastDayKey)
	local streak = typeof(p.streak) ~= "number" and 0 or math.clamp(math.floor(p.streak), 0, 7)

	if lastDayKey <= 0 or streak == 0 then
		return {
			lastDayKey = 0,
			streak = 0
		}
	end

	return {
		lastDayKey = lastDayKey,
		streak = streak
	}
end

local function getRewardCounts(i: number)
	local v = Config.reward.byCnId["每日钻石充值" .. tostring(i)]
	local total = 0
	local total2 = 0

	if typeof(v) ~= "table" then
		return total, total2
	end

	for _, v2 in ipairs(v) do
		if v2.itemType == "货币" and v2.itemId == "钻石" then
			total += v2.count
		elseif v2.itemType == "券" and v2.itemId == "钻石奖池券" then
			total2 += v2.count
		end
	end

	return total, total2
end

local function getViewState(dailyDiamondDeal, p: number?)
	local v = cleanProgress(dailyDiamondDeal)
	local v2 = p or TimeService.now()
	local dayKeyAt = TimeService.getDayKeyAt(v2, 0)
	local purchasedToday = v.lastDayKey == dayKeyAt
	local v4 = v.lastDayKey == dayKeyAt - 1
	local v5

	if v.streak < 7 then
		v5 = purchasedToday or v4
	else
		v5 = false
	end

	local highlightDay = not v5 and 1 or v.streak + 1
	local streak

	if purchasedToday then
		streak = v.streak
	else
		streak = highlightDay
	end

	if not v5 then
		highlightDay = nil
	end

	local deadline

	if v5 then
		deadline = (v.lastDayKey + 2) * 86400
	end

	return {
		today = dayKeyAt,
		purchasedToday = purchasedToday,
		offerDay = streak,
		highlightDay = highlightDay,
		deadline = deadline
	}
end

DailyDiamondDealService.productKey = "DAILY DIAMONDS DEAL"
DailyDiamondDealService.getRewardCounts = getRewardCounts
DailyDiamondDealService.getViewState = getViewState

function DailyDiamondDealService.server.grantPurchase(p)
	assert(RunService:IsServer(), "每日钻石活动只能在服务端发奖")
	local PlayerData = require(script.Parent.PlayerData)
	local server = PlayerData.server
	local RewardItemService = require(script.Parent.RewardItemService)
	server.Service:waitForData(p)
	local viewState = getViewState(server[p].dailyDiamondDeal(), TimeService.now())
	local offerDay = viewState.offerDay
	local v = "每日钻石充值" .. tostring(offerDay)
	local v2 = RewardItemService.grant(p, v)

	if not v2.ok then
		error((`每日钻石活动发奖失败: {v}, {v2.reason}`))
	end

	if not viewState.purchasedToday then
		server[p].dailyDiamondDeal({
			lastDayKey = viewState.today,
			streak = offerDay
		})
	end
end

function DailyDiamondDealService.server.resetTodayPurchase(p)
	assert(RunService:IsServer(), "每日钻石活动购买记录只能在服务端重置")
	local PlayerData = require(script.Parent.PlayerData)
	local server = PlayerData.server
	server.Service:waitForData(p)
	local v = cleanProgress(server[p].dailyDiamondDeal())
	local dayKeyAt = TimeService.getDayKeyAt(TimeService.now(), 0)

	if v.lastDayKey ~= dayKeyAt then
		return false
	end

	server[p].dailyDiamondDeal({
		lastDayKey = dayKeyAt - 1,
		streak = v.streak
	})
	return true
end

local function init()
	assert(RunService:IsServer(), "DailyDiamondDealService.server.init 只能在服务端调用")

	if flag then
		return
	end

	flag = true
	local DevProductService = require(ReplicatedStorage.Engine.Market.DevProductService)

	for i = 1, 7 do
		local rewardCounts, v = getRewardCounts(i)
		local v2

		if rewardCounts > 0 then
			v2 = v > 0
		else
			v2 = false
		end

		assert(v2, (`每日钻石充值{i}奖励配置缺少钻石或钻石奖池券`))
	end

	DevProductService.server.bindProduct("DAILY DIAMONDS DEAL", function(p)
		DailyDiamondDealService.server.grantPurchase(p.plr)
	end)
end

DailyDiamondDealService.server.init = init
return DailyDiamondDealService