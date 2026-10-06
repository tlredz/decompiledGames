local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local Config = require(ReplicatedStorage.Engine.Service.Config)
local AssetLibrary = require(ReplicatedStorage.Engine.Service.AssetLibrary)
local v = AssetLibrary.Get("通用组件", "占位格子"):WaitForChild("已装备标签")
local BallCardQuality = require(ReplicatedStorage.Engine.Service.BallCardQuality)
local BallQualityTextStyle = require(ReplicatedStorage.Engine.Service.BallQualityTextStyle)
local ItemMetadataDisplay = require(ReplicatedStorage.Engine.Gui.Inventory.ItemMetadataDisplay)
local ItemService = require(ReplicatedStorage.Engine.Service.ItemService)
local client2 = ItemService.client
local ConfirmDialogController = require(script.Parent.ConfirmDialogController)
local StarterPackOffer = require(script.Parent.StarterPackOffer)
local FriendInviteRewardService = require(ReplicatedStorage.Engine.Service.FriendInviteRewardService)
local FusionClient = require(script.FusionClient)
local PriceHistory = require(script.PriceHistory)
local BallCopySelection = require(ReplicatedStorage.Engine.Service.BallCopySelection)
local GameFlags = require(ReplicatedStorage.GameFlags)
local v2 = GameFlags.feature["小球合成"] == true
local upgrade = nil
local v4 = {}
local Inventory = {}
local GamepadNavigation = require(script.GamepadNavigation)
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
local v5 = nil
local CopiesView = require(script.CopiesView)
local InventoryEntries = require(script.InventoryEntries)
local cnId = nil
local v6 = nil
local copies = nil
local v8 = nil
local v9 = nil
local zero = Vector2.zero
local v10 = {
	ball = {
		itemType = "Ball",
		tabButton = "小球库存按钮"
	},
	explosion = {
		itemType = "爆炸特效",
		tabButton = "爆炸特效按钮"
	},
	flyer = {
		itemType = "飞行器",
		tabButton = "飞行器按钮"
	}
}
local v11 = "ball"

-- equivalent calls inferred from this helper; original call sites unknown
local function selectionKey()
	if cnId then
		return v11 .. ":copies:" .. cnId
	end

	return v11
end

local v12 = nil
local v13 = nil
local panel = nil
local v15 = nil
local v16 = nil
local owned = nil
local unowned = nil
local uIGridLayout = nil
local uIGridLayout2 = nil
local v19 = nil
local v20 = nil
local v21 = nil
local v22 = nil
local v23 = nil
local v24 = nil
local equip2 = nil
local unequip = nil
local info = nil
local v28 = nil
local v29 = nil
local v30 = nil
local v31 = {}
local v32 = {}
local LazyGrid = require(script.LazyGrid)
local v33 = nil
local v34 = false
local v35 = nil
local v36 = {}
local canvasPositions = {}
local flag = false
local size = nil
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v37 = nil
local v38 = nil
local v39 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function hideLockDescription(p)
	if v37 then
		v37.Visible = false
	end

	v39 = nil

	if p then
		v38 = nil
	end
end

local function positionLockDescription()
	local v40 = v39

	if v40 and v40.Parent and v40.Visible and flag and v12.Enabled and v13.Visible and v15.Visible and v16.Visible then
		local absoluteSize = v15.AbsoluteSize

		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return
		end

		local absolutePosition = v40.AbsolutePosition
		local absoluteSize2 = v40.AbsoluteSize
		local absolutePosition2 = v16.AbsolutePosition
		local absoluteSize3 = v16.AbsoluteSize

		if not (absolutePosition.Y + absoluteSize2.Y <= absolutePosition2.Y or absolutePosition.Y >= absolutePosition2.Y + absoluteSize3.Y or absolutePosition.X + absoluteSize2.X <= absolutePosition2.X or absolutePosition.X >= absolutePosition2.X + absoluteSize3.X) then
			local v41 = absolutePosition + absoluteSize2 - v15.AbsolutePosition
			local absoluteSize4 = v37.AbsoluteSize
			v37.Position = UDim2.fromScale(
				math.clamp(v41.X / absoluteSize.X + 0.005, 0, (math.max(0, 1 - absoluteSize4.X / absoluteSize.X))),
				(math.clamp(v41.Y / absoluteSize.Y + 0.005, 0, (math.max(0, 1 - absoluteSize4.Y / absoluteSize.Y))))
			)
			return
		end
	end

	if v37 then
		v37.Visible = false
	end

	v39 = nil
	v38 = nil
end

local function bindLockDescription(button)
	if not (button and button:IsA("GuiButton")) then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function show()
		if not button.Visible then
			return
		end

		v39 = button
		v37.Visible = true
		positionLockDescription()
	end

	local function leave()
		if v39 == button and v38 ~= button then
			hideLockDescription(false) -- equivalent call inferred; original call site unknown
		end
	end

	button.MouseEnter:Connect(show)
	button.MouseLeave:Connect(leave)
	button.SelectionGained:Connect(show)
	button.SelectionLost:Connect(leave)
	ButtonActions.Bind(button, function()
		if not GamepadSupport.CanActivate(button) then
			return
		end

		if v38 == button then
			if v37 then
				v37.Visible = false
			end

			v39 = nil
			v38 = nil
		else
			v38 = button
			show() -- equivalent call inferred; original call site unknown
		end
	end)
	button:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		if v39 == button then
			positionLockDescription()
		end
	end)
	button:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if v39 == button then
			positionLockDescription()
		end
	end)
