local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local Items = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("Items"))
local ItemRewardUISystem = require(ReplicatedStorage:WaitForChild("ItemRewardUISystem"))
local SoundManager = require(ReplicatedStorage:WaitForChild("SoundManager"))
local ItemRarityGradient = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("ItemRarityGradient"))
local LimitedSerialLabel = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.LimitedSerialLabel)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local itemAction = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemAction")
local templates = ReplicatedStorage:WaitForChild("Templates")
local softStar = templates:WaitForChild("SoftStar")
local emphasizedStar = templates:WaitForChild("EmphasizedStar")
local silentStar = templates:WaitForChild("SilentStar")
local missingStar = templates:WaitForChild("MissingStar")
local selectableItemCard = templates:WaitForChild("SelectableItemCard")
local unselectableItemCard = templates:WaitForChild("UnselectableItemCard")
local MERGE_COUNT = Items.MERGE_COUNT
local v = nil
local v2 = false
local v3 = {}

local function getWindow(p)
	for _, v4 in ipairs(CollectionService:GetTagged("InventoryWindow")) do
		if v4:IsDescendantOf(playerGui) and v4:GetAttribute("Window") == p then
			return v4
		end
	end

	return nil
end

local function fillStars(tierFrame, instance, p)
	local layoutContainer = tierFrame.LayoutContainer

	for _, guiObject in ipairs(layoutContainer:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for _ = 1, p do
		local clone = instance:Clone()
		clone.Visible = true
		clone.Parent = layoutContainer
	end
end

local function tierText(p, p2)
	return string.format("Tier: %d - Bonus: +%d%%", p2, Items.EntryBonusPercent(Items.Entry(p, p2)))
end

local function groupOwnedItems()
	local items = ClientState:Get().Items or {}
	local v4 = {}
	local result = {}

	for _, item in ipairs(items) do
		local key = Items.KeyOf(item)
		local v5 = key and Items.ITEMS[key]

		if not v5 then
			continue
		end

		local tier = Items.TierOf(item)
		local limitedNumber = Items.LimitedNumberOf(item)
		local maxLimited = Items.MaxLimitedOf(item)
		local v6 = key .. "\0" .. tostring(tier)

		if Items.IsLimitedKey(key) then
			v6 ..= "\0" .. tostring(limitedNumber or "unserialized")
		end

		local v7 = v4[v6]

		if not v7 then
			v7 = {
				Key = key,
				Tier = tier,
				Count = 0,
				Data = v5,
				limited = limitedNumber,
				maxLimited = maxLimited
			}
			v4[v6] = v7
			table.insert(result, v7)
		end

		v7.Count += 1
	end

	return result
end

local function clearPickerCards(ownedItemsFrame)
	for _, guiObject in ipairs(ownedItemsFrame:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end
end

local function fillSelectedSpotIcons(layoutContainer, icon)
	for _, guiObject in ipairs(layoutContainer:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject.SpotFrame.Icon.Image = icon
		end
	end
end

local function applyEmptyMerger(merger)
	local itemSpots = merger.ItemSpots
	local mergeResult = merger.MergeResult
	local middle = merger.Middle
	itemSpots.SelectedItems.Visible = false
	itemSpots.Button.Visible = true
	itemSpots.Button.Active = true
	middle.MergeInactive.Visible = true
	middle.MergeActive.Visible = false
	middle.MergeActive.Active = false
	mergeResult.SpotFrameInactive.Visible = true
	mergeResult.SpotFrame.Visible = false
	mergeResult.TierFrame.Visible = false
	mergeResult.TierMultiplier.Visible = false
	fillStars(itemSpots.SelectedItems.TierFrame, softStar, 0)
	fillStars(mergeResult.TierFrame, emphasizedStar, 0)
end

local function applyFilledMerger(merger, key, tier)
	local v4 = Items.ITEMS[key]
	local itemSpots = merger.ItemSpots
	local selectedItems = itemSpots.SelectedItems
	local mergeResult = merger.MergeResult
	local middle = merger.Middle
	local v5 = tier + 1
	itemSpots.Button.Visible = false
	selectedItems.Visible = true
	selectedItems.NameLabel.Text = "[" .. MERGE_COUNT .. "] - " .. v4.name
	selectedItems.TierMultiplier.Text = string.format(
		"Tier: %d - Bonus: +%d%%",
		tier,
		Items.EntryBonusPercent(Items.Entry(key, tier))
	)
	fillStars(selectedItems.TierFrame, softStar, tier)
	fillSelectedSpotIcons(selectedItems.LayoutContainer, v4.icon)
	middle.MergeInactive.Visible = false
	middle.MergeActive.Visible = true
	middle.MergeActive.Active = true
	mergeResult.SpotFrameInactive.Visible = false
	mergeResult.SpotFrame.Visible = true
	mergeResult.TierFrame.Visible = true
	mergeResult.TierMultiplier.Visible = true
	mergeResult.SpotFrame.Icon.Image = v4.icon
	mergeResult.TierMultiplier.Text = string.format(
		"Tier: %d - Bonus: +%d%%",
		v5,
		Items.EntryBonusPercent(Items.Entry(key, v5))
	)
	fillStars(mergeResult.TierFrame, emphasizedStar, v5)
end

local fn

local function fn2()
	local window = getWindow("ItemsMerger")

	if not window then
		return
	end

	local merger = window.Merger

	if v then
		applyFilledMerger(merger, v.Key, v.Tier)
	else
		applyEmptyMerger(merger)
	end
end

local function fn3()
	local window = getWindow("ItemsMerger")

	if not window then
		return
	end

	local ownedItemsFrame = window.Picker.OwnedItemsFrame
	clearPickerCards(ownedItemsFrame)
	local v4 = groupOwnedItems()
	table.sort(v4, function(a, b)
		local v5 = not Items.IsLimitedKey(a.Key)

		if v5 then
			if MERGE_COUNT <= a.Count then
				v5 = a.Tier < Items.MAX_TIER
			else
				v5 = false
			end
		end

		local v6 = not Items.IsLimitedKey(b.Key)

		if v6 then
			if MERGE_COUNT <= b.Count then
				v6 = b.Tier < Items.MAX_TIER
			else
				v6 = false
			end
		end

		if v5 == v6 then
			return Items.EntryMultiplier(Items.Entry(a.Key, a.Tier)) > Items.EntryMultiplier(Items.Entry(b.Key, b.Tier))
		end

		return v5
	end)

	for _, v5 in ipairs(v4) do
		local v6 = not Items.IsLimitedKey(v5.Key)

		if v6 then
			if MERGE_COUNT <= v5.Count then
				v6 = v5.Tier < Items.MAX_TIER
			else
				v6 = false
			end
		end

		local clone

		if v6 then
			clone = selectableItemCard:Clone()
		else
			clone = unselectableItemCard:Clone()
		end

		clone.Name = v5.Key .. "_T" .. v5.Tier .. (not v5.limited and "" or "_S" .. v5.limited)
		local root = clone.Root
		root.SpotFrame.Icon.Image = v5.Data.icon
		root.NameLabel.Text = v5.Data.name

		if v5.limited and v5.maxLimited then
			local limitedSerialLabel = LimitedSerialLabel({
				serial = v5.limited,
				maxSerial = v5.maxLimited
			})
			limitedSerialLabel.Parent = root.NameLabel
		end

		root.Multiplier.Text = "+" .. Items.EntryBonusPercent(Items.Entry(v5.Key, v5.Tier)) .. "%"
		root.Amount.Text = Items.IsLimitedKey(v5.Key) and "LIMITED" or v5.Count .. "/" .. MERGE_COUNT
		local v7

		if v5.Tier == 0 then
			v7 = missingStar
		elseif v6 then
			v7 = emphasizedStar
		else
			v7 = silentStar
		end

		local v8 = v5.Tier == 0 and 1 or v5.Tier
		fillStars(root.TierFrame, v7, v8)
		ItemRarityGradient.apply(root.SpotFrame, v5.Data.rarity, nil, true)

		if v6 then
			local v9 = v5.Key
			local tier = v5.Tier
			root.SelectButton.MouseButton1Up:Connect(function()
				SoundManager:Play("CLICK")
				v = {
					Key = v9,
					Tier = tier
				}
				fn()
			end)
		end

		clone.Visible = true
		clone.Parent = ownedItemsFrame
	end
end

local function fn4()
	local window = getWindow("ItemsMerger")

	if window then
		window.Merger.Visible = false
		window.Picker.Visible = true
		fn3()
	end
end

fn = function()
	local window = getWindow("ItemsMerger")

	if window then
		window.Picker.Visible = false
		window.Merger.Visible = true
		fn2()
	end
end

local function getInventoryModal()
	for _, v4 in ipairs(CollectionService:GetTagged("InventoryModal")) do
		if v4:IsDescendantOf(playerGui) then
			return v4
		end
	end

	return nil
end

local function reopenMergerMenu()
	local inventoryModal = getInventoryModal()

	if inventoryModal and ClientState.ActiveModal == nil then
		fn()
		ClientState:ToggleModal(inventoryModal)
	elseif inventoryModal and ClientState.ActiveModal == inventoryModal then
		fn()
	end
end

local function wireMergerWindow(p)
	if v3[p] then
		return
	end

	v3[p] = true
	local merger = p.Merger
	merger.ItemSpots.Button.MouseButton1Up:Connect(function()
		SoundManager:Play("CLICK")
		fn4()
	end)
	merger.Middle.MergeActive.MouseButton1Up:Connect(function()
		if v2 or not v then
			return
		end

		v2 = true
		itemAction:FireServer("Merge", v.Key, v.Tier)
		task.delay(0.4, function()
			v2 = false
		end)
	end)
	p.Picker.Visible = false
	p.Merger.Visible = true
	fn2()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tryWireWindows()
	local window = getWindow("ItemsMerger")

	if window then
		wireMergerWindow(window)
	end
end

itemAction.OnClientEvent:Connect(function(p, data)
	if p == "Update" then
		ClientState:Update({
			Items = data.Items,
			EquippedItems = data.EquippedItems
		})

		if v then
			local v4 = false

			for _, v6 in ipairs((groupOwnedItems())) do
				if Items.IsLimitedKey(v6.Key) or v6.Key ~= v.Key or v6.Tier ~= v.Tier or not (MERGE_COUNT <= v6.Count) then
					continue
				end

				v4 = true
				break
			end

			if not v4 then
				v = nil
			end
		end

		fn2()
		local window = getWindow("ItemsMerger")

		if window and window.Picker.Visible then
			fn3()
		end
	elseif p == "MergeSuccess" then
		v = nil
		ClientState:CloseCurrentModal()
		ItemRewardUISystem.playForItemKey(
			data.Key,
			string.format("Tier %d > %d Success!", data.Tier - 1, data.Tier),
			data.Tier,
			nil,
			reopenMergerMenu
		)
	end
end)

local function wireMergerTabButton(instance)
	if not v3[instance] and instance:IsDescendantOf(playerGui) and instance:GetAttribute("Action") == "ItemsMerger" then
		v3[instance] = true
		instance.MouseButton1Up:Connect(function()
			v = nil
			task.defer(fn)
		end)
	end
end

for _, v4 in ipairs(CollectionService:GetTagged("InventoryButtons")) do
	wireMergerTabButton(v4)
end

CollectionService:GetInstanceAddedSignal("InventoryButtons"):Connect(function(p)
	task.defer(wireMergerTabButton, p)
end)

for _, v4 in ipairs(CollectionService:GetTagged("UIActionBtn")) do
	wireMergerTabButton(v4)
end

CollectionService:GetInstanceAddedSignal("UIActionBtn"):Connect(function(p)
	task.defer(wireMergerTabButton, p)
end)
CollectionService:GetInstanceAddedSignal("InventoryWindow"):Connect(function(instance)
	task.defer(function()
		if instance:IsDescendantOf(playerGui) and instance:GetAttribute("Window") == "ItemsMerger" then
			wireMergerWindow(instance)
		end
	end)
end)
tryWireWindows() -- equivalent call inferred; original call site unknown