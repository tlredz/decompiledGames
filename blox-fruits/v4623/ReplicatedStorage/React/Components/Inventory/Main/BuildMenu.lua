local React = require(game.ReplicatedStorage.Packages.React)
local EquipmentRow = require(script.EquipmentRow)
local AccessoriesColumn = require(script.AccessoriesColumn)
local MiscColumn = require(script.MiscColumn)
local StatsPanel = require(script.StatsPanel)
require(game.ReplicatedStorage.React.RobloxTypes)
local createElement = React.createElement
return function(_)
	return createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1)
	}, {
		UIPadding = createElement("UIPadding", {
			PaddingLeft = UDim.new(0.015, 0),
			PaddingRight = UDim.new(0.015, 0),
			PaddingTop = UDim.new(0.05, 0)
		}),
		Display = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.247348, 0.5),
			Size = UDim2.fromScale(0.483412, 0.98)
		}, {
			BodyOutline = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://89066869886895",
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1, 1)
			}, {
				UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
					AspectRatio = 0.631584
				})
			}),
			Buttons = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2
			}, {
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 5)
				}),
				TopButtons = createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 0.82)
				}, {
					Accessories = createElement(AccessoriesColumn, {}),
					Misc = createElement(MiscColumn, {})
				}),
				EquippedItems = createElement(EquipmentRow, {})
			})
		}),
		BuildStats = createElement(StatsPanel, {})
	})
end