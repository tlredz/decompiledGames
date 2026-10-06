local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local DevProductService = require(ReplicatedStorage.Engine.Market.DevProductService)
local TimeService = require(ReplicatedStorage.Engine.Service.TimeService)

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentWeekKey()
	return (tostring(TimeService.getWeekKey(0, 0, 1)))
end

local flag = false

local function recordPurchase(data)
	local buyer = data.buyer
	local robuxSpent = data.robuxSpent

	if not buyer or buyer.Parent ~= Players then
		warn((`[RobuxSpendService] 购买 {data.purchaseId} 的付款人已离开，跳过本服消费统计`))
		return
	end

	if typeof(robuxSpent) ~= "number" or robuxSpent <= 0 then
		warn((`[RobuxSpendService] 购买 {data.purchaseId} 的消费金额无效: {tostring(robuxSpent)}`))
		return
	end

	local v = PlayerData.server.Service:waitForData(buyer)

	if buyer.Parent ~= Players then
		warn((`[RobuxSpendService] 购买 {data.purchaseId} 等待数据时付款人离开，跳过本服消费统计`))
		return
	end

	v.robuxSpent(function(p: number)
		return p + robuxSpent
	end)
	local currentWeekKey = getCurrentWeekKey() -- equivalent call inferred; original call site unknown
	v.weeklyRobuxSpent[currentWeekKey](function(value: number?)
		return (value or 0) + robuxSpent
	end)
end

return {
	init = function()
		if flag then
			return
		end

		flag = true
		DevProductService.server.onPurchaseSucceeded(function(p)
			task.spawn(function()
				local success, result = pcall(recordPurchase, p)

				if not success then
					warn((`[RobuxSpendService] 记录购买 {p.purchaseId} 的消费失败: {tostring(result)}`))
				end
			end)
		end)
	end
}