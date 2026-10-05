local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local Wen = require(script.Parent.HudBottomRight.FirstVertical.Wen)
local uDim = UDim2.fromScale(0.195, 0.14625)
return function(object, parent)
	return object:Create("Frame")({
		Parent = parent,
		Name = "HudTopRight",
		Size = uDim,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -11, 0, 5),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Top
		}),
		object:Create("Frame")({
			Name = "Column",
			Size = UDim2.fromScale(0.6, 0.6),
			object:Create("UIAspectRatioConstraint")({}),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.Name
			}),
			Wen(object, parent)
		})
	})
end