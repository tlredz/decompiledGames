local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local Tile = require(script.Parent.Tile)
return function(object, layoutOrder: number, p2: string, p3, p4)
	return object:Create("Frame")({
		Name = p2,
		LayoutOrder = layoutOrder,
		Size = UDim2.fromScale(1, 0.48),
		BackgroundTransparency = 1,
		object:Create("TextLabel")({
			Name = "Label",
			Size = UDim2.fromScale(1, 0.18),
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansSemibold,
			Text = p2,
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = 0.25,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		object:Create("Frame")({
			Name = "Tiles",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(1, 0.8),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0.012)
			}),
			object:Iterate(p3, function(p5, p6, p7)
				return Tile(p7, p5, p6, p4)
			end)
		})
	})
end