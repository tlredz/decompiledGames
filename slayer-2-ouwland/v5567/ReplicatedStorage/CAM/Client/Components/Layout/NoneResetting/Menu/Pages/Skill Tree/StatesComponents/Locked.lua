local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
require(script.Parent.Parent.TreeConfigurations)
return function(_, object, _)
	return object:Create("ImageLabel")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.8, 0.8),
		ImageColor3 = Color3.fromRGB(80, 80, 80),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://16873598266",
		object:Create("ImageLabel")({
			ZIndex = 2,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Image = "rbxassetid://101321312253593"
		}),
		object:Create("ImageLabel")({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.9),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageColor3 = Color3.new(),
			BackgroundTransparency = 1,
			Image = "rbxassetid://16873598266",
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.8),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			object:Create("UIStroke")({
				Thickness = 1,
				Transparency = 0.85,
				Color = Color3.new(1, 1, 1)
			}),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			})
		})
	})
end