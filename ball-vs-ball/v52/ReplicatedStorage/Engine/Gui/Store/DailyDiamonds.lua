local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local TimeService = require(ReplicatedStorage.Engine.Service.TimeService)
local Config = require(ReplicatedStorage.Engine.Service.Config)
local DailyDiamondsService = require(ReplicatedStorage.Engine.Service.DailyDiamondsService)
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
		local v8 = parent:WaitForChild("额外比例")
		local v9 = parent:WaitForChild("刷新倒计时")
		local v10 = instance:WaitForChild("连续奖励结束倒计时")
		local v11 = instance:WaitForChild("连续购买奖励"):WaitForChild("奖励列表")
		local v12 = DevProductService.products.byProductKey[DailyDiamondsService.productKey]
		local v13 = not v12 and 49 or v12.PriceInRobux

		if not v12 then
			warn("[DailyDiamonds] 未找到 Daily Diamonds，价格暂按 49 Robux 展示")
		end

		v5.Text = string.format("%d%s (1/1)", v13, v)
		v6.Text = string.format("%d%s (0/1)", v13, v)
		local v14 = Config.currencyStore and Config.currencyStore.byCurrencyCnId["钻石"]
		local v15 = v14 and v14[1]
		local v16 = not v15 and 0 or v15.count
		local priceInRobux

		if v15 then
			local v17 = DevProductService.products.byProductKey[v15.robloxProductName]

			if not v17 then
				warn((`[DailyDiamonds] 未找到 {v15.robloxProductName}，额外比例基准价回退飞书配置值`))
			end

			if v17 then
				priceInRobux = v17.PriceInRobux
			else
				priceInRobux = v15.price
			end
		else
			priceInRobux = 0
		end

		local visible

		if v16 > 0 and priceInRobux > 0 then
			visible = v13 > 0
		else
			visible = false
		end

		local v18 = {}

		for i = 2, 7 do
			local child = v11:WaitForChild("奖励格" .. tostring(i - 1))
			local rewardCounts = DailyDiamondsService.getRewardCounts(i)
			local v19 = child:WaitForChild("天数")
			local v20 = child:WaitForChild("奖励数量")
			v19.Text = "Day " .. tostring(i)
			v20.Text = "x" .. tostring(rewardCounts)
			v18[i] = {
				stroke = child:WaitForChild("描边")
			}
		end

		local offerDay = 0

		local function refresh()
			local now = TimeService.now()
			local viewState = DailyDiamondsService.getViewState(client.dailyDiamonds(), now)

			if offerDay ~= viewState.offerDay then
				offerDay = viewState.offerDay
				local rewardCounts = DailyDiamondsService.getRewardCounts(viewState.offerDay)
				v7.Text = "x" .. tostring(rewardCounts)
				v8.Visible = visible

				if visible then
					local v19 = math.round((rewardCounts * priceInRobux / (v13 * v16) - 1) * 100)
					v8.Text = string.format("%+d%%", v19)
				end
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
				local stroke = v18[i].stroke
				local v20 = viewState.highlightDay == i
				local color3

				if v20 then
					color3 = color
				else
					color3 = color2
				end

				stroke.Color = color3
				stroke.Thickness = v20 and 0.032 or 0.015
			end
		end

		callback(v3)
		ButtonActions.Bind(v3, function()
			if DailyDiamondsService.getViewState(client.dailyDiamonds(), TimeService.now()).purchasedToday then
				return
			end

			DevProductService.client.promptPurchase(DailyDiamondsService.productKey)
		end)
		callback(v4)
		ButtonActions.Bind(v4, function()
			DevProductService.client.promptGift(DailyDiamondsService.productKey)
		end)
		client.dailyDiamonds.Changed(refresh)
		DevProductService.client.onPurchaseGranted(DailyDiamondsService.productKey, refresh)
		refresh()
		task.spawn(function()
			while instance:IsDescendantOf(game) do
				task.wait(1)
				refresh()
			end
		end)
	end
}