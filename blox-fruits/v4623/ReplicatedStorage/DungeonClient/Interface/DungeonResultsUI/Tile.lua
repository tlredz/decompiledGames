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
local Tile = require(game.ReplicatedStorage.React.Components.Tile)
require(game.ReplicatedStorage.React.RobloxTypes)
local createElement = React.createElement
return React.forwardRef(function(data, ref)
	local forcedQuantity = use(data.Info.ItemId, data.Info.NetworkedUID)

	if data.ForcedQuantity then
		forcedQuantity = data.ForcedQuantity
	end

	local upgrades = use2(data.Info.ItemId, data.Info.NetworkedUID)
	local isEquipped = useIsEquipped(data.Info.ItemId, data.Info.NetworkedUID)
	local v3 = useMatch(data.Info.ItemId)
	assert(v3, (`bad ItemConfig: {data.Info.ItemId}`))
	local name = v3.Display.Name or v3.Index.StorageKey
	local category = v3.Display.Category
	local forceAccessoryItem = useDynamicAccessory(data.Info.ItemId, data.Info.NetworkedUID)

	if data.ForceAccessoryItem then
		forceAccessoryItem = data.ForceAccessoryItem
	end

	local v4 = useKeyInfo(v3.Index.StorageKey)
	local v5 = useModifiers(data.Info.ItemId, data.Info.NetworkedUID)
	local overlays = React.useMemo(function()
		local result = {}

		if v3.Inventory.TileOverlays then
			for _, tileOverlay in v3.Inventory.TileOverlays do
				table.insert(result, tileOverlay)
			end
		end

		if v5 then
			for _, v7 in v5 do
				local v8 = v7
				local success, result2 = pcall(function(...)
					PseudoEnum.getValueFromEnumItem("InventoryTileOverlay", v8)
					table.insert(result, v8)
				end)

				if not success then
					warn("Failed to apply fish modifier overlay:", result2)
				end
			end
		end

		table.freeze(result)
		return result
	end, { v5, v3.Inventory.TileOverlays })
	local v9 = {
		ref = ref,
		Size = data.Size,
		Position = data.Position,
		AnchorPoint = data.AnchorPoint,
		SizeConstraint = data.SizeConstraint,
		Selectable = data.Selectable,
		AutomaticSize = data.AutomaticSize,
		LayoutOrder = data.LayoutOrder,
		ZIndex = data.ZIndex,
		SelectionBorderColor = data.SelectionBorderColor,
		ForceAsLabel = data.ForceAsLabel,
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
		Quantity = forcedQuantity,
		Upgrades = upgrades,
		IsEquipped = isEquipped
	}
	local isPermanent

	if v4 then
		isPermanent = v4.IsPermanent
	end

	v9.IsPermanent = isPermanent
	v9.Rarity = v3.Quality.Rarity
	v9.Overlays = overlays
	v9.Title = name
	v9.Category = category
	local isTrinket

	if forceAccessoryItem then
		isTrinket = forceAccessoryItem.Type == "Trinket"
	end

	v9.IsTrinket = isTrinket
	local modifiers

	if forceAccessoryItem then
		modifiers = forceAccessoryItem.Modifiers
	end

	v9.Modifiers = modifiers
	v9.Icon = v3.Display.Sprite
	v9.IconBorderThickness = v3.Display.SpriteBorderThickness
	v9.OutlineIcon = v3.Display.OutlineSprite
	v9.OutlineIconColor = v3.Display.OutlineColor
	v9.CornerIcon = v3.Display.CornerIcon
	v9.WasRecentlyReceived = false
	return createElement(Tile, v9)
end)