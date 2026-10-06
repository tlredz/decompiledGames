local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GameFlags = require(ReplicatedStorage.GameFlags)
local DevProductService = require(ReplicatedStorage.Engine.Market.DevProductService)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local CurrencyService = require(ReplicatedStorage.Engine.Service.CurrencyService)
local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))
local LootboxNav = require(script.LootboxNav)
local DailyShop = require(script.DailyShop)
local DailyDiamondDeal = require(script.DailyDiamondDeal)
local DailyDiamonds = require(script.DailyDiamonds)
local StarterPackOffer = require(script.Parent.StarterPackOffer)
local LimitedPack = require(script.Parent.LimitedPack)
local DiamondDraw = require(script.Parent.DiamondDraw)
local DiamondDrawService = require(ReplicatedStorage.Engine.Service.DiamondDrawService)
local ServerTypeService = require(ReplicatedStorage.Engine.Service.ServerTypeService)
local ServerTeleport = require(ReplicatedStorage.Packages.ServerTeleport)
local GamepadNavigation = require(script.GamepadNavigation)
local Store = {}
local v = nil
local v2 = "home"
local v3 = nil
local v4 = nil
local panel = nil
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = {
	ball = "小球",
	explosion = "爆炸特效",
	flyer = "飞行器"
}
local flag = false
local size = nil
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local count = 0

local function showStore()
	count += 1

	if flag then
		return
	end

	flag = true
	v4.Visible = true
	v4.BackgroundTransparency = 1
	TweenService:Create(v4, tweenInfo, {
		BackgroundTransparency = 0.5
	}):Play()
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = size
	}):Play()
end

local function hideStore()
	if v9 then
		v9.hidePage()
	end

	flag = false

	if v then
		v:Release()
	end

	count += 1
	local v11 = count
	TweenService:Create(v4, tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0)
	}):Play()
	task.delay(0.3, function()
		if count == v11 then
			v4.Visible = false
		end
	end)
end

local function scaleUDim2(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset * p, udim.Y.Scale * p, udim.Y.Offset * p)
end

local function setupButtonFeedback(instance)
	instance:SetAttribute("StoreGamepadAction", true)
	local size2 = instance.Size
	instance.MouseEnter:Connect(function()
		local size3 = size2
		TweenService:Create(instance, TweenInfo.new(0.1), {
			Size = UDim2.new(size3.X.Scale * 1.05, size3.X.Offset * 1.05, size3.Y.Scale * 1.05, size3.Y.Offset * 1.05)
		}):Play()
	end)
	instance.MouseLeave:Connect(function()
		TweenService:Create(instance, TweenInfo.new(0.1), {
			Size = size2
		}):Play()
	end)
end

local function switchTab(p: string)
	v2 = p
	v8.Visible = p == "home"
	v6.Visible = p == "currency"
	v7.Visible = v10[p] ~= nil
	local v11 = v10[p]

	if v11 then
		v9.setItemType(v11)
	end

	v9.hidePage()
end

local function formatGemPrice(p)
	local v11 = DevProductService.products.byProductKey[p.robloxProductName]

	if not v11 then
		warn((`[Store] 商品 {p.robloxProductName} 在 DevProductService.products 中找不到，价格显示回退飞书配置值`))
	end

	local priceInRobux = v11 and v11.PriceInRobux or p.price
	return string.format("%s %d", "", priceInRobux)
end

