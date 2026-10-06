local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Net = require(ReplicatedStorage.Packages.Net)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local Config = require(ReplicatedStorage.Engine.Service.Config)
local ItemMetadataDisplay = require(ReplicatedStorage.Engine.Gui.Inventory.ItemMetadataDisplay)
local AssetLibrary = require(ReplicatedStorage.Engine.Service.AssetLibrary)
local LazyGrid = require(ReplicatedStorage.Engine.Gui.Inventory.LazyGrid)
local BallCardQuality = require(ReplicatedStorage.Engine.Service.BallCardQuality)
local BallQualityTextStyle = require(ReplicatedStorage.Engine.Service.BallQualityTextStyle)
local PlayerThumbnail = require(ReplicatedStorage.Engine.Service.PlayerThumbnail)
local ConfirmDialogController = require(script.Parent.ConfirmDialogController)
local NumberFormat = require(ReplicatedStorage.Packages.NumberFormat)
local GamepadNavigation = require(script.GamepadNavigation)
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
local v = nil
local Trade = {}
local remoteEvent = Net:RemoteEvent("TradeRequest")
local remoteEvent2 = Net:RemoteEvent("TradeRespond")
local remoteEvent3 = Net:RemoteEvent("TradeOffer")
local remoteEvent4 = Net:RemoteEvent("TradeSetDiamonds")
local remoteEvent5 = Net:RemoteEvent("TradeAccept")
local remoteEvent6 = Net:RemoteEvent("TradeCancel")
local remoteEvent7 = Net:RemoteEvent("TradeState")
local v2 = { "Ball", "爆炸特效", "飞行器" }
local v3 = nil
local v4 = nil
local folder = nil
local v5 = nil
local ownList = nil
local otherList = nil
local accept = nil
local countdown = nil
local decline = nil
local v11 = nil
local v12 = nil
local v13 = nil
local v14 = nil
local diamonds = nil
local v16 = nil
local v17 = nil
local v18 = nil
local v19 = nil
local v20 = nil
local v21 = {}
local v22 = nil
local inventoryList = nil
local v24 = nil
local v25 = nil
local v26 = {}
local canvasPositions = {}
local count = 0
local v27 = {}
local backgroundColor3 = nil
local backgroundColor32 = nil
local v28 = "Ball"
local flag = false
local count2 = 0
local size = nil
local count3 = 0
local v29 = 0
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)

-- equivalent calls inferred from this helper; original call sites unknown
local function hideConfirmation()
	ConfirmDialogController.Hide()
end

local function scaleUDim2(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset * p, udim.Y.Scale * p, udim.Y.Offset * p)
end

local function setupButtonFeedback(data)
	local size2 = data.Size
	data.MouseEnter:Connect(function()
		local size3 = size2
		TweenService:Create(data, TweenInfo.new(0.1), {
			Size = UDim2.new(size3.X.Scale * 1.05, size3.X.Offset * 1.05, size3.Y.Scale * 1.05, size3.Y.Offset * 1.05)
		}):Play()
	end)
	data.MouseLeave:Connect(function()
		TweenService:Create(data, TweenInfo.new(0.1), {
			Size = size2
		}):Play()
	end)
end

local function flashInvalid(p)
	local color = p.Color
	TweenService:Create(p, TweenInfo.new(0.12), {
		Color = Color3.fromRGB(255, 60, 60)
	}):Play()
	task.delay(0.35, function()
		TweenService:Create(p, TweenInfo.new(0.25), {
			Color = color
		}):Play()
	end)
end

local function receivedAfterTax(p: number)
	return (math.floor(p * 0.95))
end

local function showTrade()
	if v4.Visible then
		return
	end

	count3 += 1
	v4.Visible = true
	v4.BackgroundTransparency = 1
	folder.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(v4, tweenInfo, {
		BackgroundTransparency = 0.5
	}):Play()
	TweenService:Create(folder, tweenInfo2, {
		Size = size
	}):Play()
end

