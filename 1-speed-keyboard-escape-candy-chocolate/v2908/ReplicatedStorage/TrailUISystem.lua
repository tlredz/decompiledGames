local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local PlayerUpgradesCatalog = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PlayerUpgradesCatalog"))
local GiftConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("GiftConfig"))
local PlayerUpgradesInventoryUI = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("PlayerUpgradesInventoryUI"))
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
local TrailRemotes = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("TrailRemotes"))
local UpgradeMultipliers = require(ReplicatedStorage._FRAMEWORK.Libraries.UpgradeMultipliers)
local flag = false
local clones = {}
local v = {}
local v2 = false
local v3 = nil
local localPlayer = Players.LocalPlayer

local function getEventTrailData(p)
	if v[p] then
		return v[p]
	end

	for _, v4 in ipairs(PlayerUpgradesCatalog.GetSeasonalTrails()) do
		if v4.Key ~= p then
			continue
		end

		v[p] = v4
		return v4
	end

	return nil
end

local function getCatalogSignature(inventoryTrails)
	local v4 = {}

	for k in pairs(inventoryTrails) do
		table.insert(v4, k)
	end

	table.sort(v4)
	return table.concat(v4, "\0")
end

local function collectTrailEntries(inventoryTrails)
	local v4 = {}

	for k, item in pairs(inventoryTrails) do
		table.insert(v4, {
			key = k,
			data = item,
			isEvent = false
		})
	end

	for _, v5 in ipairs(PlayerUpgradesCatalog.GetSeasonalTrails()) do
		table.insert(v4, {
			key = v5.Key,
			data = v5,
			isEvent = true
		})
	end

	return PlayerUpgradesInventoryUI.groupEntriesByGalaxy(v4, function(p)
		return p.data.Multiplier
	end)
end

