local React = require(game.ReplicatedStorage.Packages.React)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
local TileContainer = require(game.ReplicatedStorage.React.Components.Inventory.Main.BuildMenu.TileContainer)
local useBloxFruit = require(game.ReplicatedStorage.React.Hooks.Player.useBloxFruit)
local useFightingStyle = require(game.ReplicatedStorage.React.Hooks.Player.useFightingStyle)
local useGun = require(game.ReplicatedStorage.React.Hooks.Player.useGun)
local useSword = require(game.ReplicatedStorage.React.Hooks.Player.useSword)
local useCurrentBracket = require(game.ReplicatedStorage.React.Hooks.Inventory.useCurrentBracket)
require(game.ReplicatedStorage.React.RobloxTypes)
local createElement = React.createElement
return function(_)
	local _, v = useCurrentBracket()
	local v2 = useBloxFruit()
	local v3 = useFightingStyle()
	local v4 = useGun()
	local v5 = useSword()
	local v8 = {
		LayoutOrder = 2,
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 2
	}
	local v9 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 4,
			DominantAxis = Enum.DominantAxis.Width,
			AspectType = Enum.AspectType.ScaleWithParentSize
		}),
		Fruit = 0,
		Sword = 0,
		Gun = 0,
		FightingStyle = 0
	}
	local itemId

	if v2 then
		itemId = v2.ItemId
	end

	v9.Fruit = createElement(TileContainer, {
		CategoryLabelOnNull = "Fruit",
		ItemId = itemId,
		Variant = "Elevated",
		Size = UDim2.fromScale(0.25, 0.25),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		PlusButtonHorizontalAlignment = Enum.HorizontalAlignment.Left,
		PlusButtonVerticalAlignment = Enum.VerticalAlignment.Bottom
	})
	local v16 = {
		CategoryLabelOnNull = "Sword",
		OnEmptySelect = function()
			v(PseudoEnum.InventoryItemBracket.Swords)
		end,
		ItemId = 0,
		Variant = "Elevated",
		Size = 0,
		SizeConstraint = 0
	}
	local itemId2

	if v5 then
		itemId2 = v5.ItemId
	end

	v16.ItemId = itemId2
	v16.Size = UDim2.fromScale(0.25, 0.25)
	v16.SizeConstraint = Enum.SizeConstraint.RelativeXX
	v9.Sword = createElement(TileContainer, v16)
	local v20 = {
		CategoryLabelOnNull = "Gun",
		OnEmptySelect = function()
			v(PseudoEnum.InventoryItemBracket.Guns)
		end,
		ItemId = 0,
		Variant = "Elevated",
		Size = 0,
		SizeConstraint = 0
	}
	local itemId3

	if v4 then
		itemId3 = v4.ItemId
	end

	v20.ItemId = itemId3
	v20.Size = UDim2.fromScale(0.25, 0.25)
	v20.SizeConstraint = Enum.SizeConstraint.RelativeXX
	v9.Gun = createElement(TileContainer, v20)
	local itemId4

	if v3 then
		itemId4 = v3.ItemId
	end

	v9.FightingStyle = createElement(TileContainer, {
		CategoryLabelOnNull = "Fighting Style",
		ItemId = itemId4,
		Variant = "Elevated",
		Size = UDim2.fromScale(0.25, 0.25),
		SizeConstraint = Enum.SizeConstraint.RelativeXX
	})
	return createElement("Frame", v8, v9)
end