local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Textures = require(game.ReplicatedStorage.Textures)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local use = require(game.ReplicatedStorage.React.Hooks.Item.Owned.use)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local yETIMUTFiend = IdMap.Redeemable.YETIMUTFiend
local unwrapped = ItemConfig.match(yETIMUTFiend):unwrap()
local createElement = React.createElement
return function(props)
	local yetiYeti = use(IdMap.Moveset["Yeti-Yeti"])
	local yETIMUTFiend2 = use(IdMap.Mutation.YETIMUTFiend)
	local price = useRobuxPrice(yETIMUTFiend)
	return createElement(Card, {
		IsDisabled = not yetiYeti or yETIMUTFiend2,
		ErrorMessage = not yetiYeti and "You must own the Permanent Yeti fruit to purchase this mutation." or yETIMUTFiend2 and "You already own this mutation." or nil,
		ZIndex = props.ZIndex,
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder or 2,
		SizeConstraint = props.SizeConstraint,
		AutomaticSize = props.AutomaticSize,
		Title = unwrapped.Display.Name or unwrapped.Index.StorageKey,
		TitleColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		}),
		ProductImage = Textures.banner.shop["red-yeti.png"],
		ProductGlow = nil,
		StorageKey = unwrapped.Index.StorageKey,
		ProductImageIconSize = nil,
		ProductImageIconAnchorPoint = nil,
		OnClick = props.OnClick and function()
			props.OnClick(yETIMUTFiend)
		end or nil,
		Price = price,
		IsRework = false,
		FlexWidthRatio = props.FlexWidthRatio or 2
	})
end