end

local function showInventory()
	if flag then
		return
	end

	flag = true
	v13.Visible = true
	v13.BackgroundTransparency = 1
	TweenService:Create(v13, tweenInfo, {
		BackgroundTransparency = 0.5
	}):Play()
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = size
	}):Play()
end

local function hideInventory()
	if v37 then
		v37.Visible = false
	end

	v39 = nil
	v38 = nil

	if not flag then
		return
	end

	if v5 then
		v5:Close()
	end

	PriceHistory.Close()
	FusionClient.Clear()
	flag = false

	for _, v40 in v32 do
		v40:Invalidate()
	end

	TweenService:Create(v13, tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0)
	}):Play()
	task.delay(0.3, function()
		if not flag then
			v13.Visible = false
		end
	end)
end

local object = setmetatable({}, {
	__mode = "k"
})

local function setupButtonFeedback(instance)
	if object[instance] then
		return
	end

	object[instance] = true
	local size2 = instance.Size
	local v40 = false
	local v41 = false
	local v42 = nil
	local count = 0

	local function animate(p, duration)
		if v42 then
			v42:Cancel()
		end

		v42 = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(size2.X.Scale * p, size2.X.Offset * p, size2.Y.Scale * p, size2.Y.Offset * p)
		})
		v42:Play()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function restore()
		count += 1
		animate(instance.Active and (v40 or v41) and 1.05 or 1, 0.1)
	end

	instance.MouseEnter:Connect(function()
		v40 = true
		restore() -- equivalent call inferred; original call site unknown
	end)
	instance.MouseLeave:Connect(function()
		v40 = false
		restore() -- equivalent call inferred; original call site unknown
	end)
	instance.SelectionGained:Connect(function()
		v41 = true
		restore() -- equivalent call inferred; original call site unknown
	end)
	instance.SelectionLost:Connect(function()
		v41 = false
		restore() -- equivalent call inferred; original call site unknown
	end)
	instance.Activated:Connect(function()
		if not (instance.Active and GamepadSupport.CanActivate(instance)) then
			return
		end

		count += 1
		local v43 = count
		animate(0.94, 0.06)
		task.delay(0.07, function()
			if instance.Parent and count == v43 then
				restore() -- equivalent call inferred; original call site unknown
			end
		end)
	end)
	instance:GetPropertyChangedSignal("Active"):Connect(restore)
	instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if not instance.Visible then
			v40 = false
			v41 = false
			count += 1

			if v42 then
				v42:Cancel()
			end

			instance.Size = size2
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isValidImageValue(image)
	return typeof(image) == "string" and image ~= "" and string.match(image, "^%a+://") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findRatingByLvl(rating: number)
	for _, v40 in Config.rating.list do
		if v40.lvl == rating then
			return v40
		end
	end

	return nil
end

local function describeBallSkills(p)
	if not p or typeof(p.skills) ~= "table" then
		return ""
	end

	local byCnId = Config.skill.byCnId
	local descs = {}

	for _, skill in p.skills do
		local v40 = byCnId and byCnId[skill]

		if v40 and typeof(v40.desc) == "string" and v40.desc ~= "" then
			table.insert(descs, v40.desc)
		end
	end

	return table.concat(descs, "\n")
end

local function updateGridCellSize(parent, uIGridLayout3)
	local absoluteWindowSize = parent.Parent.AbsoluteWindowSize

	if absoluteWindowSize.X <= 0 or absoluteWindowSize.Y <= 0 then
		return
	end

	local v40 = 1

	while parent do
		local uIScale = parent:FindFirstChildOfClass("UIScale")

		if uIScale then
			v40 *= uIScale.Scale
		end

		parent = parent.Parent
	end

	if v40 <= 0 then
		return
	end

	local v41 = math.max(1, absoluteWindowSize.Y * 0.02)
	local v42 = math.min((absoluteWindowSize.X - v41 * 2) / 3, (absoluteWindowSize.Y - v41) / 2)
	uIGridLayout3.CellSize = UDim2.fromOffset(v42 / v40, v42 / v40)
	uIGridLayout3.CellPadding = UDim2.fromOffset(v41 / v40, v41 / v40)
	uIGridLayout3.FillDirectionMaxCells = 3
	uIGridLayout3.HorizontalAlignment = Enum.HorizontalAlignment.Center
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateScrollBarThickness(p)
	local X = p.AbsoluteSize.X

	if X <= 0 then
		return
	end

	p.ScrollBarThickness = math.max(1, (math.floor(X * 0.025)))
end

local function prepareTemplate(instance, flag2: boolean?)
	local _1

	if flag2 then
		_1 = AssetLibrary.Get("小球卡片", "已拥有小球卡片")
	else
		_1 = instance:WaitForChild("格子1")
	end

	for _, guiObject in instance:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = false
		end
	end

	return _1
end

local function clearGeneratedSlots(instance)
	for _, button in instance:GetChildren() do
		if button:IsA("GuiButton") and button:GetAttribute("InventoryGeneratedSlot") then
			button:Destroy()
		end
	end
