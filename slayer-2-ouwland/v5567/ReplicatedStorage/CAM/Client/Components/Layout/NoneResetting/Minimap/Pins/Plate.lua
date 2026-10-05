local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local color = Color3.new(0.25, 0.25, 0.25)
local color2 = Color3.new(1, 1, 1)
return function(object, data)
	return object:Create("Frame")({
		Name = "Plate",
		ZIndex = data.ZIndex,
		Visible = data.Visible,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		object:Create("ImageLabel")({
			Name = "Bg",
			ZIndex = 1,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://17369850725",
			ImageColor3 = color
		}),
		object:Create("ImageLabel")({
			Name = "Outline",
			ZIndex = 2,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = "rbxassetid://18356056375",
			ImageColor3 = color2,
			ImageTransparency = 0.45
		}),
		object:Create("ImageLabel")({
			Name = "Icon",
			ZIndex = 3,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.71, 0.71),
			BackgroundTransparency = 1,
			Image = data.Icon,
			ImageColor3 = data.IconColor,
			ScaleType = Enum.ScaleType.Crop,
			object:Create("UICorner")({
				CornerRadius = UDim.new(1, 0)
			})
		})
	})
end