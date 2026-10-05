local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
require(ReplicatedStorage.Packages.faye)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
	ColorSequenceKeypoint.new(1, Color3.new(0.8, 0.8, 0.8))
})
return function(object, data)
	local value = object:Value(ColorSequence.new(Color3.new(1, 1, 1)))
	local info = object.Info(0.2)
	local v = nil
	local v2 = nil
	local v3

	if data.StrokeDisabled ~= true then
		v3 = object:Create("UIStroke")({
			Thickness = data.StrokeThickness or 1,
			Color = object:Animation(data.Color or Color3.new(1, 1, 1), info)
		})
	end

	if data.Text then
		v = object:Create("TextLabel")({
			Name = "1Txt",
			Size = UDim2.fromScale(2, 0.8),
			BackgroundTransparency = 1,
			Text = data.Text or "",
			TextXAlignment = data.Alignment or Enum.TextXAlignment.Center,
			Font = Enum.Font.SourceSansSemibold,
			TextColor3 = data.ContentColor or Color3.new(),
			TextStrokeTransparency = data.TextStrokeTransparency,
			TextScaled = true,
			function(instance)
				if typeof(data.Text) == "table" then
					instance.Size = UDim2.fromScale(0.55, 0.8)
					return
				end

				local function apply()
					local parent = instance.Parent

					if parent == nil or parent.AbsoluteSize.X <= 0 or parent.AbsoluteSize.Y <= 0 then
						return
					end

					local v4 = math.clamp(parent.AbsoluteSize.Y * instance.Size.Y.Scale, 1, 100)
					local textSize = TextService:GetTextSize(
						instance.Text,
						v4,
						instance.Font,
						Vector2.new(1000000, 1000000)
					)
					instance.Size = UDim2.fromScale((textSize.X + 2) / parent.AbsoluteSize.X, instance.Size.Y.Scale)
				end

				apply()

				if instance.Parent then
					object:Connect(instance.Parent:GetPropertyChangedSignal("AbsoluteSize"), apply)
				end
			end
		})
	end

	if data.Image then
		v2 = object:Create("ImageLabel")({
			Name = "2Img",
			Size = UDim2.fromScale(0.7, 0.7),
			AnchorPoint = Vector2.new(0.5, 0.5),
			object:Create("UIAspectRatioConstraint")({}),
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1),
			Image = data.Image or "",
			ImageColor3 = data.ContentColor or Color3.new()
		})
	end

	local v4 = object:Create("Frame")
	local size

	if data.TweenSizeOnEntry then
		size = object:Animation(UDim2.fromScale(1, 1), object.SpringInfo(0.25, 1, 0.5), {
			From = UDim2.fromScale(0.8, 0.8)
		})
	else
		size = UDim2.fromScale(1, 1)
	end

	return v4({
		Size = size,
		Name = data.Name,
		data.BgProperties,
		object:Create("TextButton")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			MouseEnter = function()
				value:Set(colorSequence)
			end,
			MouseLeave = function()
				value:Reset()
			end,
			MouseButton1Up = function(p)
				ScreenEffects.StrokeClick(p, data ~= nil and data.CornerRadius or UDim.new(1))

				if data ~= nil and data.Clicked then
					data.Clicked()
				end
			end
		}),
		BackgroundColor3 = object:Animation(data.Color or Color3.new(1, 1, 1), info),
		object:Create("UICorner")({
			CornerRadius = data ~= nil and data.CornerRadius or UDim.new(1)
		}),
		v3,
		object:Create("UIGradient")({
			Color = object:Animation(value, info),
			Rotation = data.GradientRotation or -90
		}),
		object:Create("Frame")({
			Name = "ContentHolder",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.Name,
				Padding = UDim.new(0.025, 0)
			}),
			v,
			v2
		})
	})
end