end

local flag2 = false

local function openBallRulesPanel()
	if flag2 then
		return
	end

	flag2 = true
	ConfirmDialogController.Enqueue("小球规则面板", {
		category = "BallRules",
		onShown = function(instance, callback)
			local v40 = instance:WaitForChild("关闭按钮")
			local connection = nil
			connection = ConfirmDialogController.BindButton(v40, "B", function()
				connection:Disconnect()
				flag2 = false
				callback()
			end)
		end
	})
end

local function collectListedInstanceIds()
	local result = {}
	local boothListings = client.boothListings()

	if type(boothListings) == "table" then
		for _, boothListing in boothListings do
			if type(boothListing) == "table" and boothListing.itemInstanceId then
				result[boothListing.itemInstanceId] = true
			end
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function displayName(p)
	if v11 == "ball" then
		return p.displayName
	end

	return p.name
end

local function updateEquipButtons()
	local v40 = not (cnId and v35) and "Classic" or CopiesView.Kind(v35)

	if #v4 > 0 then
		upgrade = v4[v40 == "Classic" and 1 or v40 == "Shiny" and 2 or 3]

		for _, v41 in v4 do
			v41.Visible = false
		end
	end

	if upgrade then
		local v41 = v2

		if v41 then
			if v11 == "ball" and v35 ~= nil then
				v41 = cnId ~= nil
			else
				v41 = false
			end
		end

		upgrade.Visible = v41
		local v42 = v41 and v40 ~= "Rainbow"

		if v42 then
			local count = 0

			for _, v43 in client.items() do
				if not (v43.itemType == "Ball" and v43.itemId == v35.config.cnId) then
					continue
				end

				local BallUpgradeRules = require(ReplicatedStorage.Engine.Service.BallUpgradeRules)

				if BallUpgradeRules.kind(v43) ~= v40 then
					continue
				end

				local BallUpgradeRules2 = require(ReplicatedStorage.Engine.Service.BallUpgradeRules)

				if BallUpgradeRules2.eligible(v43, Players.LocalPlayer.UserId) then
					count += 1
				end
			end

			if count >= 6 then
				v42 = true
			else
				v42 = false
			end
		end

		local v43 = upgrade
		local backgroundColor

		if v42 then
			backgroundColor = upgrade:GetAttribute("EnabledColor")
		else
			backgroundColor = upgrade:GetAttribute("DisabledColor")
		end

		v43.BackgroundColor3 = backgroundColor
		upgrade.Selectable = v41
		upgrade.Interactable = v41
		upgrade.Active = v41
		upgrade.AutoButtonColor = v41
		upgrade:SetAttribute("UpgradeEnabled", v42)
	end

	local v41 = v10[v11]
	local visible = v11 == "ball"
	local v43

	if v41 == nil then
		v43 = false
	else
		v43 = not visible or cnId ~= nil
	end

	local equipment = client.equipment()
	local resolved = nil

	if visible and cnId then
		resolved = BallCopySelection.resolve(client.items(), equipment, cnId)
	elseif v43 and type(equipment) == "table" then
		resolved = equipment[v41.itemType]
	end

	v33 = resolved
	v34 = v43

	for k, v44 in v31 do
		local firstChild = k:FindFirstChild("卡片内容")
		local v45 = firstChild and firstChild:FindFirstChild("已装备标签")

		if not v45 then
			continue
		end

		local visible2

		if v43 then
			if v44.instanceId == nil or v44.instanceId ~= resolved then
				visible2 = false
			else
				visible2 = not (v44.listed or v44.locked)
			end
		else
			visible2 = v43
		end

		v45.Visible = visible2
	end

	if v43 then
		if v35 == nil or v35.instanceId == nil then
			v43 = false
		else
			v43 = not (v35.listed or v35.locked)
		end
	end

	equip2.Visible = v43 and v35.instanceId ~= resolved
	unequip.Visible = v43 and not visible and v35.instanceId == resolved

	if copies then
		local v44 = copies
		local visible2 = not cnId

		if visible2 then
			if v35 == nil then
				visible2 = false
			else
				visible2 = v35.count ~= nil
			end
		end

		v44.Visible = visible2
	end

	if v9 then
		v9.Visible = cnId ~= nil and v35 ~= nil
		v9.Text = v35 and v35.listed and "In Booth" or v35 and v35.locked and "Unavailable" or v43 and v35.instanceId == resolved and "Equipped" or ""
	end

	local v44 = equip2
	local position

	if visible and cnId then
		position = UDim2.fromScale(0.5, 0.9125)
	else
		position = UDim2.fromScale(0.505, 0.6225)
	end

	v44.Position = position
	local v46 = v15["右框"]

	for _, v47 in { "名称", "物品图标", "品质" } do
		v46[v47].Visible = v47 == "名称" or v47 == "物品图标" or not visible and v47 == "品质"
	end

	v28.Visible = visible and v35 ~= nil
	v29.Visible = false
	v46["描述分隔线"].Visible = visible and v35 ~= nil
	v46["详情分隔线"].Visible = false

	if visible then
		local v47 = {
			Classic = 0,
			Shiny = 0,
			Rainbow = 0
		}
		local BallUpgradeRules = require(ReplicatedStorage.Engine.Service.BallUpgradeRules)

		if v35 then
			for _, v48 in client.items() do
				if not (v48.itemType == "Ball" and v48.itemId == v35.config.cnId) then
					continue
				end

				local kind = BallUpgradeRules.kind(v48)
				v47[kind] += 1
			end
		end

		local v48 = v47.Classic + v47.Shiny + v47.Rainbow
		local visible2 = v48 > 0
		v29.Visible = v35 ~= nil and not visible2
		v46["拥有数量"].Visible = visible2
		v46["分类数量"].Visible = visible2
		v46["当前装备"].Visible = visible2
		v46["详情分隔线"].Visible = visible2

		if copies then
			copies.Visible = visible2 and not cnId
		end

		v46["拥有数量"].Text = "Owned: " .. v48
		v46["分类数量"]["经典数量"].Text = tostring(v47.Classic)
		v46["分类数量"]["闪光数量"].Text = tostring(v47.Shiny)
		v46["分类数量"]["彩虹数量"].Text = tostring(v47.Rainbow)
		local resolved2 = v35 and BallCopySelection.resolve(client.items(), equipment, v35.config.cnId)
		local v52 = resolved2 and client.items()[resolved2]
		local metadata = v52 and v52.metadata
		local v53

		if typeof(metadata) == "table" then
			v53 = typeof(metadata.killCount) == "number"
		else
			v53 = false
		end

		local v54

		if v52 == nil then
			v54 = false
		else
			v54 = typeof(v52.serial) == "number"
		end

		local v55 = v53 and not v54
		local v56 = v46["当前装备"]["装备属性"]
		v56.Text = resolved2 and (v54 and "Rainbow" or v55 and "Shiny" or "Classic") or "None"
		BallQualityTextStyle.apply(v56, v54 and "Rainbow" or v55 and "Shiny" or "Classic")

		if copies then
			copies["文字"].Text = "View " .. v48 .. (v48 == 1 and " Ball" or " Balls")
		end
	else
		local v47 = not v35 and 0 or v35.count or 0
		local v48 = v35 and InventoryEntries.equippedId(equipment, v41.itemType, v35.config.cnId)
		local v49 = v48 and client.items()[v48]
		local v50

		if v49 == nil or v35 == nil then
			v50 = false
		else
			v50 = v49.itemId == v35.config.cnId
		end

		local v51 = v46["拥有数量"]
		v51.Visible = v47 > 0 and not cnId
		v46["拥有数量"].Text = "Owned: " .. v47
		v46["分类数量"].Visible = false
		v46["当前装备"].Visible = false
		local v53 = v46["当前装备"]["装备属性"]
		v53.Text = not v50 and "None" or typeof(v49.serial) ~= "number" and "Yes" or "#" .. tostring(v49.serial)
		BallQualityTextStyle.apply(v53, "Classic")

		if copies then
			copies["文字"].Text = "View " .. v47 .. (v47 == 1 and " Item" or " Items")
		end
	end

	CopiesView.Detail(v35, cnId ~= nil, visible)
	unequip.Position = equip2.Position
	unequip.AnchorPoint = equip2.AnchorPoint
	unequip.Size = equip2.Size
	local v47 = v46["已装备文字"]
	v47.AnchorPoint = equip2.AnchorPoint
	v47.Position = equip2.Position
	v47.Size = equip2.Size

	if visible then
		if cnId == nil then
			visible = false
		else
			visible = v43 and v35.instanceId == resolved
		end
	end

	v47.Visible = visible

	if v47.Visible then
		equip2.Visible = false
	end
