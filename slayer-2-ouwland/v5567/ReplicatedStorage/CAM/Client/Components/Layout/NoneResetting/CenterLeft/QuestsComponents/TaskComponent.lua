local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local color = Color3.new(0.72, 0.72, 0.72)
return function(object, instance, callback, p, value: number?, value2: string?, p2: number)
	local transparency = object:Value(0.85)
	local color2 = object:Value(Color3.new())
	local backgroundTransparency = object:Value(1)
	local backgroundColor = object:Value(Color3.new(1, 1, 1))
	local uDim = object:Value(UDim2.fromScale(0.225, 0.225))
	local backgroundTransparency2 = object:Value(0.25)
	local backgroundColor2 = object:Value(Color3.new(1, 1, 1))
	local size = object:Value(UDim2.fromScale(0.2, 0.6))
	local position = object:Value(UDim2.fromScale(0.6, 0.55))
	local value11 = object:Value(Color3.new(1, 1, 1))
	local value12 = object:Value(0)
	local value13 = instance:FindFirstChild("Value")
	local max = instance:FindFirstChild("Max")
	local v

	if p == nil or p.Icon == nil then
		v = false
	else
		v = p.Icon ~= ""
	end

	local need = instance:FindFirstChild("Need")
	local child

	if not (need == nil or instance.Parent == nil) then
		child = instance.Parent:FindFirstChild(need.Value) or nil
	end

	local value14

	if child == nil then
		value14 = nil
	else
		value14 = child:FindFirstChild("Value") or nil
	end

	local max2

	if child == nil then
		max2 = nil
	else
		max2 = child:FindFirstChild("Max") or nil
	end

	local v2

	if value14 == nil then
		v2 = false
	else
		v2 = max2 ~= nil
	end

	local value15 = object:Value(v2 and value14.Value < max2.Value)

	if v2 then
		object:Reactive(function(callback2)
			value15:Set(callback2(value14) < callback2(max2))
		end)
	end

	local value16 = object:Value(value13.Value == max.Value)

	local function updState()
		if value16.Value == true then
			position:Set(UDim2.fromScale(0.5, 0.55))
			size:Set(UDim2.fromScale(0.2, 1))
			uDim = UDim2.fromScale(0.4, 0.4)
			backgroundTransparency:Set(0.5)
			transparency:Set(0.5)
			value12:Set(0.5)
			backgroundTransparency2:Set(0.85)
			color2:Set(Color3.new(0.4, 1, 0.4))
			backgroundColor:Set(color2.Value)
			value11:Set(color2.Value)
			backgroundColor2:Set(Color3.new())
		else
			position:Reset()
			size:Reset()
			backgroundTransparency:Reset()
			transparency:Reset()
			value12:Reset()
			backgroundTransparency2:Reset()
			color2:Reset()
			backgroundColor:Reset()
			value11:Reset()
			backgroundColor2:Reset()

			if value15.Value == true then
				value12:Set(0.35)
				backgroundColor:Set(color)
				color2:Set(color)
			end
		end
	end

	updState()
	value16.Changed:Connect(updState)
	value15.Changed:Connect(updState)
	local v3

	if type(value2) == "string" then
		v3 = value2 ~= ""
	else
		v3 = false
	end

	local v4 = v2 and `Do {need.Value} first` or nil
	local v5 = v3 or v4 ~= nil
	local v6 = p2 * 0.1724137931034483
	local v7 = v6 * 0.8

	local function hintShown(callback2)
		if callback2(value16) == true then
			return false
		end

		local v8 = v3

		if not v8 then
			if v4 == nil then
				return false
			else
				return callback2(value15) == true
			end
		end

		return v8
	end

	local v8 = object:Create("Frame")
	local v9 = {
		Size = object:Do(function(callback2)
			local v10

			if callback2(value16) == true then
				v10 = false
			else
				v10 = v3

				if not v10 then
					if v4 == nil then
						v10 = false
					else
						v10 = callback2(value15) == true
					end
				end
			end

			local v14

			if v10 then
				v14 = v6 + 2 + v7
			else
				v14 = v6
			end

			return UDim2.new(1, 0, 0, v14)
		end),
		BackgroundTransparency = 1,
		Name = instance.Name,
		LayoutOrder = object:Do(function(callback2)
			return (value or 0) + (callback2(value16) and -1000 or callback2(value15) and 1000 or 0)
		end)
	}
	local v10 = object:Create("Frame")({
		Name = "Bg",
		Size = UDim2.new(1, 0, 0, v6),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.75,
		object:Create("UIGradient")({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.3, 0.5),
				NumberSequenceKeypoint.new(1, 0.95)
			})
		}),
		object:Create("UICorner")({
			CornerRadius = UDim.new(1)
		})
	})
	local v11 = object:Create("Frame")
	local v12 = {
		Name = "Holder",
		Size = UDim2.new(1, 0, 0, v6)
	}
	local position2

	if v then
		position2 = UDim2.fromOffset(3, 0)
	else
		position2 = UDim2.new()
	end

	v12.Position = position2
	v12.BackgroundTransparency = 1
	do local _values = table.pack(object:Create("UIListLayout")({
	Name = "List",
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	FillDirection = Enum.FillDirection.Horizontal,
	[object:GetSignal("GetPropertyChangedSignal", "AbsoluteContentSize", true)] = function(p3)
		p3.Parent.Parent.Bg.Size = UDim2.new((p3.AbsoluteContentSize.X + 15) / p3.Parent.Parent.AbsoluteSize.X, 0, 0, 25)
	end
}), object:Create("TextLabel")({
	Name = "Txt",
	Size = UDim2.fromScale(2, 0.9),
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.fromScale(0, 0.5),
	Text = object:Do(function(callback2, _, _)
		local v16 = callback2(value13)
		value16:Set(v16 == max.Value)
		callback()
		return (`{instance.Name} {v16}/{max.Value}`)
	end),
	TextScaled = true,
	Font = Enum.Font.SourceSansSemibold,
	TextColor3 = value11,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTransparency = value12,
	object:Create("UIStroke")({
		Transparency = 0.75,
		Thickness = 2
	}),
	object:State(function(callback2, object2, _)
		if callback2(value16) then
			return object2:Create("Frame")({
				Size = UDim2.new(1, 6, 0, 1),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.55),
				BackgroundColor3 = Color3.new(0.75, 1, 0.75)
			})
		end
	end),
	TextBoundsOnChangedInit = function(state)
		if state.TextBounds.X > 0 then
			state.Size = UDim2.fromScale(state.TextBounds.X / state.Parent.Parent.AbsoluteSize.X, 1)
		end
	end
}), object:State(function(callback2, object2, _)
	if callback2(value15) and callback2(value16) ~= true then
		return object2:Create("ImageLabel")({
			Name = "Selector",
			Size = UDim2.fromScale(0.2, 0.8),
			Instance.new("UIAspectRatioConstraint"),
			ScaleType = Enum.ScaleType.Fit,
			BackgroundTransparency = 1,
			Image = BunchaIcons.Locked,
			ImageTransparency = value12,
			ImageColor3 = Color3.new(1, 1, 1)
		})
	end

	if v then
		return object2:Create("ImageLabel")({
			Name = "Selector",
			Size = UDim2.fromScale(0.2, 0.8),
			Instance.new("UIAspectRatioConstraint"),
			ScaleType = Enum.ScaleType.Fit,
			BackgroundTransparency = 1,
			Image = p.Icon,
			ImageTransparency = value12,
			ImageColor3 = value11,
			object2:State(function(callback3, object3, _)
				if callback3(value16) then
					return object3:Create("Frame")({
						Size = UDim2.new(1, 6, 0, 1),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.55),
						BackgroundColor3 = Color3.new(0.75, 1, 0.75)
					})
				end
			end)
		})
	end

	return object2:Create("Frame")({
		Name = "Selector",
		Size = size,
		Instance.new("UIAspectRatioConstraint"),
		BackgroundTransparency = 1,
		object2:Create("Frame")({
			Name = "Outer",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = position,
			Size = uDim,
			object2:Create("UICorner")({
				CornerRadius = UDim.new(0.2)
			}),
			Rotation = 45,
			BackgroundColor3 = backgroundColor2,
			BackgroundTransparency = backgroundTransparency2,
			object2:Create("UIStroke")({
				Color = color2,
				Transparency = transparency
			}),
			object2:Create("Frame")({
				Name = "Inner",
				BackgroundColor3 = backgroundColor,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.6, 0.6),
				BackgroundTransparency = backgroundTransparency,
				object2:Create("UICorner")({
					CornerRadius = UDim.new(0.2)
				})
			})
		})
	})
