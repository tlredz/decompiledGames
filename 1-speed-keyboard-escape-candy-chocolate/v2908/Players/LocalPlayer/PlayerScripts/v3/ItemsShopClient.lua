local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Items = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("Items"))
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local ItemsShopConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("ItemsShopConfig"))
local SoundManager = require(ReplicatedStorage:WaitForChild("SoundManager"))
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local ItemRarityGradient = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("ItemRarityGradient"))
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local ItemsShopRemotes = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("ItemsShopRemotes"))
local v = nil
local flag = false

local function getShopElement(p, p2)
	for _, v2 in ipairs(CollectionService:GetTagged("ItemsShop")) do
		if v2:IsDescendantOf(playerGui) and v2:GetAttribute("Rarity") == p and v2:GetAttribute("Type") == p2 then
			return v2
		end
	end

	return nil
end

local function getShopElementByType(p)
	for _, v2 in ipairs(CollectionService:GetTagged("ItemsShop")) do
		if v2:IsDescendantOf(playerGui) and v2:GetAttribute("Type") == p then
			return v2
		end
	end

	return nil
end

local function formatNumber(p)
	if p >= 1000000000 then
		return string.format("%.1fB", p / 1000000000)
	end

	if p >= 1000000 then
		return string.format("%.1fM", p / 1000000)
	end

	if p >= 1000 then
		return string.format("%.1fK", p / 1000)
	end

	return (tostring(p))
end

local function updateSlotUI(p, p2, p3, p4)
	if not p2 then
		return
	end

	local v2 = Items.ITEMS[p2]

	if not v2 then
		return
	end

	local v3 = math.max(0, p3 - p4)
	local shopElement = getShopElement(p, "Stock")

	if shopElement then
		if v3 <= 0 then
			shopElement.Text = "Sold out"
		else
			shopElement.Text = v3 .. "/" .. p3
		end
	end

	local shopElement2 = getShopElement(p, "Icon")

	if shopElement2 then
		shopElement2.Image = v2.icon
	end

	local shopElement3 = getShopElement(p, "Name")

	if shopElement3 then
		shopElement3.Text = v2.name
	end

	local shopElementByType = getShopElementByType("Bonus" .. p)

	if shopElementByType then
		shopElementByType.Text = "+" .. math.floor(v2.multiplier * 100) .. "% " .. Config.GetSpeedLabel()
	end
end

local function updateMysteriousUI(mysterious, mysteriousRarity, mysterious2, mysterious3)
	if not (mysterious and mysteriousRarity) then
		return
	end

	local v2 = Items.ITEMS[mysterious]

	if not v2 then
		return
	end

	local v3 = math.max(0, mysterious2 - mysterious3)
	local shopElement = getShopElement("Mysterious", "Stock")

	if shopElement then
		if v3 <= 0 then
			shopElement.Text = "Sold out"
		else
			shopElement.Text = v3 .. "/" .. mysterious2
		end
	end

	local shopElement2 = getShopElement("Mysterious", "Icon")

	if shopElement2 then
		shopElement2.Image = v2.icon
	end

	local shopElement3 = getShopElement("Mysterious", "Name")

	if shopElement3 then
		shopElement3.Text = v2.name
	end

	local shopElementByType = getShopElementByType("MysteriousFrame")

	if shopElementByType then
		ItemRarityGradient.apply(
			shopElementByType,
			mysteriousRarity,
			ItemsShopConfig.MYSTERIOUS_FRAME_COLORS[mysteriousRarity]
		)
	end

	local shopElementByType2 = getShopElementByType("MysteriousRarity")

	if shopElementByType2 then
		shopElementByType2.Text = mysteriousRarity
		local textColor = ItemsShopConfig.MYSTERIOUS_RARITY_COLORS[mysteriousRarity]

		if textColor then
			shopElementByType2.TextColor3 = textColor
		end
	end

	local shopElementByType3 = getShopElementByType("BonusMysterious")

	if shopElementByType3 then
		shopElementByType3.Text = "+" .. math.floor(v2.multiplier * 100) .. "% " .. Config.GetSpeedLabel()
		local textColor = ItemsShopConfig.MYSTERIOUS_RARITY_COLORS[mysteriousRarity]

		if textColor then
			shopElementByType3.TextColor3 = textColor
		end
	end

	local shopElement4 = getShopElement("Mysterious", "BuyRobux")
	local price = shopElement4 and shopElement4:FindFirstChild("Price")

	if price then
		price.Text = ItemsShopConfig.MYSTERIOUS_ROBUX_PRICES[mysteriousRarity] or "???"
	end

	local shopElement5 = getShopElement("Mysterious", "BuyWins")
	local price2 = shopElement5 and shopElement5:FindFirstChild("Price")

	if price2 then
		price2.Text = ItemsShopConfig.MYSTERIOUS_WINS_DISPLAY[mysteriousRarity] or "???"
	end
end

