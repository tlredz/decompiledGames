local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local RefineCeremony = require(script.Parent.RefineCeremony)
local info = faye.Info(0.22, Enum.EasingStyle.Quad)
local info2 = faye.Info(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1)
local info3 = faye.Info(RefineCeremony.CHARGE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local color = Color3.new(1, 0.803922, 0.305882)
local color2 = Color3.new(0.627451, 1, 0.466667)
local color3 = Color3.new(1, 0.35, 0.35)
return function(object, data, p, p2)
	local function band(zIndex: number, p4: number, p5: number?, color4: Color3)
		local v = not (p4 > 0) and 0 or math.max(p4, 0.05)

		if p5 ~= nil and p5 > 0 then
			p5 = math.max(p5, 0.05)
		end

		local v2 = object:Create("Frame")
		local v3 = {
			ZIndex = zIndex,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5)
		}
		local size

		if p5 == nil then
			size = UDim2.fromScale(v, 1)
		else
			size = object:Animation(UDim2.fromScale(v, 1), info, {
				From = UDim2.fromScale(p5, 1)
			})
		end

		v3.Size = size
		v3.BackgroundColor3 = color4
		do local _values = table.pack(object:Create("UICorner")({
	CornerRadius = UDim.new(1)
}), object:Create("UIGradient")({
	Rotation = 90,
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color4:Lerp(Color3.new(1, 1, 1), 0.35)),
		ColorSequenceKeypoint.new(1, color4:Lerp(Color3.new(), 0.15))
	})
})); for _k = 1, _values.n do v3[_k] = _values[_k] end end
		return v2(v3)
	end

	local v = data.FailBp / 10000
	local textColor

	if v >= 0.6 then
		textColor = color3
	elseif v >= 0.25 then
		textColor = color
	else
		textColor = color2
	end

	local v3

	if p ~= nil then
		v3 = p.SuccessBp / 10000
	end

	local v4

	if p ~= nil then
		v4 = (p.SuccessBp + p.GreatBp) / 10000
	end

	return object:Create("Frame")({
		Name = "OddsBar",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.05, 0)
		}),
		object:Create("Frame")({
			Name = "Headline",
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 0.4),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0.015, 0)
			}),
			object:Create("TextLabel")({
				Name = "Chance",
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.3, 1),
				BackgroundTransparency = 1,
				Text = `{data.SuccessBp / 100}%`,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				Font = Enum.Font.SourceSansBold,
				TextColor3 = textColor,
				object:Create("UIStroke")({
					Thickness = 1.5,
					Transparency = 0.3
				})
			}),
			object:Create("TextLabel")({
				Name = "Caption",
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.44, 0.62),
				BackgroundTransparency = 1,
				Text = "success chance",
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansSemibold,
				TextColor3 = Color3.new(1, 1, 1),
				TextTransparency = 0.2,
				object:Create("UIStroke")({
					Thickness = 1.5,
					Transparency = 0.35
				})
			})
		}),
		object:Create("Frame")({
			Name = "Strip",
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.9, 0.2),
			BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
			BackgroundTransparency = 0.25,
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			object:Create("UIStroke")({
				Color = Color3.new(1, 1, 1),
				Thickness = 1,
				Transparency = 0.8
			}),
			band(1, 1, nil, color3),
			band(2, (data.SuccessBp + data.GreatBp) / 10000, v4, color),
			band(3, data.SuccessBp / 10000, v3, color2),
			object:Create("Frame")({
				Name = "Sheen",
				ZIndex = 4,
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				object:Create("UIGradient")({
					Rotation = 18,
					Offset = object:Animation(Vector2.new(2.5, 0), info2, {
						From = Vector2.new(-1, 0)
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.36, 1),
						NumberSequenceKeypoint.new(0.5, 0.45),
						NumberSequenceKeypoint.new(0.64, 1),
						NumberSequenceKeypoint.new(1, 1)
					})
				})
			}),
			object:State(function(callback, object2)
				if callback(p2) then
					return object2:Create("Frame")({
						Name = "ChargeFill",
						ZIndex = 5,
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						Size = object2:Animation(UDim2.fromScale(1, 1), info3, {
							From = UDim2.fromScale(0, 1)
						}),
						BackgroundColor3 = color,
						BackgroundTransparency = 0.35,
						object2:Create("UICorner")({
							CornerRadius = UDim.new(1)
						})
					})
				end

				return nil
			end)
		}),
		object:Create("Frame")({
			Name = "Legend",
			LayoutOrder = 3,
			Size = UDim2.fromScale(0.9, 0.28),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0.02, 0)
			}),
			object:Iterate({
				{
					Label = "Success",
					Bp = data.SuccessBp,
					Color = color2
				},
				{
					Label = "Great",
					Bp = data.GreatBp,
					Color = color
				},
				{
					Label = "Fail",
					Bp = data.FailBp,
					Color = color3
				}
			}, function(layoutOrder: number, data2, object2)
				if data2.Bp <= 0 then
					return nil
				end

				return object2:Create("Frame")({
					LayoutOrder = layoutOrder,
					Size = UDim2.fromScale(0.28, 1),
					BackgroundTransparency = 1,
					object2:Create("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0.04, 0)
					}),
					object2:Create("TextLabel")({
						Name = "Label",
						LayoutOrder = 1,
						Size = UDim2.fromScale(0.5, 0.68),
						BackgroundTransparency = 1,
						Text = data2.Label,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Right,
						Font = Enum.Font.SourceSansSemibold,
						TextColor3 = Color3.new(1, 1, 1),
						TextTransparency = 0.25,
						object2:Create("UITextSizeConstraint")({
							MaxTextSize = 14
						}),
						object2:Create("UIStroke")({
							Thickness = 1.5,
							Transparency = 0.3
						})
					}),
					object2:Create("TextLabel")({
						Name = "Value",
						LayoutOrder = 2,
						Size = UDim2.fromScale(0.42, 1),
						BackgroundTransparency = 1,
						Text = `{data2.Bp / 100}%`,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						Font = Enum.Font.SourceSansBold,
						TextColor3 = data2.Color,
						object2:Create("UITextSizeConstraint")({
							MaxTextSize = 20
						}),
						object2:Create("UIStroke")({
							Thickness = 1.5,
							Transparency = 0.2
						})
					})
				})
			end)
		})
	})
end