local function closeTrade()
	if v then
		v:Close()
	end

	count2 += 1
	count3 += 1
	local v30 = count3
	TweenService:Create(v4, tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(folder, tweenInfo3, {
		Size = UDim2.new(0, 0, 0, 0)
	}):Play()
	task.delay(tweenInfo3.Time, function()
		if count3 ~= v30 then
			return
		end

		v4.Visible = false
		folder.Size = size
	end)
	v20 = nil
	v21 = {}
	hideConfirmation() -- equivalent call inferred; original call site unknown

	if v25 then
		v25:Set(v24, {})
		v25:Update()
	end

	diamonds.Text = ""
	v29 = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function definitionFor(p: string, p2: string)
	if p == "Ball" then
		return Config.ball.byCnId[p2]
	end

	return Config.skin.byCnId[p2]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function imageFor(p: string, p2: string)
	local v30 = definitionFor(p, p2) -- equivalent call inferred; original call site unknown

	if v30 and typeof(v30.image) == "string" and string.match(v30.image, "^%a+://") then
		return v30.image
	end

	return ""
end

-- equivalent calls inferred from this helper; original call sites unknown
local function nameFor(p: string, p2: string)
	local v30 = definitionFor(p, p2) -- equivalent call inferred; original call site unknown

	if not v30 then
		return p2
	end

	if p == "Ball" then
		return v30.displayName
	end

	return v30.name
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ratingFor(p: string, p2: string)
	local v30 = definitionFor(p, p2) -- equivalent call inferred; original call site unknown

	if v30 and typeof(v30.rating) == "number" then
		return v30.rating
	end

	return -1e999
end

local function clearGenerated(parent)
	for _, child in ipairs(parent:GetChildren()) do
		if child:GetAttribute("TradeGenerated") then
			child:Destroy()
		end
	end
end

local function fillSlot(parent, itemType: string, itemId: string, serial: number?, killCount: number?, p)
	local button = p or AssetLibrary.Clone("小球卡片", "已拥有小球卡片")
	button.Name = "物品卡片"
	button.AnchorPoint = Vector2.zero
	button.Position = UDim2.fromScale(0, 0)
	button.Size = UDim2.fromScale(1, 1)
	button.SizeConstraint = Enum.SizeConstraint.RelativeXY
	button.AutomaticSize = Enum.AutomaticSize.None
	button.Selectable = false
	button.Active = false

	if button:IsA("GuiButton") then
		button.Interactable = false
		button.AutoButtonColor = false
	end

	for _, guiObject in button:GetDescendants() do
		if guiObject:IsA("GuiObject") then
			guiObject.Selectable = false
		end

		if not guiObject:IsA("GuiButton") then
			continue
		end

		guiObject.Interactable = false
		guiObject.Active = false
		guiObject.AutoButtonColor = false
	end

	parent.BackgroundTransparency = 1
	local firstChild = button:FindFirstChild("物品图标")
	firstChild.Image = imageFor(itemType, itemId)
	local firstChild2 = button:FindFirstChild("底栏"):FindFirstChild("名称")
	local text = nameFor(itemType, itemId) -- equivalent call inferred; original call site unknown
	firstChild2.Text = text
	local v31 = itemType ~= "Ball" and "Classic" or BallCardQuality.kind({
		serial = serial,
		killCount = killCount
	}, Config.ball.byCnId[itemId])
	BallQualityTextStyle.apply(firstChild2, v31)
	ItemMetadataDisplay.apply(button, serial, killCount)
	local firstChild3 = firstChild:FindFirstChild("击杀统计+唯一编号效果")
	local firstChild4 = firstChild:FindFirstChild("击杀统计效果")
	firstChild3.Visible = typeof(killCount) == "number" and typeof(serial) == "number"
	firstChild4.Visible = typeof(killCount) == "number" and typeof(serial) ~= "number"

	for _, childName in { "锁", "摆摊中遮罩", "数量" } do
		local findFirstChild = button:FindFirstChild(childName)
		findFirstChild.Visible = false
	end

	local v34 = ratingFor(itemType, itemId) -- equivalent call inferred; original call site unknown

	for _, v35 in Config.rating.list do
		if not (v35.lvl == v34 and typeof(v35.colorHex) == "string") then
			continue
		end

		local findFirstChild_2 = button:FindFirstChild("品质描边")
		findFirstChild_2.Color = Color3.fromHex(v35.colorHex)
		break
	end

	button.Visible = true
	button.Parent = parent

	if button:IsA("GuiButton") then
		button.Interactable = true
		button.Active = true
		button.AutoButtonColor = true
	end

	local guiObject = parent:FindFirstChild("选中")

	if not (guiObject and guiObject:IsA("GuiObject")) then
		return button
	end

	local zIndex = button.ZIndex

	for _, guiObject2 in button:GetDescendants() do
		if guiObject2:IsA("GuiObject") then
			zIndex = math.max(zIndex, guiObject2.ZIndex)
		end
	end

	guiObject.ZIndex = zIndex + 1

	for _, guiObject2 in guiObject:GetDescendants() do
		if guiObject2:IsA("GuiObject") then
			guiObject2.ZIndex = zIndex + 2
		end
	end

	return button
end

local fn
local fn2

local function renderOffer(parent, offer, flag2: boolean)
	clearGenerated(parent)
	local guiObject = parent:FindFirstChild("占位格子")

	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	guiObject.Visible = false
	local clone = table.clone(offer)
	table.sort(clone, function(a, b)
		local v30 = ratingFor(a.itemType, a.itemId) -- equivalent call inferred; original call site unknown
		local v31 = ratingFor(b.itemType, b.itemId) -- equivalent call inferred; original call site unknown

		if v30 == v31 then
			return tostring(a.instanceId) < tostring(b.instanceId)
		end

		return v31 < v30
	end)

	for i, v30 in ipairs(clone) do
		local clone2 = guiObject:Clone()
		clone2.Name = tostring(i)
		clone2.Visible = true
		clone2.LayoutOrder = i
		clone2:SetAttribute("TradeNavigationKey", v30.instanceId)
		clone2:SetAttribute("TradeGenerated", true)
		local v31 = fillSlot(clone2, v30.itemType, v30.itemId, v30.serial, ItemMetadataDisplay.getKillCount(v30))

		if flag2 then
			local v32 = v31
			local v33 = v30
			ButtonActions.Bind(v31, function()
				if not (v20 and GamepadSupport.CanActivate(v32)) then
					return
				end

				v21[v33.instanceId] = nil
				fn()
				fn2()
			end)
		end

		clone2.Parent = parent
	end
end

local function canDisplayItem(data)
	if typeof(data) ~= "table" or data.tradable ~= true or data.ownerUserId ~= Players.LocalPlayer.UserId or not table.find(
		v2,
		data.itemType
	) then
		return false
	end

	if data.locks ~= nil and typeof(data.locks) ~= "table" then
		return false
	end

	for k, v30 in data.locks or {} do
		if k ~= "trade" or not v20 or v30 ~= v20.id then
			return false
		end
	end

	return true
end

local function pruneSelection()
	local items = client.items()

	for k in v21 do
		if not canDisplayItem(items[k]) then
			v21[k] = nil
		end
	end
end

fn2 = function()
	pruneSelection()
	local v30 = {}

	for k in v21 do
		table.insert(v30, k)
	end

	table.sort(v30)
	remoteEvent3:FireServer(v30)
end

local function selectedCount()
	local count4 = 0

	for _ in v21 do
		count4 += 1
	end

	return count4
end

fn = function(point: Vector2?)
	local v30 = inventoryList
	local v31 = v24

	if not (v30 and v31) then
		return
	end

	local canvasPosition = point or v30.CanvasPosition
	count += 1
	pruneSelection()
	v31.Visible = false
	local v33 = {}

	for k, v34 in client.items() do
		if canDisplayItem(v34) and v34.itemType == v28 then
			table.insert(v33, {
				key = k,
				id = k,
				item = table.clone(v34),
				kills = ItemMetadataDisplay.getKillCount(v34),
				selected = v21[k] == true
			})
		end
	end

	table.sort(v33, function(a, b)
		local v34 = ratingFor(a.item.itemType, a.item.itemId) -- equivalent call inferred; original call site unknown
		local v35 = ratingFor(b.item.itemType, b.item.itemId) -- equivalent call inferred; original call site unknown

		if v34 ~= v35 then
			return v35 < v34
		end

		local itemId3 = tostring(a.item.itemId)
		local itemId4 = tostring(b.item.itemId)

		if itemId3 == itemId4 then
			return a.id < b.id
		end

		return itemId3 < itemId4
	end)

	if not v25 then
		local function activate(p)
			local v34 = v26[p]

			if not (v34 and v20 and GamepadSupport.CanActivate(p)) then
				return
			end

			if not canDisplayItem(client.items()[v34.id]) then
				fn()
				return
			end

			if v21[v34.id] then
				v21[v34.id] = nil
			else
				local count4 = 0

				for _ in v21 do
					count4 += 1
				end

				if count4 < 4 then
					v21[v34.id] = true
				else
					return
				end
			end

			fn()
			fn2()
		end

		v25 = LazyGrid.new(v30, v30, {
			slotAttribute = "TradeGenerated",
			active = function()
				return v20 ~= nil and v20.state ~= "Inviting" and v3.Enabled and v4.Visible and v22.Visible
			end,
			assign = function(instance, p)
				v26[instance] = p
				instance:SetAttribute("TradeNavigationKey", p and p.id or nil)
			end,
			equal = function(data, data2)
				if data then
					if data.id == data2.id and data.item.itemId == data2.item.itemId and data.item.itemType == data2.item.itemType and data.item.serial == data2.item.serial and data.kills == data2.kills then
						data = data.selected == data2.selected
					else
						data = false
					end
				end

				return data
			end,
			paint = function(instance, data)
				fillSlot(
					instance,
					data.item.itemType,
					data.item.itemId,
					data.item.serial,
					data.kills,
					instance:FindFirstChild("物品卡片")
				)
				local firstChild = instance:FindFirstChild("选中")

				if firstChild then
					firstChild.Visible = data.selected
				end
			end,
			bindCell = function(p)
				ButtonActions.Bind(p, function()
					activate(p)
				end)
			end,
			bindVisual = function(parent)
				parent.BackgroundTransparency = 1
				local clone = AssetLibrary.Clone("小球卡片", "已拥有小球卡片")
				clone.Name = "物品卡片"
				clone.Parent = parent
				ButtonActions.Bind(clone, function()
					if parent.Parent then
						activate(parent.Parent)
					end
				end)
			end,
			changed = function()
				if v then
					v:Refresh()
				end
			end
		})
	end

	v25:Set(v31, v33)
	v25:Update()
	v30.CanvasPosition = canvasPosition
	v25:Invalidate()
	v25:Update()

	if v then
		v:Refresh()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCategoryButtonColors()
	for k, v30 in v27 do
		local backgroundColor

		if k == v28 then
			backgroundColor = backgroundColor3
		else
			backgroundColor = backgroundColor32
		end

		v30.BackgroundColor3 = backgroundColor
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setActiveCategory(p: string)
	if v28 == p then
		return
	end

	canvasPositions[v28] = inventoryList.CanvasPosition
	v28 = p
	updateCategoryButtonColors() -- equivalent call inferred; original call site unknown
	fn(canvasPositions[p] or Vector2.zero)

	if v then
		v:SetCategory()
	end
end

local function setCountdown(value: string?, visible: boolean)
	countdown.Visible = visible
	accept.Visible = not visible

	if visible then
		local textLabel = countdown:FindFirstChild("TextLabel")

		if textLabel and textLabel:IsA("TextLabel") then
			textLabel.Text = value or ""
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startCountdown(endsAt)
	count2 += 1
	local v30 = count2
	countdown.Visible = true
	accept.Visible = false
	local textLabel = countdown:FindFirstChild("TextLabel")

	if textLabel and textLabel:IsA("TextLabel") then
		textLabel.Text = ""
	end

	if typeof(endsAt) ~= "number" then
		return
	end

	task.spawn(function()
		while v30 == count2 and v20 and (v20.state == "Cooldown" or v20.state == "FinalCountdown") do
			local v31 = math.max(0, (math.ceil(endsAt - Workspace:GetServerTimeNow())))
			local v32 = tostring(v31) .. "s"
			countdown.Visible = true
			accept.Visible = false
			local textLabel2 = countdown:FindFirstChild("TextLabel")

			if textLabel2 and textLabel2:IsA("TextLabel") then
				textLabel2.Text = v32 or ""
			end

			if v31 <= 0 then
				break
			else
				task.wait(0.1)
			end
		end
	end)
end

local function stopCountdown()
	count2 += 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showOutcome(p)
	closeTrade()
	ConfirmDialogController.Show(p.Name, {
		category = "Trade",
		priority = 100
	})
end

local function renderState()
	if not v20 then
		return
	end

	local userId = Players.LocalPlayer.UserId
	local a

	if v20.a.userId == userId then
		a = v20.a
	else
		a = v20.b
	end

	local b

	if v20.a.userId == userId then
		b = v20.b
	else
		b = v20.a
	end

	if v20.state == "Inviting" then
		if userId == v20.inviter then
			local label = v12:FindFirstChild("玩家名字")

			if label and label:IsA("TextLabel") then
				label.Text = b.name
			end

			ConfirmDialogController.Show(v12.Name, {
				category = "Trade",
				priority = 100
			})
		else
			local label = v11:FindFirstChild("玩家名字")

			if label and label:IsA("TextLabel") then
				label.Text = b.name
			end

			ConfirmDialogController.Show(v11.Name, {
				category = "Trade",
				priority = 100
			})
		end
	else
		hideConfirmation() -- equivalent call inferred; original call site unknown

		if v20.state == "Cancelled" then
			showOutcome(v14) -- equivalent call inferred; original call site unknown
		elseif v20.state == "Completed" then
			showOutcome(v13) -- equivalent call inferred; original call site unknown
		else
			showTrade()
			renderOffer(ownList, a.offer, true)
			renderOffer(otherList, b.offer, false)
			fn()
			local label = v5:FindFirstChild("对方名字")

			if label and label:IsA("TextLabel") then
				label.Text = b.name .. "'s offer"
			end

			local image = v5:FindFirstChild("我方头像")

			if image and image:IsA("ImageLabel") then
				PlayerThumbnail.applyAsync(image, userId)
			end

			local image2 = v5:FindFirstChild("对方头像")

			if image2 and image2:IsA("ImageLabel") then
				PlayerThumbnail.applyAsync(image2, b.userId)
			end

			if not diamonds:IsFocused() then
				diamonds.Text = (typeof(a.diamonds) ~= "number" or not (a.diamonds > 0)) and "" or tostring(a.diamonds)
			end

			v29 = typeof(a.diamonds) ~= "number" and 0 or a.diamonds
			v16.Text = NumberFormat.commaFormat((math.floor(v29 * 0.95)))
			v18.Text = NumberFormat.commaFormat(b.diamonds or 0)
			v19.Text = NumberFormat.commaFormat((math.floor((b.diamonds or 0) * 0.95)))

			if v20.outcome == "insufficientBalance" and v20.insufficientUserId == userId then
				v20.outcome = nil
				flashInvalid(v17)
				diamonds.Text = ""

				if v29 ~= 0 then
					v29 = 0
					remoteEvent4:FireServer(0)
				end
			end

			if v20.state == "Cooldown" or v20.state == "FinalCountdown" then
				startCountdown(v20.endsAt) -- equivalent call inferred; original call site unknown
			elseif a.accepted then
				count2 += 1
				countdown.Visible = true
				accept.Visible = false
				local textLabel = countdown:FindFirstChild("TextLabel")

				if textLabel and textLabel:IsA("TextLabel") then
					textLabel.Text = "Accepted"
				end
			else
				count2 += 1
				countdown.Visible = false
				accept.Visible = true
			end

			if v then
				v:Open()
				v:Refresh()
			end
		end
	end
end

local function submitMyDiamonds()
	if not v20 or v20.state == "Completed" or v20.state == "Cancelled" then
		return false
	end

	local text = diamonds.Text
	local v30

	if text == "" then
		v30 = 0
	elseif string.match(text, "^%d+$") then
		v30 = tonumber(text)
	end

	local v31

	if v30 == nil or v30 ~= 0 and not (math.floor(v30 * 0.95) > 0) then
		v31 = false
	else
		v31 = v30 <= (client.diamonds() or 0)
	end

	if not v31 then
		flashInvalid(v17)
		diamonds.Text = ""
		v30 = 0
	end

	v16.Text = NumberFormat.commaFormat((math.floor(v30 * 0.95)))

	if v30 == v29 then
		return v31
	end

	v29 = v30
	remoteEvent4:FireServer(v30)
	return false
end

function Trade.Init()
	if flag then
		print("[TradeDebug][Client] Trade.Init skipped; already initialized")
		return
	end

	flag = true
	print("[TradeDebug][Client] Trade.Init begin; user=" .. tostring(Players.LocalPlayer.UserId))
	ConfirmDialogController.Init()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	v3 = playerGui:WaitForChild("交易")
	v4 = v3:WaitForChild("背景")
	folder = v4:WaitForChild("面板")
	size = folder.Size
	local v30 = folder:WaitForChild("选择栏"):WaitForChild("选择栏")
	v22 = folder:WaitForChild("通用库存")
	inventoryList = v22:WaitForChild("列表")
	v24 = inventoryList:WaitForChild("占位格子")
	v24.Visible = false
	v22.Visible = true
	local v31 = {
		Ball = "小球库存按钮",
		["爆炸特效"] = "爆炸特效库存按钮",
		["飞行器"] = "飞行器库存按钮"
	}

	for _, v32 in ipairs(v2) do
		v27[v32] = v30:WaitForChild(v31[v32])
	end

	backgroundColor3 = v27.Ball.BackgroundColor3
	backgroundColor32 = v27["爆炸特效"].BackgroundColor3
	updateCategoryButtonColors() -- equivalent call inferred; original call site unknown
	local v32 = {}

	for k, v33 in v27 do
		v32[v33] = true
		setupButtonFeedback(v33)
		local v34 = v33
		local v35 = k
		ButtonActions.Bind(v33, function()
			if GamepadSupport.CanActivate(v34) then
				setActiveCategory(v35) -- equivalent call inferred; original call site unknown
			end
		end)
	end

	v5 = folder:WaitForChild("交易面板")
	ownList = v5:WaitForChild("我方列表")
	otherList = v5:WaitForChild("对方列表")

	for _, v33 in { inventoryList, ownList, otherList } do
		for _, guiObject in v33:GetChildren() do
			if not (guiObject:IsA("GuiObject") and (guiObject.Name == "占位格子" or guiObject.Name:match("^占位格子%d+$"))) then
				continue
			end

			guiObject.Visible = false
			guiObject.Selectable = false
			guiObject.Active = false
		end
	end

	accept = v5:WaitForChild("接受按钮")
	countdown = v5:WaitForChild("倒计时")
	decline = v5:WaitForChild("拒绝按钮")
	countdown.Position = accept.Position
	local v33 = v5:WaitForChild("我方钻石支付")
	diamonds = v33:WaitForChild("数量输入框")
	v16 = v33:WaitForChild("实收数量")
	v17 = diamonds:WaitForChild("边框")
	local v34 = v5:WaitForChild("对方钻石支付")
	v18 = v34:WaitForChild("数量")
	v19 = v34:WaitForChild("实收数量")
	local v35 = playerGui:WaitForChild("通用确认框"):WaitForChild("背景")
	v11 = v35:WaitForChild("确认交易面板")
	v12 = v35:WaitForChild("等待交易面板")
	v13 = v35:WaitForChild("交易完成面板")
	v14 = v35:WaitForChild("交易取消面板")
	v4.Visible = false
	countdown.Visible = false

	for _, button in ipairs(folder:GetDescendants()) do
		if not button:IsA("GuiButton") or v32[button] then
			continue
		end

		setupButtonFeedback(button)
	end

	ButtonActions.Bind(accept, function()
		if not (v20 and GamepadSupport.CanActivate(accept) and submitMyDiamonds()) then
			return
		end

		remoteEvent5:FireServer()
	end)
	ButtonActions.Bind(decline, function()
		if v20 and GamepadSupport.CanActivate(decline) then
			remoteEvent6:FireServer()
		end
	end)
	v = GamepadNavigation.new({
		panel = folder,
		tabs = { v27.Ball, v27["爆炸特效"], v27["飞行器"] },
		inventoryList = inventoryList,
		ownList = ownList,
		otherList = otherList,
		accept = accept,
		decline = decline,
		countdown = countdown,
		diamonds = diamonds,
		getCategoryIndex = function()
			return table.find(v2, v28) or 1
		end,
		onCategory = function(p)
			setActiveCategory(v2[p]) -- equivalent call inferred; original call site unknown
		end,
		onCancel = function()
			if v20 and GamepadSupport.CanActivate(decline) then
				remoteEvent6:FireServer()
			end
		end
	})
	ConfirmDialogController.BindButton(v11:WaitForChild("接受按钮"), "A", function()
		remoteEvent2:FireServer(true)
	end)
	ConfirmDialogController.BindButton(v11:WaitForChild("拒绝按钮"), "B", function()
		remoteEvent2:FireServer(false)
	end)
	ConfirmDialogController.BindButton(v12:WaitForChild("取消按钮"), "B", function()
		remoteEvent6:FireServer()
	end)
	local v36 = { v13, v14 }

	for _, v37 in ipairs(v36) do
		ConfirmDialogController.BindButton(v37:WaitForChild("确定按钮"), "A", hideConfirmation)
	end

	diamonds.FocusLost:Connect(function()
		submitMyDiamonds()
	end)
	diamonds:GetPropertyChangedSignal("Text"):Connect(function()
		local text = tonumber(diamonds.Text)
		v16.Text = NumberFormat.commaFormat(not (text and text > 0) and 0 or math.floor(text * 0.95))
	end)
	remoteEvent7.OnClientEvent:Connect(function(data)
		if data.state == "RequestRejected" then
			Trade.ShowRequestFailure(data)
			return
		end

		print("[TradeDebug][Client] TradeState received; user=" .. tostring(Players.LocalPlayer.UserId) .. "; state=" .. tostring(data and data.state) .. "; id=" .. tostring(data and data.id))

		if not v20 or v20.id ~= data.id then
			v28 = "Ball"
			canvasPositions = {}
			inventoryList.CanvasPosition = Vector2.zero
			updateCategoryButtonColors() -- equivalent call inferred; original call site unknown
		end

		v20 = data
		v21 = {}
		local v37

		if data.a.userId == Players.LocalPlayer.UserId then
			v37 = data.a
		else
			v37 = data.b
		end

		for _, v38 in v37.offer do
			v21[v38.instanceId] = true
		end

		renderState()
	end)
	client.items.Changed(function()
		if v20 and v20.state ~= "Inviting" then
			renderState()
		end
	end)
end

local v30 = {
	selfInBattle = "You are in a match.",
	targetInBattle = "Player is in a match.",
	selfInTrade = "You are already trading.",
	targetInTrade = "Player is already trading.",
	selfTeleporting = "You are teleporting.",
	targetTeleporting = "Player is teleporting.",
	requestsDisabled = "Player's trade requests are off.",
	targetOffline = "Player has left.",
	selfTarget = "You can't trade with yourself.",
	invalidTarget = "Player unavailable."
}

function Trade.ShowRequestFailure(p)
	local reason

	if typeof(p) == "table" then
		reason = p.reason
	end

	local v31 = v30[reason] or "Request failed. Try again."

	if reason == "selfLevel" or reason == "targetLevel" then
		local allowTradeLvl = Config.misc and Config.misc.allowTradeLvl
		local requiredLevel

		if typeof(p.requiredLevel) == "number" then
			requiredLevel = p.requiredLevel
		else
			requiredLevel = (typeof(allowTradeLvl) ~= "number" or not (allowTradeLvl >= 1)) and 10 or math.floor(allowTradeLvl)
		end

		if reason == "selfLevel" then
			v31 = ("You need level %d to trade."):format(requiredLevel)
		else
			v31 = ("Player needs level %d to trade."):format(requiredLevel)
		end
	end

	ConfirmDialogController.ShowMessage(v31, {
		category = "Trade",
		priority = 100
	})
end

function Trade.ShowQualificationRequired()
	Trade.ShowRequestFailure({
		reason = "selfLevel"
	})
end

function Trade.Request(p: number)
	local success, result = pcall(function()
		return Net:RemoteFunction("TradeGetEligibility"):InvokeServer(p)
	end)

	if success and typeof(result) == "table" and result.ok == true then
		remoteEvent:FireServer(p)
		return
	end

	local showRequestFailure = Trade.ShowRequestFailure

	if not success then
		result = nil
	end

	showRequestFailure(result)
end

return Trade