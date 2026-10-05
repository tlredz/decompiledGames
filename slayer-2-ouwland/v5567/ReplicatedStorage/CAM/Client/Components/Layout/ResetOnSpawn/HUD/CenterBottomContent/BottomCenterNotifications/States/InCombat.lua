local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local info = faye.Info(0.65, Enum.EasingStyle.Back)
local info2 = faye.Info(0.85, Enum.EasingStyle.Back)
local info3 = faye.Info(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
return function(object, p)
	return object:Create("Frame")({
		Size = UDim2.fromScale(0.8, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
		object:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.55),
				NumberSequenceKeypoint.new(1, 0.9)
			}),
			Rotation = 210
		}),
		object:Create("Frame")({
			Name = "TopHolder",
			Position = UDim2.fromScale(0, 0.1),
			Size = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.05, 0)
			}),
			object:Create("Frame")({
				Name = "ImageHolder",
				Size = UDim2.fromScale(1, 1),
				Instance.new("UIAspectRatioConstraint"),
				BackgroundTransparency = 1,
				object:Create("ImageLabel")({
					Name = "Bg",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(2, 2),
					ImageColor3 = object:Animation(Color3.new(1, 0.25, 0.25), info3, {
						From = Color3.new(0.25, 0.25, 0.25)
					}),
					BackgroundTransparency = 1,
					Image = "rbxassetid://134657809787110"
				}),
				object:Create("ImageLabel")({
					Name = "Left",
					Image = "rbxassetid://135958450156694",
					BackgroundTransparency = 1,
					Position = object:Animation(UDim2.fromScale(0.5, 0.5), info, {
						From = UDim2.fromScale(-0.5, -0.5)
					}),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromScale(2, 2)
				}),
				object:Create("ImageLabel")({
					Name = "Right",
					Image = "rbxassetid://100349697664920",
					BackgroundTransparency = 1,
					Position = object:Animation(UDim2.fromScale(0.5, 0.5), info2, {
						From = UDim2.fromScale(1.5, -0.5)
					}),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromScale(2, 2)
				})
			}),
			object:Create("Frame")({
				Name = "TextHolder",
				Size = UDim2.fromScale(0.65, 0.9),
				object:Create("UIAspectRatioConstraint")({
					AspectRatio = 3.35
				}),
				BackgroundTransparency = 1,
				object:Create("TextLabel")({
					Size = UDim2.fromScale(15, 1),
					BackgroundTransparency = 1,
					Text = "In Combat",
					TextScaled = true,
					Font = Enum.Font.SourceSansSemibold,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = object:Animation(Color3.new(1, 0, 0), info3, {
						From = Color3.new(1, 1, 1)
					})
				})
			})
		}),
		object:Create("Frame")({
			Name = "BottomHolder",
			Position = UDim2.fromScale(0.05, 0.485),
			Size = UDim2.fromScale(1, 0.55),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.015, 0)
			}),
			object:Create("Frame")({
				Name = "IconHolder",
				Size = UDim2.fromScale(1, 0.8),
				Instance.new("UIAspectRatioConstraint"),
				BackgroundTransparency = 1,
				object:Create("ImageLabel")({
					Name = "Clock",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Image = "rbxassetid://120352136875263",
					ImageColor3 = Color3.new(1, 1, 1)
				})
			}),
			object:Create("Frame")({
				Name = "TextHolder",
				Size = UDim2.fromScale(0.2, 0.95),
				object:Create("UIAspectRatioConstraint")({
					AspectRatio = 1.5
				}),
				BackgroundTransparency = 1,
				object:Create("TextLabel")({
					Name = "Timer",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					TextScaled = true,
					Font = Enum.Font.SourceSansSemibold,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = Color3.new(1, 1, 1),
					Text = object:Do(function(callback)
						return Utility.formatTime(callback(p) or 200)
					end)
				})
			})
		}),
		object:Create("UICorner")({
			CornerRadius = UDim.new(1)
		})
	})
end