local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
require(ReplicatedStorage.Packages.faye)
return function(object, p)
	return {
		object:Create("ImageLabel")({
			Name = "OuterMost",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageTransparency = 0.5,
			Image = "rbxassetid://100257091873025"
		}),
		object:Create("ImageLabel")({
			Name = "Outer",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = "rbxassetid://92575568952036",
			ImageColor3 = Color3.new(0.290196, 0.309804, 0.345098)
		}),
		object:Create("ImageLabel")({
			Name = "Inner",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = "rbxassetid://117857011741205",
			ImageColor3 = Color3.new(),
			object:Create("UIGradient")({
				Rotation = 120,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.5),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		}),
		object:Create("ImageLabel")({
			Name = "InnerBorder",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = "rbxassetid://115174948101494",
			ImageColor3 = Color3.new(1, 1, 1),
			object:Create("UIGradient")({
				Rotation = 45,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.45),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		}),
		object:Create("TextLabel")({
			Size = UDim2.fromScale(0.7, 0.35),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Text = p.SkillPoints,
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = Font.new(
				"rbxasset://fonts/families/JosefinSans.json",
				Enum.FontWeight.Regular,
				Enum.FontStyle.Normal
			)
		}),
		object:Create("TextLabel")({
			Size = UDim2.fromScale(1.5, 0.2),
			Position = UDim2.fromScale(0.6, 1.115),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			TextTransparency = 0.1,
			TextStrokeTransparency = 0.5,
			Text = "SKILL POINTS",
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = Font.new(
				"rbxasset://fonts/families/FredokaOne.json",
				Enum.FontWeight.Regular,
				Enum.FontStyle.Normal
			),
			object:Create("ImageLabel")({
				Size = UDim2.fromScale(0.4, 1.2),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(-0.06, 0.5),
				Instance.new("UIAspectRatioConstraint"),
				BackgroundTransparency = 1,
				Image = BunchaIcons.SkillPoints
			})
		})
	}
end