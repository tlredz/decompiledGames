local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local info2 = faye.Info(0.2)
local info3 = faye.Info(0.3)
local font = Font.fromEnum(Enum.Font.SourceSansBold)
local time = info3.Time
local color = Color3.new(1, 1, 1)
return function(animator, data)
	local text = data.Text
	local color2 = data.Color
	local font2 = data.Font or font
	local stroke = data.Stroke
	local tracking = data.Tracking
	local info4 = data.Info or info
	local count = #data.Template

	local function labelSize(value: string)
		return UDim2.new(0, 1000, string.match(value, "%a") == nil and 1 or 1.35, 0)
	end

	local function addGradient(parent)
		if stroke == nil or stroke.Gradient == nil then
			return
		end

		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = stroke.Gradient.Rotation or 0
		uIGradient.Transparency = stroke.Gradient.Transparency
		uIGradient.Parent = parent
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function colorNow()
		if color2 == nil then
			return color
		end

		return (color2:Get())
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function strokeColorNow()
		if stroke == nil then
			return color
		end

		if stroke.Color ~= nil then
			return (stroke.Color:Get())
		end

		if color2 == nil then
			return color
		end

		return (color2:Get())
	end

	local v = {}
	local v2 = {}
	local v3 = {}
	local v4 = {}
	local v5 = {}
	local uIStrokes = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rawOf(instance)
		if instance == nil then
			return nil
		end

		return typeof(instance) == "Instance" and instance or instance.Instance
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function measure(p: number, point: Vector2)
		if point.X <= 0 then
			return
		end

		local v6

		if tracking == nil then
			v6 = point.Y * 0.17
		else
			v6 = tracking
		end

		v3[p]:Set(UDim2.new(0, point.X + v6, 1, 0))
	end

	local function makeLabel(parent, p: number, text2: string)
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Value"
		textLabel.AnchorPoint = Vector2.new(0.5, 1)
		textLabel.Size = UDim2.new(0, 1000, string.match(text2, "%a") == nil and 1 or 1.35, 0)
		textLabel.Position = UDim2.fromScale(0.5, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextScaled = true
		textLabel.TextXAlignment = Enum.TextXAlignment.Center
		textLabel.TextYAlignment = Enum.TextYAlignment.Bottom
		textLabel.FontFace = font2
		local textColor = colorNow() -- equivalent call inferred; original call site unknown
		textLabel.TextColor3 = textColor
		textLabel.Text = text2

		if stroke ~= nil then
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Thickness = stroke.Thickness
			local color3 = strokeColorNow() -- equivalent call inferred; original call site unknown
			uIStroke.Color = color3
			uIStroke.Transparency = stroke.Transparency or 0

			if stroke ~= nil and stroke.Gradient ~= nil then
				local uIGradient = Instance.new("UIGradient")
				uIGradient.Rotation = stroke.Gradient.Rotation or 0
				uIGradient.Transparency = stroke.Gradient.Transparency
				uIGradient.Parent = uIStroke
			end

			uIStroke.Parent = textLabel
		end

		textLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
			if v5[p] == textLabel then
				measure(p, textLabel.TextBounds) -- equivalent call inferred; original call site unknown
			end
		end)
		textLabel.Parent = parent
		measure(p, textLabel.TextBounds) -- equivalent call inferred; original call site unknown
		return textLabel
	end

	local function setChar(i: number, text2: string)
		local parent = rawOf(v2[i]) -- equivalent call inferred; original call site unknown

		if not (parent ~= nil and v4[i] ~= text2) then
			return
		end

		v4[i] = text2
		local v9 = rawOf(v5[i]) -- equivalent call inferred; original call site unknown
		local label = makeLabel(parent, i, text2)
		v5[i] = label
		uIStrokes[i] = label:FindFirstChildOfClass("UIStroke")

		if v9 == nil then
			label.Position = UDim2.fromScale(0.5, 1)
			return
		end

		animator:LoadAnimation(v9, {
			Position = UDim2.fromScale(0.5, 2)
		}, info4):Play()
		task.delay(info4.Time + 0.05, v9.Destroy, v9)
		animator:LoadAnimation(label, {
			Position = UDim2.fromScale(0.5, 1)
		}, info4):Play()
	end

	local function render()
		local v6 = tostring(text:Get() or "")
		local v7 = count - #v6

		for i = 1, count do
			local v9 = rawOf(v[i]) -- equivalent call inferred; original call site unknown

			if v9 == nil then
				continue
			end

			local v10 = i - v7

			if v10 < 1 then
				v9.Visible = false
				v4[i] = nil
			else
				v9.Visible = true
				setChar(i, string.sub(v6, v10, v10))
			end
		end
	end

	if color2 ~= nil then
		animator:Connect(color2.Changed, function()
			local v6 = colorNow() -- equivalent call inferred; original call site unknown

			for k, v7 in v5 do
				local animator2 = animator
				local v8 = rawOf(v7) -- equivalent call inferred; original call site unknown
				animator2:LoadAnimation(v8, {
					TextColor3 = v6
				}, info2):Play()

				if not (stroke ~= nil and stroke.Color == nil and uIStrokes[k] ~= nil) then
					continue
				end

				local animator3 = animator
				local v10 = rawOf(uIStrokes[k]) -- equivalent call inferred; original call site unknown
				animator3:LoadAnimation(v10, {
					Color = v6
				}, info2):Play()
			end
		end)
	end

	if stroke ~= nil and stroke.Color ~= nil then
		animator:Connect(stroke.Color.Changed, function()
			local color3 = strokeColorNow() -- equivalent call inferred; original call site unknown

			for _, v7 in uIStrokes do
				local animator2 = animator
				local v8 = rawOf(v7) -- equivalent call inferred; original call site unknown
				animator2:LoadAnimation(v8, {
					Color = color3
				}, info2):Play()
			end
		end)
	end

	local v6 = tostring(text:Get() or "")
	local v7 = count - #v6
	local parent2 = animator:Create("Frame")({
		Name = "FlipDigits",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	})
	local instancePropertySync = animator:InstancePropertySync(parent2, "AbsoluteSize")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function scaleOf(callback)
		return (math.max(1, callback(instancePropertySync).Y / 100))
	end

	animator:Create("Frame")({
		Name = "Row",
		Parent = parent2,
		CleanDelay = time,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = animator:Do(function(callback)
			local v9 = scaleOf(callback) -- equivalent call inferred; original call site unknown
			return UDim2.fromScale(1 / v9, 1 / v9)
		end),
		BackgroundTransparency = 1,
		animator:Create("UIScale")({
			Scale = animator:Do(scaleOf)
		}),
		animator:Create("UIListLayout")({
			HorizontalAlignment = data.Alignment or Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, data.Padding or 0)
		}),
		animator:Iterate(string.split(data.Template, ""), function(layoutOrder: number, _: string, object)
			v3[layoutOrder] = object:Value(UDim2.new(0, 0, 1, 0))
			local v9 = layoutOrder - v7
			local text2

			if v9 >= 1 then
				text2 = string.sub(v6, v9, v9)
			end

			local v11

			if not (text2 == nil or text2 == "") then
				local v12 = object:Create("TextLabel")
				local v13 = {
					Name = "Value",
					AnchorPoint = Vector2.new(0.5, 1),
					CleanDelay = time,
					Position = UDim2.fromScale(0.5, 1),
					Size = UDim2.new(0, 1000, string.match(text2, "%a") == nil and 1 or 1.35, 0),
					BackgroundTransparency = 1,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					TextTransparency = object:Animation(0, info3, {
						From = 1
					}),
					FontFace = font2
				}
				local textColor = colorNow() -- equivalent call inferred; original call site unknown
				v13.TextColor3 = textColor
				v13.Text = text2

				function v13.TextBoundsOnChangedInit(_, point: Vector2)
					measure(layoutOrder, point) -- equivalent call inferred; original call site unknown
				end

				local v15

				if stroke ~= nil then
					local v16 = object:Create("UIStroke")
					local v17 = {
						Thickness = stroke.Thickness
					}
					local color3 = strokeColorNow() -- equivalent call inferred; original call site unknown
					v17.Color = color3
					v17.Transparency = object:Animation(stroke.Transparency or 0, info3, {
						From = 1
					})
					local v19

					if stroke.Gradient ~= nil then
						v19 = object:Create("UIGradient")({
							Rotation = stroke.Gradient.Rotation or 0,
							Transparency = stroke.Gradient.Transparency
						})
					end

					v17[1] = v19
					v15 = v16(v17)
				end

				v13[1] = v15
				v11 = v12(v13)
			end

			if v11 ~= nil then
				v4[layoutOrder] = text2
				v5[layoutOrder] = v11
				local v12 = uIStrokes
				local v13

				if stroke ~= nil then
					v13 = v11.Instance:FindFirstChildOfClass("UIStroke")
				end

				v12[layoutOrder] = v13
			end

			local v12 = object:Create("Frame")({
				Name = "Box",
				CleanDelay = time,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.6666666666666666, 0.7692307692307692),
				BackgroundTransparency = 1,
				v11
			})
			local v13 = object:Create("Frame")({
				Name = `Slot{layoutOrder}`,
				CleanDelay = time,
				LayoutOrder = layoutOrder,
				Size = object:Lerp(v3[layoutOrder], 0.35),
				BackgroundTransparency = 1,
				Visible = v9 >= 1,
				object:Create("Frame")({
					Name = "Clip",
					CleanDelay = time,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1.5, 1.3),
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					v12
				})
			})
			v[layoutOrder] = v13
			v2[layoutOrder] = v12
			return v13
		end)
	})
	render()
	animator:Connect(text.Changed, render)
	return parent2
end