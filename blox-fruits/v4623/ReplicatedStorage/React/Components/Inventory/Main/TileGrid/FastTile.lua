local React = require(game.ReplicatedStorage.Packages.React)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local use = require(game.ReplicatedStorage.React.Hooks.Item.Quantity.use)
local useIsEquipped = require(game.ReplicatedStorage.React.Hooks.Item.useIsEquipped)
local use2 = require(game.ReplicatedStorage.React.Hooks.Item.Upgrades.use)
local useDynamicAccessory = require(game.ReplicatedStorage.React.Hooks.Item.useDynamicAccessory)
local useKeyInfo = require(game.ReplicatedStorage.React.Hooks.Fruit.useKeyInfo)
local useModifiers = require(game.ReplicatedStorage.React.Hooks.Item.Fish.useModifiers)
local useIsNew = require(game.ReplicatedStorage.React.Hooks.Item.useIsNew)
local use3 = require(game.ReplicatedStorage.React.Hooks.Item.Favorited.use)
local useConfig = require(game.ReplicatedStorage.React.Hooks.Inventory.useConfig)
local Tile = require(game.ReplicatedStorage.React.Components.Tile)
local v = {
	PseudoEnum.ItemEquipMethod.UnstoreConsumable,
	PseudoEnum.ItemEquipMethod.LoadFruit,
	PseudoEnum.ItemEquipMethod.UnstoreHolidayGift,
	PseudoEnum.ItemEquipMethod.UnstoreConsumable
}
require(game.ReplicatedStorage.React.RobloxTypes)
local createElement = React.createElement
return function(data)
	local quantity = use(data.Info.ItemId, data.Info.NetworkedUID)
	local upgrades = use2(data.Info.ItemId, data.Info.NetworkedUID)
	local isEquipped = useIsEquipped(data.Info.ItemId, data.Info.NetworkedUID)
	local isFavorited = use3(data.Info.ItemId, data.Info.NetworkedUID)
	local v6 = useMatch(data.Info.ItemId)
	assert(v6, (`bad ItemConfig: {data.Info.ItemId}`))

	if not table.find(v6.Inventory.Groups, PseudoEnum.InventoryItemGroup.Stash) and v6.State.StorageMethod ~= PseudoEnum.ItemStorageMethod.StoredFruits and quantity and quantity <= 1 then
		quantity = nil
	end

	if not v6.State.EquipMethod or table.find(v, v6.State.EquipMethod) then
		isEquipped = nil
	end

	local v7 = useConfig()
	local stackDisplayName

	if v6.Inventory.StackKey and v6.Inventory.StackDisplayName and v7.TileStackingDisabled ~= true then
		stackDisplayName = v6.Inventory.StackDisplayName
	else
		stackDisplayName = v6.Display.Name or v6.Index.StorageKey
	end

	local categoryIconText = v6.Display.CategoryIcon and v6.Display.CategoryIconText or v6.Display.Category

	if v6.Inventory.StackKey and v6.Inventory.StackDisplayCategory and not v7.TileStackingDisabled then
		categoryIconText = v6.Inventory.StackDisplayCategory
	end

	local v8 = useDynamicAccessory(data.Info.ItemId, data.Info.NetworkedUID)
	local v9 = useKeyInfo(v6.Index.StorageKey)
	local v10 = useModifiers(data.Info.ItemId, data.Info.NetworkedUID)
	local wasRecentlyReceived = useIsNew(data.Info.ItemId, data.Info.NetworkedUID)
	local isPurchase = React.useMemo(function()
		if v7 and v7.PurchaseTiles then
			for _, purchaseTile in v7.PurchaseTiles do
				if purchaseTile.ItemId == data.Info.ItemId and purchaseTile.NetworkedUID == data.Info.NetworkedUID then
					return true
				end
			end
		end

		return false
	end, { v7 and v7.PurchaseTiles, data.Info })
	local overlays = React.useMemo(function()
		local result = {}

		if v6.Inventory.TileOverlays then
			for _, tileOverlay in v6.Inventory.TileOverlays do
				table.insert(result, tileOverlay)
			end
		end

		if v10 then
			for _, v14 in v10 do
				local v15 = v14
				local success, result2 = pcall(function(...)
					PseudoEnum.getValueFromEnumItem("InventoryTileOverlay", v15)
					table.insert(result, v15)
				end)

				if not success then
					warn("Failed to apply fish modifier overlay:", result2)
				end
			end
		end

		table.freeze(result)
		return result
	end, { v10, v6.Inventory.TileOverlays })
	local tileCategoryIconOverride

	if v6.Display.CategoryIcon then
		tileCategoryIconOverride = v7.TileCategoryIconOverride or v6.Display.CategoryIcon
	end

	if v6.Inventory.StackCategoryIcon and v6.Inventory.StackKey and not v7.TileStackingDisabled then
		tileCategoryIconOverride = v6.Inventory.StackCategoryIcon
	end

	local v16 = {
		Size = data.Size,
		Position = data.Position,
		AnchorPoint = data.AnchorPoint,
		SizeConstraint = data.SizeConstraint,
		Selectable = data.Selectable,
		AutomaticSize = data.AutomaticSize,
		LayoutOrder = data.LayoutOrder,
		ZIndex = data.ZIndex,
		SelectionBorderColor = data.SelectionBorderColor,
		[React.Event.Activated] = function(...)
			if data[React.Event.Activated] then
				data[React.Event.Activated](...)
			end
		end,
		[React.Event.SelectionGained] = data[React.Event.SelectionGained],
		[React.Event.SelectionLost] = data[React.Event.SelectionLost],
		Variant = data.Variant,
		LoadingPriority = data.LoadingPriority,
		IsSelected = data.IsSelected,
		DrawContext = data.DrawContext,
		CornerRadius = data.CornerRadius,
		IsFavorited = isFavorited,
		RibbonText = v6.Display.RibbonText,
		OutlineAppearance = v7.ForceSolidOutline == true and PseudoEnum.InventoryOutlineAppearance.Solid or v6.Inventory.OutlineAppearance,
		TileAppearance = v6.Inventory.TileAppearance,
		Quantity = quantity,
		Upgrades = upgrades,
		IsPurchase = isPurchase,
		IsEquipped = isEquipped,
		SelectionGroup = data.SelectionGroup,
		SelectionBehaviorUp = data.SelectionBehaviorUp,
		SelectionBehaviorLeft = data.SelectionBehaviorLeft,
		SelectionBehaviorRight = data.SelectionBehaviorRight,
		SelectionBehaviorDown = data.SelectionBehaviorDown
	}
	local isPermanent

	if v9 then
		isPermanent = v9.IsPermanent
	end

	v16.IsPermanent = isPermanent
	v16.Rarity = v6.Quality.Rarity
	v16.TileRarity = (table.find(v6.Inventory.Tags, PseudoEnum.InventoryItemTag.UsePremiumTile) or isPurchase) and "Premium" or v6.Quality.Rarity
	v16.Overlays = overlays
	v16.Title = stackDisplayName
	v16.Category = categoryIconText
	local isTrinket

	if v8 then
		isTrinket = v8.Type == "Trinket"
	end

	v16.IsTrinket = isTrinket
	local modifiers

	if v8 then
		modifiers = v8.Modifiers
	end

	v16.Modifiers = modifiers
	v16.Icon = v6.Display.Sprite
	v16.IconBorderThickness = v6.Display.SpriteBorderThickness
	v16.OutlineIcon = v6.Display.OutlineSprite
	v16.OutlineIconColor = v6.Display.OutlineColor
	v16.CornerIcon = v6.Display.CornerIcon
	v16.CategoryIcon = tileCategoryIconOverride
	v16.WasRecentlyReceived = wasRecentlyReceived
	return createElement(Tile, v16)
end