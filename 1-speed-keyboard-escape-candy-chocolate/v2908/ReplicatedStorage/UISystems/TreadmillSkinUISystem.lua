local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local PersonalTreadmill = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PersonalTreadmill"))
local Skins = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PersonalTreadmill"):WaitForChild("Skins"))
local SKINS = Skins.SKINS
local PlayerUpgradesCatalog = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PlayerUpgradesCatalog"))
local CATEGORY_LABELS = Skins.CATEGORY_LABELS
local CATEGORY_RANK = Skins.CATEGORY_RANK
local LAYOUT_CATEGORY_BLOCK = Skins.LAYOUT_CATEGORY_BLOCK
local GiftConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("GiftConfig"))
local PlayerUpgradesInventoryUI = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("PlayerUpgradesInventoryUI"))
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local TreadmillSkinUISystem = {}
local flag = false
local clones = {}
local v = {}
local v2 = false
local v3 = ""
local v4 = #Skins.CATEGORY_ORDER + 1
local localPlayer = Players.LocalPlayer
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2, p3)
	if p ~= localPlayer or not p3 then
		return
	end

	for k, v5 in pairs(SKINS) do
		if not (v5.isRobux and v5.price == p2) then
			continue
		end

		remotes.EquipTreadmillSkin:FireServer(k)
		break
	end
end)

local function getCatalogSignature(inventorySkins)
	local v5 = {}

	for k in pairs(inventorySkins) do
		table.insert(v5, k)
	end

	table.sort(v5)
	return table.concat(v5, "\0")
end

local function collectSkinEntries(inventorySkins)
	local result = {}

	for k, item in pairs(inventorySkins) do
		table.insert(result, {
			key = k,
			data = item
		})
	end

	table.sort(result, function(a, b)
		local v5 = CATEGORY_RANK[a.data.category] or v4
		local v6 = CATEGORY_RANK[b.data.category] or v4

		if v5 ~= v6 then
			return v5 < v6
		end

		local price = a.data.price or 0
		local price2 = b.data.price or 0

		if price == price2 then
			return a.data.displayName < b.data.displayName
		end

		return price < price2
	end)
	return result
end

local function buildRowOptions(key, data)
	local v5 = (data.isRobux or data.isProduct) and 0 or data.price or 0
	local v6 = not data.isRobux and 0 or data.price or 0
	local v7 = not data.isProduct and 0 or data.price or 0
	local showBuyGift

	if data.canGift == false then
		showBuyGift = false
	else
		showBuyGift = GiftConfig.SKIN_GIFTS[key] ~= nil
	end

	local v9 = {
		showBuyWins = v5 > 0,
		winsPriceText = 0,
		onBuyWins = 0,
		showBuyGamepass = 0,
		gamepassId = 0,
		devProductId = 0,
		onBuyGamepass = 0,
		showBuyGift = 0,
		onBuyGift = 0,
		onEquip = 0
	}
	local winsPriceText

	if v5 > 0 then
		winsPriceText = Numbers.formatNumber(v5) or nil
	end

	v9.winsPriceText = winsPriceText
	v9.onBuyWins = v5 > 0 and (function()
		local v11, v12 = remotes.BuyTreadmillSkin:InvokeServer(key)

		if not v11 then
			warn("[TreadmillSkinSystem] " .. tostring(v12))
		end
	end or nil) or nil
	v9.showBuyGamepass = v6 > 0 or v7 > 0
	v9.gamepassId = v6 > 0 and v6 or nil
	v9.devProductId = v7 > 0 and v7 or nil
	v9.onBuyGamepass = v7 > 0 and function()
		MarketplaceService:PromptProductPurchase(localPlayer, v7)
	end or v6 > 0 and function()
		MarketplaceService:PromptGamePassPurchase(localPlayer, v6)
	end or nil
	v9.showBuyGift = showBuyGift
	v9.onBuyGift = showBuyGift and (function()
		PlayerUpgradesInventoryUI.openGiftModal(key)
	end or nil) or nil

	function v9.onEquip()
		remotes.EquipTreadmillSkin:FireServer(key)
	end

	return v9
end

local function createCategoryHeader(category, layoutOrder, scrollingFrame)
	local text = CATEGORY_LABELS[category] or category
	local frame = Instance.new("Frame")
	frame.Name = "CategoryHeader_" .. category
	frame.LayoutOrder = layoutOrder
	frame.Size = UDim2.new(1, 0, 0, 36)
	frame.BackgroundTransparency = 1
	frame:SetAttribute("IsCategoryHeader", true)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Label"
	textLabel.Size = UDim2.new(1, -8, 1, -12)
	textLabel.Position = UDim2.new(0, 4, 0, 4)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 18
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.Text = text
	textLabel.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "Divider"
	frame2.AnchorPoint = Vector2.new(0, 1)
	frame2.Position = UDim2.new(0, 4, 1, -2)
	frame2.Size = UDim2.new(1, -8, 0, 2)
	frame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame2.BackgroundTransparency = 0.7
	frame2.BorderSizePixel = 0
	frame2.Parent = frame
	frame.Parent = scrollingFrame
	return frame
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearBuiltHeaders()
	for _, v5 in ipairs(v) do
		v5:Destroy()
	end

	table.clear(v)
