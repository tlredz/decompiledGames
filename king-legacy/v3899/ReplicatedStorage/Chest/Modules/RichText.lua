local RichText = {}
local v = {
	Color = "TextColor3",
	StrokeColor = "TextStrokeColor3",
	ImageColor = "ImageColor3"
}
RichText.ColorShortcuts = {}
RichText.ColorShortcuts.White = Color3.new(1, 1, 1)
RichText.ColorShortcuts.Black = Color3.new(0, 0, 0)
RichText.ColorShortcuts.Red = Color3.new(1, 0.4, 0.4)
RichText.ColorShortcuts.Green = Color3.new(0.4, 1, 0.4)
RichText.ColorShortcuts.Blue = Color3.new(0, 0.333333, 1)
RichText.ColorShortcuts.Cyan = Color3.new(0.4, 0.85, 1)
RichText.ColorShortcuts.Orange = Color3.new(1, 0.5, 0.2)
RichText.ColorShortcuts.Yellow = Color3.new(1, 0.9, 0.2)
RichText.ColorShortcuts.Pink = Color3.new(1, 0, 1)
RichText.ColorShortcuts.Purple = Color3.new(0.666667, 0.333333, 1)
RichText.ColorShortcuts.Gray = Color3.new(0.74902, 0.74902, 0.74902)
RichText.ImageShortcuts = {}
RichText.ImageShortcuts.Eggplant = 639588687
RichText.ImageShortcuts.Thinking = 955646496
RichText.ImageShortcuts.Sad = 947900188
RichText.ImageShortcuts.Happy = 414889555
RichText.ImageShortcuts.Despicable = 711674643
local v2 = {
	ContainerHorizontalAlignment = "Left",
	ContainerVerticalAlignment = "Center",
	TextYAlignment = "Bottom",
	TextScaled = true,
	TextScaleRelativeTo = "Frame",
	TextScale = 0.25,
	TextSize = 20,
	Font = "SourceSans",
	TextColor3 = "White",
	TextStrokeColor3 = "Black",
	TextTransparency = 0,
	TextStrokeTransparency = 1,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ImageColor3 = "White",
	ImageTransparency = 0,
	ImageRectOffset = "0,0",
	ImageRectSize = "0,0",
	AnimateStepTime = 0,
	AnimateStepGrouping = "Letter",
	AnimateStepFrequency = 4,
	AnimateYield = 0,
	AnimateStyle = "Appear",
	AnimateStyleTime = 0.5,
	AnimateStyleNumPeriods = 3,
	AnimateStyleAmplitude = 0.5
}
local v3 = {
	Appear = function(p)
		p.Visible = true
	end,
	Fade = function(guiObject, p, p2)
		guiObject.Visible = true

		if guiObject:IsA("TextLabel") then
			guiObject.TextTransparency = 1 - p * (1 - p2.TextTransparency)
		elseif guiObject:IsA("ImageLabel") then
			guiObject.ImageTransparency = 1 - p * (1 - p2.ImageTransparency)
		end
	end,
	DarkGlitch = function(p, p2, p3)
		p.Visible = true
		local v4 = math.random(-p3.InitialSize.X.Offset * 1.3, p3.InitialSize.X.Offset * 1.3)
		local v5 = math.random(-p3.InitialSize.Y.Offset * 1.3, p3.InitialSize.Y.Offset * 1.3)
		p.Position = p3.InitialPosition + UDim2.new(0, v4 * (1 - p2), 0, v5 * (1 - p2))
		p.TextColor3 = Color3.fromRGB(255, 255, 255):Lerp(Color3.fromRGB(126, 0, 0), p2)
	end,
	CrazyGlitch = function(p, p2, p3)
		p.Visible = true
		local v4 = math.random(-p3.InitialSize.X.Offset * 2.5, p3.InitialSize.X.Offset * 2.5)
		local v5 = math.random(-p3.InitialSize.Y.Offset * 2.5, p3.InitialSize.Y.Offset * 2.5)
		p.Position = p3.InitialPosition + UDim2.new(0, v4 * (1 - p2), 0, v5 * (1 - p2))
	end,
	Glitch = function(p, p2, p3)
		p.Visible = true
		local v4 = math.random(-p3.InitialSize.X.Offset, p3.InitialSize.X.Offset)
		local v5 = math.random(-p3.InitialSize.Y.Offset, p3.InitialSize.Y.Offset)
		p.Position = p3.InitialPosition + UDim2.new(0, v4 * (1 - p2), 0, v5 * (1 - p2))
	end,
	Wiggle = function(p, p2, data)
		p.Visible = true
		local v4 = data.InitialSize.Y.Offset * (1 - p2) * data.AnimateStyleAmplitude
		p.Position = data.InitialPosition + UDim2.new(
			0,
			0,
			0,
			math.sin(p2 * 3.141592653589793 * 2 * data.AnimateStyleNumPeriods) * v4 / 2
		)
	end,
	Swing = function(p, p2, p3)
		p.Visible = true
		local v4 = 90 * (1 - p2) * p3.AnimateStyleAmplitude
		p.Rotation = math.sin(p2 * 3.141592653589793 * 2 * p3.AnimateStyleNumPeriods) * v4
	end,
	Spin = function(p, p2, data)
		p.Visible = true
		p.Position = data.InitialPosition + UDim2.new(
			0,
			data.InitialSize.X.Offset / 2,
			0,
			data.InitialSize.Y.Offset / 2
		)
		p.AnchorPoint = Vector2.new(0.5, 0.5)
		p.Rotation = p2 * data.AnimateStyleNumPeriods * 360
	end,
	Rainbow = function(label, p, data)
		label.Visible = true
		local color = Color3.fromHSV(p * data.AnimateStyleNumPeriods % 1, 1, 1)

		if label:IsA("TextLabel") then
			local colorFromString = getColorFromString(data.TextColor3)
			label.TextColor3 = Color3.new(
				color.r + p * (colorFromString.r - color.r),
				color.g + p * (colorFromString.g - color.g),
				color.b + p * (colorFromString.b - color.b)
			)
		else
			local colorFromString = getColorFromString(data.ImageColor3)
			label.ImageColor3 = Color3.new(
				color.r + p * (colorFromString.r - color.r),
				color.g + p * (colorFromString.g - color.g),
				color.b + p * (colorFromString.b - color.b)
			)
		end
	end
}
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local count = 0

