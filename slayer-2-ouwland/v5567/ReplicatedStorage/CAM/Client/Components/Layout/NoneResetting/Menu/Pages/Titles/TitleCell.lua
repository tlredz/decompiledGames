local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Titles = require(ReplicatedStorage.CAM.Global.Titles)
local TitleController = require(ReplicatedStorage.CAM.Client.Controllers.TitleController)
local Types = require(script.Parent.Types)
local vector = Vector2.new(16, 6)
local info = faye.Info(0.25, Enum.EasingStyle.Back)
local info2 = faye.Info(0.2)
local v = {
	Plate = 0.3,
	Shadow = 0.7,
	Content = 0
}
local v2 = {
	Plate = 0.7,
	Shadow = 0.95,
	Content = 0.5
}
return function(object, layoutOrder: number, data, data2)
	local value = Titles.GetColor(data.Id).Keypoints[1].Value
	local HSV, v3 = value:ToHSV()
	local color = Color3.fromHSV(HSV, v3, 0.3)
	local v4

	if data.Unlocked then
		v4 = v
	else
		v4 = v2
	end

	local v5 = {
		Id = data.Id,
		PlateColor = object:Value(color),
		ShadowColor = object:Value(value),
		PlateTransparency = object:Value(v4.Plate),
		ShadowTransparency = object:Value(v4.Shadow),
		ContentColor = object:Value(Color3.new(1, 1, 1)),
		ContentTransparency = object:Value(v4.Content)
	}
	data2.Space:Add(v5, object, true):Call()
	local value2 = object:Value(UDim2.fromOffset(0, 0))
	local size = object:Value(UDim2.fromOffset(0, 0))
	local size2 = object:Value(UDim2.fromOffset(0, 0))

	local function wornOf()
		local index = table.find(TitleController.Boost(), data.Id)
		return {
			Vanity = TitleController.Vanity() == data.Id,
			Boost = index
		}
	end

	local value5 = object:Value((wornOf()))
	object:Connect(TitleController.Updated, function()
		value5:Set((wornOf()))
	end)
	local v6 = object:Create("Frame")
	local v7 = {
		Name = data.Id,
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1
	}
	local v8 = object:Create("Frame")({
		Name = "Bg",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = object:Animation(value2, info),
		BackgroundColor3 = object:Animation(v5.PlateColor, info2),
		BackgroundTransparency = object:Animation(v5.PlateTransparency, info2),
		object:Create("UICorner")({
			CornerRadius = UDim.new(1, 0)
		}),
		object:Create("UIShadow")({
			BlurRadius = UDim.new(1),
			Color = object:Animation(v5.ShadowColor, info2),
			Transparency = object:Animation(v5.ShadowTransparency, info2)
		})
	})
	local state = object:State(function(callback, object2)
		local v9 = callback(value5)

		if not v9.Vanity and v9.Boost == nil then
			return
		end

		local value6 = object2:Value(0)

		local function height(callback2)
			return (math.floor(callback2(value2).Y.Offset * 0.8))
		end

		local v10 = object2:Create("Frame")
		local v11 = {
			Name = "SelectFrame",
			ZIndex = 3,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = object2:Do(function(callback2)
				return UDim2.new(0.5, math.floor(callback2(value2).X.Offset / 2) + 4, 0.5, 0)
			end),
			Size = object2:Do(function(callback2)
				return UDim2.fromOffset(callback2(value6), (math.floor(callback2(value2).Y.Offset * 0.8)))
			end),
			BackgroundTransparency = 1
		}
		local v12 = object2:Create("Frame")({
			Name = "TxtGradient",
			ZIndex = -1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.new(1, 10, 0.75, 0),
			BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
			BackgroundTransparency = 0.1,
			object2:Create("UIGradient")({
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) })
			})
		})
		local v13 = object2:Create("Frame")
		local v14 = {
			Name = "Row",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1
		}
		local v15 = object2:Create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
			AbsoluteContentSizeOnChangedInit = function(_, point: Vector2)
				value6:Set((math.ceil(point.X / data2.uiScale())))
			end
		})
		local v16

		if v9.Vanity then
			v16 = object2:Create("ImageLabel")({
				Name = "Vanity",
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1,
				Image = "rbxassetid://81079881410330"
			}) or nil
		end

		local v17 = object2:Create("Frame")({
			Name = "Check",
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			object2:Create("ImageLabel")({
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.8, 0.8),
				Image = "rbxassetid://116594504938394",
				ImageTransparency = 0.5,
				Name = "Square"
			}),
			object2:Create("ImageLabel")({
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://115228880374136",
				Name = "Checkmark"
			})
		})
		local v18

		if v9.Boost ~= nil then
			v18 = object2:Create("TextLabel")({
				Name = "Text",
				LayoutOrder = 3,
				TextSize = object2:Do(function(callback2)
					return (math.max(1, (math.floor(math.floor(callback2(value2).Y.Offset * 0.8) * 0.7))))
				end),
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Text = Types.BOOST_LABELS[v9.Boost] or tostring(v9.Boost),
				TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansSemibold
			}) or nil
		end

		v14[1], v14[2], v14[3], v14[4] = v15, v16, v17, v18
		do local _values = table.pack(v12, v13(v14)); for _k = 1, _values.n do v11[_k] = _values[_k] end end
		return v10(v11)
	end)
	local v9 = object:Create("TextButton")({
		Name = "Hitbox",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 5,
		BackgroundTransparency = 1,
		MouseButton1Click = function()
			ScreenEffects.CircleClick()
			data2.Equipped:Set(data2.Equipped:Compare(data.Id) and "" or data.Id)
		end
	})
	local v10 = object:Create("Frame")
	local v11 = {
		Name = "Name",
		Size = size2,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 2,
		BackgroundTransparency = 1
	}
	local v12 = object:Create("TextLabel")({
		Name = "TitleName",
		Size = size,
		ZIndex = 2,
		BackgroundTransparency = 1,
		Font = Enum.Font.SourceSansBold,
		Text = data.Name,
		TextColor3 = object:Animation(v5.ContentColor, info2),
		TextTransparency = object:Animation(v5.ContentTransparency, info2),
		TextSize = data2.TextSize,
		TextBoundsOnChangedInit = function(p2, point: Vector2)
			if point.X <= 0 or p2.TextSize <= 0 then
				return
			end

			local uiScale = data2.uiScale()
			local v13 = point.X / uiScale
			local v14 = point.Y / uiScale
			local v15

			if data.Unlocked then
				v15 = v13
			else
				v15 = v13 + data2.LockGap + v14
			end

			size:Set(UDim2.fromOffset(v13, v14))
			size2:Set(UDim2.fromOffset(v15, v14))
			value2:Set(UDim2.fromOffset(v15 + vector.X, v14 + vector.Y))
			data2.Measure(data.Id, point.X / p2.TextSize)
		end
	})
	local v13

	if not data.Unlocked then
		v13 = object:Create("ImageLabel")({
			Name = "Lock",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			ZIndex = 2,
			BackgroundTransparency = 1,
			Image = BunchaIcons.Locked,
			ImageColor3 = object:Animation(v5.ContentColor, info2),
			ImageTransparency = object:Animation(v5.ContentTransparency, info2)
		}) or nil
	end

	v11[1], v11[2] = v12, v13
	do local _values = table.pack(v8, state, v9, v10(v11)); for _k = 1, _values.n do v7[_k] = _values[_k] end end
	return v6(v7)
end