local function populateCurrencyShop(instance, items)
	local v11 = {}

	if items then
		for _, item in items do
			if item.exchangeCurrencyType == "Robux" and item.robloxProductName and item.robloxProductName ~= "" then
				table.insert(v11, item)
			end
		end
	else
		warn("[Store] 飞书 currencyStore 没有对应数据: " .. instance.Name)
	end

	for i = 1, 6 do
		local child = instance:FindFirstChild("格子" .. i)

		if child then
			local v12 = v11[i]
			child.Visible = v12 ~= nil

			if v12 then
				local firstChild = child:FindFirstChild("名称")
				local v13 = firstChild and firstChild:FindFirstChild("文字")
				local firstChild2 = child:FindFirstChild("数量")
				local firstChild3 = child:FindFirstChild("优惠")
				local firstChild4 = child:FindFirstChild("礼物按钮")

				if v13 then
					local v14 = DevProductService.products.byProductKey[v12.robloxProductName]

					if not v14 then
						warn((`[Store] 商品 {v12.robloxProductName} 在 DevProductService.products 中找不到，价格显示回退飞书配置值`))
					end

					local priceInRobux = v14 and v14.PriceInRobux or v12.price
					v13.Text = string.format("%s %d", "", priceInRobux)
				end

				if firstChild2 then
					firstChild2.Text = tostring(v12.count)
				end

				if firstChild3 then
					if v12.discount and v12.discount > 0 then
						firstChild3.Visible = true
						firstChild3.Text = string.format("+%d%%", (math.floor(v12.discount * 100 + 0.5)))
					else
						firstChild3.Visible = false
					end
				end

				setupButtonFeedback(child)
				local v14 = v12
				ButtonActions.Bind(child, function()
					DevProductService.client.promptPurchase(v14.robloxProductName)
				end)

				if firstChild4 then
					setupButtonFeedback(firstChild4)
					local v15 = v12
					ButtonActions.Bind(firstChild4, function()
						DevProductService.client.promptGift(v15.robloxProductName)
					end)
				end
			end
		else
			warn("[Store] 货币商店缺少 格子" .. i)
		end
	end

	if #v11 > 6 then
		warn((`[Store] 飞书 currencyStore 配置了 {#v11} 个钻石购买项，超过预留的 {6} 个格子，多出的会被忽略`))
	end
end

local function bindPlayerCurrencyBar(instance)
	local v11 = instance:WaitForChild("金币"):WaitForChild("数量")
	local v12 = instance:WaitForChild("钻石"):WaitForChild("数量")
	v11.Text = tostring(client.coins())
	v12.Text = tostring(client.diamonds())
	CurrencyService.client.onChanged(function(p, _, p2)
		if p == CurrencyService.ref.Coins then
			v11.Text = tostring(p2)
		elseif p == CurrencyService.ref.Diamonds then
			v12.Text = tostring(p2)
		end
	end)
	local v13 = instance:WaitForChild("金币加号")
	local v14 = instance:WaitForChild("钻石加号")
	setupButtonFeedback(v13)
	setupButtonFeedback(v14)
	ButtonActions.Bind(v13, function()
		Store.OpenToSection("金币")
	end)
	ButtonActions.Bind(v14, function()
		Store.OpenToSection("钻石")
	end)
end

function Store.IsOpen()
	return flag
end

function Store.Open()
	showStore()
end

function Store.Close()
	if flag then
		hideStore()
	end
end

function Store.OpenHome()
	local v11 = flag
	showStore()

	if not v11 then
		v9.hidePage()
	end

	v2 = "home"
	v8.Visible = true
	v6.Visible = false
	v7.Visible = v10.home ~= nil
	local home = v10.home

	if home then
		v9.setItemType(home)
	end

	v9.hidePage()
end

function Store.OpenLootbox()
	local v11 = flag
	showStore()

	if not v11 then
		v9.hidePage()
	end

	v2 = "ball"
	v8.Visible = false
	v6.Visible = false
	v7.Visible = v10.ball ~= nil
	local ball = v10.ball

	if ball then
		v9.setItemType(ball)
	end

	v9.hidePage()
end

function Store.OpenFlyerShop()
	local v11 = flag
	showStore()

	if not v11 then
		v9.hidePage()
	end

	v2 = "flyer"
	v8.Visible = false
	v6.Visible = false
	v7.Visible = v10.flyer ~= nil
	local flyer = v10.flyer

	if flyer then
		v9.setItemType(flyer)
	end

	v9.hidePage()
end

function Store.OpenExplosionShop()
	local v11 = flag
	showStore()

	if not v11 then
		v9.hidePage()
	end

	v2 = "explosion"
	v8.Visible = false
	v6.Visible = false
	v7.Visible = v10.explosion ~= nil
	local explosion = v10.explosion

	if explosion then
		v9.setItemType(explosion)
	end

	v9.hidePage()