end

local function showDetail(p)
	v35 = p

	if p then
		local v40 = v36
		local v41 = selectionKey() -- equivalent call inferred; original call site unknown
		v40[v41] = p.key
		local config = p.config
		local v42 = v23
		local text = displayName(config) -- equivalent call inferred; original call site unknown
		v42.Text = text
		local v44 = v22
		local validImageValue = isValidImageValue(config.image) -- equivalent call inferred; original call site unknown
		v44.Image = not validImageValue and "" or config.image
		local ratingByLvl = findRatingByLvl(config.rating) -- equivalent call inferred; original call site unknown
		v24.Text = not ratingByLvl and "" or ratingByLvl.name

		if ratingByLvl then
			v24.TextColor3 = Color3.fromHex(ratingByLvl.colorHex)
		end

		v28.Text = (v11 ~= "ball" or typeof(config.shortDesc) ~= "string") and "" or config.shortDesc
		v30.Text = (v11 ~= "ball" or typeof(config.detailDesc) ~= "string") and "" or config.detailDesc
		v29.CanvasPosition = Vector2.zero
		local select = PriceHistory.Select
		local v45 = v11
		local cnId2 = config.cnId
		local v46 = displayName(config) -- equivalent call inferred; original call site unknown
		select(v45, cnId2, v46)
		updateEquipButtons()
	else
		v23.Text = ""
		v22.Image = ""
		v24.Text = ""
		v30.Text = ""
		v29.CanvasPosition = Vector2.zero
		v28.Text = ""
		PriceHistory.Select(v11, nil, "")
		updateEquipButtons()
	end
end