local function buildRowOptions(key, data, isEvent)
	local price = data.Price or 0
	local currencyPrice = data.CurrencyPrice
	local devProduct = data.DevProduct or 0
	local gamepass = data.Gamepass or 0
	local v4 = GiftConfig.ALL_GIFTS[key] ~= nil
	local showBuyGamepass = devProduct > 0 or gamepass > 0
	local showBuyWins = false
	local winsPriceText = nil
	local onBuyWins

	-- equivalent calls inferred from this helper; original call sites unknown
	local function buy(p)
		local v8, v9, v10 = TrailRemotes.BuyTrail:request(key, p):await()

		if not (v8 and v9) then
			warn("[TrailSystem] " .. tostring(v10 or v9))
		end
	end

	if isEvent and currencyPrice and currencyPrice.Amount and currencyPrice.Amount > 0 then
		winsPriceText = Numbers.formatNumber(currencyPrice.Amount) .. " " .. (currencyPrice.Key or "")

		onBuyWins = function()
			buy("Currency") -- equivalent call inferred; original call site unknown
		end

		showBuyWins = true
	elseif price > 0 and UpgradeMultipliers.matchesActiveGalaxy(data) then
		winsPriceText = Numbers.formatNumber(price)

		onBuyWins = function()
			buy("Wins") -- equivalent call inferred; original call site unknown
		end

		showBuyWins = true
	end

	local v8 = {
		showBuyWins = showBuyWins,
		winsPriceText = winsPriceText,
		onBuyWins = onBuyWins,
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

	v8.gamepassId = gamepassId
	v8.onBuyGamepass = showBuyGamepass and function()
		if devProduct > 0 then
			MarketplaceService:PromptProductPurchase(localPlayer, devProduct)
		else
			MarketplaceService:PromptGamePassPurchase(localPlayer, gamepass)
		end
	end or nil
	v8.showBuyGift = v4 and not PlayerUpgradesCatalog.IsWorldEvent()
	v8.onBuyGift = v4 and not PlayerUpgradesCatalog.IsWorldEvent() and (function()
		PlayerUpgradesInventoryUI.openGiftModal(key)
	end or nil) or nil

	function v8.onEquip()
		TrailRemotes.EquipTrail:fire(key)
	end

	function v8.onEquipAsCosmetic()
		TrailRemotes.EquipTrail:fire(key, "Skin")
	end

	return v8
end

local function buildInventory(ownedTrails)
	local inventoryTrails = PlayerUpgradesCatalog.GetInventoryTrails(ownedTrails)
	local catalogSignature = getCatalogSignature(inventoryTrails)

	if v2 and v3 == catalogSignature then
		return
	end

	local inventoryTab = PlayerUpgradesInventoryUI.getInventoryTab("Trails")

	if not inventoryTab then
		return
	end

	local rowTemplate = PlayerUpgradesInventoryUI.getRowTemplate("AuraTrailTemplate")
	local scrollingFrame = PlayerUpgradesInventoryUI.getScrollingFrame(inventoryTab)
	PlayerUpgradesInventoryUI.clearBuiltRows(scrollingFrame)
	table.clear(clones)

	local function addTrailRow(data, layoutOrder)
		local clone = rowTemplate:Clone()
		clone.Name = data.key
		clone.LayoutOrder = layoutOrder
		clone:SetAttribute("CosmeticKey", data.key)

		if data.isEvent then
			clone:SetAttribute("IsEventTrail", true)
		end

		PlayerUpgradesInventoryUI.applyRowContent(
			clone,
			data.key,
			data.data.Icon,
			UpgradeMultipliers.trail(data.key),
			nil
		)
		PlayerUpgradesInventoryUI.applyRowColor(clone, data.data.Color)
		PlayerUpgradesInventoryUI.wireRow(clone, (buildRowOptions(data.key, data.data, data.isEvent)))
		clone.Parent = scrollingFrame

		if data.data.reveal and PlayerUpgradesInventoryUI.isTrailObtainable(data.key, data.data) then
			PlayerUpgradesInventoryUI.applyRevealGate(clone, data.data.reveal)
		else
			PlayerUpgradesInventoryUI.showRow(clone)
		end

		clones[data.key] = clone
	end

	local v4, v5, v6 = collectTrailEntries(inventoryTrails)
	PlayerUpgradesInventoryUI.renderGalaxyGroups(scrollingFrame, v4, v5, v6, "Trails", addTrailRow)
	v2 = true
	v3 = catalogSignature
end

local function updateTrailRow(k, ownedTrails, equippedTrail, trailSkin)
	local v4 = clones[k]

	if not v4 then
		return
	end

	local v5 = table.find(ownedTrails, k) ~= nil
	local v6 = equippedTrail == k
	local v7 = trailSkin == k
	local isEventTrail = v4:GetAttribute("IsEventTrail") == true
	local v8

	if isEventTrail then
		if v[k] then
			v8 = v[k]
		else
			for _, v10 in ipairs(PlayerUpgradesCatalog.GetSeasonalTrails()) do
				if v10.Key ~= k then
					continue
				end

				v[k] = v10
				v8 = v10
				break
			end
		end
	else
		v8 = PlayerUpgradesCatalog.GetTrailData(k)
	end

	local v9

	if isEventTrail then
		v9 = (v8 and PlayerUpgradesInventoryUI.shouldHideEventTrail(v8, ownedTrails, k)) == true
	else
		v9 = false
	end

	if v8 then
		v9 = v9 or PlayerUpgradesInventoryUI.shouldHideIfUnobtainable(
			PlayerUpgradesInventoryUI.isTrailObtainable(k, v8),
			ownedTrails,
			k
		)
	end

	v4:SetAttribute("Hidden", v9)

	if v5 and CollectionService:HasTag(v4, "RevealUI") then
		PlayerUpgradesInventoryUI.clearRevealGate(v4)
	end

	PlayerUpgradesInventoryUI.updateRowState(v4, v5, v6, v7)
end

local TrailUISystem = {}

function TrailUISystem:UpdateDisplay()
	local v4 = ClientState:Get()
	local ownedTrails = v4.OwnedTrails or {}
	local equippedTrail = v4.EquippedTrail or "None"
	local trailSkin = v4.TrailSkin or "None"
	buildInventory(ownedTrails)

	for k in pairs(clones) do
		updateTrailRow(k, ownedTrails, equippedTrail, trailSkin)
	end
end

function TrailUISystem:InitLogic()
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

	for _, v4 in ipairs(CollectionService:GetTagged("TrailsCloseBtn")) do
		connectClose(v4) -- equivalent call inferred; original call site unknown
	end

	CollectionService:GetInstanceAddedSignal("TrailsCloseBtn"):Connect(connectClose)
	PlayerUpgradesInventoryUI.whenInventoryTabReady("Trails", function()
		v2 = false
		v3 = nil
		table.clear(clones)
		table.clear(v)
		self:UpdateDisplay()
	end)
	self:UpdateDisplay()
end

function TrailUISystem.OnClose(_) end

return TrailUISystem