end

function Store.OpenToSection(_: string)
	showStore()
	v2 = "currency"
	v8.Visible = false
	v6.Visible = true
	v7.Visible = v10.currency ~= nil
	local currency = v10.currency

	if currency then
		v9.setItemType(currency)
	end

	v9.hidePage()
	v6.CanvasPosition = Vector2.new(0, 0)
end

local function bindContentCanvas(instance)
	local uIListLayout = instance:FindFirstChildWhichIsA("UIListLayout")
	assert(uIListLayout, "商店滚动页面缺少纵向列表布局")
	local uIPadding = instance:FindFirstChildWhichIsA("UIPadding")
	instance.AutomaticCanvasSize = Enum.AutomaticSize.None

	local function resize()
		local parent = instance
		local v11 = 1

		while parent and not parent:IsA("LayerCollector") do
			for _, uIScale in parent:GetChildren() do
				if uIScale:IsA("UIScale") then
					v11 *= uIScale.Scale
				end
			end

			parent = parent.Parent
		end

		if v11 <= 0 or instance.AbsoluteSize.Y <= 0 then
			return
		end

		local v12 = not uIPadding and 0 or uIPadding.PaddingTop.Offset + uIPadding.PaddingBottom.Offset + (uIPadding.PaddingTop.Scale + uIPadding.PaddingBottom.Scale) * instance.AbsoluteSize.Y / v11
		instance.CanvasSize = UDim2.fromOffset(0, (math.ceil(uIListLayout.AbsoluteContentSize.Y / v11 + v12)))
	end

	uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
	instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
	resize()
end

