local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Textures = require(game.ReplicatedStorage.Textures)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local permanentKitsuneKitsune = IdMap.Redeemable["Permanent Kitsune-Kitsune"]
local unwrapped = ItemConfig.match(permanentKitsuneKitsune):unwrap()
local createElement = React.createElement
return function(props)
	local price = useRobuxPrice(permanentKitsuneKitsune)
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
		ProductImage = Textures.banner.shop["kitsune.png"],
		ProductGlow = nil,
		StorageKey = unwrapped.Index.StorageKey,
		ProductImageIconSize = nil,
		ProductImageIconAnchorPoint = nil,
		OnClick = props.OnClick and function()
			props.OnClick(permanentKitsuneKitsune)
		end or nil,
		Price = price,
		IsRework = false,
		FlexWidthRatio = props.FlexWidthRatio or 2
	})
end