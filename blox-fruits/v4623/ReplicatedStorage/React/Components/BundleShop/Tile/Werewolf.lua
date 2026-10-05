local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Textures = require(game.ReplicatedStorage.Textures)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local use = require(game.ReplicatedStorage.React.Hooks.Item.Owned.use)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local tIGERMUTWerewolf = IdMap.Redeemable.TIGERMUTWerewolf
local unwrapped = ItemConfig.match(tIGERMUTWerewolf):unwrap()
local createElement = React.createElement
return function(props)
	local tigerTiger = use(IdMap.Moveset["Tiger-Tiger"])
	local tIGERMUTWerewolf2 = use(IdMap.Mutation.TIGERMUTWerewolf)
	local price = useRobuxPrice(tIGERMUTWerewolf)
	return createElement(Card, {
		IsDisabled = not tigerTiger or tIGERMUTWerewolf2,
		ErrorMessage = not tigerTiger and "You must own the Permanent Tiger fruit to purchase this mutation." or tIGERMUTWerewolf2 and "You already own this mutation." or nil,
		ZIndex = props.ZIndex,
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		SizeConstraint = props.SizeConstraint,
		AutomaticSize = props.AutomaticSize,
		Title = (unwrapped.Display.Name or unwrapped.Index.StorageKey):gsub("Permanent ", ""),
		TitleColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 105, 162)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(158, 172, 189)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 105, 162))
		}),
		ProductImage = Textures.banner.shop["werewolf.png"],
		ProductGlow = nil,
		StorageKey = unwrapped.Index.StorageKey,
		ProductImageIconSize = nil,
		ProductImageIconAnchorPoint = nil,
		OnClick = props.OnClick and function()
			props.OnClick(tIGERMUTWerewolf)
		end or nil,
		Price = price,
		IsRework = false,
		FlexWidthRatio = props.FlexWidthRatio or 2
	})
end