end

local function buildInventory(ownedTreadmillSkins)
	local inventorySkins = PlayerUpgradesCatalog.GetInventorySkins(ownedTreadmillSkins)
	local catalogSignature = getCatalogSignature(inventorySkins)

	if v2 and v3 == catalogSignature then
		return
	end

	local inventoryTab = PlayerUpgradesInventoryUI.getInventoryTab("TreadmillSkins")

	if not inventoryTab then
		return
	end

	local rowTemplate = PlayerUpgradesInventoryUI.getRowTemplate("TreadmillSkinTemplate")
	local scrollingFrame = PlayerUpgradesInventoryUI.getScrollingFrame(inventoryTab)
	PlayerUpgradesInventoryUI.clearBuiltRows(scrollingFrame)
	clearBuiltHeaders() -- equivalent call inferred; original call site unknown
	table.clear(clones)
	local v5 = nil
	local count = 0

	for _, v6 in ipairs((collectSkinEntries(inventorySkins))) do
		local v7 = CATEGORY_RANK[v6.data.category] or v4

		if v7 ~= v5 then
			count = 0

			if v6.data.category then
				table.insert(v, (createCategoryHeader(v6.data.category, v7 * LAYOUT_CATEGORY_BLOCK, scrollingFrame)))
			end

			v5 = v7
		end

		count += 1
		local clone = rowTemplate:Clone()
		clone.Name = v6.key
		clone.LayoutOrder = v7 * LAYOUT_CATEGORY_BLOCK + count
		clone:SetAttribute("CosmeticKey", v6.key)
		PlayerUpgradesInventoryUI.applyRowContent(
			clone,
			v6.data.displayName,
			v6.data.icon,
			nil,
			v6.data.color,
			v6.data.description
		)
		PlayerUpgradesInventoryUI.wireRow(clone, (buildRowOptions(v6.key, v6.data)))
		clone.Parent = scrollingFrame
		clones[v6.key] = clone
	end

	v2 = true
	v3 = catalogSignature
end

local function updateSkinRow(k, ownedTreadmillSkins, equippedTreadmillSkin)
	local v5 = clones[k]

	if not v5 then
		return
	end

	local v6 = SKINS[k]
	local v7 = table.find(ownedTreadmillSkins, k) ~= nil
	local v8 = equippedTreadmillSkin == k
	local v9

	if type(v6.price) == "number" then
		v9 = v6.price > 0
	else
		v9 = false
	end

	v5:SetAttribute("Hidden", not v7 and (v6.isLocked == true or not v9))
	PlayerUpgradesInventoryUI.updateRowState(v5, v7, v8)
	local unlockHint = v6.unlockHint

	if unlockHint then
		PlayerUpgradesInventoryUI.setBonusOverride(v5, unlockHint, v7)
	end
end

function TreadmillSkinUISystem:UpdateDisplay()
	local v5 = ClientState:Get()
	local ownedTreadmillSkins = v5.OwnedTreadmillSkins or {}
	local equippedTreadmillSkin = v5.EquippedTreadmillSkin or PersonalTreadmill.DEFAULT_SKIN
	buildInventory(ownedTreadmillSkins)

	for k in pairs(clones) do
		updateSkinRow(k, ownedTreadmillSkins, equippedTreadmillSkin)
	end
end

function TreadmillSkinUISystem:InitLogic()
	if flag then
		return
	end

	flag = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function connectClose(instance)
		if instance:GetAttribute("IsConnectedClose") then
			return
		end

		instance:SetAttribute("IsConnectedClose", true)
		instance.MouseButton1Click:Connect(function()
			ClientState:CloseCurrentModal()
		end)
	end

	for _, v5 in ipairs(CollectionService:GetTagged("TreadmillSkinsCloseButton")) do
		connectClose(v5) -- equivalent call inferred; original call site unknown
	end

	CollectionService:GetInstanceAddedSignal("TreadmillSkinsCloseButton"):Connect(connectClose)
	PlayerUpgradesInventoryUI.whenInventoryTabReady("TreadmillSkins", function()
		v2 = false
		v3 = ""
		table.clear(clones)
		self:UpdateDisplay()
	end)
	self:UpdateDisplay()
end

function TreadmillSkinUISystem.OnClose(_) end

return TreadmillSkinUISystem