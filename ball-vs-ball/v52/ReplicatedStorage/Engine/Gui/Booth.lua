local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DiamondTopUpService = require(ReplicatedStorage.Engine.Service.DiamondTopUpService)
local Players = game:GetService("Players")
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local Config = require(ReplicatedStorage.Engine.Service.Config)
local BoothService = require(ReplicatedStorage.Engine.Service.BoothService)
local client2 = BoothService.client
local ConfirmDialogController = require(script.Parent.ConfirmDialogController)
local BoothSaleNotification = require(script.Parent.BoothSaleNotification)
local RAPService = require(ReplicatedStorage.Engine.Service.RAPService)
local RAPChart = require(script.RAPChart)
local Booth = {}
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil
local parent = nil
local _1 = nil
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local v16 = nil
local v17 = nil
local v18 = {}
local backgroundColor3 = nil
local backgroundColor32 = nil
local v19 = nil
local _12 = nil
local v20 = nil
local v21 = nil
local v22 = nil
local v23 = nil
local v24 = nil
local v25 = nil
local v26 = nil
local v27 = nil
local v28 = nil
local v29 = nil
local v30 = nil
local v31 = nil
local v32 = nil
local v33 = nil
local v34 = nil
local v35 = nil
local parent2 = nil
local _13 = nil
local v37 = nil
local v38 = "Ball"
local v39 = nil
local v40 = nil
local flag = false
local flag2 = false
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local size = nil
local v41 = {
	purchase = {
		listingGone = "小摊购买_商品已失效",
		sellerOffline = "小摊购买_卖家已离线",
		boothClosed = "小摊购买_已停止营业",
		itemGone = "小摊购买_物品不存在",
		notEnoughCurrency = "小摊购买_钻石不足",
		selfBuy = "小摊购买_不能自购",
		invalid = "小摊购买_请求无效"
	},
	list = {
		invalid = "小摊上架_价格无效",
		full = "小摊上架_已达上限",
		notOwned = "小摊上架_不再拥有",
		notTradable = "小摊上架_不可交易",
		lockFailed = "小摊上架_锁定失败"
	},
	unlist = {
		failed = "小摊下架_记录失效"
	},
	close = {
		failed = "小摊收摊_没有摊位"
	}
}

local function getBoothFailureText(p: string, value: string?)
	local v42 = v41[p]
	local v43 = value == "requestFailed" and "小摊操作_结果未确认" or v42 and v42[value or "failed"] or "小摊操作_失败"
	local asset = Config.asset

	local function findText(p2: string)
		local v44 = asset and asset.byCnId and asset.byCnId[p2]

		if v44 and typeof(v44.txt) == "string" and v44.txt ~= "" then
			return v44.txt
		end

		for _, v45 in asset and asset.list or {} do
			if v45.cnId == p2 and typeof(v45.txt) == "string" and v45.txt ~= "" then
				return v45.txt
			end
		end

		return nil
	end

	local text = findText(v43)

	if not text then
		warn("[Booth] Config.asset 缺少提示文案，请同步飞书配置: " .. v43)
		text = findText("小摊操作_失败")
	end

	return text
end

local function showBoothFailure(p: string, p2: string?, callback)
	local boothFailureText = getBoothFailureText(p, p2)

	if not boothFailureText then
		return
	end

	local connection = nil
	ConfirmDialogController.Enqueue("通用确认面板", {
		category = "BoothFailure",
		priority = 10,
		onShown = function(instance, callback2)
			local waitForChild = instance:WaitForChild("文本")
			waitForChild.Text = boothFailureText
			local v42 = instance:WaitForChild("确定按钮")
			connection = ConfirmDialogController.BindButton(v42, "A", function()
				if connection then
					connection:Disconnect()
				end

				callback2()

				if callback then
					callback()
				end
			end)
		end,
		onHidden = function()
			if connection then
				connection:Disconnect()
			end
		end
	})
end

