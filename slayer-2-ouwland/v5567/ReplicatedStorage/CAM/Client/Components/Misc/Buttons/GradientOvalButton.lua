local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local faye = require(ReplicatedStorage.Packages.faye)
local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0) })
local info = faye.Info(0.175)
return function(object, data)
	local value = object:Value(NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 0.75)
	}))
	local value2 = object:Value(NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 0.75)
	}))
	local v = nil
	local v2 = nil
	local contentColor = data.ContentColor or Color3.new(1, 1, 1)

	if data ~= nil and data.Text then
		v = object:Create("TextLabel")({
			Name = "2Txt",
			Size = UDim2.fromScale(2, 0.75),
			BackgroundTransparency = 1,
			Text = data.Text or "",
			TextXAlignment = data.Alignment or Enum.TextXAlignment.Center,
			Font = data and data.Font or Enum.Font.SourceSansSemibold,
			TextColor3 = contentColor,
			TextStrokeTransparency = data.TextStrokeTransparency,
			TextScaled = true,
			After = function(instance)
				if typeof(data.Text) == "table" then
					instance.Size = UDim2.fromScale(0.55, 0.8)
					return
				end

				local function apply()
					local parent = instance.Parent

					if parent == nil or parent.AbsoluteSize.X <= 0 or parent.AbsoluteSize.Y <= 0 then
						return
					end

					local v3 = math.clamp(parent.AbsoluteSize.Y * instance.Size.Y.Scale, 1, 100)
					local v4 = TextService:GetTextSize(instance.Text, v3, instance.Font, Vector2.new(1000000, 1000000)).X + 2

					if not data.FitWidth then
						local v5 = parent.AbsoluteSize.X - 6

						if v2 ~= nil then
							local scale = (data.ImageSize or UDim2.fromScale(0.7, 0.7)).Y.Scale
							v5 -= parent.AbsoluteSize.Y * scale + parent.AbsoluteSize.X * 0.025
						end

						v4 = math.min(v4, (math.max(v5, 1)))
					end

					instance.Size = UDim2.fromScale(v4 / parent.AbsoluteSize.X, instance.Size.Y.Scale)
				end

				apply()

				if instance.Parent then
					object:Connect(instance.Parent:GetPropertyChangedSignal("AbsoluteSize"), apply)
				end
			end
		})
	end

	if data ~= nil and data.Image then
		v2 = object:Create("ImageLabel")({
			Name = "1Img",
			Size = data and data.ImageSize or UDim2.fromScale(0.7, 0.7),
			AnchorPoint = Vector2.new(0.5, 0.5),
			object:Create("UIAspectRatioConstraint")({}),
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1),
			Image = data.Image or "",
			ImageColor3 = contentColor
		})
	end

	return object:Create("Frame")({
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
		BackgroundTransparency = 0.35,
		object:Create("UICorner")({
			CornerRadius = UDim.new(1)
		}),
		object:Create("UIGradient")({
			Rotation = 0,
			Transparency = object:Animation(value, info)
		}),
		object:Create("UIStroke")({
			BorderOffset = UDim.new(0, -3),
			object:Create("UIGradient")({
				Rotation = 0,
				Transparency = object:Animation(value2, info)
			}),
			Color = contentColor
		}),
		object:Create("TextButton")({
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			MouseEnter = function()
				value:Set(numberSequence)
				value2:Set(numberSequence)
			end,
			MouseLeave = function()
				value:Reset()
				value2:Reset()
			end,
			MouseButton1Up = function(p)
				ScreenEffects.StrokeClick(p, UDim.new(1))

				if data ~= nil and data.Clicked then
					data.Clicked()
				end
			end
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
				Padding = UDim.new(0.025, 0),
				[object:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p)
					if not data.FitWidth then
						return
					end

					local parent = p.Parent
					local parent2

					if parent ~= nil then
						parent2 = parent.Parent
					end

					local parent3

					if parent2 ~= nil then
						parent3 = parent2.Parent
					end

					if parent3 == nil or not parent3:IsA("GuiObject") or parent2 == nil then
						return
					end

					local v13 = p.AbsoluteContentSize.X + parent2.AbsoluteSize.Y * 0.35 * 2
					parent3.Size = UDim2.new(0, v13, parent3.Size.Y.Scale, parent3.Size.Y.Offset)
				end
			}),
			v,
			v2
		})
	})
end