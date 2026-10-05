local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Items = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("Items"))
local ItemRarityGradient = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("ItemRarityGradient"))
local ItemSignatures = require(ReplicatedStorage._FRAMEWORK.Features.ItemSignatures)
local LimitedSerialLabel = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.LimitedSerialLabel)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local itemAction = remotes:WaitForChild("ItemAction")
local updateUI = remotes:WaitForChild("UpdateUI")
local templates = ReplicatedStorage:WaitForChild("Templates")
local templateItemButton = templates:WaitForChild("TemplateItemButton")
local emphasizedStar = templates:WaitForChild("EmphasizedStar")
local RARITY_PRIORITY = Items.RARITY_PRIORITY
local v = {
	ItemsMerger = true
}
local flag = false
local MAX_EQUIPPED_DEFAULT = Items.MAX_EQUIPPED_DEFAULT
local gamepassReceived = {}
local v2 = false
task.spawn(function()
	if Items.EXTRA_SLOTS_GAMEPASS_ID ~= 0 then
		local EXTRA_SLOTS_GAMEPASS_ID = Items.EXTRA_SLOTS_GAMEPASS_ID
		local success, result = pcall(
			MarketplaceService.UserOwnsGamePassAsync,
			MarketplaceService,
			localPlayer.UserId,
			EXTRA_SLOTS_GAMEPASS_ID
		)

		if success and result then
			MAX_EQUIPPED_DEFAULT = Items.MAX_EQUIPPED_GAMEPASS

			for _, v3 in ipairs(CollectionService:GetTagged("MoreItemsGamepass")) do
				if v3:IsDescendantOf(playerGui) then
					v3.Visible = false
				end
			end
		elseif gamepassReceived[tostring(EXTRA_SLOTS_GAMEPASS_ID)] then
			MAX_EQUIPPED_DEFAULT = Items.MAX_EQUIPPED_GAMEPASS

			for _, v3 in ipairs(CollectionService:GetTagged("MoreItemsGamepass")) do
				if v3:IsDescendantOf(playerGui) then
					v3.Visible = false
				end
			end
		end
	end

	v2 = true
end)
updateUI.OnClientEvent:Connect(function(p)
	if p and p.GamepassReceived then
		gamepassReceived = p.GamepassReceived

		if Items.EXTRA_SLOTS_GAMEPASS_ID ~= 0 then
			local EXTRA_SLOTS_GAMEPASS_ID = tostring(Items.EXTRA_SLOTS_GAMEPASS_ID)

			if gamepassReceived[EXTRA_SLOTS_GAMEPASS_ID] and MAX_EQUIPPED_DEFAULT ~= Items.MAX_EQUIPPED_GAMEPASS then
				MAX_EQUIPPED_DEFAULT = Items.MAX_EQUIPPED_GAMEPASS

				for _, v3 in ipairs(CollectionService:GetTagged("MoreItemsGamepass")) do
					if v3:IsDescendantOf(playerGui) then
						v3.Visible = false
					end
				end
			end
		end
	end
end)

local function getInventoryWindow(parent)
	while parent and parent ~= playerGui do
		if CollectionService:HasTag(parent, "InventoryWindow") then
			return parent
		else
			parent = parent.Parent
		end
	end

	return nil
end

local function getFrameByTag(tag)
	for _, v3 in ipairs(CollectionService:GetTagged(tag)) do
		if not v3:IsDescendantOf(playerGui) then
			continue
		end

		local inventoryWindow = getInventoryWindow(v3)
		local window = inventoryWindow and inventoryWindow:GetAttribute("Window")

		if not (window and v[window]) then
			return v3
		end
	end

	return nil
end