local function writeCell(parent, data)
	local config = data.config
	local v40 = cnId == nil
	local v41 = parent:FindFirstChild("物品图标") or parent:FindFirstChild("ImageLabel")

	if v41 then
		local validImageValue = isValidImageValue(config.image) -- equivalent call inferred; original call site unknown
		v41.Image = not validImageValue and "" or config.image
		local v42

		if v11 == "ball" and typeof(data.killCount) == "number" then
			v42 = config.isSpecial ~= true
		else
			v42 = false
		end

		local v43 = typeof(data.serial) == "number"
		local firstChild = v41:FindFirstChild("击杀统计效果")
		local firstChild2 = v41:FindFirstChild("击杀统计+唯一编号效果")

		if firstChild then
			firstChild.Visible = v42 and not v43
		end

		if firstChild2 then
			firstChild2.Visible = v42 and v43
		end

		local position

		if v40 or cnId then
			position = UDim2.fromScale(0.5, 0.45)
		else
			position = UDim2.fromScale(0.5, 0.5)
		end

		v41.Position = position
		local size2

		if v40 or cnId then
			size2 = UDim2.fromScale(0.94, 0.94)
		else
			size2 = UDim2.fromScale(1, 1)
		end

		v41.Size = size2
	end

	local guiObject = (parent:FindFirstChild("底栏") or parent):FindFirstChild("名称")

	if guiObject then
		local v42

		if guiObject:IsA("TextLabel") then
			v42 = guiObject
		else
			v42 = guiObject["文字"]
		end

		local v43 = data.instanceId and client.items()[data.instanceId]
		local v44 = v11 ~= "ball" and "Classic" or BallCardQuality.kind(v43, config)
		BallQualityTextStyle.apply(v42, v44)

		if cnId and v11 == "ball" then
			v42.Text = CopiesView.Kind(data)
		else
			local text = displayName(config) -- equivalent call inferred; original call site unknown
			v42.Text = text
		end
	end

	local firstChild = parent:FindFirstChild("数量")

	if firstChild then
		firstChild.Visible = not cnId and data.instanceId ~= nil
		firstChild.Text = not firstChild.Visible and "" or "x" .. tostring(data.count or 1)
	end

	local firstChild2 = parent:FindFirstChild("交易状态")

	if firstChild2 then
		firstChild2.Text = data.tradable == false and "Untradable" or "Tradable"
	end

	local ratingByLvl = findRatingByLvl(config.rating) -- equivalent call inferred; original call site unknown

	if ratingByLvl then
		local color = Color3.fromHex(ratingByLvl.colorHex)
		local v42 = parent:FindFirstChild("品质描边") or parent:FindFirstChild("UIStroke")

		if v42 then
			v42.Color = color
		end

		local uIStroke = guiObject and guiObject:IsA("Frame") and guiObject:FindFirstChild("UIStroke")

		if uIStroke then
			uIStroke.Color = color
		end
	end

	local firstChild3 = parent:FindFirstChild("锁")

	if firstChild3 then
		firstChild3.Visible = cnId ~= nil and data.instanceId ~= nil and (data.tradable == false or data.locked == true)
	end

	ItemMetadataDisplay.apply(parent, data.serial, data.killCount)
	local clone = parent:FindFirstChild("已装备标签")

	if not clone then
		clone = v:Clone()
		clone.Visible = false
		clone.Parent = parent
	end

	if clone then
		local visible = v34

		if visible then
			if data.instanceId == nil or data.instanceId ~= v33 then
				visible = false
			else
				visible = not (data.listed or data.locked)
			end
		end

		clone.Visible = visible
	end

	local firstChild4 = parent:FindFirstChild("摆摊中遮罩")

	if firstChild4 then
		firstChild4.Visible = data.listed == true
	end
end

local refresh