function getLayerCollector(layerCollector)
	if not layerCollector then
		return nil
	end

	if layerCollector:IsA("LayerCollector") then
		return layerCollector
	end

	if layerCollector and layerCollector.Parent then
		return getLayerCollector(layerCollector.Parent)
	end

	return nil
end

function shallowCopy(items)
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

function getColorFromString(value)
	if RichText.ColorShortcuts[value] then
		return RichText.ColorShortcuts[value]
	end

	local match, v4, v5 = value:match("(%d+),(%d+),(%d+)")
	return Color3.new(match / 255, v4 / 255, v5 / 255)
end

function getVector2FromString(value)
	local match, v4 = value:match("(%d+),(%d+)")
	return Vector2.new(match, v4)
end

function setHorizontalAlignment(p, p2)
	if p2 == "Left" then
		p.AnchorPoint = Vector2.new(0, 0)
		p.Position = UDim2.new(0, 0, 0, 0)
	elseif p2 == "Center" then
		p.AnchorPoint = Vector2.new(0.5, 0)
		p.Position = UDim2.new(0.5, 0, 0, 0)
	elseif p2 == "Right" then
		p.AnchorPoint = Vector2.new(1, 0)
		p.Position = UDim2.new(1, 0, 0, 0)
	end
end

function RichText:New(parent, text, startingProperties, p, state)
	for _, child in pairs(parent:GetChildren()) do
		child:Destroy()
	end

	local v4 = p == nil or p
	local overflowPickupProperties = {}
	local v5 = {}

	if state then
		text = state.Text
		startingProperties = state.StartingProperties
	end

	local v6 = {}
	local v7 = {}
	local copiesByData = {}
	local total = 0
	local flag = false
	local textLabel = Instance.new("TextLabel")
	local imageLabel = Instance.new("ImageLabel")
	local layerCollector = getLayerCollector(parent)
	textLabel.AutoLocalize = false
	local applyProperty
	local printText
	local printImage

	local function applyMarkup(p2, p3)
		local v8 = v[p2] or p2

		if p3 == "/" then
			if v5[v8] then
				p3 = v5[v8]
			else
				warn("Attempt to default <" .. v8 .. "> to value with no default")
			end
		end

		if tonumber(p3) then
			p3 = tonumber(p3)
		elseif p3 == "false" or p3 == "true" then
			p3 = p3 == "true"
		end

		overflowPickupProperties[v8] = p3

		if applyProperty(v8, p3) then
			return true
		end

		if v8 == "ContainerHorizontalAlignment" and v6[#v6] then
			setHorizontalAlignment(v6[#v6].Container, p3)
		elseif not v2[v8] then
			if v8 ~= "Img" then
				return false
			end

			printImage(p3)
		end

		return true
	end

	applyProperty = function(p2, p3, p4)
		local typeName = nil
		local v8 = false

		for _, v9 in pairs(p4 and { p4 } or { textLabel, imageLabel }) do
			local v10 = v9

			if not pcall(function()
				typeName = typeof(v10[p2])
			end) then
				continue
			end

			if typeName == "Color3" then
				v9[p2] = getColorFromString(p3)
			elseif typeName == "Vector2" then
				v9[p2] = getVector2FromString(p3)
			else
				v9[p2] = p3
			end

			v8 = true
		end

		return v8
	end

	for k, v8 in pairs(v2) do
		applyMarkup(k, v8)
		v5[v[k] or k] = overflowPickupProperties[v[k] or k]
	end

	for k, v8 in pairs(startingProperties or {}) do
		applyMarkup(k, v8)
		v5[v[k] or k] = overflowPickupProperties[v[k] or k]
	end

	if state then
		overflowPickupProperties = state.OverflowPickupProperties

		for k, overflowPickupProperty in pairs(overflowPickupProperties) do
			applyMarkup(k, overflowPickupProperty)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getTextSize()
		if overflowPickupProperties.TextScaled ~= true then
			return overflowPickupProperties.TextSize
		end

		local Y = nil

		if overflowPickupProperties.TextScaleRelativeTo == "Screen" then
			Y = layerCollector.AbsoluteSize.Y
		elseif overflowPickupProperties.TextScaleRelativeTo == "Frame" then
			Y = parent.AbsoluteSize.Y
		end

		return (math.min(overflowPickupProperties.TextScale * Y, 100))
	end

	local total2 = 0

	local function newLine()
		local v8 = v6[#v6]

		if v8 then
			total2 += v8.Size.Y.Offset

			if not v4 then
				local v9 = total2
				local textSize = getTextSize() -- equivalent call inferred; original call site unknown

				if v9 + textSize > parent.AbsoluteSize.Y then
					flag = true
					return
				end
			end
		end

		local frame = Instance.new("Frame")
		frame.Name = string.format("Line%03d", #v6 + 1)
		frame.Size = UDim2.new(0, 0, 0, 0)
		frame.BackgroundTransparency = 1
		local frame2 = Instance.new("Frame", frame)
		frame2.Name = "Container"
		frame2.Size = UDim2.new(0, 0, 0, 0)
		frame2.BackgroundTransparency = 1
		setHorizontalAlignment(frame2, overflowPickupProperties.ContainerHorizontalAlignment)
		frame.Parent = parent
		table.insert(v6, frame)
		v7[#v6] = {}
		total = 0
	end

	newLine()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addFrameProperties(data)
		copiesByData[data] = shallowCopy(overflowPickupProperties)
		copiesByData[data].InitialSize = data.Size
		copiesByData[data].InitialPosition = data.Position
		copiesByData[data].InitialAnchorPoint = data.AnchorPoint
	end

	local function formatLabel(clone, textSize, p2, fn)
		local v8 = v6[#v6]
		local textYAlignment = tostring(overflowPickupProperties.TextYAlignment)

		if textYAlignment == "Top" then
			clone.Position = UDim2.new(0, total, 0, 0)
			clone.AnchorPoint = Vector2.new(0, 0)
		elseif textYAlignment == "Center" then
			clone.Position = UDim2.new(0, total, 0.5, 0)
			clone.AnchorPoint = Vector2.new(0, 0.5)
		elseif textYAlignment == "Bottom" then
			clone.Position = UDim2.new(0, total, 1, 0)
			clone.AnchorPoint = Vector2.new(0, 1)
		end

		total += p2

		if total > parent.AbsoluteSize.X and total ~= p2 then
			clone:Destroy()
			local label = v7[#v6][#v7[#v6]]

			if label:IsA("TextLabel") and label.Text == " " then
				v8.Container.Size = UDim2.new(0, total - p2 - label.Size.X.Offset, 1, 0)
				label:Destroy()
				table.remove(v7[#v6])
			end

			newLine()
			fn()
		else
			clone.Size = UDim2.new(0, p2, 0, textSize)
			v8.Container.Size = UDim2.new(0, total, 1, 0)
			v8.Size = UDim2.new(1, 0, 0, (math.max(v8.Size.Y.Offset, textSize)))
			clone.Name = string.format("Group%03d", #v7[#v6] + 1)
			clone.Parent = v8.Container
			table.insert(v7[#v6], clone)
			addFrameProperties(clone) -- equivalent call inferred; original call site unknown
			overflowPickupProperties.AnimateYield = 0
		end
	end

	printText = function(text2)
		if text2 == "\n" then
			newLine()
			return
		end

		if text2 == " " and total == 0 then
			return
		end

		local textSize = getTextSize() -- equivalent call inferred; original call site unknown
		local X = TextService:GetTextSize(
			text2,
			textSize,
			textLabel.Font,
			Vector2.new(layerCollector.AbsoluteSize.X, textSize)
		).X
		local clone = textLabel:Clone()
		clone.TextScaled = false
		clone.TextSize = textSize
		clone.Text = text2
		clone.TextTransparency = 1
		clone.TextStrokeTransparency = 1
		clone.TextWrapped = false
		local total3 = 0
		local v8 = 1

		for k, v9 in utf8.graphemes(text2) do
			local text3 = string.sub(text2, k, v9)
			local X2 = TextService:GetTextSize(
				text3,
				textSize,
				textLabel.Font,
				Vector2.new(layerCollector.AbsoluteSize.X, textSize)
			).X
			local clone2 = textLabel:Clone()
			clone2.Text = text3
			clone2.TextScaled = false
			clone2.TextSize = textSize
			clone2.Position = UDim2.new(0, total3, 0, 0)
			clone2.Size = UDim2.new(0, X2 + 1, 0, textSize)
			clone2.Name = string.format("Char%03d", v8)
			clone2.Parent = clone
			clone2.Visible = false
			addFrameProperties(clone2) -- equivalent call inferred; original call site unknown
			total3 += X2
			v8 += 1
		end

		formatLabel(clone, textSize, X, function()
			if not flag then
				printText(text2)
			end
		end)
	end

	printImage = function(p2)
		local textSize = getTextSize() -- equivalent call inferred; original call site unknown
		local clone = imageLabel:Clone()

		if RichText.ImageShortcuts[p2] then
			clone.Image = typeof(RichText.ImageShortcuts[p2]) == "number" and "rbxassetid://" .. RichText.ImageShortcuts[p2] or RichText.ImageShortcuts[p2]
		else
			clone.Image = "rbxassetid://" .. p2
		end

		clone.Size = UDim2.new(0, textSize, 0, textSize)
		clone.Visible = false
		formatLabel(clone, textSize, textSize, function()
			if not flag then
				printImage(p2)
			end
		end)
	end

	local function printSeries(items)
		for _, item in pairs(items) do
			local v8, v9 = string.match(item, "<(.+)=(.+)>")

			if v8 and v9 then
				if not applyMarkup(v8, v9) then
					warn("Could not apply markup: ", item)
				end
			else
				printText(item)
			end
		end
	end

	local count2 = #text
	local v8 = {}
	local overflowPickupIndex

	if state then
		overflowPickupIndex = state.OverflowPickupIndex
	else
		overflowPickupIndex = 1
	end

	while overflowPickupIndex and overflowPickupIndex <= count2 do
		local v9, v10 = string.find(text, "<.->", overflowPickupIndex)
		local v11, v12 = string.find(text, "[ \t\n]", overflowPickupIndex)
		local flag2

		if not (v9 and v10 and (not v11 or v9 < v11)) then
			v9 = v11 or count2 + 1
			v10 = v12 or count2 + 1
			flag2 = true
		end

		local v13

		if overflowPickupIndex < v9 then
			v13 = string.sub(text, overflowPickupIndex, v9 - 1) or nil
		end

		local v14

		if v9 <= count2 then
			v14 = string.sub(text, v9, v10) or nil
		end

		table.insert(v8, v13)

		if flag2 then
			printSeries(v8)

			if flag then
				break
			end

			printSeries({ v14 })

			if flag then
				overflowPickupIndex = v9
				break
			else
				v8 = {}
			end
		else
			table.insert(v8, v14)
		end

		overflowPickupIndex = v10 + 1
	end

	if not flag then
		printSeries(v8)
	end

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.HorizontalAlignment = overflowPickupProperties.ContainerHorizontalAlignment
	uIListLayout.VerticalAlignment = overflowPickupProperties.ContainerVerticalAlignment
	uIListLayout.Parent = parent
	local X = parent.AbsoluteSize.X
	local total3 = 0
	local v9 = 0

	for _, v10 in pairs(v6) do
		total3 += v10.Size.Y.Offset
		local container = v10.Container
		local offset = nil
		local offset2 = nil

		if container.AnchorPoint.X == 0 then
			offset = container.Position.X.Offset
			offset2 = container.Size.X.Offset
		elseif container.AnchorPoint.X == 0.5 then
			offset = v10.AbsoluteSize.X / 2 - container.Size.X.Offset / 2
			offset2 = v10.AbsoluteSize.X / 2 + container.Size.X.Offset / 2
		elseif container.AnchorPoint.X == 1 then
			offset = v10.AbsoluteSize.X - container.Size.X.Offset
			offset2 = v10.AbsoluteSize.X
		end

		X = math.min(X, offset)
		v9 = math.max(v9, offset2)
	end

	count += 1
	local flag2 = false
	local v10 = false
	local v11 = false
	local v12 = "TextAnimation" .. count
	local v13 = {}

	local function updateAnimations()
		if v10 and #v13 == 0 or flag2 then
			flag2 = true
			RunService:UnbindFromRenderStep(v12)
			v13 = {}
		else
			local now = tick()

			for i = #v13, 1, -1 do
				local v14 = v13[i]
				local settings = v14.Settings
				local appear = v3[settings.AnimateStyle]

				if not appear then
					warn("No animation style found for: ", settings.AnimateStyle, ", defaulting to Appear")
					appear = v3.Appear
				end

				local v15 = math.min((now - v14.Start) / settings.AnimateStyleTime, 1)
				appear(v14.Char, v15, settings)

				if v15 >= 1 then
					table.remove(v13, i)
				end
			end
		end
	end

	local function setFrameToDefault(p2)
		p2.Position = copiesByData[p2].InitialPosition
		p2.Size = copiesByData[p2].InitialSize
		p2.AnchorPoint = copiesByData[p2].InitialAnchorPoint

		for k, v14 in pairs(copiesByData[p2]) do
			applyProperty(k, v14, p2)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setGroupVisible(image, visible)
		image.Visible = visible

		for _, child in pairs(image:GetChildren()) do
			child.Visible = visible

			if visible then
				setFrameToDefault(child)
			end
		end

		if visible and image:IsA("ImageLabel") then
			setFrameToDefault(image)
		end
	end

	local function animate(p2)
		flag2 = false
		RunService:BindToRenderStep(v12, Enum.RenderPriority.Last.Value, updateAnimations)
		local v14 = nil
		local animateStepFrequency = nil
		local richTextSkipped = nil
		local animateStepGrouping = nil

		for _, v15 in pairs(v7) do
			for _, v16 in pairs(v15) do
				setGroupVisible(v16, false) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function animateCharacter(char, settings)
			table.insert(v13, {
				Char = char,
				Settings = settings,
				Start = tick()
			})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function yield()
			if not v11 and v14 % animateStepFrequency == 0 and richTextSkipped >= 0 then
				local v15 = richTextSkipped > 0 and richTextSkipped or nil
				wait(v15)
			end
		end

		for _, v15 in pairs(v7) do
			for _, label in pairs(v15) do
				local settings = copiesByData[label]

				if settings.AnimateStepGrouping ~= animateStepGrouping or settings.AnimateStepFrequency ~= animateStepFrequency then
					v14 = 0
				end

				animateStepGrouping = settings.AnimateStepGrouping
				richTextSkipped = _G.RichTextSkipped or settings.AnimateStepTime
				animateStepFrequency = settings.AnimateStepFrequency

				if settings.AnimateYield > 0 then
					wait(settings.AnimateYield)
				end

				if animateStepGrouping == "Word" or animateStepGrouping == "All" then
					if label:IsA("TextLabel") then
						label.Visible = true

						for _, child in pairs(label:GetChildren()) do
							animateCharacter(child, copiesByData[child]) -- equivalent call inferred; original call site unknown
						end
					else
						animateCharacter(label, settings) -- equivalent call inferred; original call site unknown
					end

					if animateStepGrouping == "Word" then
						v14 += 1
						yield() -- equivalent call inferred; original call site unknown
					end
				elseif animateStepGrouping == "Letter" then
					if label:IsA("TextLabel") then
						label.Visible = true
						local _ = label.Text
						local v17 = 1

						while true do
							local child = label:FindFirstChild(string.format("Char%03d", v17))

							if not child then
								break
							end

							animateCharacter(child, copiesByData[child]) -- equivalent call inferred; original call site unknown
							v14 += 1

							if not v11 and v14 % animateStepFrequency == 0 and richTextSkipped >= 0 then
								local v19

								if richTextSkipped > 0 then
									v19 = richTextSkipped or nil
								end

								wait(v19)
							end

							if flag2 then
								return
							else
								v17 += 1
							end
						end
					else
						animateCharacter(label, settings) -- equivalent call inferred; original call site unknown
						v14 += 1
						yield() -- equivalent call inferred; original call site unknown
					end
				else
					warn("Invalid step grouping: ", animateStepGrouping)
				end

				if flag2 then
					return
				end
			end
		end

		v10 = true

		if p2 then
			while #v13 > 0 do
				RunService.RenderStepped:Wait()
			end
		end
	end

	local nextTextObject = {
		Overflown = flag,
		OverflowPickupIndex = overflowPickupIndex,
		StartingProperties = startingProperties,
		OverflowPickupProperties = overflowPickupProperties,
		Text = text
	}

	if state then
		state.NextTextObject = nextTextObject
	end

	nextTextObject.ContentSize = Vector2.new(v9 - X, total3)

	function nextTextObject:Animate(p3)
		if p3 then
			animate()
		else
			coroutine.wrap(animate)()
		end

		if self.NextTextObject then
			self.NextTextObject:Animate(p3)
		end
	end

	function nextTextObject:Show(p3)
		if p3 then
			v11 = true
		else
			flag2 = true

			for _, v15 in pairs(v7) do
				for _, v16 in pairs(v15) do
					setGroupVisible(v16, true) -- equivalent call inferred; original call site unknown
				end
			end
		end

		if self.NextTextObject then
			self.NextTextObject:Show(p3)
		end
	end

	function nextTextObject:Hide()
		flag2 = true

		for _, v15 in pairs(v7) do
			for _, v16 in pairs(v15) do
				setGroupVisible(v16, false) -- equivalent call inferred; original call site unknown
			end
		end

		if self.NextTextObject then
			self.NextTextObject:Hide()
		end
	end

	return nextTextObject
end

function RichText.ContinueOverflow(_, p, p2)
	return RichText:New(p, nil, nil, false, p2)
end

return RichText