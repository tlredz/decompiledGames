local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Textures = require(game.ReplicatedStorage.Textures)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local use = require(game.ReplicatedStorage.React.Hooks.Item.Owned.use)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local kITSUNEMUTKyukon = IdMap.Redeemable.KITSUNEMUTKyukon
local unwrapped = ItemConfig.match(kITSUNEMUTKyukon):unwrap()
local createElement = React.createElement
return function(props)
	local kitsuneKitsune = use(IdMap.Moveset["Kitsune-Kitsune"])
	local kITSUNEMUTKyukon2 = use(IdMap.Mutation.KITSUNEMUTKyukon)
	local price = useRobuxPrice(kITSUNEMUTKyukon)
	return createElement(Card, {
		IsDisabled = not kitsuneKitsune or kITSUNEMUTKyukon2,
		ErrorMessage = not kitsuneKitsune and "You must own the Permanent Kitsune fruit to purchase this mutation." or kITSUNEMUTKyukon2 and "You already own this mutation." or nil,
		ZIndex = props.ZIndex,
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		SizeConstraint = props.SizeConstraint,
		AutomaticSize = props.AutomaticSize,
		Title = "Crimson <Empyrean (Kitsune)>",
		TitleColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 105, 162)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(158, 172, 189)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 105, 162))
		}),
		ProductImage = Textures.banner.shop["9-tails.png"],
		ProductGlow = nil,
		StorageKey = unwrapped.Index.StorageKey,
		ProductImageIconSize = nil,
		ProductImageIconAnchorPoint = nil,
		OnClick = props.OnClick and function()
			props.OnClick(kITSUNEMUTKyukon)
		end or nil,
		Price = price,
		IsRework = false,
		FlexWidthRatio = props.FlexWidthRatio or 2
	})
end