local function fillStars(tierFrame, emphasizedStar2, tier)
	local layoutContainer = tierFrame.LayoutContainer

	for _, guiObject in ipairs(layoutContainer:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for _ = 1, tier do
		local clone = emphasizedStar2:Clone()
		clone.Visible = true
		clone.Parent = layoutContainer
	end
end

local function createItemButton(p, frameByTag)
	local key = Items.KeyOf(p)
	local v3 = Items.ITEMS[key]

	if not v3 then
		return nil
	end

	local tier = Items.TierOf(p)
	local limitedNumber = Items.LimitedNumberOf(p)
	local maxLimited = Items.MaxLimitedOf(p)
	local clone = templateItemButton:Clone()
	clone.Name = "Item_" .. key .. "_" .. tier
	clone.SpotFrame.Icon.Image = v3.icon
	clone.NameLabel.Text = v3.shortName or v3.name

	if limitedNumber and maxLimited then
		local limitedSerialLabel = LimitedSerialLabel({
			serial = limitedNumber,
			maxSerial = maxLimited
		})
		limitedSerialLabel.Parent = clone.NameLabel
	end

	local label = ItemSignatures.createLabel(p)

	if label then
		label.Parent = clone
	end

	clone.Multiplier.Text = "+" .. Items.EntryBonusPercent(p) .. "%"
	fillStars(clone.TierFrame, emphasizedStar, tier)
	clone.LayoutOrder = (RARITY_PRIORITY[v3.rarity] or 8) * 10 - tier
	ItemRarityGradient.apply(clone.SpotFrame, v3.rarity)
	clone.Parent = frameByTag
	clone.Visible = true
	return clone
end

local function clearFrame(frameByTag)
	for _, button in ipairs(frameByTag:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end
end

local function refreshUI()
	local frameByTag = getFrameByTag("OwnedItemsFrame")
	local frameByTag2 = getFrameByTag("EquippedItemsFrame")

	if not (frameByTag and frameByTag2) then
		return
	end

	clearFrame(frameByTag)
	clearFrame(frameByTag2)
	local v3 = ClientState:Get()
	local items = v3.Items or {}
	local equippedItems = v3.EquippedItems or {}

	for _, item in ipairs(items) do
		local key = Items.KeyOf(item)
		local tier = Items.TierOf(item)
		local limitedNumber = Items.LimitedNumberOf(item)
		local signature = Items.SignatureOf(item)
		local itemButton = createItemButton(item, frameByTag)

		if not itemButton then
			continue
		end

		local v4 = key
		local v5 = tier
		local v6 = limitedNumber
		local v7 = signature
		itemButton.Activated:Connect(function()
			if not flag then
				flag = true
				itemAction:FireServer("Equip", v4, v5, v6, v7)
				task.delay(0.4, function()
					flag = false
				end)
			end
		end)
		local v8 = item
		itemButton.MouseButton2Click:Connect(function()
			ItemSignatures.requestSign(v8)
		end)
	end

	for _, equippedItem in ipairs(equippedItems) do
		local key = Items.KeyOf(equippedItem)
		local tier = Items.TierOf(equippedItem)
		local limitedNumber = Items.LimitedNumberOf(equippedItem)
		local signature = Items.SignatureOf(equippedItem)
		local itemButton = createItemButton(equippedItem, frameByTag2)

		if not itemButton then
			continue
		end

		local v4 = key
		local v5 = tier
		local v6 = limitedNumber
		local v7 = signature
		itemButton.Activated:Connect(function()
			if not flag then
				flag = true
				itemAction:FireServer("Unequip", v4, v5, v6, v7)
				task.delay(0.4, function()
					flag = false
				end)
			end
		end)
		local v8 = equippedItem
		itemButton.MouseButton2Click:Connect(function()
			ItemSignatures.requestSign(v8)
		end)
	end

	local frameByTag3 = getFrameByTag("EquippedItemsText")

	if frameByTag3 and frameByTag3:IsA("TextLabel") then
		frameByTag3.Text = "Equipped (" .. #equippedItems .. "/" .. MAX_EQUIPPED_DEFAULT .. ")"
	end

	local frameByTag4 = getFrameByTag("OwnedItemsText")

	if frameByTag4 and frameByTag4:IsA("TextLabel") then
		frameByTag4.Text = "Owned (" .. #items .. ")"
	end

	local totalBonusPercent = Items.GetTotalBonusPercent(equippedItems)
	local frameByTag5 = getFrameByTag("ItemsMultiplierLabel")

	if frameByTag5 then
		frameByTag5.Text = "+" .. totalBonusPercent .. "% " .. Config.GetSpeedLabel() .. " (Items)"
	end

	local frameByTag6 = getFrameByTag("ItemsMultiplierLabel2")

	if frameByTag6 then
		frameByTag6.Text = "+" .. totalBonusPercent .. "% " .. Config.GetSpeedLabel()
	end
end

itemAction.OnClientEvent:Connect(function(p, p2)
	if p == "Update" then
		ClientState:Update({
			Items = p2.Items,
			EquippedItems = p2.EquippedItems
		})
		refreshUI()
	elseif p == "Error" then
		warn("[ItemsInventory] Erreur:", p2)
	end
end)
local v3 = false
updateUI.OnClientEvent:Connect(function(p)
	if p.Items ~= nil or p.EquippedItems ~= nil then
		if p.Items then
			ClientState:Update({
				Items = p.Items
			})
		end

		if p.EquippedItems then
			ClientState:Update({
				EquippedItems = p.EquippedItems
			})
		end

		task.defer(function()
			local frameByTag = getFrameByTag("OwnedItemsFrame")
			local frameByTag2 = getFrameByTag("EquippedItemsFrame")

			if frameByTag and frameByTag2 then
				refreshUI()
			else
				v3 = true
			end
		end)
	end
end)

local function onFrameTagAdded(instance)
	if instance:IsDescendantOf(playerGui) then
		task.defer(function()
			v3 = false
			refreshUI()
		end)
	end
end

CollectionService:GetInstanceAddedSignal("OwnedItemsFrame"):Connect(onFrameTagAdded)
CollectionService:GetInstanceAddedSignal("EquippedItemsFrame"):Connect(onFrameTagAdded)

local function connectBulkButton(tag, p)
	local v4 = {}

	local function tryConnect(button)
		if v4[button] or not button:IsDescendantOf(playerGui) then
			return
		end

		if not (button:IsA("GuiButton") or button:IsA("TextButton") or button:IsA("ImageButton")) then
			return
		end

		v4[button] = true
		print("[Items] Bouton connecté:", tag, "→", p)
		button.Activated:Connect(function()
			if flag then
				return
			end

			flag = true
			print("[Items] Clic:", p)
			itemAction:FireServer(p)
			task.delay(0.4, function()
				flag = false
			end)
		end)
		button.Destroying:Connect(function()
			v4[button] = nil
		end)
	end

	for _, v5 in ipairs(CollectionService:GetTagged(tag)) do
		tryConnect(v5)
	end

	CollectionService:GetInstanceAddedSignal(tag):Connect(function(p2)
		task.defer(function()
			tryConnect(p2)
		end)
	end)
end

connectBulkButton("EquipBestItems", "EquipBest")
connectBulkButton("UnequipAllItems", "UnequipAll")

local function setupMoreItemsButton(button)
	if not (button:IsDescendantOf(playerGui) and (button:IsA("GuiButton") or button:IsA("TextButton") or button:IsA("ImageButton"))) then
		return
	end

	if MAX_EQUIPPED_DEFAULT == Items.MAX_EQUIPPED_GAMEPASS then
		button.Visible = false
	else
		button.Activated:Connect(function()
			MarketplaceService:PromptGamePassPurchase(localPlayer, Items.EXTRA_SLOTS_GAMEPASS_ID)
		end)
	end
end

for _, v4 in ipairs(CollectionService:GetTagged("MoreItemsGamepass")) do
	setupMoreItemsButton(v4)
end

CollectionService:GetInstanceAddedSignal("MoreItemsGamepass"):Connect(function(p)
	task.defer(function()
		setupMoreItemsButton(p)
	end)
end)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2, p3)
	if not (p == localPlayer and p2 == Items.EXTRA_SLOTS_GAMEPASS_ID) then
		return
	end

	if p3 then
		MAX_EQUIPPED_DEFAULT = Items.MAX_EQUIPPED_GAMEPASS

		for _, v4 in ipairs(CollectionService:GetTagged("MoreItemsGamepass")) do
			if v4:IsDescendantOf(playerGui) then
				v4.Visible = false
			end
		end

		refreshUI()
	end
end)
task.spawn(function()
	local total = 0

	while total < 10 do
		local frameByTag = getFrameByTag("OwnedItemsFrame")
		local frameByTag2 = getFrameByTag("EquippedItemsFrame")

		if frameByTag and frameByTag2 then
			refreshUI()
			break
		else
			task.wait(0.5)
			total += 0.5
		end
	end
end)