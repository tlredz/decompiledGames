local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
return function(object)
	return object:Create("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.4,
		BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.35)
		}),
		object:Create("UIStroke")({
			BorderOffset = UDim.new(0, -6),
			Transparency = 0.8,
			Color = Color3.new(1, 1, 1)
		}),
		object:Create("Frame")({
			Name = "InnerGloss",
			Size = UDim2.new(1, -10, 1, -10),
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.35)
			}),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.9,
			BackgroundColor3 = Color3.new(),
			object:Create("UIGradient")({
				Rotation = 280,
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) })
			})
		}),
		object:Create("TextLabel")({
			Name = "txt",
			Size = UDim2.fromScale(1, 0.6),
			BackgroundTransparency = 1,
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.SourceSansBold,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Text = "UNLOCK PREVIOUS",
			TextTransparency = 0.35,
			TextScaled = true
		})
	})
end