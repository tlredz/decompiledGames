local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
return function(object)
	return object:Create("Frame")({
		Size = UDim2.new(0.7, -4, 0.675, -4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
		object:Create("UIStroke")({
			BorderOffset = UDim.new(0, 1),
			Color = Color3.new(0.066667, 1, 0.392157),
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.35),
					NumberSequenceKeypoint.new(1, 0.6)
				}),
				Rotation = 120
			})
		}),
		object:Create("ImageLabel")({
			Name = "Icon",
			Size = UDim2.fromScale(0.6, 0.6),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.035, 0.5),
			Instance.new("UIAspectRatioConstraint"),
			Image = "rbxassetid://94422410738309",
			BackgroundTransparency = 1
		}),
		object:Create("TextLabel")({
			Size = UDim2.fromScale(0.775, 0.85),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.185, 0.475),
			BackgroundTransparency = 1,
			Text = "In safe zone",
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextColor3 = Color3.new(0.72549, 1, 0.690196),
			Font = Enum.Font.SourceSansSemibold
		}),
		object:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.45),
				NumberSequenceKeypoint.new(1, 0.8)
			}),
			Rotation = 210
		}),
		object:Create("UICorner")({
			CornerRadius = UDim.new(1)
		})
	})
end