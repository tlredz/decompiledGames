local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local SimpleShopTile = require(game.ReplicatedStorage.React.Components.Shop.SimpleShopTile)
local Tile = require(game.ReplicatedStorage.React.Components.BundleShop.Tile)
local useRecommended = require(game.ReplicatedStorage.React.Hooks.Fruit.useRecommended)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement

function recommendedTile(props)
	local index = props.Index
	local fruitId = props.FruitId
	local unwrapped = ItemConfig.match(fruitId):unwrap()
	local unwrapped2 = ItemConfig.match("Permanent " .. unwrapped.Index.StorageKey, "Redeemable"):unwrap()
	local unwrapped3 = RarityUtil.matchRarity(unwrapped.Quality.Rarity or "Common"):unwrap()
	local robuxPrice = useRobuxPrice(unwrapped2.Index.ItemId)
	return createElement(SimpleShopTile, {
		ItemId = fruitId,
		LayoutOrder = index,
		Title = unwrapped.Display.Name or unwrapped.Index.StorageKey,
		HeaderColor3 = unwrapped3.Color,
		IconSize = UDim2.fromScale(0.7, 1),
		RobuxPrice = robuxPrice,
		OnClick = function()
			props.OnClick(unwrapped2.Index.ItemId)
		end
	})
end

return function(p)
	local v = {
		Magnet = createElement(Tile, {
			LayoutOrder = 1,
			Type = "Magnet",
			FlexWidthRatio = 2,
			OnClick = p.OnClick
		}),
		Dragon = createElement(Tile, {
			LayoutOrder = 2,
			Type = "Dragon",
			FlexWidthRatio = 2,
			OnClick = p.OnClick
		})
	}
	useRecommended()
	return createElement("Frame", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.fromScale(1, 0.3),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		ZIndex = CONSTANTS.LAYER.RAISED,
		LayoutOrder = p.LayoutOrder
	}, {
		UIGridLayout = createElement("UIListLayout", {
			Padding = UDim.new(0.012, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			VerticalFlex = Enum.UIFlexAlignment.Fill
		}),
		Fruits = createElement(React.Fragment, {}, v)
	})
end