refresh = function()
	if v37 then
		v37.Visible = false
	end

	v39 = nil
	v38 = nil
	local v40 = v10[v11]

	if not v40 then
		return
	end

	local canvasPosition = v16.CanvasPosition
	local v41 = {}
	local v42 = {}
	local v43 = {}
	local ball

	if v11 == "ball" then
		ball = Config.ball
	else
		ball = Config.skin
	end

	local v44 = collectListedInstanceIds()
	local items = client.items()

	for k, item in items do
		if item.itemType ~= v40.itemType then
			continue
		end

		local config = ball.byCnId[item.itemId]

		if not config then
			continue
		end

		local instanceId = item.instanceId or k
		local v46 = {
			config = config,
			instanceId = instanceId,
			key = instanceId,
			serial = item.serial,
			killCount = 0,
			killTracking = 0,
			tradable = 0,
			locked = 0,
			listed = 0
		}
		local killCount

		if typeof(item.metadata) == "table" then
			killCount = item.metadata.killCount
		end

		v46.killCount = killCount
		v46.killTracking = typeof(item.metadata) == "table" and typeof(item.metadata.killCount) == "number"
		v46.tradable = item.tradable
		v46.locked = not BallCopySelection.available(item)
		v46.listed = v44[instanceId] == true
		table.insert(v41, v46)
		v43[item.itemId] = true
	end

	for _, config in ball.list do
		local v46

		if v11 == "ball" then
			v46 = config.canPlayerUse
		else
			v46 = config.skinType == v40.itemType
		end

		if not v46 or v43[config.cnId] then
			continue
		end

		table.insert(v42, {
			config = config,
			key = "unowned:" .. config.cnId
		})
	end

	local function compare(p, p2)
		if p.config.rating ~= p2.config.rating then
			return p.config.rating > p2.config.rating
		end

		if p.config.cnId == p2.config.cnId then
			return InventoryEntries.compareCopies(p, p2)
		end

		return p.config.cnId < p2.config.cnId
	end

	table.sort(v42, compare)
	local filtered

	if cnId then
		local v45 = {}

		for _, v46 in v41 do
			if v46.config.cnId == cnId then
				table.insert(v45, v46)
			end
		end

		if #v45 == 0 then
			v36[v11] = nil
			cnId = nil
			v16.CanvasPosition = zero
			return refresh()
		else
			table.sort(v45, InventoryEntries.compareCopies)
			filtered = CopiesView.Filter(v45, v11 == "ball")
			v42 = {}
		end
	else
		filtered = InventoryEntries.aggregate(v41, client.equipment(), v40.itemType, v11)
		table.sort(filtered, compare)
	end

	v6.Visible = cnId ~= nil
	v16.Position = UDim2.fromScale(0, cnId and 0.12 or 0)
	v16.Size = UDim2.fromScale(1, cnId and 0.88 or 1)

	if cnId then
		local v45 = v6["标题"]
		local text = displayName(ball.byCnId[cnId]) -- equivalent call inferred; original call site unknown
		v45.Text = text
	end

	v31 = {}
	local v45 = nil
	local v46 = nil

	local function populate(p, p2, items2)
		local v47 = v32[p]

		if not v47 then
			clearGeneratedSlots(p)
			v47 = LazyGrid.new(p, v16, {
				active = function()
					return flag and v12.Enabled and v15.Visible and v13.Visible
				end,
				assign = function(p3, p4)
					v31[p3] = p4
				end,
				equal = function(data, data2)
					if data then
						if data.config == data2.config and data.instanceId == data2.instanceId and data.count == data2.count and data.serial == data2.serial and data.killCount == data2.killCount and data.tradable == data2.tradable and data.locked == data2.locked then
							data = data.listed == data2.listed
						else
							data = false
						end
					end

					return data
				end,
				paint = writeCell,
				changed = function()
					if v5 then
						v5:Refresh()
					end
				end,
				bindVisual = function(instance)
					bindLockDescription(instance:FindFirstChild("锁"))
					setupButtonFeedback(instance)
					ButtonActions.Bind(instance, function()
						local v48 = v31[instance.Parent]

						if v48 and GamepadSupport.CanActivate(instance) then
							showDetail(v48)
						end
					end)
				end,
				bindCell = function(p3)
					ButtonActions.Bind(p3, function()
						local v48 = v31[p3]

						if v48 and GamepadSupport.CanActivate(p3) then
							showDetail(v48)
						end
					end)
					p3.SelectionGained:Connect(function()
						local v48 = v31[p3]

						if v48 and GamepadSupport.IsGamepad() and GamepadSupport.CanActivate(p3) then
							showDetail(v48)
						end
					end)
				end
			})
			v32[p] = v47
		end

		v47:Set(p2, items2)

		for _, item in items2 do
			if not v46 then
				v46 = item
			end

			local key = item.key
			local v49 = selectionKey() -- equivalent call inferred; original call site unknown

			if key == v36[v49] then
				v45 = item
			end
		end
	end

	local v47 = owned
	local v48

	if cnId then
		v48 = v8
	else
		v48 = v19
	end

	populate(v47, v48, filtered)
	populate(unowned, v20, v42)
	unowned.Visible = #v42 > 0
	owned.Visible = true
	v21.Visible = #v42 > 0
	local v49 = cnId and InventoryEntries.equippedId(client.equipment(), v40.itemType, cnId)
	local v51 = v45

	if not v51 then
		if cnId then
			v51 = InventoryEntries.preferred(filtered, v49)
		else
			v51 = v46
		end
	end

	showDetail(v51)
	v16.CanvasPosition = canvasPosition

	if v5 then
		v5:Refresh()
	end
end

local flag3 = false

local function queueRefresh()
	if flag and not flag3 then
		flag3 = true
		task.defer(function()
			flag3 = false

			if not flag then
				return
			end

			if v11 == "fusion" then
				FusionClient.Refresh()
			else
				refresh()
			end
		end)
	end
end

local function switchInventoryTab(inventoryCategory)
	if v37 then
		v37.Visible = false
	end

	v39 = nil
	v38 = nil

	if cnId then
		v16.CanvasPosition = zero
	end

	cnId = nil
	CopiesView.Reset()
	v6.Visible = false

	if v10[v11] then
		canvasPositions[v11] = v16.CanvasPosition
	end

	PriceHistory.Close()
	v11 = inventoryCategory

	if v5 then
		v5:SetTab()
	end

	v35 = nil
	v15.Visible = inventoryCategory ~= "fusion"

	for _, v40 in v32 do
		v40:Invalidate()
	end

	panel["福利入口栏"].Visible = inventoryCategory ~= "fusion"
	v15:SetAttribute("InventoryCategory", inventoryCategory)
	FusionClient.SetVisible(inventoryCategory == "fusion")
	info.Visible = inventoryCategory == "ball"
	equip2.Visible = false
	unequip.Visible = false
	PriceHistory.SetCategory(inventoryCategory)

	if v10[inventoryCategory] then
		refresh()
		v16.CanvasPosition = canvasPositions[inventoryCategory] or Vector2.zero
	end