local function setBuyButtonsVisible(visible)
	for _, v2 in ipairs(CollectionService:GetTagged("ItemsShop")) do
		if not v2:IsDescendantOf(playerGui) then
			continue
		end

		local type = v2:GetAttribute("Type")

		if type == "BuyWins" or type == "BuyRobux" then
			v2.Visible = visible
		end
	end

	for _, v2 in ipairs(CollectionService:GetTagged("GiftItem")) do
		if v2:IsDescendantOf(playerGui) then
			v2.Visible = visible
		end
	end
end

local function updateGiftItemButtons(items)
	for _, v2 in ipairs(CollectionService:GetTagged("GiftItem")) do
		if not v2:IsDescendantOf(playerGui) then
			continue
		end

		local slot = v2:GetAttribute("Slot")

		if slot and items[slot] then
			v2:SetAttribute("ItemKey", items[slot])
		else
			v2:SetAttribute("ItemKey", "")
		end
	end
end

local function refreshShopUI()
	if not v then
		return
	end

	if not v.active then
		setBuyButtonsVisible(false)
		return
	end

	setBuyButtonsVisible(true)
	local items = v.items
	local stocks = v.stocks
	local purchases = v.purchases or {}

	if not (items and stocks) then
		return
	end

	updateSlotUI("Common", items.Common, stocks.Common or 0, purchases.Common or 0)
	updateSlotUI("Uncommon", items.Uncommon, stocks.Uncommon or 0, purchases.Uncommon or 0)
	updateSlotUI("Rare", items.Rare, stocks.Rare or 0, purchases.Rare or 0)
	updateMysteriousUI(items.Mysterious, v.mysteriousRarity, stocks.Mysterious or 0, purchases.Mysterious or 0)
	updateGiftItemButtons(items)
end

local heartbeatConnection = nil

local function startCountdown()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not v then
			return
		end

		local v2 = math.max(0, (v.nextRestockTime or 0) - os.time())
		local v3 = math.floor(v2 / 60)
		local v4 = v2 % 60
		local shopElementByType = getShopElementByType("NewItemsText")

		if shopElementByType then
			shopElementByType.Text = string.format("New items in %dm %02ds", v3, v4)
		end

		if not v.active then
			local text = string.format("%dm %02ds", v3, v4)

			for _, v6 in ipairs({
				"BonusCommon",
				"BonusUncommon",
				"BonusRare",
				"BonusMysterious"
			}) do
				local shopElementByType2 = getShopElementByType(v6)

				if shopElementByType2 then
					shopElementByType2.Text = text
				end
			end
		end
	end)
end

local v2 = {}

local function connectBuyButton(instance)
	if v2[instance] or not instance:IsDescendantOf(playerGui) then
		return
	end

	local rarity = instance:GetAttribute("Rarity")
	local type = instance:GetAttribute("Type")

	if not (rarity and type) or type ~= "BuyWins" and type ~= "BuyRobux" then
		return
	end

	v2[instance] = true
	instance.Activated:Connect(function()
		if flag or not (v and v.active) then
			return
		end

		local v3 = rarity
		local purchases = v.purchases or {}
		local v4 = ((v.stocks or {})[v3] or 0) - (purchases[v3] or 0)

		if type == "BuyWins" then
			if v4 <= 0 then
				return
			end

			flag = true
			ItemsShopRemotes.BuyWins:fire(v3)
		elseif type == "BuyRobux" then
			flag = true
			ItemsShopRemotes.BuyRobux:fire(v3)
		end

		task.delay(0.3, function()
			flag = false
		end)
	end)
	instance.Destroying:Connect(function()
		v2[instance] = nil
	end)
end

local function connectRestockButton(instance)
	if v2[instance] or not instance:IsDescendantOf(playerGui) then
		return
	end

	v2[instance] = true
	instance.Visible = ItemsShopConfig.RESTOCK_ENABLED
	instance.Activated:Connect(function()
		if not ItemsShopConfig.RESTOCK_ENABLED or flag then
			return
		end

		flag = true
		ItemsShopRemotes.PromptRestock:fire()
		task.delay(0.3, function()
			flag = false
		end)
	end)
	instance.Destroying:Connect(function()
		v2[instance] = nil
	end)
end

local function setupAllButtons()
	for _, v3 in ipairs(CollectionService:GetTagged("ItemsShop")) do
		if not v3:IsDescendantOf(playerGui) then
			continue
		end

		local type = v3:GetAttribute("Type")

		if type == "BuyWins" or type == "BuyRobux" then
			connectBuyButton(v3)
		elseif type == "RestockButton" then
			connectRestockButton(v3)
		end
	end
end

local v3 = {
	"CommonFrame",
	"UncommonFrame",
	"RareFrame",
	"MysteriousFrame"
}

local function getShopFrames()
	local shopElementByTypes = {}

	for _, v4 in ipairs(v3) do
		local shopElementByType = getShopElementByType(v4)

		if shopElementByType then
			table.insert(shopElementByTypes, shopElementByType)
		end
	end

	return shopElementByTypes
