local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local PlayerUpgradesCatalog = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PlayerUpgradesCatalog"))
local GiftConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("GiftConfig"))
local PlayerUpgradesInventoryUI = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("PlayerUpgradesInventoryUI"))
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
local AuraRemotes = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("AuraRemotes"))
local UpgradeMultipliers = require(ReplicatedStorage._FRAMEWORK.Libraries.UpgradeMultipliers)
local flag = false
local clones = {}
local v = false
local v2 = nil
local localPlayer = Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function getAuraIcon(key, data)
	if data.icon then
		return data.icon
	end

	local v3 = GiftConfig.AURA_GIFTS[key]

	if v3 then
		return v3.Image
	end

	return nil
end

local function getCatalogSignature(inventoryAuras)
	local v3 = {}

	for k in pairs(inventoryAuras) do
		table.insert(v3, k)
	end

	table.sort(v3)
	return table.concat(v3, "\0")
end

local function collectAuraEntries(inventoryAuras)
	local v3 = {}

	for k, item in pairs(inventoryAuras) do
		table.insert(v3, {
			key = k,
			data = item
		})
	end

	return PlayerUpgradesInventoryUI.groupEntriesByGalaxy(v3, function(p)
		return p.data.multiplier
	end)
end

local function buildRowOptions(key, data)
	local price = data.price or 0
	local devProduct = data.DevProduct or 0
	local gamepass = data.gamepass or 0
	local showBuyGift = GiftConfig.ALL_GIFTS[key] ~= nil and not PlayerUpgradesCatalog.IsWorldEvent()
	local showBuyGamepass = devProduct > 0 or gamepass > 0
	local showBuyWins

	if price > 0 then
		showBuyWins = UpgradeMultipliers.matchesActiveGalaxy(data)
	else
		showBuyWins = false
	end

	local v6 = {
		showBuyWins = showBuyWins,
		winsPriceText = showBuyWins and Numbers.formatNumber(price) or nil,
		onBuyWins = showBuyWins and (function()
			local v7, v8, v9 = AuraRemotes.BuyAura:request(key, "Wins"):await()

			if not (v7 and v8) then
				warn("[AuraSystem] " .. tostring(v9 or v8))
			end
		end or nil) or nil,
		showBuyGamepass = showBuyGamepass,
		devProductId = devProduct > 0 and devProduct or nil,
		gamepassId = 0,
		onBuyGamepass = 0,
		showBuyGift = 0,
		onBuyGift = 0,
		onEquip = 0,
		onEquipAsCosmetic = 0
	}
	local gamepassId

	if devProduct <= 0 and gamepass > 0 and gamepass then
		gamepassId = gamepass
	end

	v6.gamepassId = gamepassId
	v6.onBuyGamepass = showBuyGamepass and function()
		if devProduct > 0 then
			MarketplaceService:PromptProductPurchase(localPlayer, devProduct)
		else
			MarketplaceService:PromptGamePassPurchase(localPlayer, gamepass)
		end
	end or nil
	v6.showBuyGift = showBuyGift
	v6.onBuyGift = showBuyGift and (function()
		PlayerUpgradesInventoryUI.openGiftModal(key)
	end or nil) or nil

	function v6.onEquip()
		AuraRemotes.EquipAura:fire(key)
	end

	function v6.onEquipAsCosmetic()
		AuraRemotes.EquipAura:fire(key, "Skin")
	end

	return v6
end

local function buildInventory(ownedAuras)
	local inventoryAuras = PlayerUpgradesCatalog.GetInventoryAuras(ownedAuras)
	local catalogSignature = getCatalogSignature(inventoryAuras)

	if v and v2 == catalogSignature then
		return
	end

	local inventoryTab = PlayerUpgradesInventoryUI.getInventoryTab("Auras")

	if not inventoryTab then
		return
	end

	local rowTemplate = PlayerUpgradesInventoryUI.getRowTemplate("AuraTrailTemplate")
	local scrollingFrame = PlayerUpgradesInventoryUI.getScrollingFrame(inventoryTab)
	PlayerUpgradesInventoryUI.clearBuiltRows(scrollingFrame)
	table.clear(clones)

	local function addAuraRow(p, layoutOrder)
		local clone = rowTemplate:Clone()
		clone.Name = p.key
		clone.LayoutOrder = layoutOrder
		clone:SetAttribute("CosmeticKey", p.key)
		local applyRowContent = PlayerUpgradesInventoryUI.applyRowContent
		local name = p.data.name
		local auraIcon = getAuraIcon(p.key, p.data) -- equivalent call inferred; original call site unknown
		applyRowContent(clone, name, auraIcon, UpgradeMultipliers.aura(p.key), nil)
		PlayerUpgradesInventoryUI.applyRowColor(clone, p.data.color)

		if p.data.RoundedIcon then
			PlayerUpgradesInventoryUI.applyRoundedIcon(clone)
		end

		PlayerUpgradesInventoryUI.wireRow(clone, (buildRowOptions(p.key, p.data)))
		clone.Parent = scrollingFrame

		if p.data.reveal and PlayerUpgradesInventoryUI.isAuraObtainable(p.key, p.data) then
			PlayerUpgradesInventoryUI.applyRevealGate(clone, p.data.reveal)
		else
			PlayerUpgradesInventoryUI.showRow(clone)
		end

		clones[p.key] = clone
	end

	local v3, v4, v5 = collectAuraEntries(inventoryAuras)
	PlayerUpgradesInventoryUI.renderGalaxyGroups(scrollingFrame, v3, v4, v5, "Auras", addAuraRow)
	v = true
	v2 = catalogSignature
end

local function updateAuraRow(k, ownedAuras, equippedAura, auraSkin)
	local v3 = clones[k]

	if not v3 then
		return
	end

	local v4 = table.find(ownedAuras, k) ~= nil
	local v5 = equippedAura == k
	local v6 = auraSkin == k
	local auraData = PlayerUpgradesCatalog.GetAuraData(k)
	local v7

	if auraData then
		v7 = PlayerUpgradesInventoryUI.shouldHideIfUnobtainable(
			PlayerUpgradesInventoryUI.isAuraObtainable(k, auraData),
			ownedAuras,
			k
		)
	else
		v7 = false
	end

	v3:SetAttribute("Hidden", v7)

	if v4 and CollectionService:HasTag(v3, "RevealUI") then
		PlayerUpgradesInventoryUI.clearRevealGate(v3)
	end

	PlayerUpgradesInventoryUI.updateRowState(v3, v4, v5, v6)
end

local AuraUISystem = {}

function AuraUISystem:UpdateDisplay()
	local v3 = ClientState:Get()
	local ownedAuras = v3.OwnedAuras or {}
	local equippedAura = v3.EquippedAura or "None"
	local auraSkin = v3.AuraSkin or "None"
	buildInventory(ownedAuras)

	for k in pairs(clones) do
		updateAuraRow(k, ownedAuras, equippedAura, auraSkin)
	end
end

function AuraUISystem:InitLogic()
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

	for _, v3 in ipairs(CollectionService:GetTagged("AurasCloseButton")) do
		connectClose(v3) -- equivalent call inferred; original call site unknown
	end

	CollectionService:GetInstanceAddedSignal("AurasCloseButton"):Connect(connectClose)
	PlayerUpgradesInventoryUI.whenInventoryTabReady("Auras", function()
		v = false
		v2 = nil
		table.clear(clones)
		self:UpdateDisplay()
	end)
	self:UpdateDisplay()
end

function AuraUISystem.OnClose(_) end

return AuraUISystem