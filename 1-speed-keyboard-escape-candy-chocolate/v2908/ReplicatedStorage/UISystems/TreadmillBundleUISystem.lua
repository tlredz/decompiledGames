local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local SkinBundles = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PersonalTreadmill"):WaitForChild("SkinBundles"))
local BUNDLES = SkinBundles.BUNDLES
local Skins = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PersonalTreadmill"):WaitForChild("Skins"))
local CATEGORY_RANK = Skins.CATEGORY_RANK
local LAYOUT_CATEGORY_BLOCK = Skins.LAYOUT_CATEGORY_BLOCK
local LAYOUT_BUNDLE_OFFSET = Skins.LAYOUT_BUNDLE_OFFSET
local v = #Skins.CATEGORY_ORDER + 1
local GiftConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("GiftConfig"))
local PlayerUpgradesInventoryUI = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("PlayerUpgradesInventoryUI"))
local flag = false
local flag2 = false
local clones = {}
local localPlayer = Players.LocalPlayer

local function collectBundleEntries()
	local result = {}

	for k, v2 in pairs(BUNDLES) do
		if v2.EventKey == nil or v2.EventKey == Config.GetEventDataKey() then
			table.insert(result, {
				key = k,
				data = v2
			})
		end
	end

	table.sort(result, function(a, b)
		local v2 = CATEGORY_RANK[a.data.category] or v
		local v3 = CATEGORY_RANK[b.data.category] or v

		if v2 == v3 then
			return a.data.displayName < b.data.displayName
		end

		return v2 < v3
	end)
	return result
end

local function buildRowOptions(key, data)
	local price = data.price or 0
	return {
		showBuyGamepass = price > 0,
		devProductId = price > 0 and price or nil,
		onBuyGamepass = price > 0 and function()
			MarketplaceService:PromptProductPurchase(localPlayer, price)
		end or nil,
		showBuyGift = GiftConfig.SKIN_BUNDLE_GIFTS[key] ~= nil,
		onBuyGift = GiftConfig.SKIN_BUNDLE_GIFTS[key] ~= nil and (function()
			PlayerUpgradesInventoryUI.openGiftModal(key)
		end or nil) or nil
	}
end

local function buildInventory()
	if flag2 then
		return
	end

	local inventoryTab = PlayerUpgradesInventoryUI.getInventoryTab("TreadmillSkins")

	if not inventoryTab then
		return
	end

	local rowTemplate = PlayerUpgradesInventoryUI.getRowTemplate("TreadmillBundleTemplate")
	local scrollingFrame = PlayerUpgradesInventoryUI.getScrollingFrame(inventoryTab)
	local v2 = nil
	local count = 0

	for _, v3 in ipairs((collectBundleEntries())) do
		local v4 = CATEGORY_RANK[v3.data.category] or v

		if v4 ~= v2 then
			v2 = v4
			count = 0
		end

		count += 1
		local clone = rowTemplate:Clone()
		clone.Name = v3.key
		clone.LayoutOrder = v4 * LAYOUT_CATEGORY_BLOCK + LAYOUT_BUNDLE_OFFSET + count
		clone:SetAttribute("CosmeticKey", v3.key)
		PlayerUpgradesInventoryUI.applyRowContent(
			clone,
			v3.data.displayName,
			v3.data.icon,
			nil,
			v3.data.color,
			v3.data.description
		)
		PlayerUpgradesInventoryUI.wireRow(clone, (buildRowOptions(v3.key, v3.data)))
		clone.Parent = scrollingFrame
		clones[v3.key] = clone
	end

	flag2 = true
end

local function isBundleOwned(p, list)
	for _, skinKey in ipairs(p.skinKeys) do
		if not table.find(list, skinKey) then
			return false
		end
	end

	return true
end

local function updateBundleRow(k, ownedTreadmillSkins)
	local v2 = clones[k]

	if not v2 then
		return
	end

	local v3 = BUNDLES[k]
	local bundleOwned = isBundleOwned(v3, ownedTreadmillSkins)
	v2:SetAttribute("Hidden", not bundleOwned and (type(v3.price) ~= "number" or not (v3.price > 0)))
	PlayerUpgradesInventoryUI.updateRowState(v2, bundleOwned, false)

	if bundleOwned then
		PlayerUpgradesInventoryUI.setEquipTitle(v2, "Owned", false)
	end
end

local TreadmillBundleUISystem = {}

function TreadmillBundleUISystem:UpdateDisplay()
	buildInventory()
	local ownedTreadmillSkins = ClientState:Get().OwnedTreadmillSkins or {}

	for k in pairs(clones) do
		updateBundleRow(k, ownedTreadmillSkins)
	end
end

function TreadmillBundleUISystem:InitLogic()
	if flag then
		return
	end

	flag = true
	PlayerUpgradesInventoryUI.whenInventoryTabReady("TreadmillSkins", function()
		flag2 = false
		table.clear(clones)
		buildInventory()
		self:UpdateDisplay()
	end)
	buildInventory()
	self:UpdateDisplay()
end

function TreadmillBundleUISystem.OnClose(_) end

return TreadmillBundleUISystem