local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Textures = require(game.ReplicatedStorage.Textures)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local permanentControlControl = IdMap.Redeemable["Permanent Control-Control"]
local unwrapped = ItemConfig.match(permanentControlControl):unwrap()
local createElement = React.createElement
return function(props)
	local price = useRobuxPrice(permanentControlControl)
	return createElement(Card, {
		ZIndex = props.ZIndex,
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		SizeConstraint = props.SizeConstraint,
		AutomaticSize = props.AutomaticSize,
		Title = (unwrapped.Display.Name or unwrapped.Index.StorageKey):gsub("Permanent ", ""),
		TitleColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#0054ff")),
			ColorSequenceKeypoint.new(0.2, Color3.fromHex("#00c6ff")),
			ColorSequenceKeypoint.new(0.6, Color3.fromHex("#00c6ff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#0054ff"))
		}),
		ProductImage = Textures.banner.shop["control.png"],
		ProductGlow = nil,
		StorageKey = unwrapped.Index.StorageKey,
		ProductImageIconSize = nil,
		ProductImageIconAnchorPoint = nil,
		OnClick = props.OnClick and function()
			props.OnClick(permanentControlControl)
		end or nil,
		Price = price,
		IsRework = false,
		FlexWidthRatio = props.FlexWidthRatio or 2
	})
end