end

function Inventory.Open()
	showInventory()
	switchInventoryTab(v11)

	if v5 then
		v5:Open()
	end
end

function Inventory.Init()
	v12 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("背包")
	v13 = v12:WaitForChild("背景")
	panel = v13:WaitForChild("面板")
	v15 = panel:WaitForChild("通用库存")
	v16 = v15["左框"]["球列表"]
	v37 = v15:WaitForChild("锁说明框")
	v16:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if v37 then
			v37.Visible = false
		end

		v39 = nil
		v38 = nil
	end)
	v37.AnchorPoint = Vector2.zero

	if v37 then
		v37.Visible = false
	end

	v39 = nil
	v38 = nil
	v15:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if v39 then
			positionLockDescription()
		end
	end)

	for _, screenGui in {
		v12,
		v13,
		v15,
		v16
	} do
		screenGui:GetPropertyChangedSignal(screenGui:IsA("ScreenGui") and "Enabled" or "Visible"):Connect(function()
			if v39 then
				positionLockDescription()
			end

			for _, v40 in v32 do
				v40:Invalidate()
			end
		end)
	end

	owned = v16["已拥有列表"]
	unowned = v16["未拥有列表"]
	uIGridLayout = owned:WaitForChild("UIGridLayout")
	uIGridLayout2 = unowned:WaitForChild("UIGridLayout")
	v21 = v16["未拥有标题"]
	v19 = prepareTemplate(owned, true)
	v20 = prepareTemplate(unowned)
	local v40 = v15["右框"]

	for k, v41 in {
		Classic = "经典属性",
		Shiny = "闪光属性",
		Rainbow = "彩虹属性"
	} do
		BallQualityTextStyle.apply(v40["分类数量"][v41], k)
	end

	BallQualityTextStyle.apply(v40["升级按钮"]["品质文字"], "Shiny")
	BallQualityTextStyle.apply(v40["合成彩虹按钮"]["品质文字"], "Rainbow")
	v22 = v40["物品图标"]
	v23 = v40["名称"]
	v24 = v40["品质"]
	v28 = v40["详细描述"]
	v29 = v40["未拥有详细描述区"]
	v30 = v29["详细描述"]
	equip2 = v40["装备按钮"]
	unequip = v40["取消装备按钮"]
	unequip.Position = equip2.Position
	v6 = v15:WaitForChild("副本标题栏")
	copies = v40:WaitForChild("查看副本按钮")
	v9 = v40:WaitForChild("副本状态")
	v8 = v19
	CopiesView.Init(v15, setupButtonFeedback, function()
		v16.CanvasPosition = Vector2.zero
		refresh()
	end, v2)
	v4 = { v40:WaitForChild("升级按钮"), v40:WaitForChild("合成彩虹按钮"), v40:WaitForChild("最高形态按钮") }
	upgrade = v4[1]

	for _, v41 in { v4[1], v4[2] } do
		setupButtonFeedback(v41)
		local v42 = v41
		ButtonActions.Bind(v41, function()
			if not (GamepadSupport.CanActivate(v42) and v35) then
				return
			end

			local cnId2 = v35.config.cnId
			local v43 = not cnId and "All" or CopiesView.Kind(v35)
			switchInventoryTab("fusion")
			FusionClient.OpenBall(cnId2, v43)
		end)
	end

	local function closeCopies()
		if not cnId then
			return false
		end

		local v41 = cnId
		cnId = nil
		v36[v11] = v11 .. ":" .. v41
		refresh()
		v16.CanvasPosition = zero
		return true
	end

	local function openCopies()
		if not (GamepadSupport.CanActivate(copies) and v35 and v35.count) then
			return
		end

		zero = v16.CanvasPosition
		cnId = v35.config.cnId
		CopiesView.Reset()
		local v41 = v36
		local v42 = selectionKey() -- equivalent call inferred; original call site unknown
		v41[v42] = nil
		refresh()
		v16.CanvasPosition = Vector2.zero
	end

	setupButtonFeedback(v6["返回按钮"])
	setupButtonFeedback(copies)
	ButtonActions.Bind(copies, openCopies)
	ButtonActions.Bind(v6["返回按钮"], function()
		if GamepadSupport.CanActivate(v6["返回按钮"]) then
			if not cnId then
				return
			end

			local v41 = cnId
			cnId = nil
			v36[v11] = v11 .. ":" .. v41
			refresh()
			v16.CanvasPosition = zero
		end
	end)
	info = v15["说明按钮"]
	PriceHistory.Init(panel)
	FusionClient.Init({
		fusionFrame = panel:WaitForChild("合成界面"),
		setupButtonFeedback = setupButtonFeedback,
		changed = function()
			if v5 then
				v5:Refresh()
			end
		end
	})

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateSizes()
		updateScrollBarThickness(v16) -- equivalent call inferred; original call site unknown
		updateGridCellSize(owned, uIGridLayout)
		updateGridCellSize(unowned, uIGridLayout2)
	end

	updateSizes() -- equivalent call inferred; original call site unknown
	owned:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSizes)
	unowned:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSizes)
	v16:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSizes)
	v16:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateSizes)
	v16.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	size = panel.Size
	local close = panel["关闭按钮"]
	setupButtonFeedback(close)
	ButtonActions.Bind(close, hideInventory)
	local v42 = panel["福利入口栏"]
	local _24H = v42["24H新手礼包按钮"]
	setupButtonFeedback(_24H)
	StarterPackOffer.bindEntryButton(_24H, hideInventory)
	local invite = v42["邀请按钮"]
	setupButtonFeedback(invite)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshInviteButton()
		invite.Visible = not client.hasClaimedFriendInviteFreeChest()
	end

	refreshInviteButton() -- equivalent call inferred; original call site unknown
	client.hasClaimedFriendInviteFreeChest.Changed(refreshInviteButton)
	ButtonActions.Bind(invite, function()
		if not GamepadSupport.CanActivate(invite) then
			return
		end

		FriendInviteRewardService.client.promptInvite()
	end)
	setupButtonFeedback(info)
	ButtonActions.Bind(info, openBallRulesPanel)
	local v44 = panel["上方选择栏"]["上方选择栏"]

	for k, v45 in v10 do
		local v46 = v44[v45.tabButton]
		setupButtonFeedback(v46)
		local v47 = k
		ButtonActions.Bind(v46, function()
			switchInventoryTab(v47)
		end)
	end

	local v45 = v44["合成界面按钮"]
	setupButtonFeedback(v45)
	ButtonActions.Bind(v45, function()
		switchInventoryTab("fusion")
	end)
	setupButtonFeedback(equip2)
	setupButtonFeedback(unequip)

	local function equipSelected(p)
		local v46 = v10[v11]

		if not v46 or v11 == "ball" and (not cnId or p) or not v35 or not v35.instanceId or v35.listed or v35.locked then
			return
		end

		local canActivate = GamepadSupport.CanActivate
		local v47

		if p then
			v47 = unequip
		else
			v47 = equip2
		end

		if not canActivate(v47) then
			return
		end

		local equip = client2.equip
		local itemType = v46.itemType
		local v48

		if not p then
			v48 = v35.instanceId
		end

		if not equip(itemType, v48) then
			warn("[Inventory] Equipment update failed")
		end
	end

	ButtonActions.Bind(equip2, function()
		equipSelected(false)
	end)
	ButtonActions.Bind(unequip, function()
		equipSelected(true)
	end)
	client.items.Changed(queueRefresh)
	client.boothListings.Changed(function()
		if v11 ~= "fusion" and flag then
			if flag3 then
				return
			end

			flag3 = true
			task.defer(function()
				flag3 = false

				if not flag then
					return
				end

				if v11 == "fusion" then
					FusionClient.Refresh()
				else
					refresh()
				end
			end)
		end
	end)
	client.equipment.Changed(function()
		if flag and v11 ~= "fusion" and flag then
			if flag3 then
				return
			end

			flag3 = true
			task.defer(function()
				flag3 = false

				if not flag then
					return
				end

				if v11 == "fusion" then
					FusionClient.Refresh()
				else
					refresh()
				end
			end)
		end
	end)
	v15:SetAttribute("InventoryCategory", "ball")
	equip2.Visible = false
	unequip.Visible = false
	v13.Visible = false
	local v46 = panel["合成界面"]
	local v47 = v46["左侧选择栏"]["左侧选择栏"]
	v5 = GamepadNavigation.new({
		panel = panel,
		getTab = function()
			return v11
		end,
		tabs = {
			v44["小球库存按钮"],
			v44["爆炸特效按钮"],
			v44["飞行器按钮"],
			v44["合成界面按钮"]
		},
		owned = owned,
		unowned = unowned,
		close = close,
		starter = _24H,
		invite = invite,
		equip = equip2,
		unequip = unequip,
		price = nil,
		info = info,
		history = panel["价格趋势页面"],
		back = panel["价格趋势页面"]["返回按钮"],
		fusionInventory = v46["库存"]["列表"],
		getFusionSelected = FusionClient.GetMaterialList,
		fusionTabs = {
			v47["小球合成按钮"],
			v47["小球库存按钮"],
			v47["飞行器库存按钮"],
			v47["爆炸特效库存按钮"]
		},
		fusionHome = v46["球种主页"]["列表"],
		fusionHeader = v46["库存"]["副本标题栏"],
		onFusionBack = FusionClient.Back,
		compose = v46["合成框"]["合成按钮"],
		unavailable = v46["合成框"]["无法合成按钮"],
		upgrade = upgrade,
		getUpgrade = function()
			return upgrade
		end,
		isUpgrade = function()
			return false
		end,
		onUpgradeBack = function() end,
		copiesFilters = {
			v6["全部筛选"],
			v6["经典筛选"],
			v6["闪光筛选"],
			v6["彩虹筛选"]
		},
		copies = copies,
		copiesBack = v6["返回按钮"],
		isCopies = function()
			return cnId ~= nil
		end,
		onCopiesBack = closeCopies,
		onTab = switchInventoryTab,
		onClose = hideInventory,
		onBack = function()
			if v11 == "fusion" then
				return FusionClient.Back()
			end

			return PriceHistory.Close()
		end,
		onPrice = PriceHistory.Open,
		onEquip = equipSelected
	})
end

return Inventory