local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local GiftConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("GiftConfig"))
local Numbers = require(script.Parent.Parent.Utilities.Numbers)
local MarketplaceInfoCache = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("MarketplaceInfoCache"))
local UpgradeMultipliers = require(ReplicatedStorage._FRAMEWORK.Libraries.UpgradeMultipliers)
local PlayerUpgradesInventoryUI = {}
local color = Color3.fromHex("3cff00")
local object = setmetatable({}, {
	__mode = "k"
})
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local object2 = setmetatable({}, {
	__mode = "k"
})

local function configureScrollingFrame(folder)
	if object2[folder] then
		return
	end

	object2[folder] = true
	local Y = folder.CanvasSize.Y
	folder.AutomaticCanvasSize = Enum.AutomaticSize.None
	local uIListLayout = folder:FindFirstChildOfClass("UIListLayout")
	local v = not uIListLayout and 0 or uIListLayout.Padding.Scale or 0
	local v2 = not uIListLayout and 0 or uIListLayout.Padding.Offset or 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateListPadding()
		if not uIListLayout then
			return
		end

		local v3 = math.max(0, (math.round((folder.AbsoluteWindowSize.Y * Y.Scale + Y.Offset) * v + v2)))
		uIListLayout.Padding = UDim.new(0, v3)
	end

	local function getContentWidth()
		local X = folder.AbsoluteWindowSize.X
		local uIPadding = folder:FindFirstChildWhichIsA("UIPadding")

		if not uIPadding then
			return X
		end

		local v3 = uIPadding.PaddingLeft.Offset + uIPadding.PaddingLeft.Scale * X
		local v4 = uIPadding.PaddingRight.Offset + uIPadding.PaddingRight.Scale * X
		return (math.max(0, X - v3 - v4))
	end

	local function resizeRow(guiObject)
		if not guiObject:IsA("GuiObject") or guiObject:GetAttribute("InventoryGroupHeader") then
			return
		end

		local inventoryRowScaleY = guiObject:GetAttribute("InventoryRowScaleY")

		if inventoryRowScaleY == nil and guiObject.Size.Y.Scale ~= 0 then
			inventoryRowScaleY = guiObject.Size.Y.Scale
			guiObject:SetAttribute("InventoryRowScaleY", inventoryRowScaleY)
			guiObject:SetAttribute("InventoryRowOffsetY", guiObject.Size.Y.Offset)
		end

		if type(inventoryRowScaleY) ~= "number" then
			return
		end

		local inventoryRowOffsetY = guiObject:GetAttribute("InventoryRowOffsetY") or 0
		local uIAspectRatioConstraint = guiObject:FindFirstChildWhichIsA("UIAspectRatioConstraint")
		local v3

		if uIAspectRatioConstraint and uIAspectRatioConstraint.AspectRatio > 0 then
			uIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Width
			local X = folder.AbsoluteWindowSize.X
			local uIPadding = folder:FindFirstChildWhichIsA("UIPadding")

			if uIPadding then
				local v4 = uIPadding.PaddingLeft.Offset + uIPadding.PaddingLeft.Scale * X
				local v5 = uIPadding.PaddingRight.Offset + uIPadding.PaddingRight.Scale * X
				X = math.max(0, X - v4 - v5)
			end

			v3 = math.max(
				0,
				(math.round((X * guiObject.Size.X.Scale + guiObject.Size.X.Offset) / uIAspectRatioConstraint.AspectRatio + inventoryRowOffsetY))
			)
		else
			v3 = math.max(0, (math.round(inventoryRowScaleY * folder.AbsoluteSize.Y + inventoryRowOffsetY)))
		end

		guiObject.Size = UDim2.new(guiObject.Size.X.Scale, guiObject.Size.X.Offset, 0, v3)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resizeRows()
		for _, child in ipairs(folder:GetChildren()) do
			resizeRow(child)
		end

		updateListPadding() -- equivalent call inferred; original call site unknown
	end

	local function isEffectivelyVisible(folder2)
		local parent = folder2

		while parent and parent ~= playerGui do
			if parent:IsA("GuiObject") and not parent.Visible then
				return false
			end

			if parent:IsA("ScreenGui") and not parent.Enabled then
				return false
			else
				parent = parent.Parent
			end
		end

		local currentCamera = workspace.CurrentCamera

		if not currentCamera or folder2.AbsoluteSize.X <= 0 or folder2.AbsoluteSize.Y <= 0 then
			return false
		end

		local absolutePosition = folder2.AbsolutePosition
		local absoluteSize = folder2.AbsoluteSize
		local viewportSize = currentCamera.ViewportSize
		return absolutePosition.X < viewportSize.X and absolutePosition.Y < viewportSize.Y and absolutePosition.X + absoluteSize.X > 0 and absolutePosition.Y + absoluteSize.Y > 0
	end

	local function isVisibleDescendant(parent)
		while parent and parent ~= folder do
			if parent:IsA("GuiObject") and not parent.Visible then
				return false
			else
				parent = parent.Parent
			end
		end

		return parent == folder
	end

	local function updateCanvasSize()
		if not isEffectivelyVisible(folder) then
			return
		end

		local Y2 = folder.AbsolutePosition.Y
		local v3 = 0

		for _, guiObject in ipairs(folder:GetDescendants()) do
			if guiObject:IsA("GuiObject") and isVisibleDescendant(guiObject) then
				v3 = math.max(
					v3,
					guiObject.AbsolutePosition.Y - Y2 + folder.CanvasPosition.Y + guiObject.AbsoluteSize.Y
				)
			end
		end

		local uIPadding = folder:FindFirstChildWhichIsA("UIPadding")

		if uIPadding then
			v3 += uIPadding.PaddingBottom.Offset + uIPadding.PaddingBottom.Scale * folder.AbsoluteWindowSize.Y
		end

		folder.CanvasSize = UDim2.new(
			folder.CanvasSize.X.Scale,
			folder.CanvasSize.X.Offset,
			0,
			(math.max(0, (math.ceil(v3))))
		)
	end

	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function scheduleCanvasUpdate()
		if flag then
			return
		end

		flag = true
		task.defer(function()
			RunService.RenderStepped:Wait()
			flag = false

			if folder.Parent then
				updateCanvasSize()
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watchGuiObject(guiObject)
		if not guiObject:IsA("GuiObject") then
			return
		end

		guiObject:GetPropertyChangedSignal("Visible"):Connect(scheduleCanvasUpdate)
		guiObject:GetPropertyChangedSignal("AbsoluteSize"):Connect(scheduleCanvasUpdate)
	end

	folder.DescendantAdded:Connect(function(descendant)
		watchGuiObject(descendant) -- equivalent call inferred; original call site unknown
		task.defer(function()
			resizeRows() -- equivalent call inferred; original call site unknown
			scheduleCanvasUpdate() -- equivalent call inferred; original call site unknown
		end)
	end)
	folder.DescendantRemoving:Connect(scheduleCanvasUpdate)
	folder:GetPropertyChangedSignal("Visible"):Connect(scheduleCanvasUpdate)
	folder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		resizeRows() -- equivalent call inferred; original call site unknown
		scheduleCanvasUpdate() -- equivalent call inferred; original call site unknown
	end)
	folder:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
		resizeRows() -- equivalent call inferred; original call site unknown
		scheduleCanvasUpdate() -- equivalent call inferred; original call site unknown
	end)

	if uIListLayout then
		uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(scheduleCanvasUpdate)
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		watchGuiObject(descendant) -- equivalent call inferred; original call site unknown
	end

	local parent = folder.Parent

	while parent and parent ~= playerGui do
		if parent:IsA("GuiObject") then
			parent:GetPropertyChangedSignal("Visible"):Connect(scheduleCanvasUpdate)
		elseif parent:IsA("ScreenGui") then
			parent:GetPropertyChangedSignal("Enabled"):Connect(scheduleCanvasUpdate)
		end

		parent = parent.Parent
	end

	resizeRows() -- equivalent call inferred; original call site unknown

	if not flag then
		flag = true
		task.defer(function()
			RunService.RenderStepped:Wait()
			flag = false

			if folder.Parent then
				updateCanvasSize()
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getModalsFrame()
	local speedGameUI = playerGui:FindFirstChild("SpeedGameUI")
	local modals = speedGameUI and speedGameUI:FindFirstChild("Modals")
	local inventoryModal = modals and modals:FindFirstChild("InventoryModal")
	return inventoryModal and inventoryModal:FindFirstChild("ModalsFrame")
end

function PlayerUpgradesInventoryUI.getInventoryTab(childName)
	local modalsFrame = getModalsFrame() -- equivalent call inferred; original call site unknown
	return modalsFrame and modalsFrame:FindFirstChild(childName)
end

function PlayerUpgradesInventoryUI.whenInventoryTabReady(childName, callback)
	task.spawn(function()
		callback((playerGui:WaitForChild("SpeedGameUI", 60):WaitForChild("Modals"):WaitForChild("InventoryModal"):WaitForChild("ModalsFrame"):WaitForChild(childName)))
	end)
end

local function getGiftModalElement(p)
	for _, v in ipairs(CollectionService:GetTagged("GiftToPlayer")) do
		if v:IsDescendantOf(playerGui) and v:GetAttribute("Type") == p then
			return v
		end
	end

	return nil
end

local function getGiftModal()
	for _, v in ipairs(CollectionService:GetTagged("GiftToPlayerModal")) do
		if v:IsDescendantOf(playerGui) then
			return v
		end
	end

	return nil
end

local flag = false

function PlayerUpgradesInventoryUI.openGiftModal(giftType, data)
	if flag then
		return
	end

	flag = true
	task.delay(0.5, function()
		flag = false
	end)
	local v = GiftConfig.ALL_GIFTS[giftType]

	if not v then
		return
	end

	local giftModal = getGiftModal()

	if not giftModal then
		return
	end

	giftModal:SetAttribute("GiftType", giftType)
	local v3

	if data then
		v3 = data.Source or nil
	end

	giftModal:SetAttribute("GiftSource", v3)
	local v5

	if data then
		v5 = data.SlotId or nil
	end

	giftModal:SetAttribute("GiftSourceSlotId", v5)
	local giftModalElement = getGiftModalElement("ItemNameLabel")

	if giftModalElement then
		local tier = data and data.Tier or 0
		giftModalElement.Text = v.Name .. (not (tier > 0) and "" or (" (T%d)"):format(tier))
	end

	local giftModalElement2 = getGiftModalElement("ItemImage")

	if giftModalElement2 then
		giftModalElement2.Image = v.Image
	end

	local giftModalElement3 = getGiftModalElement("UsernameInput")

	if giftModalElement3 then
		giftModalElement3.Text = ""
	end

	local giftModalElement4 = getGiftModalElement("AvatarImage")

	if giftModalElement4 then
		giftModalElement4.Image = ""
	end

	local giftModalElement5 = getGiftModalElement("PlayerNameLabel")

	if giftModalElement5 then
		giftModalElement5.Text = ""
	end

	if giftModal.Parent and (giftModal.Parent.Name == "InventoryModal" or giftModal.Parent.Name == "ModalsFrame") then
		local speedGameUI = playerGui:FindFirstChild("SpeedGameUI")
		local modals = speedGameUI and speedGameUI:FindFirstChild("Modals")

		if modals then
			giftModal.Parent = modals
		end
	end

	ClientState:ToggleModal(giftModal)
end

function PlayerUpgradesInventoryUI.getRowTemplate(p)
	return ReplicatedStorage.Templates[p]
end

function PlayerUpgradesInventoryUI.getScrollingFrame(p)
	local scrollingFrame = p.Root.ScrollingFrame
	configureScrollingFrame(scrollingFrame)
	return scrollingFrame
end

function PlayerUpgradesInventoryUI.groupEntriesByGalaxy(list, callback)
	local GALAXY_INDEX = Config.GALAXY_INDEX

	local function compare(p, p2)
		local v = callback(p)
		local v2 = callback(p2)

		if v == v2 then
			return p.key < p2.key
		end

		return v < v2
	end

	local result = {}
	local result2 = {}

	for _, v in ipairs(list) do
		local catalogGalaxy = UpgradeMultipliers.catalogGalaxy(v.data)

		if catalogGalaxy == GALAXY_INDEX then
			table.insert(result, v)
		else
			result2[catalogGalaxy] = result2[catalogGalaxy] or {}
			table.insert(result2[catalogGalaxy], v)
		end
	end

	table.sort(result, compare)
	local result3 = {}

	for k, list2 in pairs(result2) do
		table.sort(list2, compare)
		table.insert(result3, k)
	end

	table.sort(result3)
	return result, result2, result3
end

function PlayerUpgradesInventoryUI.addGalaxyGroupHeader(parent, layoutOrder, p, p2)
	local clone = ReplicatedStorage.Templates.TrailsAurasHeader:Clone()
	clone.LayoutOrder = layoutOrder
	clone.Visible = true
	clone.Title.Text = string.format("Galaxy %d %s:", p, p2)
	clone:SetAttribute("InventoryGroupHeader", true)
	clone.Parent = parent
end

function PlayerUpgradesInventoryUI.renderGalaxyGroups(_, list, p, list2, _, callback)
	local count = 0

	local function nextOrder()
		count += 1
		return count
	end

	for _, v in ipairs(list) do
		count += 1
		callback(v, count)
	end

	for _, v in ipairs(list2) do
		for _, v2 in ipairs(p[v]) do
			count += 1
			callback(v2, count)
		end
	end
end

function PlayerUpgradesInventoryUI.isEventActive(p)
	local now = os.time()
	local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))

	for _, v in ipairs(EventsConfig.Events or {}) do
		if v.Name == p and v.Start <= now and now < v.End then
			return true
		end
	end

	return false
