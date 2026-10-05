local React = require(game.ReplicatedStorage.Packages.React)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
local TileContainer = require(game.ReplicatedStorage.React.Components.Inventory.Main.BuildMenu.TileContainer)
local useTrinkets = require(game.ReplicatedStorage.React.Hooks.Player.useTrinkets)
local useAccessory = require(game.ReplicatedStorage.React.Hooks.Player.useAccessory)
local useCurrentBracket = require(game.ReplicatedStorage.React.Hooks.Inventory.useCurrentBracket)
local createElement = React.createElement
return function(_)
	local _, v = useCurrentBracket()
	local itemId, networkedUID = useAccessory()
	local v4 = useTrinkets()
	local v5 = React.useMemo(function()
		if not v4 then
			return table.freeze({})
		end

		local v6 = {}

		for k, _ in v4 do
			table.insert(v6, k)
		end

		table.sort(v6)
		return table.freeze(v6)
	end, { v4 })
	local networkedUID2 = v5[1]
	local itemId2

	if networkedUID2 and v4 then
		itemId2 = v4[networkedUID2]
	end

	local networkedUID3 = v5[2]
	local itemId3

	if networkedUID3 and v4 then
		itemId3 = v4[networkedUID3]
	end

	return createElement("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(-0.01, 0),
		Size = UDim2.fromScale(0.246141, 0.66),
		ZIndex = 2
	}, {
		UIListLayout = createElement("UIListLayout", {
			Padding = UDim.new(0.04, 0),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Accessory = createElement(TileContainer, {
			LayoutOrder = 1,
			CategoryLabelOnNull = "Accessory",
			OnEmptySelect = function()
				v(PseudoEnum.InventoryItemBracket.Accessories)
			end,
			ItemId = itemId,
			NetworkedUID = networkedUID,
			Variant = "Display",
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeXX
		}),
		Trinket1 = createElement(TileContainer, {
			LayoutOrder = 2,
			OnEmptySelect = function()
				v(PseudoEnum.InventoryItemBracket.Trinkets)
			end,
			ItemId = itemId2,
			NetworkedUID = networkedUID2,
			CategoryLabelOnNull = "Trinket",
			Variant = "Display",
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeXX
		}),
		Trinket2 = createElement(TileContainer, {
			LayoutOrder = 3,
			OnEmptySelect = function()
				v(PseudoEnum.InventoryItemBracket.Trinkets)
			end,
			ItemId = itemId3,
			NetworkedUID = networkedUID3,
			CategoryLabelOnNull = "Trinket",
			Variant = "Display",
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeXX
		})
	})
end