local function invokeBoothRequest(callback, ...)
	local success, result, v42, v43, v44 = pcall(callback, ...)

	if success then
		return result == true, v42, v43, v44
	end

	warn("[Booth] 请求异常: " .. tostring(result))
	return false, "requestFailed", nil, nil
end

local function setupButtonFeedback(data)
	local size2 = data.Size
	data.MouseEnter:Connect(function()
		TweenService:Create(data, TweenInfo.new(0.1), {
			Size = UDim2.new(size2.X.Scale * 1.05, size2.X.Offset * 1.05, size2.Y.Scale * 1.05, size2.Y.Offset * 1.05)
		}):Play()
	end)
	data.MouseLeave:Connect(function()
		TweenService:Create(data, TweenInfo.new(0.1), {
			Size = size2
		}):Play()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isValidImageValue(image)
	return typeof(image) == "string" and image ~= "" and string.match(image, "^%a+://") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findRatingByLvl(rating: number)
	for _, v42 in Config.rating.list do
		if v42.lvl == rating then
			return v42
		end
	end

	return nil
end

local function resolveItemDisplay(p: string, p2: string)
	if p == "Ball" then
		local v42 = Config.ball.byCnId[p2]

		if not v42 then
			return nil
		end

		local ratingByLvl = findRatingByLvl(v42.rating) -- equivalent call inferred; original call site unknown
		local v43 = {
			name = v42.displayName,
			image = 0,
			ratingName = 0,
			ratingColor = 0
		}
		local validImageValue = isValidImageValue(v42.image) -- equivalent call inferred; original call site unknown
		v43.image = not validImageValue and "" or v42.image
		local ratingName

		if ratingByLvl then
			ratingName = ratingByLvl.name
		end

		v43.ratingName = ratingName
		local ratingColor

		if ratingByLvl then
			ratingColor = Color3.fromHex(ratingByLvl.colorHex)
		end

		v43.ratingColor = ratingColor
		return v43
	else
		local v42 = Config.skin.byCnId[p2]

		if not v42 then
			return nil
		end

		local ratingByLvl = findRatingByLvl(v42.rating) -- equivalent call inferred; original call site unknown
		local v43 = {
			name = v42.name,
			image = 0,
			ratingName = 0,
			ratingColor = 0
		}
		local validImageValue = isValidImageValue(v42.image) -- equivalent call inferred; original call site unknown
		v43.image = not validImageValue and "" or v42.image
		local ratingName

		if ratingByLvl then
			ratingName = ratingByLvl.name
		end

		v43.ratingName = ratingName
		local ratingColor

		if ratingByLvl then
			ratingColor = Color3.fromHex(ratingByLvl.colorHex)
		end

		v43.ratingColor = ratingColor
		return v43
	end
end

local function ratingLevelFor(p: string, p2: string)
	local v42

	if p == "Ball" then
		v42 = Config.ball.byCnId[p2]
	else
		v42 = Config.skin.byCnId[p2]
	end

	if v42 and typeof(v42.rating) == "number" then
		return v42.rating
	end

	return -1e999
end

local function formatSerial(p: number)
	return "#" .. string.format("%d", p):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function showBackground()
	if flag then
		return
	end

	flag = true
	v2.Visible = true
	v2.BackgroundTransparency = 1
	TweenService:Create(v2, tweenInfo, {
		BackgroundTransparency = 0.5
	}):Play()
	v3.AnchorPoint = Vector2.new(0.5, 0.5)
	v3.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(v3, tweenInfo2, {
		Size = size
	}):Play()
end

local function hideBackground()
	if not flag then
		return
	end

	flag = false
	v40 = nil
	TweenService:Create(v2, tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(v3, tweenInfo3, {
		Size = UDim2.new(0, 0, 0, 0)
	}):Play()
	task.delay(tweenInfo3.Time, function()
		v2.Visible = false
	end)
end

local function destroyStaticSlots(instance, _14, p)
	for _, guiObject in instance:GetChildren() do
		if guiObject == _14 or not (guiObject:IsA("GuiButton") or guiObject:IsA("Frame")) or p and p[guiObject] then
			continue
		end

		guiObject:Destroy()
	end
end

local function clearGeneratedSlots(instance)
	for _, guiObject in instance:GetChildren() do
		if not ((guiObject:IsA("GuiButton") or guiObject:IsA("Frame")) and guiObject:GetAttribute("BoothGeneratedSlot")) then
			continue
		end

		guiObject:Destroy()
	end
end

local function refreshListed()
	v14.Visible = Players.LocalPlayer:GetAttribute("BoothHasStall") == true
	local boothListings = client.boothListings()
	local items = client.items()
	local v42 = {}

	for k, boothListing in boothListings do
		local item = items[boothListing.itemInstanceId]

		if item then
			table.insert(v42, {
				listingId = k,
				listing = boothListing,
				item = item
			})
		end
	end

	table.sort(v42, function(a, b)
		return (a.listing.listedAt or 0) < (b.listing.listedAt or 0)
	end)
	clearGeneratedSlots(parent)
	local count = #v42
	v9.Text = string.format("Listed %d / 8", count)

	for k, v43 in v42 do
		local clone = _1:Clone()
		clone.Name = "格子" .. k
		clone.LayoutOrder = k
		clone:SetAttribute("BoothGeneratedSlot", true)
		clone.Visible = true
		clone.Parent = parent
		local itemDisplay = resolveItemDisplay(v43.item.itemType, v43.item.itemId)
		local firstChild = clone:FindFirstChild("名称")
		local firstChild2 = clone:FindFirstChild("唯一编号")
		local firstChild3 = clone:FindFirstChild("物品图标")
		local firstChild4 = clone:FindFirstChild("卡片背景")
		local v44 = firstChild4 and firstChild4:FindFirstChild("品质描边")
		local firstChild5 = clone:FindFirstChild("售价")
		local v45 = firstChild5 and firstChild5:FindFirstChild("数量")
		local firstChild6 = clone:FindFirstChild("下架按钮")

		if itemDisplay and firstChild then
			firstChild.Text = itemDisplay.name
		end

		if firstChild2 then
			firstChild2.Visible = v43.item.serial ~= nil

			if v43.item.serial then
				firstChild2.Text = formatSerial(v43.item.serial)
			end
		end

		if firstChild3 and itemDisplay then
			firstChild3.Image = itemDisplay.image
		end

		if v44 and itemDisplay and itemDisplay.ratingColor then
			v44.Color = itemDisplay.ratingColor
		end

		if v45 then
			v45.Text = tostring(v43.listing.price)
		end

		if not firstChild6 then
			continue
		end

		setupButtonFeedback(firstChild6)
		local v46 = v43
		ButtonActions.Bind(firstChild6, function()
			local v47, v48 = invokeBoothRequest(client2.requestUnlist, v46.listingId)

			if not v47 then
				showBoothFailure("unlist", v48)
			end
		end)
	end

	v12.LayoutOrder = count + 1
	v12.Visible = count < 8
	v15.Visible = count >= 8
	v13.Visible = count == 0
	v10.CanvasPosition = Vector2.new(0, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateListButtonState()
	v31.Visible = false
	local visible = v39 ~= nil
	v21.Visible = visible
	v29.Visible = visible
	v30.Visible = not visible

	if not visible then
		return
	end

	local text = tonumber(v26.Text) or 0
	local v43 = math.floor(text * 0.95)
	local v44 = text - v43
	v27.Text = tostring(v44)
	v28.Text = tostring(v43)
end

local function showCandidateDetail(itemType: string, itemId: string, instanceId: string, serial: number?)
	local itemDisplay = resolveItemDisplay(itemType, itemId)

	if not itemDisplay then
		return
	end

	v22.Image = itemDisplay.image
	v23.Text = itemDisplay.name

	if itemDisplay.ratingName then
		v24.Text = itemDisplay.ratingName
	end

	if itemDisplay.ratingColor then
		v24.TextColor3 = itemDisplay.ratingColor
	end

	v25.Visible = serial ~= nil

	if serial then
		v25.Text = formatSerial(serial)
	end

	v39 = {
		instanceId = instanceId,
		itemType = itemType,
		itemId = itemId
	}
	updateListButtonState() -- equivalent call inferred; original call site unknown
end

local function isEligibleForListing(data, p: string)
	if typeof(data) ~= "table" or data.itemType ~= p then
		return false
	end

	return data.tradable == true and next(data.locks or {}) == nil
end

local function refreshCategory(p: string)
	local v42 = _12
	local parent3 = v19

	if not (v42 and parent3) then
		return
	end

	clearGeneratedSlots(parent3)
	local v44 = {}

	for _, v45 in client.items() do
		local v46

		if typeof(v45) == "table" and v45.itemType == p and v45.tradable == true then
			v46 = next(v45.locks or {}) == nil
		else
			v46 = false
		end

		if v46 then
			table.insert(v44, v45)
		end
	end

	table.sort(v44, function(a, b)
		local itemType = a.itemType
		local itemId = a.itemId
		local v45

		if itemType == "Ball" then
			v45 = Config.ball.byCnId[itemId]
		else
			v45 = Config.skin.byCnId[itemId]
		end

		local v46 = (not v45 or typeof(v45.rating) ~= "number") and -1e999 or v45.rating
		local itemType2 = b.itemType
		local itemId2 = b.itemId
		local v47

		if itemType2 == "Ball" then
			v47 = Config.ball.byCnId[itemId2]
		else
			v47 = Config.skin.byCnId[itemId2]
		end

		local v48 = (not v47 or typeof(v47.rating) ~= "number") and -1e999 or v47.rating

		if v46 ~= v48 then
			return v48 < v46
		end

		local itemId3 = tostring(a.itemId)
		local itemId4 = tostring(b.itemId)

		if itemId3 == itemId4 then
			return tostring(a.instanceId) < tostring(b.instanceId)
		end

		return itemId3 < itemId4
	end)

	for k, v45 in v44 do
		local clone = v42:Clone()
		clone.Name = "格子" .. k
		clone.LayoutOrder = k
		clone:SetAttribute("BoothGeneratedSlot", true)
		clone.Visible = true
		clone.Parent = parent3
		local itemDisplay = resolveItemDisplay(v45.itemType, v45.itemId)
		local firstChild = clone:FindFirstChild("名称")
		local firstChild2 = clone:FindFirstChild("唯一编号")
		local firstChild3 = clone:FindFirstChild("物品图标")
		local firstChild4 = clone:FindFirstChild("卡片背景")
		local v46 = firstChild4 and firstChild4:FindFirstChild("品质描边")

		if itemDisplay and firstChild then
			firstChild.Text = itemDisplay.name
		end

		if firstChild2 then
			firstChild2.Visible = v45.serial ~= nil

			if v45.serial then
				firstChild2.Text = formatSerial(v45.serial)
			end
		end

		if firstChild3 and itemDisplay then
			firstChild3.Image = itemDisplay.image
		end

		if v46 and itemDisplay and itemDisplay.ratingColor then
			v46.Color = itemDisplay.ratingColor
		end

		setupButtonFeedback(clone)
		local v47 = v45
		ButtonActions.Bind(clone, function()
			showCandidateDetail(v47.itemType, v47.itemId, v47.instanceId, v47.serial)
		end)
	end

	v20.Visible = #v44 == 0
	parent3.CanvasPosition = Vector2.new(0, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCategoryButtonColors()
	if not (backgroundColor3 and backgroundColor32) then
		return
	end

	for k, v42 in v18 do
		local backgroundColor

		if k == v38 then
			backgroundColor = backgroundColor3
		else
			backgroundColor = backgroundColor32
		end

		v42.BackgroundColor3 = backgroundColor
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function switchCategoryTab(p: string)
	v38 = p
	updateCategoryButtonColors() -- equivalent call inferred; original call site unknown
	v39 = nil
	updateListButtonState() -- equivalent call inferred; original call site unknown
	refreshCategory(p)
end

local function openListItemView()
	v7.Visible = false
	v16.Visible = true
	v39 = nil
	v26.Text = ""
	v31.Visible = false
	updateListButtonState() -- equivalent call inferred; original call site unknown
	switchCategoryTab(v38) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function backToListedView()
	v16.Visible = false
	v7.Visible = true
	refreshListed()
end

local count = 0

local function openPurchaseConfirm(p: number, p2: string, data, data2)
	if p == Players.LocalPlayer.UserId then
		return
	end

	ConfirmDialogController.Enqueue("摆摊购买确认面板", {
		category = "BoothPurchase",
		onShown = function(instance, callback)
			local v42 = instance:WaitForChild("物品信息")
			local v43 = v42:WaitForChild("图标背景")
			local v44 = v43:WaitForChild("物品图标")
			local firstChild = v43:FindFirstChild("品质描边")
			local v45 = v42:WaitForChild("名称")
			local v46 = v42:WaitForChild("唯一编号")
			local v47 = v42:WaitForChild("卖家名字")
			local v48 = instance:WaitForChild("价格区域"):WaitForChild("数量")
			local v49 = instance:WaitForChild("取消按钮")
			local v50 = instance:WaitForChild("确定按钮")
			v44.Image = data2.image
			v45.Text = data2.name

			if firstChild and data2.ratingColor then
				firstChild.Color = data2.ratingColor
			end

			v46.Visible = data.serial ~= nil

			if data.serial then
				v46.Text = formatSerial(data.serial)
			end

			v47.Text = "Seller: " .. p2
			v48.Text = tostring(data.price)
			count += 1
			local v51 = count
			RAPChart.SetLoading()
			task.spawn(function()
				local success, result = pcall(RAPService.getHistory, data.itemId)

				if v51 ~= count then
					return
				end

				if success then
					RAPChart.Render(result)
				end
			end)
			local connection = nil
			local connection2 = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function cleanup()
				connection:Disconnect()
				connection2:Disconnect()
			end

			connection = ConfirmDialogController.BindButton(v49, "B", function()
				cleanup() -- equivalent call inferred; original call site unknown
				callback()
			end)
			connection2 = ConfirmDialogController.BindButton(v50, "A", function()
				cleanup() -- equivalent call inferred; original call site unknown
				local v52, v53, v54, v55 = invokeBoothRequest(client2.requestPurchase, p, data.listingId)
				callback()

				if v52 and v55 then
					BoothSaleNotification.ShowPurchase(v55, instance)
				end

				if not v52 then
					showBoothFailure("purchase", v53, v53 == "notEnoughCurrency" and v54 and function()
						DiamondTopUpService.promptIfInsufficient(v54)
					end or nil)
				end

				if v52 and v40 == p then
					task.spawn(function()
						Booth.RefreshView()
					end)
				end
			end)
		end
	})
end

local function refreshViewBoard(p: number)
	local sellerListings = client2.getSellerListings(p)

	if not sellerListings then
		hideBackground()
		return
	end

	v32.Text = sellerListings.ownerName .. "'s Booth"
	v33.Text = "● Online"
	v34.Text = tostring(client.diamonds())
	clearGeneratedSlots(parent2)
	local listings = sellerListings.listings or {}

	for k, listing in listings do
		local clone = _13:Clone()
		clone.Name = "格子" .. k
		clone.LayoutOrder = k
		clone:SetAttribute("BoothGeneratedSlot", true)
		clone.Visible = true
		clone.Parent = parent2
		local itemDisplay = resolveItemDisplay(listing.itemType, listing.itemId)
		local firstChild = clone:FindFirstChild("名称")
		local firstChild2 = clone:FindFirstChild("唯一编号")
		local firstChild3 = clone:FindFirstChild("物品图标")
		local firstChild4 = clone:FindFirstChild("卡片背景")
		local v42 = firstChild4 and firstChild4:FindFirstChild("品质描边")
		local firstChild5 = clone:FindFirstChild("购买按钮")
		local v43 = firstChild5 and firstChild5:FindFirstChild("数量")

		if itemDisplay and firstChild then
			firstChild.Text = itemDisplay.name
		end

		if firstChild2 then
			firstChild2.Visible = listing.serial ~= nil

			if listing.serial then
				firstChild2.Text = formatSerial(listing.serial)
			end
		end

		if firstChild3 and itemDisplay then
			firstChild3.Image = itemDisplay.image
		end

		if v42 and itemDisplay and itemDisplay.ratingColor then
			v42.Color = itemDisplay.ratingColor
		end

		if v43 then
			v43.Text = tostring(listing.price)
		end

		if not (firstChild5 and itemDisplay) then
			continue
		end

		setupButtonFeedback(firstChild5)
		local v44 = listing
		local v45 = itemDisplay
		ButtonActions.Bind(firstChild5, function()
			openPurchaseConfirm(p, sellerListings.ownerName, v44, v45)
		end)
	end

	v37.Visible = #listings == 0
	v35.CanvasPosition = Vector2.new(0, 0)
end

function Booth.RefreshView()
	if v40 then
		refreshViewBoard(v40)
	end
end

function Booth.OpenPurchaseFlow(p: number, p2: string, p3)
	local itemDisplay = resolveItemDisplay(p3.itemType, p3.itemId)

	if not itemDisplay then
		return
	end

	openPurchaseConfirm(p, p2, p3, itemDisplay)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openManageView()
	v6.Visible = false
	v5.Visible = true
	v16.Visible = false
	v7.Visible = true
	showBackground()
	refreshListed()
end

function Booth.OpenListing(p: number, p2: string, p3)
	if not flag2 then
		return
	end

	if p ~= Players.LocalPlayer.UserId then
		Booth.OpenPurchaseFlow(p, p2, p3)
		return
	end

	openManageView() -- equivalent call inferred; original call site unknown
end

function Booth.OpenManage()
	if flag2 then
		openManageView() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openViewBoard(p: number)
	v5.Visible = false
	v6.Visible = true
	v40 = p
	showBackground()
	refreshViewBoard(p)
end

function Booth.Init()
	v = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("小摊")
	v2 = v:WaitForChild("背景")
	v3 = v2:WaitForChild("面板")
	v4 = v3:WaitForChild("我的摊位"):WaitForChild("已上架"):WaitForChild("关闭按钮")
	v5 = v3:WaitForChild("我的摊位")
	v6 = v3:WaitForChild("查看摊位")
	v7 = v5:WaitForChild("已上架")
	v8 = v7:WaitForChild("营业状态")
	v9 = v7:WaitForChild("上架数量")
	v10 = v7:WaitForChild("上架列表")
	parent = v10:WaitForChild("格子容器")
	_1 = parent:WaitForChild("格子1")
	_1.Visible = false
	v12 = parent:WaitForChild("添加按钮")
	destroyStaticSlots(parent, _1, {
		[v12] = true
	})
	v13 = v7:WaitForChild("空摊提示")
	v14 = v7:WaitForChild("收摊按钮")
	v15 = v7:WaitForChild("上架已满提示")
	v16 = v5:WaitForChild("选择上架物品")
	v17 = v16:WaitForChild("返回按钮")
	local v42 = v16:WaitForChild("分类栏")
	v18.Ball = v42:WaitForChild("小球库存按钮")
	v18["爆炸特效"] = v42:WaitForChild("爆炸特效库存按钮")
	v18["飞行器"] = v42:WaitForChild("飞行器库存按钮")
	backgroundColor3 = v18.Ball.BackgroundColor3
	backgroundColor32 = v18["爆炸特效"].BackgroundColor3
	updateCategoryButtonColors() -- equivalent call inferred; original call site unknown
	local v43 = v16:WaitForChild("库存列表")
	v19 = v43:WaitForChild("通用列表")
	_12 = v19:WaitForChild("格子1")
	_12.Visible = false
	destroyStaticSlots(v19, _12)
	v20 = v43:WaitForChild("空库存提示")
	v21 = v16:WaitForChild("定价上架区")
	local v44 = v21:WaitForChild("物品详情")
	v22 = v44:WaitForChild("物品图标")
	v23 = v44:WaitForChild("名称")
	v24 = v44:WaitForChild("品质")
	v25 = v44:WaitForChild("唯一编号")
	local v45 = v21:WaitForChild("定价输入框")
	v26 = v45:WaitForChild("数量输入框")
	v27 = v45:WaitForChild("手续费数量")
	v28 = v45:WaitForChild("实收数量")
	v29 = v21:WaitForChild("上架按钮")
	v30 = v21:WaitForChild("无法上架按钮")
	v31 = v21:WaitForChild("错误提示")
	v32 = v6:WaitForChild("标题")
	v33 = v6:WaitForChild("营业状态")
	v34 = v6:WaitForChild("钻石余额"):WaitForChild("数量")
	v35 = v6:WaitForChild("上架列表")
	parent2 = v35:WaitForChild("格子容器")
	_13 = parent2:WaitForChild("格子1")
	_13.Visible = false
	v37 = v6:WaitForChild("空摊提示")
	local firstChild = v6:FindFirstChild("离线提示")

	if firstChild then
		firstChild.Visible = false
	end

	destroyStaticSlots(parent2, _13)
	size = v3.Size
	setupButtonFeedback(v4)
	ButtonActions.Bind(v4, hideBackground)
	local v46 = v6:WaitForChild("关闭按钮")
	setupButtonFeedback(v46)
	ButtonActions.Bind(v46, hideBackground)
	setupButtonFeedback(v12)
	ButtonActions.Bind(v12, openListItemView)
	setupButtonFeedback(v17)
	ButtonActions.Bind(v17, backToListedView)
	setupButtonFeedback(v14)
	ButtonActions.Bind(v14, function()
		local v47, v48 = invokeBoothRequest(client2.requestClose)

		if v47 then
			hideBackground()
		else
			showBoothFailure("close", v48)
		end
	end)

	for k, v47 in v18 do
		setupButtonFeedback(v47)
		local v48 = k
		ButtonActions.Bind(v47, function()
			switchCategoryTab(v48) -- equivalent call inferred; original call site unknown
		end)
	end

	v26:GetPropertyChangedSignal("Text"):Connect(updateListButtonState)
	setupButtonFeedback(v29)
	ButtonActions.Bind(v29, function()
		if not v39 then
			return
		end

		local text = tonumber(v26.Text)

		if not text or text <= 0 or text ~= math.floor(text) or math.floor(text * 0.95) <= 0 then
			showBoothFailure("list", "invalid")
			return
		end

		v31.Visible = false
		local v47, v48 = invokeBoothRequest(client2.requestList, v39.instanceId, text)

		if not v47 then
			showBoothFailure("list", v48)
			return
		end

		backToListedView() -- equivalent call inferred; original call site unknown
	end)
	client2.onOpenPanel(function(p: string, p2: number?)
		if p == "manage" then
			openManageView() -- equivalent call inferred; original call site unknown
		elseif p == "view" and p2 then
			openViewBoard(p2) -- equivalent call inferred; original call site unknown
		end
	end)
	RAPChart.Init()
	client.boothListings.Changed(function()
		if flag and v5.Visible and v7.Visible then
			refreshListed()
		end
	end)
	Players.LocalPlayer:GetAttributeChangedSignal("BoothHasStall"):Connect(function()
		v14.Visible = Players.LocalPlayer:GetAttribute("BoothHasStall") == true
	end)
	client2.onSellerChanged(function(p)
		if flag and v40 == p.ownerUserId then
			Booth.RefreshView()
		end
	end)
	v14.Visible = Players.LocalPlayer:GetAttribute("BoothHasStall") == true
	v2.Visible = false
	flag2 = true
end

return Booth