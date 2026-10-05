local React = require(game.ReplicatedStorage.Packages.React)
local Tile = require(game.ReplicatedStorage.React.Components.Tile)
require(game.ReplicatedStorage.React.Components.Inventory.Main.TileGrid.FastTile)
require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local use = require(game.ReplicatedStorage.React.Hooks.Item.Upgrades.use)
local useDynamicAccessory = require(game.ReplicatedStorage.React.Hooks.Item.useDynamicAccessory)
local createElement = React.createElement
return function(data)
	local upgrades = use(data.Info.ItemId, data.Info.NetworkedUID)
	local v2 = useMatch(data.Info.ItemId)
	assert(v2, (`bad ItemConfig: {data.Info.ItemId}`))
	local name = v2.Display.Name or v2.Index.StorageKey
	local category = v2.Display.Category
	local v3 = useDynamicAccessory(data.Info.ItemId, data.Info.NetworkedUID)
	local v6 = {
		Size = data.Size,
		Position = data.Position,
		AnchorPoint = data.AnchorPoint,
		SizeConstraint = data.SizeConstraint,
		Selectable = data.Selectable,
		AutomaticSize = data.AutomaticSize,
		LayoutOrder = data.LayoutOrder,
		ZIndex = data.ZIndex,
		[React.Event.Activated] = function(...)
			if data[React.Event.Activated] then
				data[React.Event.Activated](...)
			end
		end,
		Variant = data.Variant,
		LoadingPriority = data.LoadingPriority,
		IsSelected = data.IsSelected,
		DrawContext = data.DrawContext,
		CornerRadius = data.CornerRadius,
		Quantity = nil,
		Upgrades = upgrades,
		IsEquipped = false,
		IsPermanent = false,
		SelectionBehaviorLeft = data.SelectionBehaviorLeft,
		SelectionBehaviorRight = data.SelectionBehaviorRight,
		SelectionBehaviorUp = data.SelectionBehaviorUp,
		SelectionBehaviorDown = data.SelectionBehaviorDown,
		SelectionGroup = data.SelectionGroup,
		Rarity = v2.Quality.Rarity,
		Overlays = v2.Inventory.TileOverlays,
		Title = name,
		Category = category
	}
	local isTrinket

	if v3 then
		isTrinket = v3.Type == "Trinket"
	end

	v6.IsTrinket = isTrinket
	local modifiers

	if v3 then
		modifiers = v3.Modifiers
	end

	v6.Modifiers = modifiers
	v6.Icon = v2.Display.Sprite
	v6.IconBorderThickness = v2.Display.SpriteBorderThickness
	v6.OutlineIcon = v2.Display.OutlineSprite
	v6.CornerIcon = v2.Display.CornerIcon
	v6.WasRecentlyReceived = false
	return createElement(Tile, v6)
end