function Store.Init()
	v3 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("商店")
	v4 = v3:WaitForChild("背景")
	panel = v4:WaitForChild("面板")
	local v11 = panel:WaitForChild("关闭按钮")
	v6 = panel:WaitForChild("货币商店")
	v7 = panel:WaitForChild("通用宝箱抽奖页面")
	v8 = panel:WaitForChild("主页")
	bindContentCanvas(v8)
	bindContentCanvas(v6)
	local v12 = panel:WaitForChild("上方选择栏"):WaitForChild("上方选择栏")
	local button = v12:WaitForChild("主页按钮")
	local button2 = v12:WaitForChild("小球商店按钮")
	local button3 = v12:WaitForChild("爆炸特效商店按钮")
	local button4 = v12:WaitForChild("飞行器商店按钮")
	local firstChild = v12:FindFirstChild("货币商店按钮")
	local v17 = panel:WaitForChild("玩家货币栏")
	local _24H = panel:WaitForChild("24H新手礼包按钮")
	size = panel.Size
	v9 = LootboxNav.Init(panel)
	setupButtonFeedback(v11)
	ButtonActions.Bind(v11, hideStore)
	setupButtonFeedback(button)
	ButtonActions.Bind(button, function()
		v2 = "home"
		v8.Visible = true
		v6.Visible = false
		v7.Visible = v10.home ~= nil
		local home = v10.home

		if home then
			v9.setItemType(home)
		end

		v9.hidePage()
	end)
	setupButtonFeedback(button2)
	ButtonActions.Bind(button2, function()
		v2 = "ball"
		v8.Visible = false
		v6.Visible = false
		v7.Visible = v10.ball ~= nil
		local ball = v10.ball

		if ball then
			v9.setItemType(ball)
		end

		v9.hidePage()
	end)
	setupButtonFeedback(button3)
	ButtonActions.Bind(button3, function()
		v2 = "explosion"
		v8.Visible = false
		v6.Visible = false
		v7.Visible = v10.explosion ~= nil
		local explosion = v10.explosion

		if explosion then
			v9.setItemType(explosion)
		end

		v9.hidePage()
	end)
	setupButtonFeedback(button4)
	ButtonActions.Bind(button4, function()
		v2 = "flyer"
		v8.Visible = false
		v6.Visible = false
		v7.Visible = v10.flyer ~= nil
		local flyer = v10.flyer

		if flyer then
			v9.setItemType(flyer)
		end

		v9.hidePage()
	end)

	if firstChild then
		setupButtonFeedback(firstChild)
		ButtonActions.Bind(firstChild, function()
			v2 = "currency"
			v8.Visible = false
			v6.Visible = true
			v7.Visible = v10.currency ~= nil
			local currency = v10.currency

			if currency then
				v9.setItemType(currency)
			end

			v9.hidePage()
		end)
	end

	DailyShop.Init(v8, setupButtonFeedback)
	LimitedPack.BindStoreEntries(v8:WaitForChild("限时礼包"), setupButtonFeedback)
	v2 = "home"
	v8.Visible = true
	v6.Visible = false
	v7.Visible = v10.home ~= nil
	local home = v10.home

	if home then
		v9.setItemType(home)
	end

	v9.hidePage()
	bindPlayerCurrencyBar(v17)
	setupButtonFeedback(_24H)
	StarterPackOffer.bindEntryButton(_24H, hideStore)
	populateCurrencyShop(v6:WaitForChild("钻石商品"), Config.currencyStore and Config.currencyStore.byCurrencyCnId["钻石"])
	local v18 = v6:WaitForChild("每日钻石活动")
	local v19 = v6:WaitForChild("每日纯钻石")
	v18.Visible = GameFlags.feature["每日钻石"] == true
	v19.Visible = GameFlags.feature["每日纯钻石"] == true

	if v18.Visible then
		DailyDiamondDeal.Init(v18, setupButtonFeedback)
	end

	if v19.Visible then
		DailyDiamonds.Init(v19, setupButtonFeedback)
	end

	local v20 = v8:WaitForChild("钻石奖券活动")
	v20.Visible = DiamondDrawService.isEnabled()

	for _, v21 in {
		v20:WaitForChild("整卡跳转按钮"),
		v20:WaitForChild("查看按钮"),
		v6:WaitForChild("每日钻石活动"):WaitForChild("每日礼包"):WaitForChild("使用按钮")
	} do
		setupButtonFeedback(v21)
		ButtonActions.Bind(v21, function()
			if not DiamondDrawService.isEnabled() then
				return
			end

			hideStore()
			DiamondDraw.Open("current")
		end)
	end

	v20:WaitForChild("整卡跳转按钮"):SetAttribute("StoreGamepadAction", nil)
	v4.Visible = false
	local tabs = {
		{
			key = "home",
			button = button
		},
		{
			key = "ball",
			button = button2
		},
		{
			key = "explosion",
			button = button3
		},
		{
			key = "flyer",
			button = button4
		}
	}

	if firstChild then
		table.insert(tabs, 2, {
			key = "currency",
			button = firstChild
		})
	end

	v = GamepadNavigation.new({
		panel = panel,
		pages = { v8, v6, v7 },
		tabs = tabs,
		isOpen = function()
			return flag
		end,
		getTab = function()
			return v2
		end,
		onTab = switchTab,
		onBack = function()
			v9.back()
		end,
		onClose = hideStore
	})

	if ServerTeleport.getServerType() ~= ServerTypeService.TRADE_POOL_NAME then
		workspace:WaitForChild("大厅"):WaitForChild("商店模型"):WaitForChild("triggerPart"):WaitForChild("ProximityPrompt").Triggered:Connect(function(player)
			if player == Players.LocalPlayer and not flag then
				Store.OpenLootbox()
			end
		end)
		workspace:WaitForChild("大厅"):WaitForChild("飞行器展示"):WaitForChild("交互点"):WaitForChild("ProximityPrompt").Triggered:Connect(function(player)
			if player == Players.LocalPlayer and not flag then
				Store.OpenFlyerShop()
			end
		end)
		workspace:WaitForChild("大厅"):WaitForChild("爆炸特效展示"):WaitForChild("交互点"):WaitForChild("ProximityPrompt").Triggered:Connect(function(player)
			if player == Players.LocalPlayer and not flag then
				Store.OpenExplosionShop()
			end
		end)
	end
end

return Store