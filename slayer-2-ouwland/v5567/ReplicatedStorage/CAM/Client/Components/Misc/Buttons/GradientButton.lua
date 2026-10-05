local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
require(ReplicatedStorage.Packages.faye)
return function(object, options)
	local v = options or {}
	local v2 = nil
	local value = object:Value(v.Properties ~= nil and v.Properties.Size or UDim2.fromScale(1, 1))
	local backgroundTransparency

	if v.Properties ~= nil then
		backgroundTransparency = v.Properties.BackgroundTransparency
		v.Properties.Size = nil
		v.Properties.BackgroundTransparency = nil
	end

	if v.Image == nil then
		if v.Text ~= nil then
			v2 = object:Create("TextLabel")({
				Size = v.TextBoxSize or UDim2.fromScale(0.9, 0.9),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Text = v.Text,
				TextXAlignment = v ~= nil and v.TextXAlignment or Enum.TextXAlignment.Left,
				Position = UDim2.fromScale(0.5, 0.5),
				TextScaled = true,
				TextTransparency = v.ContentTransparency,
				TextColor3 = v.ContentColor or Color3.new(1, 1, 1),
				Font = v.Font or Enum.Font.SourceSansSemibold,
				object:Create("UIStroke")({
					Thickness = 2,
					Transparency = 0.9
				})
			})
		end
	else
		v2 = object:Create("ImageLabel")({
			Size = UDim2.fromScale(0.95, 0.95),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = v.Image,
			Position = UDim2.fromScale(0.5, 0.5),
			object:Create("UIAspectRatioConstraint")({}),
			ImageTransparency = v.ContentTransparency,
			ImageColor3 = v.ContentColor or Color3.new(1, 1, 1)
		})
	end

	return object:Create("TextButton")({
		Size = object:Animation(value, v.TweenInfo or object.Info(0.2)),
		v.Properties,
		Name = "Button",
		BackgroundTransparency = 1,
		MouseEnter = function()
			value:Set(UDim2.fromScale(value.Initial.X.Scale * 1.1, value.Initial.Y.Scale * 1))
		end,
		MouseLeave = function()
			value:Reset()
		end,
		MouseButton1Click = function(p)
			if v.StrokeClick then
				ScreenEffects.StrokeClick(p, UDim.new(0.2))
			else
				ScreenEffects.CircleClick()
			end

			if v.Clicked ~= nil then
				v.Clicked()
			end
		end,
		object:Create("Frame")({
			Name = "BG",
			BackgroundTransparency = backgroundTransparency,
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			BackgroundColor3 = v.BgColor or Color3.new(1, 0, 0),
			object:Create("UICorner")({
				CornerRadius = v.CornerRadius or UDim.new(0.2)
			}),
			object:Create("UIGradient")({
				Rotation = v.GradientRotation or 100,
				Transparency = v.GradientTransparency or NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.7, 0.9),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			object:Create("Frame")({
				Name = "FG",
				Size = UDim2.new(1, -5, 1, -5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = v.FgColor or Color3.new(0, 0, 0),
				object:Create("UICorner")({
					CornerRadius = v.CornerRadius or UDim.new(0.2)
				}),
				BackgroundTransparency = 0.85,
				object:Create("UIGradient")({
					Rotation = 90,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1)
					})
				})
			}),
			v2
		})
	})
end