end

function PlayerUpgradesInventoryUI.isTrailEventLive(p)
	for _, v in ipairs(p.Events or {}) do
		if PlayerUpgradesInventoryUI.isEventActive(v) then
			return true
		end
	end

	return false
end

function PlayerUpgradesInventoryUI.shouldHideEventTrail(p, list, p2)
	return table.find(list, p2) == nil and not PlayerUpgradesInventoryUI.isTrailEventLive(p)
end

function PlayerUpgradesInventoryUI.isAuraObtainable(p, data)
	return (data.price or 0) > 0 or (data.gamepass or 0) > 0 or (data.DevProduct or 0) > 0 or GiftConfig.ALL_GIFTS[p] ~= nil or p == "MedalAura"
end

function PlayerUpgradesInventoryUI.isTrailObtainable(p, data)
	local v = not data.CurrencyPrice and 0 or data.CurrencyPrice.Amount or 0
	return (data.Price or 0) > 0 or ((data.Gamepass or 0) > 0 or ((data.DevProduct or 0) > 0 or (v > 0 or (GiftConfig.ALL_GIFTS[p] ~= nil or PlayerUpgradesInventoryUI.isTrailEventLive(data)))))
end

function PlayerUpgradesInventoryUI.shouldHideIfUnobtainable(p, list, p2)
	return not p and table.find(list, p2) == nil
