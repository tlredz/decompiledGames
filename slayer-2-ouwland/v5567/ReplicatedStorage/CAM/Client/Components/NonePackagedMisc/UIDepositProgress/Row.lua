local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
local interfaceutility = require(ReplicatedStorage.Packages.interfaceutility)
local info = faye.Info(0.3)
local info2 = faye.Info(0.2)
local info3 = faye.Info(0.2)
local color = Color3.new(1, 1, 1)
return function(object, layoutOrder: number, data, p2: number)
	local lvlColor = gameSettings.lvlColor
	local color2 = Color3.fromRGB(150, 150, 155)
	local HSV, v, v2 = lvlColor:ToHSV()
	local color3 = Color3.fromHSV(HSV, v * 0.35, v2 * 0.75)
	local visible = object:Value(false)
	local text = object:Value("")
	local value3 = object:Value(UDim2.fromScale(0, 0.45))
	local color4 = object:Value(lvlColor)
	local value5 = object:Value(color)
	local value6 = object:Value(color)
	object:Reactive(function(callback)
		local v3 = callback(data.Value)
		local v4 = callback(data.Max)
		local v5 = v4 <= v3
		local v7

		if v5 then
			v7 = `(Complete) {v3} / {v4}`
		else
			v7 = `{v3} / {v4}`
		end

		text:Set(v7)
		value3:Set(UDim2.fromScale(not (v4 > 0) and 0 or math.clamp(v3 / v4, 0, 1), 0.45))
		local v9

		if v5 then
			v9 = color3
		else
			v9 = lvlColor
		end

		color4:Set(v9)
		local v11

		if v5 then
			v11 = color2
		else
			v11 = color
		end

		value5:Set(v11)
		local v13

		if v5 then
			v13 = color2
		else
			v13 = color
		end

		value6:Set(v13)
		visible:Set(v5)
	end)
	return object:Create("Frame")({
		Name = `Row{layoutOrder}`,
		LayoutOrder = layoutOrder,
		Size = UDim2.fromScale(1, p2),
		BackgroundTransparency = 1,
		CleanDelay = info.Time,
		object:Create("Frame")({
			Size = UDim2.new(1, -4, 1, -4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			object:Create("UICorner")({
				CornerRadius = UDim.new(0.25)
			}),
			BackgroundColor3 = Color3.new(0.125, 0.125, 0.125),
			BackgroundTransparency = 0.25,
			object:Create("UIGradient")({
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 0.4)
				}),
				Rotation = 180
			}),
			object:Create("UIStroke")({
				BorderOffset = UDim.new(0, -4),
				Color = Color3.new(1, 1, 1),
				Transparency = 0.75,
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 0.7)
					})
				})
			}),
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal
			}),
			object:Create("ImageLabel")({
				Name = "AImage",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 5, 0.5, 0),
				Instance.new("UIAspectRatioConstraint"),
				Size = UDim2.fromScale(0.13, 1),
				BackgroundTransparency = 1,
				ImageColor3 = object:Animation(value6, info3),
				Image = Items[data.Item] == nil and "" or Items[data.Item].Icon or "",
				object:Create("UIShadow")({
					BlurRadius = UDim.new(0.5),
					Spread = UDim2.fromScale(-0.6, -0.6),
					Color = Color3.new(1, 1, 1)
				})
			}),
			object:Create("Frame")({
				Name = "BarHolder",
				Size = UDim2.fromScale(0.87, 0.8),
				object:Create("UICorner")({
					CornerRadius = UDim.new(0.15)
				}),
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.5),
						NumberSequenceKeypoint.new(0.3, 0.9),
						NumberSequenceKeypoint.new(1, 1)
					}),
					Rotation = -90
				}),
				object:Create("Frame")({
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.fromScale(1, 0),
					Size = UDim2.fromScale(1, 0.625),
					BackgroundTransparency = 1,
					Name = "TextHolder",
					object:Create("Frame")({
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.58),
						Size = UDim2.new(1, 8, 0, 2),
						ZIndex = 2,
						BackgroundTransparency = 0.25,
						Visible = visible
					}),
					object:Create("TextLabel")({
						Size = UDim2.fromScale(100, 1),
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.fromScale(1, 0),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Right,
						TextColor3 = object:Animation(value5, info3),
						Text = text,
						TextScaled = true,
						Font = Enum.Font.SourceSansBold,
						TextBoundsOnChangedInit = function(p3)
							local parent = p3.Parent
							local absoluteSize = interfaceutility.GetAbsoluteSize(parent.Parent)

							if absoluteSize.X <= 0 then
								return
							end

							local offsetTextSize = interfaceutility.GetOffsetTextSize(p3)
							parent.Size = UDim2.fromScale(math.min(offsetTextSize / absoluteSize.X, 1), 0.625)
						end,
						object:Create("UIStroke")({
							Thickness = 2,
							Color = color4,
							object:Create("UIGradient")({
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0.7),
									NumberSequenceKeypoint.new(0.4, 0.95),
									NumberSequenceKeypoint.new(1, 1)
								}),
								Rotation = -90
							})
						})
					})
				}),
				object:Create("Frame")({
					Name = "FillHolder",
					Size = UDim2.new(1, -4, 1, -4),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					object:Create("Frame")({
						Name = "Fill",
						Size = object:Animation(value3, info2),
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.fromScale(0, 1),
						BackgroundColor3 = object:Animation(color4, info3),
						object:Create("UIGradient")({
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(0.3, 0),
								NumberSequenceKeypoint.new(1, 1)
							}),
							Rotation = -90
						})
					})
				})
			})
		})
	})
end