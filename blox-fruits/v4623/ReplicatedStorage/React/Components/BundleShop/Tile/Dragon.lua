local React = require(game.ReplicatedStorage.Packages.React)
local Textures = require(game.ReplicatedStorage.Textures)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
require(game.ReplicatedStorage.Spritesheets)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local permanentDragonDragon = IdMap.Redeemable["Permanent Dragon-Dragon"]
local unwrapped = ItemConfig.match(permanentDragonDragon):unwrap()
local createElement = React.createElement
return function(props)
	local price = useRobuxPrice(permanentDragonDragon)
	return createElement(Card, {
		ZIndex = props.ZIndex,
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		SizeConstraint = props.SizeConstraint,
		AutomaticSize = props.AutomaticSize,
		Title = (unwrapped.Display.Name or unwrapped.Index.StorageKey):gsub("Permanent ", ""),
		ProductImage = Textures.banner.shop.dragons["Default.png"],
		TitleColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.PRIMARY.BACKGROUND),
			ColorSequenceKeypoint.new(0.2, CONSTANTS.COLOR.PRIMARY.HIGHLIGHT),
			ColorSequenceKeypoint.new(0.6, CONSTANTS.COLOR.PRIMARY.HIGHLIGHT),
			ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.PRIMARY.BACKGROUND)
		}),
		StorageKey = unwrapped.Index.StorageKey,
		OnClick = props.OnClick and function()
			props.OnClick(permanentDragonDragon)
		end or nil,
		Price = price,
		IsRework = false,
		FlexWidthRatio = props.FlexWidthRatio or 2
	})
end