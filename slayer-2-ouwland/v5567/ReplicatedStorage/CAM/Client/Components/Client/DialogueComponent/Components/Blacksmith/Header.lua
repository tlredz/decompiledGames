local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
return function(object, text: string, text2: string, color: Color3)
	return object:Create("Frame")({
		Name = "Header",
		Size = UDim2.fromScale(1, 0.12),
		BackgroundTransparency = 1,
		object:Create("TextLabel")({
			Name = "Title",
			Size = UDim2.fromScale(1, 0.467),
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansBold,
			Text = text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		object:Create("TextLabel")({
			Name = "Subtitle",
			Position = UDim2.fromScale(0, 0.467),
			Size = UDim2.fromScale(1, 0.455),
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansSemibold,
			Text = text2,
			TextColor3 = color:Lerp(Color3.new(1, 1, 1), 0.45),
			TextTransparency = 0.15,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		object:Create("Frame")({
			Name = "Underline",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(0.385, 0, 0, 2),
			BackgroundColor3 = color,
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) })
			}),
			object:Create("UIShadow")({
				BlurRadius = UDim.new(1),
				Color = color,
				Transparency = 0.6
			})
		})
	})
end