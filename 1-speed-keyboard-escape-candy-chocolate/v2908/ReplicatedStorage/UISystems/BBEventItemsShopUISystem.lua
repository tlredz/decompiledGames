local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local BBEventItemsShopConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("BBEventItemsShopConfig"))
local Items = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("Items"))
local ItemsShopConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("ItemsShopConfig"))
local PlayerUpgradesCatalog = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PlayerUpgradesCatalog"))
local SkinBundles = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PersonalTreadmill"):WaitForChild("SkinBundles"))
local BUNDLES = SkinBundles.BUNDLES
local GiftConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("GiftConfig"))
local ItemRarityGradient = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("ItemRarityGradient"))
local MarketplaceInfoCache = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("MarketplaceInfoCache"))
local Numbers = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Numbers"))
local PlayerUpgradesInventoryUI = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("PlayerUpgradesInventoryUI"))
local BBEventItemsShopRemotes = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("BBEventItemsShopRemotes"))
local SoundManager = require(ReplicatedStorage:WaitForChild("SoundManager"))
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local BBEventItemsShopUISystem = {}
local flag = false
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v = "Items"
local v2 = {}
local color = Color3.fromRGB(255, 70, 70)
local v3 = {
	NotEnoughWins = "Not enough wins",
	InvalidItem = "Invalid item",
	NoData = "Please try again"
}

local function getTemplates()
	return ReplicatedStorage:WaitForChild("Templates")
end

local function getModal()
	for _, v4 in ipairs(CollectionService:GetTagged("BBEventItemsShopModal")) do
		if v4:IsDescendantOf(playerGui) then
			return v4
		end
	end

	return nil
end

local function clearFrame(ownedItemsFrame)
	for _, child in ipairs(ownedItemsFrame:GetChildren()) do
		if not child:IsA("GuiObject") or (child:IsA("UIListLayout") or child:IsA("UIGridLayout") or child:IsA("UIPadding")) then
			continue
		end

		child:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setInfoText(p, text: string)
	p.ShopItemsFrame.Info.Text = text
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playerOwnsSkin(key: string)
	local ownedTreadmillSkins = ClientState:Get().OwnedTreadmillSkins or {}
	return table.find(ownedTreadmillSkins, key) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setOwnedBuyVisibility(buttons, visible: boolean, flag2: boolean)
	local owned = buttons:FindFirstChild("Owned")
	local buyWins = buttons:FindFirstChild("BuyWins")
	local buyRobux = buttons:FindFirstChild("BuyRobux")
	local buyGift = buttons:FindFirstChild("BuyGift")

	if owned then
		owned.Visible = visible
	end

	if buyWins then
		buyWins.Visible = flag2 and not visible
	end

	if buyRobux then
		buyRobux.Visible = not visible
	end

	if buyGift then
		buyGift.Visible = true
	end
end

local function setItemBuyVisibility(buttons)
	local owned = buttons:FindFirstChild("Owned")
	local buyWins = buttons:FindFirstChild("BuyWins")
	local buyRobux = buttons:FindFirstChild("BuyRobux")
	local buyGift = buttons:FindFirstChild("BuyGift")

	if owned then
		owned.Visible = false
	end

	if buyWins then
		buyWins.Visible = true
	end

	if buyRobux then
		buyRobux.Visible = true
	end

	if buyGift then
		buyGift.Visible = true
	end
end

local function setRobuxTitle(instance, text: string)
	if not instance then
		return
	end

	local title = instance:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		title.Text = text
	elseif instance:FindFirstChild("Price") then
		instance.Price.Text = text
	end
end