end)); for _k = 1, _values.n do v12[_k] = _values[_k] end end
	v9[1], v9[2], v9[3] = v10, v11(v12), function()
	if v5 then
		return object:Create("Frame")({
			Name = "Hint",
			Position = UDim2.new(0, 0, 0, v6 + 2),
			Size = UDim2.new(1, 0, 0, v7),
			BackgroundTransparency = 1,
			Visible = object:Do(hintShown),
			object:Create("Frame")({
				Name = "Bg",
				Size = UDim2.new(0, 40, 1, 0),
				BackgroundColor3 = Color3.new(),
				BackgroundTransparency = 0.65,
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				}),
				object:Create("TextLabel")({
					Name = "Txt",
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 6, 0.5, 0),
					Size = UDim2.new(100, 0, 1, -4),
					BackgroundTransparency = 1,
					Text = object:Do(function(callback2)
						if v4 == nil or callback2(value15) ~= true then
							return value2 or ""
						end

						return v4
					end),
					TextScaled = true,
					Font = Enum.Font.SourceSansItalic,
					TextColor3 = Color3.new(1, 1, 1),
					TextTransparency = 0.15,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextBoundsOnChangedInit = function(p3)
						if p3.TextBounds.X > 0 then
							p3.Parent.Size = UDim2.new(0, p3.TextBounds.X + 12, 1, 0)
						end
					end
				})
			})
		})
	end
end
	return v8(v9)
end