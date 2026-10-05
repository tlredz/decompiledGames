local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Refinement = require(ReplicatedStorage.CAM.Global.Refinement)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(1.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local color = Color3.new(1, 0.803922, 0.305882)
local color2 = Color3.fromRGB(85, 170, 255)
return function(object, p: number, p2: number, p3)
	return object:Create("Frame")({
		Name = "LevelTrack",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
		BackgroundTransparency = 0.3,
		object:Create("UICorner")({
			CornerRadius = UDim.new(0, 6)
		}),
		object:Create("UIStroke")({
			Color = Color3.new(1, 1, 1),
			Thickness = 1,
			Transparency = 0.82
		}),
		object:Create("Frame")({
			Name = "Slots",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -8, 1, -6),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0.008, 0)
			}),
			object:Iterate(Refinement.MaxLevel, function(layoutOrder: number, _, object2)
				local v

				if Refinement.MaxLevel <= layoutOrder then
					v = color
				else
					v = color2:Lerp(Color3.new(), 0.45):Lerp(color2, (layoutOrder - 1) / (Refinement.MaxLevel - 1))
				end

				local v2 = layoutOrder <= p
				local v3

				if p3 == nil then
					v3 = false
				else
					v3 = layoutOrder == p + 1
				end

				local v4

				if p3 == nil or not (p3.GreatBp > 0 and p + 1 < layoutOrder) then
					v4 = false
				else
					v4 = layoutOrder <= math.min(p + Refinement.GreatStep, Refinement.MaxLevel)
				end

				local v5 = v2 and p2 < layoutOrder
				local v6 = (layoutOrder - p2 - 1) * 0.11
				local v7 = object2:Create("Frame")
				local v8 = {
					Name = `Seg{layoutOrder}`,
					LayoutOrder = layoutOrder,
					Size = UDim2.fromScale(0.092, 1)
				}
				local backgroundColor

				if v2 then
					backgroundColor = v
				else
					backgroundColor = Color3.new()
				end

				v8.BackgroundColor3 = backgroundColor
				local backgroundTransparency

				if v5 then
					backgroundTransparency = object2:Animation(
						0,
						faye.Info(0.25, Enum.EasingStyle.Quad, nil, nil, nil, v6),
						{
							From = 1
						}
					)
				else
					backgroundTransparency = v2 and 0 or 0.55
				end

				v8.BackgroundTransparency = backgroundTransparency
				local v11 = object2:Create("UICorner")({
					CornerRadius = UDim.new(0, 3)
				})
				local v12

				if v2 then
					v12 = object2:Create("UIGradient")({
						Rotation = 90,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, v:Lerp(Color3.new(1, 1, 1), 0.3)),
							ColorSequenceKeypoint.new(1, v:Lerp(Color3.new(), 0.2))
						})
					})
				end

				local v13

				if v3 then
					v13 = object2:Create("Frame")({
						Name = "Ember",
						ZIndex = 2,
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = v,
						BackgroundTransparency = object2:Animation(0.15, info, {
							From = 1
						}),
						object2:Create("UICorner")({
							CornerRadius = UDim.new(0, 3)
						})
					})
				end

				local v14

				if v3 then
					v14 = object2:Create("UIStroke")({
						Color = v,
						Thickness = 1.5,
						Transparency = 0.25
					})
				elseif v4 then
					v14 = object2:Create("UIStroke")({
						Color = color,
						Thickness = 1,
						Transparency = 0.6
					})
				end

				local v15

				if v5 then
					v15 = object2:Create("UIScale")({
						Scale = object2:Animation(1, faye.SpringInfo(0.3, 1, 0.6, nil, nil, v6), {
							From = 0.3
						})
					})
				end

				v8[1], v8[2], v8[3], v8[4], v8[5] = v11, v12, v13, v14, v15
				return v7(v8)
			end)
		})
	})
end