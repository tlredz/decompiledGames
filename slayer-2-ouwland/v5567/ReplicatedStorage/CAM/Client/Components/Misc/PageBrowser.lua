local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.25)
return function(maid, object, p, options)
	local v = options or {}

	if v.Keybinds ~= false then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function tabList()
			if typeof(p) == "table" and p.__type ~= nil then
				return p.Value
			end

			return p
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function keyOf(k: number, p2)
			if v.Key == nil then
				return k
			end

			return (v.Key(k, p2))
		end

		local function step(p2: number)
			if v.CanClick ~= nil and not v.CanClick() then
				return
			end

			local v2 = tabList() -- equivalent call inferred; original call site unknown
			local count = #v2

			if count == 0 then
				return
			end

			local v3 = nil

			for k, v5 in v2 do
				local v7 = keyOf(k, v5) -- equivalent call inferred; original call site unknown

				if not object:Compare(v7) then
					continue
				end

				v3 = k
				break
			end

			local v5 = v3 == nil and 1 or (v3 - 1 + p2) % count + 1
			local v7 = v2[v5]

			if v.Key ~= nil then
				v5 = v.Key(v5, v7)
			end

			object:Set(v5)
		end

		local function stepper(p2: number)
			return function(p3: string, flag: boolean)
				if p3 ~= "Down" or flag then
					return
				end

				step(p2)
			end
		end

		local v2 = 1
		maid:Add(InputHandler.ListenTo("Category_Next", function(p2: string, flag: boolean)
			if p2 ~= "Down" or flag then
				return
			end

			step(v2)
		end))
		local v3 = -1
		maid:Add(InputHandler.ListenTo("Category_Prev", function(p2: string, flag: boolean)
			if p2 ~= "Down" or flag then
				return
			end

			step(v3)
		end))
	end

	local v2

	if v.TabSize == nil then
		v2 = v.HugWidth == nil
	else
		v2 = false
	end

	local value = maid:Value(UDim2.fromOffset(0, 0))
	local value2 = maid:Value(UDim2.new(1.5, 14, 1, 14))
	local value3 = maid:Value(0)
	local v3 = {
		ViewWidth = 0,
		ContentWidth = 0
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyTab(p2)
		p2.Size:Set(UDim2.fromOffset(p2.Width or 0, value3:Get()))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyBackdrop()
		local v4

		if v.Overflow == true then
			v4 = v3.ContentWidth
		else
			v4 = math.min(v3.ContentWidth, v3.ViewWidth)
		end

		value2:Set(UDim2.new(0, v4 * 1.2 + 14, 1, 14))
	end

	local space = maid:Space(function(state)
		local last = object:Compare(state.Key) and 1 or state.In and 2 or 3

		if last ~= state.Last then
			state.Last = last

			if last == 1 then
				state.GradientEnabled:Set(false)
				state.TextColor3:Set(Color3.new())
				state.BgColor:Set(Color3.new(1, 1, 1))
				state.FooterTransparency:Set(0.5)
				state.BgTransparency:Set(0)
			elseif last == 2 then
				state.GradientEnabled:Reset()
				state.TextColor3:Reset()
				state.BgColor:Reset()
				state.FooterTransparency:Set(0.3)
				state.BgTransparency:Set(0.6)
			else
				state.GradientEnabled:Reset()
				state.TextColor3:Reset()
				state.BgColor:Reset()
				state.FooterTransparency:Reset()
				state.BgTransparency:Reset()
			end
		end
	end)
	space:Connect(object.Changed)
	local v4 = maid:Create("Frame")
	local v5 = {
		Name = "page Browser",
		Size = v.Size or UDim2.fromScale(0.1, 0.03),
		BackgroundTransparency = 1,
		Position = v.Position or UDim2.fromScale(0.1, 0.1),
		AnchorPoint = v.AnchorPoint
	}
	local v6 = maid:Create("Frame")
	local v7 = {
		Name = "Backdrop",
		Visible = v.Backdrop ~= false,
		ZIndex = -1
	}
	local anchorPoint

	if v2 then
		anchorPoint = Vector2.new(0, 0.5)
	else
		anchorPoint = Vector2.new(0.5, 0.5)
	end

	v7.AnchorPoint = anchorPoint
	local position

	if v2 then
		position = UDim2.new(0, -7, 0.5, 0)
	else
		position = UDim2.fromScale(0.75, 0.5)
	end

	v7.Position = position
	local size2

	if v2 then
		size2 = value2
	else
		size2 = UDim2.new(1.5, 14, 1, 14)
	end

	v7.Size = size2
	v7.BackgroundColor3 = Color3.new(0.45, 0.45, 0.45)
	v7.BackgroundTransparency = 0.5
	do local _values = table.pack(maid:Create("UIGradient")({
	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
}), maid:Create("UICorner")({
	CornerRadius = UDim.new(0.15)
})); for _k = 1, _values.n do v7[_k] = _values[_k] end end
	local v11 = v6(v7)
	local v12 = maid:Create(v2 and "ScrollingFrame" or "Frame")
	local v13 = {
		Name = "page Browser",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.new(1, 1, 1)
	}
	local canvasSize

	if v2 then
		canvasSize = value
	end

	v13.CanvasSize = canvasSize
	local scrollingDirection

	if v2 then
		scrollingDirection = Enum.ScrollingDirection.X
	end

	v13.ScrollingDirection = scrollingDirection
	v13.ScrollBarThickness = v2 and 0 or nil
	v13.ClipsDescendants = (not v2 or v.Overflow ~= true) and nil
	local elasticBehavior

	if v2 then
		elasticBehavior = Enum.ElasticBehavior.Never
	end

	v13.ElasticBehavior = elasticBehavior
	v13.AbsoluteSizeOnChangedInit = v2 and function(_, point: Vector2)
		v3.ViewWidth = point.X
		value3:Set(point.Y)
		applyBackdrop() -- equivalent call inferred; original call site unknown
	end or nil
	do local _values = table.pack(maid:Create("UIListLayout")({
	FillDirection = v.FillDirection or Enum.FillDirection.Horizontal,
	HorizontalAlignment = v.HorizontalAlignment or Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = v.Padding or UDim.new(0, 5),
	AbsoluteContentSizeOnChangedInit = v2 and function(_, point: Vector2)
		v3.ContentWidth = point.X
		value:Set(UDim2.fromOffset(point.X, point.Y))
		applyBackdrop() -- equivalent call inferred; original call site unknown
	end or nil
}), maid:Iterate(p, function(p2, p3, object2, _)
	local v18

	if v.Key == nil then
		v18 = p2
	else
		v18 = v.Key(p2, p3)
	end

	local v19 = {
		BgTransparency = object2:Value(0.9),
		BgColor = 0,
		FooterTransparency = 0,
		TextColor3 = 0,
		GradientEnabled = 0,
		Key = 0
	}
	local v20

	if typeof(v.IdleColor) == "function" then
		v20 = v.IdleColor(p2, p3)
	else
		v20 = v.IdleColor
	end

	v19.BgColor = object2:Value(v20 or Color3.new(1, 1, 1))
	v19.FooterTransparency = object2:Value(0.75)
	v19.TextColor3 = object2:Value(Color3.new(1, 1, 1))
	v19.GradientEnabled = object2:Value(true)
	v19.Key = v18
	local v21 = space:Add(v19, object2, true):Call()
	local name

	if v.Label == nil then
		name = p3.Name
	else
		name = v.Label(p2, p3)
	end

	local image

	if v.Icon ~= nil then
		image = v.Icon(p2, p3)
	end

	local v23

	if v.IconColor ~= nil then
		v23 = v.IconColor(p2, p3)
	end

	if v2 then
		v19.Size = object2:Value(UDim2.fromOffset(0, value3:Get()))
		object2:Reactive(function(callback)
			callback(value3)
			applyTab(v19) -- equivalent call inferred; original call site unknown
		end)
	end

	local hugWidth

	if v2 or image ~= nil then
		hugWidth = nil
	else
		hugWidth = v.HugWidth
	end

	local v24

	if v2 or hugWidth ~= nil then
		v24 = image == nil
	else
		v24 = false
	end

	local textXAlignment = v.TextXAlignment

	if not textXAlignment then
		if v24 then
			textXAlignment = Enum.TextXAlignment.Center
		else
			textXAlignment = Enum.TextXAlignment.Left
		end
	end

	if hugWidth ~= nil then
		v19.TextWidth = object2:Value(0)
	end

	local v25 = object2:Create("Frame")
	local size

	if v2 then
		size = v19.Size
	elseif hugWidth == nil then
		size = v.TabSize
	else
		size = object2:Do(function(callback)
			local v27 = callback(v19.TextWidth)
			local v28

			if hugWidth.Pad == nil then
				v28 = v27 * (hugWidth.Scale or 1)
			else
				v28 = v27 + hugWidth.Pad
			end

			return UDim2.fromOffset(math.ceil(v28), callback(hugWidth.Height))
		end)
	end

	local v26 = {
		Size = size,
		BackgroundTransparency = object2:Animation(v19.BgTransparency, info),
		BackgroundColor3 = object2:Animation(v19.BgColor, info)
	}
	local v27 = object2:Create("UICorner")({
		CornerRadius = UDim.new(0.15)
	})
	local v28 = object2:Create("UIGradient")({
		Enabled = v19.GradientEnabled,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }),
		Rotation = -90
	})
	local v29 = object2:Create("Frame")({
		Name = "Footer",
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.fromScale(0, 1),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = object2:Animation(v19.FooterTransparency, info)
	})
	local v30 = object2:Create("TextButton")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.05, 1.5),
		BackgroundTransparency = 1,
		MouseEnter = function()
			v19.In = true
			v21:Call()
		end,
		MouseLeave = function()
			v19.In = false
			v21:Call()
		end,
		MouseButton1Click = function(p4)
			if v.CanClick ~= nil and not v.CanClick() then
				return
			end

			ScreenEffects.StrokeClick(p4.Parent)

			if object:Compare(v18) then
				if v.ToggleOff ~= nil then
					object:Set(v.ToggleOff)
				end
			else
				object:Set(v18)
			end
		end
	})
	local v31 = object2:Create("Frame")
	local v32 = {
		Name = "Holder",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1
	}
	local v33

	if image ~= nil then
		v33 = object2:Create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4)
		}) or nil
	end

	local v34

	if image ~= nil then
		local v35 = object2:Create("ImageLabel")
		local v36 = {
			Name = "Icon",
			LayoutOrder = 1,
			Size = UDim2.fromScale(0.7, 0.7),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			Image = image,
			ImageColor3 = v23 or object2:Animation(v19.TextColor3, info)
		}
		local v37

		if v.IconShadow == true then
			v37 = object2:Create("UIShadow")({
				BlurRadius = UDim.new(1, 0),
				Transparency = 0.9,
				Offset = UDim2.fromScale(0.05, 0.05)
			}) or nil
		end

		v36[1] = v37
		v34 = v35(v36) or nil
	end

	local v35 = object2:Create("TextLabel")
	local automaticSize

	if image == nil then
		automaticSize = Enum.AutomaticSize.None
	else
		automaticSize = Enum.AutomaticSize.X
	end

	local uDim

	if image == nil then
		if v2 or hugWidth ~= nil then
			uDim = UDim2.fromScale(100, 0.7)
		else
			uDim = UDim2.new(1, -10, 0.7, 0)
		end
	else
		uDim = UDim2.fromScale(0, 0.7)
	end

	local vector

	if v24 and textXAlignment ~= Enum.TextXAlignment.Center then
		if textXAlignment == Enum.TextXAlignment.Left then
			vector = Vector2.new(0, 0.5)
		else
			vector = Vector2.new(1, 0.5)
		end
	else
		vector = Vector2.new(0.5, 0.5)
	end

	local uDim2

	if v24 and textXAlignment ~= Enum.TextXAlignment.Center then
		if textXAlignment == Enum.TextXAlignment.Left then
			uDim2 = UDim2.fromScale(0, 0.5)
		else
			uDim2 = UDim2.fromScale(1, 0.5)
		end
	else
		uDim2 = UDim2.fromScale(0.5, 0.5)
	end

	local v36 = {
		Name = "Txt",
		LayoutOrder = 2,
		AutomaticSize = automaticSize,
		Size = uDim,
		AnchorPoint = vector,
		Position = uDim2,
		BackgroundTransparency = 1,
		Font = Enum.Font.SourceSansBold,
		TextXAlignment = textXAlignment,
		TextScaled = true,
		TextColor3 = object2:Animation(v19.TextColor3, info),
		Text = name,
		TextBoundsOnChangedInit = 0
	}
	local textBoundsOnChangedInit

	if v2 and image == nil then
		textBoundsOnChangedInit = function(_, point: Vector2)
			v19.Width = point.X * 1.05 + (v.HugPad or 28)
			applyTab(v19) -- equivalent call inferred; original call site unknown
		end
	else
		textBoundsOnChangedInit = hugWidth ~= nil and function(_, point: Vector2)
			if point.X <= 0 then
				return
			end

			v19.TextWidth:Set(point.X / hugWidth.uiScale())
		end or nil
	end

	v36.TextBoundsOnChangedInit = textBoundsOnChangedInit
	do local _values = table.pack(v33, v34, v35(v36)); for _k = 1, _values.n do v32[_k] = _values[_k] end end
	do local _values = table.pack(v27, v28, v29, v30, v31(v32)); for _k = 1, _values.n do v26[_k] = _values[_k] end end
	return v25(v26)
end)); for _k = 1, _values.n do v13[_k] = _values[_k] end end
	do local _values = table.pack(v11, v12(v13)); for _k = 1, _values.n do v5[_k] = _values[_k] end end
	return v4(v5)
end