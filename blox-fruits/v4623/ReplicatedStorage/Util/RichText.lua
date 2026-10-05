local RichText = {}
local v = {
	Color = "TextColor3",
	StrokeColor = "TextStrokeColor3",
	ImageColor = "ImageColor3"
}
RichText.ColorShortcuts = require(script.ColorPalette)
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
	TextWrapped = false,
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
	AnimateStyleTime = 0.3,
	AnimateStyleNumPeriods = 1,
	AnimateStyleAmplitude = 0.5
}
local v3 = {
	TextYAlignment = "TextLabel",
	TextScaled = "TextLabel",
	TextWrapped = "TextLabel",
	TextSize = "TextLabel",
	Font = "TextLabel",
	TextColor3 = "TextLabel",
	TextStrokeColor3 = "TextLabel",
	TextStrokeTransparency = "TextLabel",
	TextTransparency = "TextLabel",
	BackgroundTransparency = "GuiObject",
	BorderSizePixel = "GuiObject",
	ImageColor3 = "ImageLabel",
	ImageTransparency = "ImageLabel",
	ImageRectOffset = "ImageLabel",
	ImageRectSize = "ImageLabel"
}
local v4 = {
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
	Wiggle = function(p, p2, data)
		p.Visible = true
		local v5 = data.InitialSize.Y.Offset * (1 - p2) * data.AnimateStyleAmplitude
		p.Position = data.InitialPosition + UDim2.new(
			0,
			0,
			0,
			math.sin(p2 * 3.141592653589793 * 2 * data.AnimateStyleNumPeriods) * v5 / 2
		)
	end,
	Swing = function(p, p2, p3)
		p.Visible = true
		local v5 = 90 * (1 - p2) * p3.AnimateStyleAmplitude
		p.Rotation = math.sin(p2 * 3.141592653589793 * 2 * p3.AnimateStyleNumPeriods) * v5
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

	local match, v5, v6 = value:match("(%d+),(%d+),(%d+)")
	return Color3.new(match / 255, v5 / 255, v6 / 255)
end

function getVector2FromString(value)
	local match, v5 = value:match("(%d+),(%d+)")
	return Vector2.new(match, v5)
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

local LocalizationService = game:GetService("LocalizationService")

function Pretranslate(value)
	local v5 = {}
	local v6 = {}
	return value:gsub("<Color=([^%s>]+)>", function(p)
		v5[p] = (v5[p] or 0) + 1
		return ("{color%s_%s}"):format(v5[p], p)
	end):gsub("<TextColor3=([^%s>]+)>", function(p)
		v5[p] = (v5[p] or 0) + 1
		return ("{colort%s_%s}"):format(v5[p], p)
	end):gsub("<AnimateYield=([0-9%.]+)>", function(p)
		v5[p] = (v5[p] or 0) + 1
		return ("{yield%s_%s}"):format(v5[p], (math.floor(tonumber(p) * 1000)))
	end):gsub("%b<>", function(value2)
		if value2:match("AnimateStyle") or value2:match("AnimateStepFrequency") or value2:match("AnimateStepTime") then
			return ""
		end

		local v7 = value2:sub(2)
		local v8 = v7:sub(1, #v7 - 1)
		v5.Items = (v5.Items or 0) + 1
		v6[v5.Items] = v8
		return "{item" .. v5.Items .. "}"
	end), v6
end

function PostTranslate(value, p)
	return (value:gsub("{color%d+_([^}]+)}", function(value2)
		return "<Color=" .. value2:gsub(" ", "") .. ">"
	end):gsub("{colort%d+_([^}]+)}", function(value2)
		return "<TextColor3=" .. value2:gsub(" ", "") .. ">"
	end):gsub("{yield%d+_(%d+)}", function(p2)
		return "<AnimateYield=" .. tonumber(p2) / 1000 .. ">"
	end):gsub("{item(%d+)}", function(p2)
		return "<" .. p[tonumber(p2)] .. ">"
	end))
end

function TranslateText(parent, p)
	local translatorForPlayer = nil
	local _, result = pcall(function()
		translatorForPlayer = LocalizationService:GetTranslatorForPlayer(game.Players.LocalPlayer)
	end)

	if not translatorForPlayer then
		warn("NO TRANSLATOR BRO", result)
		return p
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.TextTransparency = 1
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(0, 0, 0, 0)
	textLabel.Name = "TranslateMe"
	local text, v6 = Pretranslate(p)
	textLabel.Text = text
	textLabel.Parent = parent
	local v7 = text
	pcall(function()
		v7 = translatorForPlayer:Translate(textLabel, text)
	end)

	for k, v8 in pairs(v6) do
		local v9 = k
		local v10 = v8
		pcall(function()
			v6[v9] = translatorForPlayer:Translate(workspace, v10)
		end)
	end

	return (PostTranslate(v7, v6))
end

function RichText:New(parent, p, startingProperties, p2, state)
	for _, uIScale in pairs(parent:GetChildren()) do
		if not uIScale:IsA("UIScale") then
			uIScale:Destroy()
		end
	end

	local v5 = p2 == nil or p2
	local overflowPickupProperties = {}
	local v6 = {}
	local text

	if state then
		text = state.Text
		startingProperties = state.StartingProperties
	else
		text = TranslateText(parent, p)
	end

	local v7 = {}
	local textFrames = {}
	local copiesByData = {}
	local total = 0
	local flag = false
	local textLabel = Instance.new("TextLabel")
	textLabel.AutoLocalize = false
	textLabel.ZIndex = (state or parent).ZIndex
	local imageLabel = Instance.new("ImageLabel")
	local layerCollector = getLayerCollector(parent)
	local applyProperty
	local printText
	local printImage

	local function applyMarkup(p3, p4)
		local v9 = v[p3] or p3

		if p4 == "/" then
			if v6[v9] then
				p4 = v6[v9]
			else
				warn("Attempt to default <" .. v9 .. "> to value with no default")
			end
		end

		if tonumber(p4) then
			p4 = tonumber(p4)
		elseif p4 == "false" or p4 == "true" then
			p4 = p4 == "true"
		end

		overflowPickupProperties[v9] = p4

		if applyProperty(v9, p4) then
			return true
		end

		if v9 == "ContainerHorizontalAlignment" and v7[#v7] then
			setHorizontalAlignment(v7[#v7].Container, p4)
		elseif not v2[v9] then
			if v9 ~= "Img" then
				return false
			end

			printImage(p4)
		end

		return true
	end

	applyProperty = function(p3, p4, p5)
		local typeName = nil
		local v9 = false

		for _, v10 in pairs(p5 and { p5 } or { textLabel, imageLabel }) do
			local v11 = v10

			if not pcall(function()
				typeName = typeof(v11[p3])
			end) then
				continue
			end

			local v12 = v10
			pcall(function()
				if typeName == "Color3" then
					v12[p3] = getColorFromString(p4)
				elseif typeName == "Vector2" then
					v12[p3] = getVector2FromString(p4)
				else
					v12[p3] = p4
				end
			end)
			v9 = true
		end

		return v9
	end

	for k, v9 in pairs(v2) do
		applyMarkup(k, v9)
		v6[v[k] or k] = overflowPickupProperties[v[k] or k]
	end

	for k, v9 in pairs(startingProperties or {}) do
		applyMarkup(k, v9)
		v6[v[k] or k] = overflowPickupProperties[v[k] or k]
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
		local v9 = v7[#v7]

		if v9 then
			total2 += v9.Size.Y.Offset

			if not v5 then
				local v10 = total2
				local textSize = getTextSize() -- equivalent call inferred; original call site unknown

				if v10 + textSize > parent.AbsoluteSize.Y then
					flag = true
					return
				end
			end
		end

		local frame = Instance.new("Frame")
		frame.Name = string.format("Line%03d", #v7 + 1)
		frame.Size = UDim2.new(0, 0, 0, 0)
		frame.BackgroundTransparency = 1
		local frame2 = Instance.new("Frame", frame)
		frame2.Name = "Container"
		frame2.Size = UDim2.new(0, 0, 0, 0)
		frame2.BackgroundTransparency = 1
		setHorizontalAlignment(frame2, overflowPickupProperties.ContainerHorizontalAlignment)
		frame.Parent = parent
		table.insert(v7, frame)
		textFrames[#v7] = {}
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

	local function formatLabel(clone, textSize, p3, fn)
		local v9 = v7[#v7]
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

		total += p3

		if total > parent.AbsoluteSize.X and total ~= p3 then
			clone:Destroy()
			local label = textFrames[#v7][#textFrames[#v7]]

			if label:IsA("TextLabel") and label.Text == " " then
				v9.Container.Size = UDim2.new(0, total - p3 - label.Size.X.Offset, 1, 0)
				label:Destroy()
				table.remove(textFrames[#v7])
			end

			newLine()
			fn()
		else
			clone.Size = UDim2.new(0, p3, 0, textSize)
			v9.Container.Size = UDim2.new(0, total, 1, 0)
			v9.Size = UDim2.new(1, 0, 0, (math.max(v9.Size.Y.Offset, textSize)))
			clone.Name = string.format("Group%03d", #textFrames[#v7] + 1)
			clone.Parent = v9.Container
			table.insert(textFrames[#v7], clone)
			addFrameProperties(clone) -- equivalent call inferred; original call site unknown

			if clone.Text == "-=-" then
				for _, child in pairs(clone:GetChildren()) do
					child.Text = ""
				end
			end

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
		local v9 = 1

		for k, v10 in utf8.graphemes(text2) do
			local text3 = string.sub(text2, k, v10)
			local X2 = TextService:GetTextSize(
				text3,
				textSize,
				textLabel.Font,
				Vector2.new(layerCollector.AbsoluteSize.X, textSize)
			).X
			local clone2 = textLabel:Clone()
			clone2.Text = text3
			clone2.TextScaled = false
			clone2.TextWrapped = false
			clone2.TextSize = textSize
			clone2.Position = UDim2.new(0, total3, 0, 0)
			clone2.Size = UDim2.new(0, X2, 0, textSize)
			clone2.Name = string.format("Char%03d", v9)
			clone2.Parent = clone
			clone2.Visible = false
			addFrameProperties(clone2) -- equivalent call inferred; original call site unknown
			total3 += X2
			v9 += 1
		end

		formatLabel(clone, textSize, X, function()
			if not flag then
				printText(text2)
			end
		end)
	end

	printImage = function(p3)
		local textSize = getTextSize() -- equivalent call inferred; original call site unknown
		local clone = imageLabel:Clone()

		if RichText.ImageShortcuts[p3] then
			clone.Image = typeof(RichText.ImageShortcuts[p3]) == "number" and "rbxassetid://" .. RichText.ImageShortcuts[p3] or RichText.ImageShortcuts[p3]
		else
			clone.Image = "rbxassetid://" .. p3
		end

		clone.Size = UDim2.new(0, textSize, 0, textSize)
		clone.Visible = false
		formatLabel(clone, textSize, textSize, function()
			if not flag then
				printImage(p3)
			end
		end)
	end

	local function printSeries(items)
		for _, item in pairs(items) do
			local v9, v10 = string.match(item, "<(.+)=(.+)>")

			if v9 and v10 then
				if not applyMarkup(v9, v10) then
					warn("Could not apply markup: ", item)
				end
			else
				printText(item)
			end
		end
	end

	local count2 = #text
	local v9 = {}
	local overflowPickupIndex

	if state then
		overflowPickupIndex = state.OverflowPickupIndex
	else
		overflowPickupIndex = 1
	end

	while overflowPickupIndex and overflowPickupIndex <= count2 do
		local v10, v11 = string.find(text, "<.->", overflowPickupIndex)
		local v12, v13 = string.find(text, "[ \t\n]", overflowPickupIndex)
		local flag2

		if not (v10 and v11 and (not v12 or v10 < v12)) then
			v10 = v12 or count2 + 1
			v11 = v13 or count2 + 1
			flag2 = true
		end

		local v14

		if overflowPickupIndex < v10 then
			v14 = string.sub(text, overflowPickupIndex, v10 - 1) or nil
		end

		local v15

		if v10 <= count2 then
			v15 = string.sub(text, v10, v11) or nil
		end

		table.insert(v9, v14)

		if flag2 then
			printSeries(v9)

			if flag then
				break
			end

			printSeries({ v15 })

			if flag then
				overflowPickupIndex = v10
				break
			else
				v9 = {}
			end
		else
			table.insert(v9, v15)
		end

		overflowPickupIndex = v11 + 1
	end

	if not flag then
		printSeries(v9)
	end

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.HorizontalAlignment = overflowPickupProperties.ContainerHorizontalAlignment
	uIListLayout.VerticalAlignment = overflowPickupProperties.ContainerVerticalAlignment
	uIListLayout.Parent = parent
	local X = parent.AbsoluteSize.X
	local total3 = 0
	local v10 = 0

	for _, v11 in pairs(v7) do
		total3 += v11.Size.Y.Offset
		local container = v11.Container
		local offset = nil
		local offset2 = nil

		if container.AnchorPoint.X == 0 then
			offset = container.Position.X.Offset
			offset2 = container.Size.X.Offset
		elseif container.AnchorPoint.X == 0.5 then
			offset = v11.AbsoluteSize.X / 2 - container.Size.X.Offset / 2
			offset2 = v11.AbsoluteSize.X / 2 + container.Size.X.Offset / 2
		elseif container.AnchorPoint.X == 1 then
			offset = v11.AbsoluteSize.X - container.Size.X.Offset
			offset2 = v11.AbsoluteSize.X
		end

		X = math.min(X, offset)
		v10 = math.max(v10, offset2)
	end

	count += 1
	local flag2 = false
	local v11 = false
	local v12 = false
	local v13 = "TextAnimation" .. count
	local v14 = {}

	local function updateAnimations()
		if v11 and #v14 == 0 or flag2 then
			flag2 = true
			RunService:UnbindFromRenderStep(v13)
			v14 = {}
		else
			local now = tick()

			for i = #v14, 1, -1 do
				local v15 = v14[i]
				local settings = v15.Settings
				local appear = v4[settings.AnimateStyle]

				if not appear then
					warn("No animation style found for: ", settings.AnimateStyle, ", defaulting to Appear")
					appear = v4.Appear
				end

				local v16 = math.min((now - v15.Start) / settings.AnimateStyleTime, 1)
				appear(v15.Char, v16, settings)

				if v16 >= 1 then
					table.remove(v14, i)
				end
			end
		end
	end

	local function setFrameToDefault(p3)
		p3.Position = copiesByData[p3].InitialPosition
		p3.Size = copiesByData[p3].InitialSize
		p3.AnchorPoint = copiesByData[p3].InitialAnchorPoint

		for k, v15 in pairs(copiesByData[p3]) do
			applyProperty(k, v15, p3)
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

	local function animate(p3)
		flag2 = false
		RunService:BindToRenderStep(v13, Enum.RenderPriority.Last.Value, updateAnimations)
		local v15 = nil
		local animateStepFrequency = nil
		local animateStepTime = nil
		local animateStepGrouping = nil

		for _, v16 in pairs(textFrames) do
			for _, v17 in pairs(v16) do
				setGroupVisible(v17, false) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function animateCharacter(char, settings)
			table.insert(v14, {
				Char = char,
				Settings = settings,
				Start = tick()
			})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function yield()
			if not v12 and v15 % animateStepFrequency == 0 and animateStepTime >= 0 then
				local v16 = animateStepTime > 0 and animateStepTime or nil
				wait(v16)
			end
		end

		for _, v16 in pairs(textFrames) do
			for _, label in pairs(v16) do
				local settings = copiesByData[label]

				if settings.AnimateStepGrouping ~= animateStepGrouping or settings.AnimateStepFrequency ~= animateStepFrequency then
					v15 = 0
				end

				animateStepGrouping = settings.AnimateStepGrouping
				animateStepTime = settings.AnimateStepTime
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
						v15 += 1
						yield() -- equivalent call inferred; original call site unknown
					end
				elseif animateStepGrouping == "Letter" then
					if label:IsA("TextLabel") then
						label.Visible = true
						local _ = label.Text
						local v18 = 1

						while true do
							local child = label:FindFirstChild(string.format("Char%03d", v18))

							if not child then
								break
							end

							animateCharacter(child, copiesByData[child]) -- equivalent call inferred; original call site unknown
							v15 += 1

							if not v12 and v15 % animateStepFrequency == 0 and animateStepTime >= 0 then
								local v20

								if animateStepTime > 0 then
									v20 = animateStepTime or nil
								end

								wait(v20)
							end

							if flag2 then
								return
							else
								v18 += 1
							end
						end
					else
						animateCharacter(label, settings) -- equivalent call inferred; original call site unknown
						v15 += 1
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

		v11 = true

		if p3 then
			while #v14 > 0 do
				RunService.RenderStepped:Wait()
			end
		end
	end

	local nextTextObject2 = {
		Overflown = flag,
		OverflowPickupIndex = overflowPickupIndex,
		StartingProperties = startingProperties,
		OverflowPickupProperties = overflowPickupProperties,
		Text = text,
		_textFrames = textFrames,
		_frameProperties = copiesByData
	}

	if state then
		state.NextTextObject = nextTextObject2
	end

	nextTextObject2.ContentSize = Vector2.new(v10 - X, total3)

	function nextTextObject2:Animate(p4)
		if p4 then
			animate()
		else
			coroutine.wrap(animate)()
		end

		if self.NextTextObject then
			self.NextTextObject:Animate(p4)
		end
	end

	function nextTextObject2:Show(p4)
		if p4 then
			v12 = true
		else
			flag2 = true

			for _, v16 in pairs(textFrames) do
				for _, v17 in pairs(v16) do
					setGroupVisible(v17, true) -- equivalent call inferred; original call site unknown
				end
			end
		end

		if self.NextTextObject then
			self.NextTextObject:Show(p4)
		end
	end

	local function applyPropertyFast(k, p3, instance)
		if not (v3[k] and instance:IsA(v3[k])) then
			return
		end

		local v16 = string.gmatch(tostring(p3), "[^,]+")
		local v17 = v16()
		local v18 = v16()
		local v19 = v16()

		if v19 then
			instance[k] = Color3.fromRGB(v17, v18, v19)
		elseif RichText.ColorShortcuts[v17] ~= nil then
			instance[k] = RichText.ColorShortcuts[v17]
		elseif v18 then
			instance[k] = Vector2.new(v17, v18)
		else
			instance[k] = v17
		end
	end

	local function setFrameToDefaultUsing(p3, _frameProperties)
		p3.Position = _frameProperties[p3].InitialPosition
		p3.Size = _frameProperties[p3].InitialSize
		p3.AnchorPoint = _frameProperties[p3].InitialAnchorPoint

		for k, v16 in pairs(_frameProperties[p3]) do
			applyPropertyFast(k, v16, p3)
		end
	end

	function nextTextObject2.ShowFast(nextTextObject)
		local _frameProperties = {}
		local v16 = 1
		local v17 = 1
		local v18 = {
			n = 0
		}

		while true do
			for k, _frameProperty in next, nextTextObject._frameProperties, nil do
				_frameProperties[k] = _frameProperty
			end

			while nextTextObject._textFrames[v16] do
				if nextTextObject._textFrames[v16][v17] then
					v18.n += 1
					v18[v18.n] = nextTextObject._textFrames[v16][v17]
					v17 += 1
				else
					v16 += 1
					v17 = 1
				end
			end

			nextTextObject = nextTextObject.NextTextObject

			if nextTextObject ~= nil then
				continue
			end

			local v19 = 1

			while v19 <= v18.n do
				if v18[v19] and game.IsA(v18[v19], "GuiObject") then
					v18[v19].Visible = true

					if v18[v19]:IsA("ImageLabel") then
						setFrameToDefaultUsing(v18[v19], _frameProperties)
					end

					if textFrames[v19] then
						local children = v18[v19]:GetChildren()
						local count3 = #children

						for i = 1, count3 do
							v18[v18.n + i] = children[i]
						end

						v18.n += count3
					else
						setFrameToDefaultUsing(v18[v19], _frameProperties)
					end
				end

				v19 += 1
			end

			break
		end
	end

	function nextTextObject2:Hide()
		flag2 = true

		for _, v16 in pairs(textFrames) do
			for _, v17 in pairs(v16) do
				setGroupVisible(v17, false) -- equivalent call inferred; original call site unknown
			end
		end

		if self.NextTextObject then
			self.NextTextObject:Hide()
		end
	end

	return nextTextObject2
end

function RichText.ContinueOverflow(_, p, p2)
	return RichText:New(p, nil, nil, false, p2)
end

return RichText