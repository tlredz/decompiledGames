local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Textures = require(game.ReplicatedStorage.Textures)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local permanentLightningLightning = IdMap.Redeemable["Permanent Lightning-Lightning"]
local unwrapped = ItemConfig.match(permanentLightningLightning):unwrap()
local createElement = React.createElement
return function(props)
	local price = useRobuxPrice(permanentLightningLightning)
	return createElement(Card, {
		ZIndex = props.ZIndex,
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		SizeConstraint = props.SizeConstraint,
		AutomaticSize = props.AutomaticSize,
		Title = (unwrapped.Display.Name or unwrapped.Index.StorageKey):gsub("Permanent ", ""),
		TitleColor = nil,
		ProductImage = Textures.banner.shop["lightning.png"],
		ProductGlow = nil,
		StorageKey = unwrapped.Index.StorageKey,
		ProductImageIconSize = nil,
		ProductImageIconAnchorPoint = nil,
		OnClick = props.OnClick and function()
			props.OnClick(permanentLightningLightning)
		end or nil,
		Price = price,
		IsRework = false,
		FlexWidthRatio = props.FlexWidthRatio or 2
	})
end