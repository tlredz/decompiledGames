local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local permanentTigerTiger = IdMap.Redeemable["Permanent Tiger-Tiger"]
local unwrapped = ItemConfig.match(permanentTigerTiger):unwrap()
local createElement = React.createElement
return function(props)
	local price = useRobuxPrice(permanentTigerTiger)
	local unwrapped2 = Spritesheets.match("Tiger-Tiger1"):unwrap()
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
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 157, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 157, 0))
		}),
		ProductImage = typeof(unwrapped2.Image) ~= "string" and "" or unwrapped2.Image,
		ProductImageOffset = unwrapped2.ImageRectOffset,
		ProductImageSize = unwrapped2.ImageRectSize,
		ProductGlow = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#e89b36")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#dac280"))
		}),
		StorageKey = unwrapped.Index.StorageKey,
		ProductImageIconSize = nil,
		ProductImageIconAnchorPoint = Vector2.new(0.5, 0.5),
		OnClick = props.OnClick and function()
			props.OnClick(permanentTigerTiger)
		end or nil,
		Price = price,
		IsRework = false,
		FlexWidthRatio = props.FlexWidthRatio or 1
	})
end