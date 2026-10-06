local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local TimeService = require(ReplicatedStorage.Engine.Service.TimeService)
local DailyDiamondDealService = require(ReplicatedStorage.Engine.Service.DailyDiamondDealService)
local DevProductService = require(ReplicatedStorage.Engine.Market.DevProductService)
local v = utf8.char(57346)
local color = Color3.fromRGB(255, 208, 36)
local color2 = Color3.fromRGB(8, 52, 113)

-- equivalent calls inferred from this helper; original call sites unknown
local function formatRefresh(p: number)
	local v2 = math.max(0, (math.ceil(p)))
	local v3 = v2 // 3600
	local v4 = v2 % 3600 // 60
	local v5 = v2 % 60
	return string.format("Refresh in: %02d:%02d:%02d", v3, v4, v5)
end

return {
	Init = function(instance, callback)
		local parent = instance:WaitForChild("每日礼包")
		local v3 = parent:WaitForChild("购买按钮")
		local clone = parent:WaitForChild("已购按钮模板"):Clone()
		clone.Name = "已购按钮"
		clone.Visible = false
		clone.Parent = parent
		local v4 = parent:WaitForChild("赠礼按钮")
		local v5 = v3:WaitForChild("价格")
		local v6 = clone:WaitForChild("价格")
		local v7 = parent:WaitForChild("钻石数量")
		local v8 = parent:WaitForChild("奖券数量")
		local v9 = parent:WaitForChild("刷新倒计时")
		local v10 = instance:WaitForChild("连续奖励结束倒计时")
		local v11 = instance:WaitForChild("连续购买奖励"):WaitForChild("奖励列表")
		local v12 = DevProductService.products.byProductKey[DailyDiamondDealService.productKey]
		local v13 = not v12 and 49 or v12.PriceInRobux

		if not v12 then
			warn("[DailyDiamondDeal] 未找到 DAILY DIAMONDS DEAL，价格暂按 49 Robux 展示")
		end

		v5.Text = string.format("%d%s (1/1)", v13, v)
		v6.Text = string.format("%d%s (0/1)", v13, v)
		local v14 = {}

		for i = 2, 7 do
			local child = v11:WaitForChild("奖励格" .. tostring(i - 1))
			local _, v15 = DailyDiamondDealService.getRewardCounts(i)
			local v16 = child:WaitForChild("天数")
			local v17 = child:WaitForChild("奖励数量")
			v16.Text = "Day " .. tostring(i)
			v17.Text = "+" .. tostring(v15)
			v14[i] = {
				stroke = child:WaitForChild("描边")
			}
		end

		local offerDay = 0

		local function refresh()
			local now = TimeService.now()
			local viewState = DailyDiamondDealService.getViewState(client.dailyDiamondDeal(), now)

			if offerDay ~= viewState.offerDay then
				offerDay = viewState.offerDay
				local rewardCounts, v15 = DailyDiamondDealService.getRewardCounts(viewState.offerDay)
				v7.Text = "x" .. tostring(rewardCounts)
				v8.Text = "x" .. tostring(v15)
			end

			v3.Visible = not viewState.purchasedToday
			v3.Active = not viewState.purchasedToday
			clone.Visible = viewState.purchasedToday
			v9.Text = formatRefresh((viewState.today + 1) * 86400 - now)

			if viewState.deadline then
				v10.Visible = true
				v10.Text = "Bonus streak ends in: " .. TimeService.formatCountdown((math.ceil(viewState.deadline - now)))
			else
				v10.Visible = false
			end

			for i = 2, 7 do
				local stroke = v14[i].stroke
				local v16 = viewState.highlightDay == i
				local color3

				if v16 then
					color3 = color
				else
					color3 = color2
				end

				stroke.Color = color3
				stroke.Thickness = v16 and 0.032 or 0.015
			end
		end

		callback(v3)
		ButtonActions.Bind(v3, function()
			if DailyDiamondDealService.getViewState(client.dailyDiamondDeal(), TimeService.now()).purchasedToday then
				return
			end

			DevProductService.client.promptPurchase(DailyDiamondDealService.productKey)
		end)
		callback(v4)
		ButtonActions.Bind(v4, function()
			DevProductService.client.promptGift(DailyDiamondDealService.productKey)
		end)
		client.dailyDiamondDeal.Changed(refresh)
		DevProductService.client.onPurchaseGranted(DailyDiamondDealService.productKey, refresh)
		refresh()
		task.spawn(function()
			while instance:IsDescendantOf(game) do
				task.wait(1)
				refresh()
			end
		end)
	end
}