local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
return function(object, udim: UDim2, p: number)
	return object:Create("Frame")({
		Name = "Connector",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = udim,
		Size = UDim2.new(p, -5.656854249492381, 0, 2),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.5,
		object:Create("UIGradient")({
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 0) })
		}),
		object:Create("Frame")({
			Name = "Head",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, 5.656854249492381, 0.5, 0),
			Size = UDim2.fromOffset(8, 8),
			Rotation = 45,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			object:Create("UIStroke")({
				Color = Color3.new(1, 1, 1),
				Thickness = 2
			})
		})
	})
end