end

local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local tweenInfo2 = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local uDim = UDim2.new(0, 0, 0, 0)
local v4 = {}
local v5 = {}
local count = 0

local function getRestingSize(instance)
	if v4[instance] == nil then
		v4[instance] = instance.Size
		instance.Destroying:Connect(function()
			v4[instance] = nil
			v5[instance] = nil
		end)
	end

	return v4[instance]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tweenFrameSize(shopFrame, p, size2, size)
	local v6 = v5[shopFrame]

	if v6 then
		v6:Cancel()
	end

	if size then
		shopFrame.Size = size
	end

	local tween = TweenService:Create(shopFrame, p, {
		Size = size2
	})
	v5[shopFrame] = tween
	tween:Play()
end

local function playRestockAnimation()
	local shopFrames = getShopFrames()

	if #shopFrames == 0 then
		return
	end

	count += 1
	local v6 = count

	for _, shopFrame in ipairs(shopFrames) do
		if v4[shopFrame] == nil then
			v4[shopFrame] = shopFrame.Size
			local v7 = shopFrame
			shopFrame.Destroying:Connect(function()
				v4[v7] = nil
				v5[v7] = nil
			end)
		end

		local _ = v4[shopFrame]
		tweenFrameSize(shopFrame, tweenInfo, uDim) -- equivalent call inferred; original call site unknown
	end

	task.wait(0.25)

	if v6 == count then
		refreshShopUI()

		for _, shopFrame in ipairs(shopFrames) do
			if v4[shopFrame] == nil then
				v4[shopFrame] = shopFrame.Size
				local v9 = shopFrame
				shopFrame.Destroying:Connect(function()
					v4[v9] = nil
					v5[v9] = nil
				end)
			end

			tweenFrameSize(shopFrame, tweenInfo2, v4[shopFrame], uDim)
		end
	end
end

local color = Color3.fromRGB(255, 70, 70)
local v6 = {
	NotEnoughWins = "Not enough wins",
	OutOfStock = "Out of stock",
	ShopNotActive = "Shop not active"
}
local active = nil
ItemsShopRemotes.ShopUpdate:connect(function(data)
	if data.sound then
		SoundManager:Play(data.sound)
	end

	if data.message then
		NotificationSystem:ShowGeneralNotification(v6[data.message] or data.message, color)
	end

	if data.active ~= nil then
		local v7 = active
		active = data.active
		v = data

		if data.restock then
			local shopNotification = Config.ShopNotification ~= false

			if v7 then
				if shopNotification then
					NotificationSystem:ShowGeneralNotification("Items Shop restocked!", Color3.fromRGB(100, 255, 100))
					SoundManager:Play("NOTIF1")
				end

				playRestockAnimation()
			else
				if shopNotification then
					NotificationSystem:ShowGeneralNotification("Items Shop is now open!", Color3.fromRGB(100, 255, 100))
					SoundManager:Play("NOTIF1")
				end

				refreshShopUI()
			end
		else
			refreshShopUI()
		end
	end
end)
setupAllButtons()
CollectionService:GetInstanceAddedSignal("ItemsShop"):Connect(function(instance)
	task.defer(function()
		if not instance:IsDescendantOf(playerGui) then
			return
		end

		local type = instance:GetAttribute("Type")

		if type == "BuyWins" or type == "BuyRobux" then
			connectBuyButton(instance)

			if not (v and v.active) then
				instance.Visible = false
			end
		elseif type == "RestockButton" then
			connectRestockButton(instance)
		end

		if v and v.active then
			refreshShopUI()
		end
	end)
end)
CollectionService:GetInstanceAddedSignal("GiftItem"):Connect(function(instance)
	task.defer(function()
		if not instance:IsDescendantOf(playerGui) then
			return
		end

		if not (v and v.active) then
			instance.Visible = false
		end
	end)
end)

if heartbeatConnection then
	heartbeatConnection:Disconnect()
end

heartbeatConnection = RunService.Heartbeat:Connect(function()
	if not v then
		return
	end

	local v7 = math.max(0, (v.nextRestockTime or 0) - os.time())
	local v8 = math.floor(v7 / 60)
	local v9 = v7 % 60
	local shopElementByType = getShopElementByType("NewItemsText")

	if shopElementByType then
		shopElementByType.Text = string.format("New items in %dm %02ds", v8, v9)
	end

	if not v.active then
		local text = string.format("%dm %02ds", v8, v9)

		for _, v11 in ipairs({
			"BonusCommon",
			"BonusUncommon",
			"BonusRare",
			"BonusMysterious"
		}) do
			local shopElementByType2 = getShopElementByType(v11)

			if shopElementByType2 then
				shopElementByType2.Text = text
			end
		end
	end
end)
task.defer(function()
	ItemsShopRemotes.RequestState:fire()
end)