end

function PlayerUpgradesInventoryUI:showRow()
	self.Visible = true
end

function PlayerUpgradesInventoryUI:applyRevealGate(name)
	if CollectionService:HasTag(self, "RevealUI") then
		return
	end

	CollectionService:AddTag(self, "RevealUI")
	self:SetAttribute("Name", name)
	self.Visible = false
end

function PlayerUpgradesInventoryUI.clearRevealGate(instance)
	if not CollectionService:HasTag(instance, "RevealUI") then
		return
	end

	CollectionService:RemoveTag(instance, "RevealUI")
	instance:SetAttribute("Name", nil)
	PlayerUpgradesInventoryUI.showRow(instance)
end

function PlayerUpgradesInventoryUI.formatBoostText(p)
	return "👟 x" .. Numbers.formatMultiplier(p) .. " Speed Boost"
end

local function rowColor3(value)
	if typeof(value) == "ColorSequence" then
		value = value.Keypoints[1].Value
	end

	return value
end

local function paintRowGradient(uIGradient, value)
	local keypoints = uIGradient.Color.Keypoints
	local colorSequenceKeypoints = table.create(#keypoints)

	for i, keypoint in ipairs(keypoints) do
		local v

		if i <= 2 then
			v = value
		else
			v = keypoint.Value
		end

		colorSequenceKeypoints[i] = ColorSequenceKeypoint.new(keypoint.Time, v)
	end

	uIGradient.Color = ColorSequence.new(colorSequenceKeypoints)
end

function PlayerUpgradesInventoryUI.applyRowColor(p, backgroundColor)
	if typeof(backgroundColor) == "ColorSequence" then
		backgroundColor = backgroundColor.Keypoints[1].Value
	end

	p.Container.SpotFrame.BackgroundColor3 = backgroundColor
	local background = p.Container.Background
	paintRowGradient(background.UIGradient, backgroundColor)
	paintRowGradient(background.UIStroke.UIGradient, backgroundColor)
end

function PlayerUpgradesInventoryUI.applyRoundedIcon(p)
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.5, 0)
	uICorner.Parent = p.Container.SpotFrame.Icon
