local React = require(game.ReplicatedStorage.Packages.React)
require(script.Parent.Types)
local Info = require(script.Info)
local ButtonRow = require(script.ButtonRow)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(74, 74, 74),
		BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		LayoutOrder = 2,
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0.45, -2, 1, 0),
		ZIndex = CONSTANTS.LAYER.RAISED
	}, {
		Info = createElement(Info, {
			Unlocked = props.Unlocked,
			Owned = props.Owned,
			CraftingInventory = props.CraftingInventory
		}),
		Buttons = createElement(ButtonRow, {
			CraftingInventory = props.CraftingInventory,
			Owned = props.Owned,
			OnAction = props.OnAction
		}),
		UIListLayout = createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalFlex = Enum.UIFlexAlignment.Fill
		})
	})
end