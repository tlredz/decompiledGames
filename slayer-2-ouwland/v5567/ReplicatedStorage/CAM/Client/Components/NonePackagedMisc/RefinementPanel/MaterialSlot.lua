local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local color = Color3.new(1, 0.35, 0.35)
return function(object, data)
	local v = object:Create("Frame")
	local v2 = {
		Name = "MaterialSlot",
		LayoutOrder = data.LayoutOrder,
		Size = UDim2.fromScale(0.3, 1),
		BackgroundTransparency = 1
	}
	local v3 = object:Create("UIListLayout")({
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0.05, 0)
	})
	local v4

	if data.Label ~= nil then
		v4 = object:Create("TextLabel")({
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 0.13),
			BackgroundTransparency = 1,
			Text = data.Label,
			TextScaled = true,
			Font = Enum.Font.SourceSansSemibold,
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = 0.1,
			object:Create("UIStroke")({
				Thickness = 1.5,
				Transparency = 0.25
			})
		})
	end

	local v5 = object:Create("Frame")
	local v6 = {
		Name = "Plate",
		LayoutOrder = 2,
		Size = UDim2.fromScale(1, 0.5),
		Instance.new("UIAspectRatioConstraint"),
		BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
		BackgroundTransparency = 0.45
	}
	local v7 = object:Create("UICorner")({
		CornerRadius = UDim.new(0.15)
	})
	local v8 = object:Create("UIStroke")
	local color2

	if data.Short then
		color2 = color
	else
		color2 = Color3.new(1, 1, 1)
	end

	local v11 = v8({
		Color = color2,
		Thickness = 1.5,
		Transparency = data.Short and 0.25 or 0.75
	})
	local v12 = object:Create("ImageLabel")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.78, 0.78),
		BackgroundTransparency = 1,
		Image = data.Icon or ""
	})
	local v13

	if data.Substitute ~= nil then
		v13 = object:Create("Frame")({
			Name = "Substitute",
			ZIndex = 3,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1.15, 1.05),
			Size = UDim2.fromScale(0.48, 0.48),
			Instance.new("UIAspectRatioConstraint"),
			BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
			BackgroundTransparency = 0.1,
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.18)
			}),
			object:Create("UIStroke")({
				Color = Color3.new(1, 1, 1),
				Thickness = 1.5,
				Transparency = 0.5
			}),
			object:Create("ImageLabel")({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.42),
				Size = UDim2.fromScale(0.78, 0.78),
				BackgroundTransparency = 1,
				Image = data.Substitute.Icon or ""
			}),
			object:Create("TextLabel")({
				Name = "Count",
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -1),
				Size = UDim2.fromScale(1, 0.4),
				BackgroundTransparency = 1,
				Text = data.Substitute.Text,
				TextScaled = true,
				Font = Enum.Font.SourceSansBold,
				TextColor3 = Color3.new(1, 1, 1),
				object:Create("UIStroke")({
					Thickness = 1.5,
					Transparency = 0.15
				})
			})
		})
	end

	do local _values = table.pack(v7, v11, v12, v13, object:Create("TextLabel")({
	Name = "Need",
	Visible = data.Substitute == nil,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -3, 1, -1),
	Size = UDim2.fromScale(0.72, 0.32),
	BackgroundTransparency = 1,
	Text = data.NeedText,
	TextScaled = true,
	TextXAlignment = Enum.TextXAlignment.Right,
	Font = Enum.Font.SourceSansBold,
	TextColor3 = Color3.new(1, 1, 1),
	object:Create("UIStroke")({
		Thickness = 1.5,
		Transparency = 0.2
	})
})); for _k = 1, _values.n do v6[1 + _k] = _values[_k] end end
	local v14 = v5(v6)
	local v15 = object:Create("TextLabel")
	local v16 = {
		Name = "Have",
		LayoutOrder = 3,
		Size = UDim2.fromScale(1, 0.15),
		BackgroundTransparency = 1,
		Text = data.HaveText,
		TextScaled = true,
		Font = Enum.Font.SourceSansBold
	}
	local textColor

	if data.Short then
		textColor = color
	else
		textColor = Color3.new(1, 1, 1)
	end

	v16.TextColor3 = textColor
	do local _values = table.pack(object:Create("UIStroke")({
	Thickness = 1.5,
	Transparency = 0.25
})); for _k = 1, _values.n do v16[_k] = _values[_k] end end
	do local _values = table.pack(v3, v4, v14, v15(v16)); for _k = 1, _values.n do v2[_k] = _values[_k] end end
	return v(v2)
end