end

function PlayerUpgradesInventoryUI.applyRowContent(p, text, value, p2, p3, value2)
	local info = p.Container.Info
	info.Title.Text = text
	p.Container.SpotFrame.Icon.Image = value or ""
	local bonus = info.Bonus

	if p2 == nil then
		bonus.Visible = false
	else
		bonus.Visible = true
		bonus.Text = PlayerUpgradesInventoryUI.formatBoostText(p2)
	end

	local description = info:FindFirstChild("Description")

	if description then
		local text2 = value2 or ""
		description.Text = text2
		description.Visible = text2 ~= ""
	end

	if p3 then
		PlayerUpgradesInventoryUI.applyRowColor(p, p3)
	end
end

function PlayerUpgradesInventoryUI.clearBuiltRows(instance)
	if not instance then
		return
	end

	for _, child in ipairs(instance:GetChildren()) do
		if child:GetAttribute("CosmeticKey") or child:GetAttribute("InventoryGroupHeader") then
			child:Destroy()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPriceLabel(p, text)
	p.Title.Text = text
end

local function connectButton(button, onMouseButton1Click)
	if not (button and button:IsA("GuiButton")) or button:GetAttribute("IsConnected") then
		return
	end

	button:SetAttribute("IsConnected", true)
	button.MouseButton1Click:Connect(onMouseButton1Click)