local function setWinsTitle(instance, text: string)
	if not instance then
		return
	end

	local title = instance:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		title.Text = text
	elseif instance:FindFirstChild("Price") then
		instance.Price.Text = text
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindRobuxPrice(buyRobux, p: number, bundle)
	local v4 = bundle or Enum.InfoType.Product

	if buyRobux then
		local title = buyRobux:FindFirstChild("Title")

		if title and title:IsA("TextLabel") then
			title.Text = "…"
		elseif buyRobux:FindFirstChild("Price") then
			buyRobux.Price.Text = "…"
		end
	end

	MarketplaceInfoCache.Request(p, v4, function(p2)
		local priceInRobux = p2 and (p2.PriceInRobux or p2.Price)

		if buyRobux.Parent and priceInRobux then
			local v5 = buyRobux
			local text = tostring(priceInRobux)

			if not v5 then
				return
			end

			local title = v5:FindFirstChild("Title")

			if title and title:IsA("TextLabel") then
				title.Text = text
			elseif v5:FindFirstChild("Price") then
				v5.Price.Text = text
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applySpot(spotFrame, icon: string?, rarity: string?)
	local icon2 = spotFrame:FindFirstChild("Icon")

	if icon2 and icon2:IsA("ImageLabel") and icon then
		icon2.Image = icon
	end

	if rarity then
		ItemRarityGradient.apply(spotFrame, rarity)
	end
end

local function fillItemCards(ownedItemsFrame)
	local bBEventItemCard = ReplicatedStorage:WaitForChild("Templates"):WaitForChild("BBEventItemCard")

	for _, item in ipairs(BBEventItemsShopConfig.Items) do
		local v4 = Items.ITEMS[item.Key]
		local clone = bBEventItemCard:Clone()
		clone.Name = item.Key
		clone.Parent = ownedItemsFrame
		local container = clone.Container
		local v5 = ItemsShopConfig.DEV_PRODUCTS[v4.rarity]
		applySpot(container.SpotFrame, v4.icon, v4.rarity) -- equivalent call inferred; original call site unknown
		local info = container.Info
		info.NameLabel.Text = v4.name
		info.Bonus.Text = string.format("+%d%%", (math.floor((v4.multiplier or 0) * 100 + 0.5)))
		info.Rarity.Text = v4.rarity
		local buttons = container.Buttons
		setItemBuyVisibility(buttons)
		local buyWins = buttons.BuyWins
		local formatNumber = Numbers.formatNumber(item.WinsPrice)

		if buyWins then
			local title = buyWins:FindFirstChild("Title")

			if title and title:IsA("TextLabel") then
				title.Text = formatNumber
			elseif buyWins:FindFirstChild("Price") then
				buyWins.Price.Text = formatNumber
			end
		end

		if v5 then
			bindRobuxPrice(buttons.BuyRobux, v5) -- equivalent call inferred; original call site unknown
			local v6 = item
			buttons.BuyRobux.MouseButton1Down:Connect(function()
				BBEventItemsShopRemotes.BuyRobux:fire(v6.Key)
			end)
		else
			buttons.BuyRobux.Visible = false
		end

		local v6 = item
		buttons.BuyWins.MouseButton1Down:Connect(function()
			BBEventItemsShopRemotes.BuyWins:fire(v6.Key)
		end)
		local v7 = item
		buttons.BuyGift.MouseButton1Down:Connect(function()
			PlayerUpgradesInventoryUI.openGiftModal(v7.Key)
		end)
	end
end

local function fillSkinCards(ownedItemsFrame)
	local bBEventSkinCard = ReplicatedStorage:WaitForChild("Templates"):WaitForChild("BBEventSkinCard")

	for _, skin in ipairs(BBEventItemsShopConfig.Skins) do
		local skinData = PlayerUpgradesCatalog.GetSkinData(skin.Key)
		local clone = bBEventSkinCard:Clone()
		clone.Name = skin.Key
		clone.Parent = ownedItemsFrame
		local container = clone.Container
		local visible = playerOwnsSkin(skin.Key) -- equivalent call inferred; original call site unknown
		applySpot(container.SpotFrame, skinData.icon) -- equivalent call inferred; original call site unknown
		local info = container.Info
		info.NameLabel.Text = skinData.displayName
		info.Description.Text = skinData.description or ""
		local buttons = container.Buttons
		local price = skinData.isProduct and skinData.price or 0
		setOwnedBuyVisibility(buttons, visible, false) -- equivalent call inferred; original call site unknown

		if price > 0 and not visible then
			bindRobuxPrice(buttons.BuyRobux, price) -- equivalent call inferred; original call site unknown
			local v5 = price
			buttons.BuyRobux.MouseButton1Down:Connect(function()
				MarketplaceService:PromptProductPurchase(localPlayer, v5)
			end)
		else
			buttons.BuyRobux.Visible = false
		end

		if GiftConfig.SKIN_GIFTS[skin.Key] then
			local v5 = skin
			buttons.BuyGift.MouseButton1Down:Connect(function()
				PlayerUpgradesInventoryUI.openGiftModal(v5.Key)
			end)
		elseif buttons.BuyGift then
			buttons.BuyGift.Visible = false
		end
	end

	for _, v4 in ipairs(BBEventItemsShopConfig.Bundles or {}) do
		local v5 = BUNDLES[v4.Key]
		local clone = bBEventSkinCard:Clone()
		clone.Name = v4.Key
		clone.Parent = ownedItemsFrame
		local container = clone.Container
		local v6 = true

		for _, skinKey in ipairs(v5.skinKeys) do
			local ownedTreadmillSkins = ClientState:Get().OwnedTreadmillSkins or {}

			if table.find(ownedTreadmillSkins, skinKey) ~= nil then
				continue
			end

			v6 = false
			break
		end

		applySpot(container.SpotFrame, v5.icon) -- equivalent call inferred; original call site unknown
		local info = container.Info
		info.NameLabel.Text = v5.displayName
		info.Description.Text = v5.description or ""
		local buttons = container.Buttons
		local price = v5.price or 0
		setOwnedBuyVisibility(buttons, v6, false) -- equivalent call inferred; original call site unknown

		if price > 0 and not v6 then
			bindRobuxPrice(buttons.BuyRobux, price) -- equivalent call inferred; original call site unknown
			local v8 = price
			buttons.BuyRobux.MouseButton1Down:Connect(function()
				MarketplaceService:PromptProductPurchase(localPlayer, v8)
			end)
		else
			buttons.BuyRobux.Visible = false
		end

		if GiftConfig.SKIN_BUNDLE_GIFTS[v4.Key] then
			local v8 = v4
			buttons.BuyGift.MouseButton1Down:Connect(function()
				PlayerUpgradesInventoryUI.openGiftModal(v8.Key)
			end)
		elseif buttons.BuyGift then
			buttons.BuyGift.Visible = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshUgcOwned(assetId: number, isBundle: boolean, fn)
	local v4 = v2[assetId]

	if v4 == nil then
		task.spawn(function()
			local success, result

			if isBundle then
				success, result = pcall(
					MarketplaceService.PlayerOwnsBundleAsync,
					MarketplaceService,
					localPlayer,
					assetId
				)
			else
				success, result = pcall(
					MarketplaceService.PlayerOwnsAssetAsync,
					MarketplaceService,
					localPlayer,
					assetId
				)
			end

			if success then
				local v5 = result == true
				v2[assetId] = v5
				fn(v5)
			else
				warn(
					"[BBEventItemsShop] Ownership check failed for",
					assetId,
					isBundle and "Bundle" or "Asset",
					"→",
					result
				)
				fn(false)
			end
		end)
	else
		fn(v4)
	end
end

local function fillUgcCards(ownedItemsFrame)
	local bBEventUGCCard = ReplicatedStorage:WaitForChild("Templates"):WaitForChild("BBEventUGCCard")

	for _, UGC in ipairs(BBEventItemsShopConfig.UGCs) do
		local assetId = UGC.AssetId
		local isBundle = UGC.IsBundle == true
		local bundle

		if isBundle then
			bundle = Enum.InfoType.Bundle
		else
			bundle = Enum.InfoType.Asset
		end

		local clone = bBEventUGCCard:Clone()
		clone.Name = tostring(assetId)
		clone.Parent = ownedItemsFrame
		local container = clone.Container
		local formatted = ("rbxthumb://type=%s&id=%d&w=420&h=420"):format(
			isBundle and "BundleThumbnail" or "Asset",
			assetId
		)
		local icon = container.SpotFrame:FindFirstChild("Icon")

		if icon and icon:IsA("ImageLabel") and formatted then
			icon.Image = formatted
		end

		local info = container.Info
		info.NameLabel.Text = UGC.Name or "Loading ..."
		info.Description.Text = UGC.Description or "Please wait"
		local buttons = container.Buttons
		local owned = buttons.Owned
		local buyRobux = buttons.BuyRobux
		owned.Visible = false
		buyRobux.Visible = true
		bindRobuxPrice(buyRobux, assetId, bundle) -- equivalent call inferred; original call site unknown
		local v5 = UGC
		MarketplaceInfoCache.Request(assetId, bundle, function(p)
			if buyRobux.Parent and p then
				if (not v5.Name or v5.Name == "") and p.Name then
					info.NameLabel.Text = p.Name
				end

				if (not v5.Description or v5.Description == "") and p.Description then
					info.Description.Text = p.Description
				end
			end
		end)
		-- equivalent calls inferred from this helper; original call sites unknown
		local buyRobux2 = buyRobux

		local function fn(visible)
			owned.Visible = visible
			buyRobux2.Visible = not visible
		end

		refreshUgcOwned(assetId, isBundle, fn) -- equivalent call inferred; original call site unknown
		buyRobux.MouseButton1Down:Connect(function()
			BBEventItemsShopRemotes.BuyUgc:fire(assetId)
		end)
	end
end

local function refreshList(modal)
	local ownedItemsFrame = modal.ShopItemsFrame.OwnedItemsFrame
	clearFrame(ownedItemsFrame)
	setInfoText(modal, BBEventItemsShopConfig.INFO[v]) -- equivalent call inferred; original call site unknown

	if v == "Items" then
		fillItemCards(ownedItemsFrame)
	elseif v == "Skins" then
		fillSkinCards(ownedItemsFrame)
	else
		fillUgcCards(ownedItemsFrame)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function selectTab(p: string)
	v = p
	local modal = getModal()

	if modal then
		refreshList(modal)
	end
end

function BBEventItemsShopUISystem:UpdateDisplay()
	local modal = getModal()

	if modal and ClientState.ActiveModal == modal then
		refreshList(modal)
	end
end

function BBEventItemsShopUISystem.OnClose(_) end

local function prefetchShopPrices()
	local v4 = {}

	for _, item in ipairs(BBEventItemsShopConfig.Items) do
		local v5 = Items.ITEMS[item.Key]
		local v6 = v5 and ItemsShopConfig.DEV_PRODUCTS[v5.rarity]

		if not v6 or v4[v6] then
			continue
		end

		v4[v6] = true
		MarketplaceInfoCache.Prefetch(v6, Enum.InfoType.Product)
	end

	for i = #BBEventItemsShopConfig.UGCs, 1, -1 do
		local UGC = BBEventItemsShopConfig.UGCs[i]
		local v5

		if UGC.IsBundle then
			v5 = Enum.InfoType.Bundle
		else
			v5 = Enum.InfoType.Asset
		end

		MarketplaceInfoCache.Prefetch(UGC.AssetId, v5, true)
	end

	for _, skin in ipairs(BBEventItemsShopConfig.Skins) do
		local skinData = PlayerUpgradesCatalog.GetSkinData(skin.Key)

		if skinData and skinData.isProduct and skinData.price and skinData.price > 0 then
			MarketplaceInfoCache.Prefetch(skinData.price, Enum.InfoType.Product)
		end
	end
end

function BBEventItemsShopUISystem:InitLogic()
	if flag then
		return
	end

	flag = true

	local function wireModal(instance)
		if not instance:IsDescendantOf(playerGui) or instance:GetAttribute("BBShopWired") then
			return
		end

		instance:SetAttribute("BBShopWired", true)
		instance:SetAttribute("ModalVisibleY", 0.6)
		local buttonsFrame = instance.ButtonsFrame
		buttonsFrame.ButtonItems.MouseButton1Down:Connect(function()
			selectTab("Items") -- equivalent call inferred; original call site unknown
		end)
		buttonsFrame.ButtonSkins.MouseButton1Down:Connect(function()
			selectTab("Skins") -- equivalent call inferred; original call site unknown
		end)
		buttonsFrame.ButtonUGCs.MouseButton1Down:Connect(function()
			selectTab("UGCs") -- equivalent call inferred; original call site unknown
		end)
	end

	for _, v4 in ipairs(CollectionService:GetTagged("BBEventItemsShopModal")) do
		wireModal(v4)
	end

	CollectionService:GetInstanceAddedSignal("BBEventItemsShopModal"):Connect(wireModal)
	MarketplaceService.PromptPurchaseFinished:Connect(function(p, p2, p3)
		if p == localPlayer.UserId and p3 then
			v2[p2] = true
			BBEventItemsShopUISystem:UpdateDisplay()
		end
	end)
	MarketplaceService.PromptBulkPurchaseFinished:Connect(function(p, p2, p3)
		if p == localPlayer and p2 == Enum.MarketplaceBulkPurchasePromptStatus.Completed then
			local items = p3 and p3.Items

			if items then
				for _, item in ipairs(items) do
					local id = tonumber(item.id or item.Id)

					if id then
						v2[id] = nil
					end
				end
			end

			BBEventItemsShopUISystem:UpdateDisplay()
		end
	end)
	prefetchShopPrices()
	BBEventItemsShopRemotes.PurchaseFeedback:connect(function(p)
		if p.sound then
			SoundManager:Play(p.sound)
		end

		if p.message then
			NotificationSystem:ShowGeneralNotification(v3[p.message] or p.message, color)
		end
	end)
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local itemAction = remotes:FindFirstChild("ItemAction")

	if itemAction then
		itemAction.OnClientEvent:Connect(function(p)
			if p == "Update" then
				BBEventItemsShopUISystem:UpdateDisplay()
			end
		end)
	end

	local updateUI = remotes:FindFirstChild("UpdateUI")

	if updateUI then
		updateUI.OnClientEvent:Connect(function(p)
			if type(p) == "table" and p.OwnedTreadmillSkins then
				BBEventItemsShopUISystem:UpdateDisplay()
			end
		end)
	end
end

function BBEventItemsShopUISystem:Open()
	self:InitLogic()
	local modal = getModal()
	ClientState:ToggleModal(modal, self)
	v = "Items"

	if modal and ClientState.ActiveModal == modal then
		refreshList(modal)
	end
end

return BBEventItemsShopUISystem