end

function PlayerUpgradesInventoryUI.setRobuxPrice(p, p2, p3)
	if not p or not p2 or p2 <= 0 then
		return
	end

	MarketplaceInfoCache.Request(p2, p3, function(p4)
		local priceInRobux = p4 and (p4.PriceInRobux or p4.Price)

		if p.Parent and priceInRobux then
			setPriceLabel(p, tostring(priceInRobux)) -- equivalent call inferred; original call site unknown
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyHighlight(p, p2)
	local backgroundColor3 = object[p]

	if not backgroundColor3 then
		backgroundColor3 = p.BackgroundColor3
		object[p] = backgroundColor3
	end

	if p2 then
		p.BackgroundColor3 = color
	else
		p.BackgroundColor3 = backgroundColor3
	end
end

function PlayerUpgradesInventoryUI.wireRow(instance, data)
	local buttons = instance.Container.Buttons
	local buyWins = buttons.BuyWins
	local buyRobux = buttons.BuyRobux
	local buyGift = buttons.BuyGift
	local equip = buttons.Equip
	local cosmeticKey = instance:GetAttribute("CosmeticKey")
	local showBuyWins = data.showBuyWins == true
	local showBuyGamepass = data.showBuyGamepass == true
	local showBuyGift = data.showBuyGift == true
	instance:SetAttribute("ShowBuyWins", showBuyWins)
	instance:SetAttribute("ShowBuyGamepass", showBuyGamepass)
	instance:SetAttribute("ShowBuyGift", showBuyGift)

	if cosmeticKey then
		buyWins:SetAttribute("Type", cosmeticKey)
		buyRobux:SetAttribute("Type", cosmeticKey)
		buyGift:SetAttribute("Type", cosmeticKey)
		equip:SetAttribute("Type", cosmeticKey)
	end

	buyWins.Visible = showBuyWins
	buyRobux.Visible = showBuyGamepass
	buyGift.Visible = showBuyGift

	if showBuyWins and data.winsPriceText then
		setPriceLabel(buyWins, data.winsPriceText) -- equivalent call inferred; original call site unknown
	end

	if data.onBuyWins then
		local onBuyWins = data.onBuyWins

		if buyWins and buyWins:IsA("GuiButton") and not buyWins:GetAttribute("IsConnected") then
			buyWins:SetAttribute("IsConnected", true)
			buyWins.MouseButton1Click:Connect(onBuyWins)
		end
	end

	if showBuyGamepass and data.devProductId then
		PlayerUpgradesInventoryUI.setRobuxPrice(buyRobux, data.devProductId, Enum.InfoType.Product)
	elseif showBuyGamepass and data.gamepassId then
		PlayerUpgradesInventoryUI.setRobuxPrice(buyRobux, data.gamepassId, Enum.InfoType.GamePass)
	end

	if data.onBuyGamepass then
		local onBuyGamepass = data.onBuyGamepass

		if buyRobux and buyRobux:IsA("GuiButton") and not buyRobux:GetAttribute("IsConnected") then
			buyRobux:SetAttribute("IsConnected", true)
			buyRobux.MouseButton1Click:Connect(onBuyGamepass)
		end
	end

	if data.onBuyGift then
		local onBuyGift = data.onBuyGift

		if buyGift and buyGift:IsA("GuiButton") and not buyGift:GetAttribute("IsConnected") then
			buyGift:SetAttribute("IsConnected", true)
			buyGift.MouseButton1Click:Connect(onBuyGift)
		end
	end

	if data.onEquip then
		local onEquip = data.onEquip

		if equip and equip:IsA("GuiButton") and not equip:GetAttribute("IsConnected") then
			equip:SetAttribute("IsConnected", true)
			equip.MouseButton1Click:Connect(onEquip)
		end
	end

	if data.onEquipAsCosmetic then
		instance:SetAttribute("HasCosmetic", true)
		local cosmetic = buttons.Cosmetic

		if cosmeticKey then
			cosmetic:SetAttribute("Type", cosmeticKey)
		end

		local onEquipAsCosmetic = data.onEquipAsCosmetic

		if cosmetic and cosmetic:IsA("GuiButton") and not cosmetic:GetAttribute("IsConnected") then
			cosmetic:SetAttribute("IsConnected", true)
			cosmetic.MouseButton1Click:Connect(onEquipAsCosmetic)
		end

		buttons.Info.Visible = false
	end
end

function PlayerUpgradesInventoryUI:updateRowState(visible, p, p2)
	local buttons = self.Container.Buttons

	if self:GetAttribute("Hidden") == true then
		self.Visible = false
		return
	end

	if not CollectionService:HasTag(self, "RevealUI") then
		PlayerUpgradesInventoryUI.showRow(self)
	end

	buttons.BuyWins.Visible = not visible and self:GetAttribute("ShowBuyWins") == true
	buttons.BuyRobux.Visible = not visible and self:GetAttribute("ShowBuyGamepass") == true
	buttons.BuyGift.Visible = self:GetAttribute("ShowBuyGift") == true
	local equip = buttons.Equip
	equip.Visible = visible
	applyHighlight(equip, p) -- equivalent call inferred; original call site unknown
	equip.Title.Text = p and "Equipped" or "Equip"

	if self:GetAttribute("HasCosmetic") == true then
		local cosmetic = buttons.Cosmetic
		cosmetic.Visible = visible and not p
		applyHighlight(cosmetic, p2 == true) -- equivalent call inferred; original call site unknown
	end
end

function PlayerUpgradesInventoryUI.setBonusOverride(p, text, visible)
	local bonus = p.Container.Info.Bonus
	bonus.Text = text
	bonus.Visible = visible
end

function PlayerUpgradesInventoryUI.setEquipTitle(p, text, p2)
	local equip = p.Container.Buttons.Equip
	setPriceLabel(equip, text) -- equivalent call inferred; original call site unknown
	equip.Active = p2
	equip.AutoButtonColor = p2
end

return PlayerUpgradesInventoryUI