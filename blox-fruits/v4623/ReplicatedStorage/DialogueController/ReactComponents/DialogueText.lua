local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
require(script.Parent.Parent.TextTags)
local Translation = require(script.Parent.Parent.Translation)
local Effects = require(script.Parent.Effects)
local Bubble = require(script.Parent.Bubble)
local TextSizing = require(script.Parent.TextSizing)
local rbxassetfontsfamiliesHighwayGothicjson = Font.new("rbxasset://fonts/families/HighwayGothic.json")

local function getBounds(p: string, p2: number, flag: boolean?)
	return TextSizing.bounds(p, rbxassetfontsfamiliesHighwayGothicjson, p2, flag == true)
end

local function effectFor(p)
	local effect = p.animate and p.animate.effect
	local selected

	if effect then
		selected = Effects[effect]
	end

	if selected and selected.wholeText ~= true then
		return selected
	end

	return nil
end

local function wholeTextEffectFor(words)
	for _, item in words do
		local effect = item.animate and item.animate.effect
		local selected

		if effect then
			selected = Effects[effect]
		end

		if selected and selected.wholeText == true then
			return selected
		end
	end

	return nil
end

local function effectCapLinesFor(words)
	for _, item in words do
		local effect = item.animate and item.animate.effect
		local v

		if effect then
			v = Effects[effect]
		end

		if v and v.capLines then
			return v.capLines
		end
	end

	return nil
end

local function hasSameLayoutWords(words, words2)
	if #words ~= #words2 then
		return false
	end

	for k, v in words do
		local v2 = words2[k]

		if not v2 or v.rich ~= v2.rich or v.raw ~= v2.raw or v.lineBreakAfter ~= v2.lineBreakAfter or v.textXAlignment ~= v2.textXAlignment or v.textYAlignment ~= v2.textYAlignment or v.sprite ~= v2.sprite or v.bubble ~= v2.bubble then
			return false
		end
	end

	return true
end

local function normalizeTextXAlignment(textXAlignment, center)
	if textXAlignment == Enum.TextXAlignment.Left or textXAlignment == Enum.TextXAlignment.Center or textXAlignment == Enum.TextXAlignment.Right then
		return textXAlignment
	end

	if typeof(textXAlignment) ~= "string" then
		return center
	end

	local lower = textXAlignment:lower()

	if lower == "left" then
		return Enum.TextXAlignment.Left
	elseif lower == "right" then
		return Enum.TextXAlignment.Right
	end

	if lower == "middle" or lower == "center" or lower == "centre" then
		return Enum.TextXAlignment.Center
	end

	return center
end

local function normalizeTextYAlignment(textYAlignment, center)
	if textYAlignment == Enum.TextYAlignment.Top or textYAlignment == Enum.TextYAlignment.Center or textYAlignment == Enum.TextYAlignment.Bottom then
		return textYAlignment
	end

	if typeof(textYAlignment) ~= "string" then
		return center
	end

	local lower = textYAlignment:lower()

	if lower == "top" then
		return Enum.TextYAlignment.Top
	elseif lower == "bottom" then
		return Enum.TextYAlignment.Bottom
	end

	if lower == "middle" or lower == "center" or lower == "centre" then
		return Enum.TextYAlignment.Center
	end

	return center
end

local function getTaggedTextXAlignment(words)
	for _, item in words do
		if item.textXAlignment ~= nil then
			return (normalizeTextXAlignment(item.textXAlignment, Enum.TextXAlignment.Center))
		end
	end

	return nil
end

local function getTaggedTextYAlignment(words)
	for _, item in words do
		if item.textYAlignment ~= nil then
			return (normalizeTextYAlignment(item.textYAlignment, Enum.TextYAlignment.Center))
		end
	end

	return nil
end

local function computeLayout(words, state: Vector2, p, p2, p3: number, p4: number)
	local function wrap(items, p5: number, X: number)
		local result = {
			{
				width = 0,
				indices = {}
			}
		}

		for k, item in items do
			local v = result[#result]
			local width

			if #v.indices == 0 then
				width = item
			else
				width = v.width + p5 + item
			end

			if #v.indices > 0 and X < width then
				table.insert(result, {
					width = item,
					indices = { k }
				})
			else
				v.width = width
				table.insert(v.indices, k)
			end

			if words[k].lineBreakAfter and k < #words then
				table.insert(result, {
					width = 0,
					indices = {}
				})
			end
		end

		return result
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function spaceWidthAt(p5: number)
		return (math.max(
			TextSizing.bounds("a a", rbxassetfontsfamiliesHighwayGothicjson, p5, false).X - TextSizing.bounds(
				"a",
				rbxassetfontsfamiliesHighwayGothicjson,
				p5,
				false
			).X * 2,
			p5 * 0.2
		))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function spriteWidth(p5, p6: number)
		local imageRectSize = p5.sprite.ImageRectSize
		return p6 * (not (imageRectSize and imageRectSize.Y > 0) and 1 or imageRectSize.X / imageRectSize.Y)
	end

	local function measureCharacters(rich: string, p5: number)
		local v = rich:find("<", 1, true) ~= nil
		local v2 = ""
		local v3 = 0
		local result = {}
		local v4 = 0
		local v5 = 0

		for _, v6 in Translation.toCharacters(rich) do
			local rich2 = v6.rich
			local bounds = TextSizing.bounds(rich2, rbxassetfontsfamiliesHighwayGothicjson, p5, true)
			local v7

			if v then
				v7 = v6.rich
			else
				v7 = v6.raw
			end

			v2 ..= v7
			local X = TextSizing.bounds(v2, rbxassetfontsfamiliesHighwayGothicjson, p5, v == true).X
			table.insert(result, {
				rich = v6.rich,
				x = v3,
				width = bounds.X
			})
			v4 = math.max(v4, v3 + bounds.X, X)
			v5 = math.max(v5, bounds.Y)
			v3 = X
		end

		return result, v4, v5
	end

	local function measureWords(p5: number, flag: boolean)
		local v = math.max(TextSizing.bounds("Ag", rbxassetfontsfamiliesHighwayGothicjson, p5, false).Y, 1)
		local result = {}
		local Xs = {}
		local result2 = {}

		for k, v2 in words do
			local chars = {}
			local X, height

			if v2.sprite then
				X = spriteWidth(v2, v)
				height = v
			else
				local rich = v2.rich
				local bounds = TextSizing.bounds(rich, rbxassetfontsfamiliesHighwayGothicjson, p5, true)
				X = bounds.X
				height = math.max(v, bounds.Y)

				if flag then
					local v5, v6
					chars, v5, v6 = measureCharacters(v2.rich, p5)
					X = math.max(X, v5)
					height = math.max(height, v6)
				end
			end

			if v2.bubble then
				X += height * 0.12 * 2
			end

			result[k] = {
				width = X,
				height = height,
				chars = chars
			}
			Xs[k] = X
			result2[k] = height
		end

		return v, result, Xs, result2
	end

	local function measureLayout(p5: number, flag: boolean)
		local defaultLineHeight, measured, v3, v4 = measureWords(p5, flag)
		local spaceWidth = spaceWidthAt(p5) -- equivalent call inferred; original call site unknown
		local lines = wrap(v3, spaceWidth, state.X)
		local lineHeights = {}
		local total = 0
		local maxLineWidth = 0

		for k, v9 in lines do
			local v10 = defaultLineHeight

			for _, v11 in v9.indices do
				v10 = math.max(v10, v4[v11] or defaultLineHeight)
			end

			lineHeights[k] = v10
			total += v10
			maxLineWidth = math.max(maxLineWidth, v9.width)
		end

		return {
			defaultLineHeight = defaultLineHeight,
			spaceWidth = spaceWidth,
			measured = measured,
			lines = lines,
			lineHeights = lineHeights,
			totalHeight = total,
			maxLineWidth = maxLineWidth
		}
	end

	local v = math.max(TextSizing.bounds("Ag", rbxassetfontsfamiliesHighwayGothicjson, 20, false).Y, 1) / 20
	local v2 = math.max(p4, (math.floor(state.Y / p3 / v + 0.5)))
	local textSize = p4
	local v4 = textSize
	textSize = v4

	while v4 <= v2 do
		local v6 = math.floor((v4 + v2) / 2)
		local v7 = measureLayout(v6, false)

		if v7.totalHeight <= state.Y + 0.5 and v7.maxLineWidth <= state.X + 0.5 then
			v4 = v6 + 1
			textSize = v6
		else
			v2 = v6 - 1
		end
	end

	local v6

	while true do
		v6 = measureLayout(textSize, true)

		if v6.totalHeight <= state.Y + 0.5 and v6.maxLineWidth <= state.X + 0.5 or textSize <= p4 then
			break
		end

		textSize -= 1
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function lineX(width: number)
		if p == Enum.TextXAlignment.Left then
			return 0
		end

		if p == Enum.TextXAlignment.Right then
			return (math.max(state.X - width, 0))
		end

		return (state.X - width) / 2
	end

	local totalHeight = v6.totalHeight
	local v7

	if p2 == Enum.TextYAlignment.Top then
		v7 = 0
	elseif p2 == Enum.TextYAlignment.Bottom then
		v7 = math.max(state.Y - totalHeight, 0)
	else
		v7 = (state.Y - totalHeight) / 2
	end

	local rects = {}

	for k, line in v6.lines do
		local v9 = lineX(line.width) -- equivalent call inferred; original call site unknown
		local height = v6.lineHeights[k] or v6.defaultLineHeight

		for _, v11 in line.indices do
			local v12 = v6.measured[v11]
			rects[v11] = {
				x = v9,
				y = v7,
				width = v12.width,
				height = height,
				chars = v12.chars
			}
			v9 += v12.width + v6.spaceWidth
		end

		v7 += height
	end

	return {
		rects = rects,
		textSize = textSize,
		renderTextSize = TextSizing.renderTextSizeForMeasuredSize(textSize, rbxassetfontsfamiliesHighwayGothicjson),
		words = words
	}
end

local memo = React.memo(function(props)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(false)
	local ref4 = React.useRef(nil)
	local effect = props.effect
	local visible = props.visible ~= false
	local textTransparency = props.textTransparency or 0
	local renderTextSize = props.renderTextSize or props.textSize

	local function fn()
		if props.entrance == true and visible and not ref3.current then
			ref3.current = true
			ref4.current = os.clock()
		end

		local v = not ref4.current and 1e999 or os.clock() - ref4.current

		if effect or not (v >= 0.15) then
			if not ref.current then
				return
			end

			local current = ref2.current
			local uIStroke

			if current then
				uIStroke = current:FindFirstChildOfClass("UIStroke")
			else
				uIStroke = nil
			end

			local total = 0
			local total2 = 1e999
			local zero = Vector2.zero
			local rotation = 0

			local function step(p: number)
				total += p
				total2 += p
				v += p
				local current2 = ref.current

				if not current2 then
					return
				end

				local current3 = ref2.current

				if effect and total2 >= effect.interval then
					total2 = 0
					local v3

					if effect.offset then
						v3 = effect.offset(props.textSize, total)
					else
						v3 = Vector2.zero
					end

					zero = v3
					rotation = not effect.rotation and 0 or effect.rotation(props.textSize, total)

					if effect.color then
						current2.TextColor3 = effect.color(props.textSize, total)
					end
				end

				local v3 = math.clamp(v / 0.15, 0, 1)
				local uDim = UDim2.fromOffset(props.x + zero.X, props.y + zero.Y - (1 - v3) * props.textSize * 0.3)
				current2.Position = uDim
				current2.Rotation = rotation
				current2.TextTransparency = textTransparency + (1 - textTransparency) * (1 - v3)

				if current3 then
					current3.Position = uDim
					current3.Rotation = rotation
				end

				if uIStroke then
					uIStroke.Transparency = 1 - v3
				end
			end

			step(0)
			local connection

			if effect or v < 0.15 then
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					step(dt)

					if not effect and v >= 0.15 then
						heartbeatConnection:Disconnect()
					end
				end)
				connection = heartbeatConnection
			else
				connection = nil
			end

			return function()
				if connection then
					connection:Disconnect()
				end
			end
		else
			local current = ref.current
			local current2 = ref2.current

			if current then
				current.Position = UDim2.fromOffset(props.x, props.y)
				current.Rotation = 0
				current.TextTransparency = textTransparency
			end

			if current2 then
				current2.Position = UDim2.fromOffset(props.x, props.y)
				current2.Rotation = 0
				local uIStroke = current2:FindFirstChildOfClass("UIStroke")

				if uIStroke then
					uIStroke.Transparency = 0
				end
			end
		end
	end

	React.useLayoutEffect(fn, {
		effect or false,
		props.entrance == true and visible,
		props.textSize,
		props.x,
		props.y,
		textTransparency,
		renderTextSize
	})
	local v4 = {
		AutoLocalize = false,
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesHighwayGothicjson,
		MaxVisibleGraphemes = props.maxVisibleGraphemes or -1,
		Position = UDim2.fromOffset(props.x, props.y),
		RichText = true,
		Size = UDim2.fromOffset(props.width, props.height),
		Text = props.rich,
		TextColor3 = props.textColor or Color3.new(1, 1, 1),
		TextSize = renderTextSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		Visible = visible
	}
	local clone = table.clone(v4)
	clone.ref = ref
	clone.TextTransparency = textTransparency
	clone.ZIndex = 2
	local clone2 = table.clone(v4)
	clone2.ref = ref2
	clone2.TextTransparency = 1
	clone2.ZIndex = 1
	local createElement = React.createElement
	local fragment = React.Fragment
	local outline

	if props.stroke ~= false then
		outline = React.createElement("TextLabel", clone2, {
			uIStroke = React.createElement("UIStroke", {
				Thickness = props.height * 0.06
			})
		})
	end

	return createElement(fragment, nil, {
		outline = outline,
		fill = React.createElement("TextLabel", clone)
	})
end)
local memo2 = React.memo(function(props)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(false)
	local ref3 = React.useRef(nil)
	local effect = props.effect
	local visible = props.visible ~= false
	local imageTransparency = props.imageTransparency or 0
	local v = math.min(props.width, props.height)

	local function fn()
		if props.entrance == true and visible and not ref2.current then
			ref2.current = true
			ref3.current = os.clock()
		end

		local v2 = not ref3.current and 1e999 or os.clock() - ref3.current

		if effect or not (v2 >= 0.15) then
			local total = 0
			local total2 = 1e999
			local zero = Vector2.zero
			local rotation = 0

			local function step(p: number)
				total += p
				total2 += p
				v2 += p
				local current = ref.current

				if not current then
					return
				end

				if effect and total2 >= effect.interval then
					total2 = 0
					local v4

					if effect.offset then
						v4 = effect.offset(v, total)
					else
						v4 = Vector2.zero
					end

					zero = v4
					rotation = not effect.rotation and 0 or effect.rotation(v, total)
				end

				local v4 = math.clamp(v2 / 0.15, 0, 1)
				current.Position = UDim2.fromOffset(props.x + zero.X, props.y + zero.Y - (1 - v4) * props.height * 0.3)
				current.Rotation = rotation
				current.ImageTransparency = imageTransparency + (1 - imageTransparency) * (1 - v4)
			end

			step(0)
			local connection

			if effect or v2 < 0.15 then
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					step(dt)

					if not effect and v2 >= 0.15 then
						heartbeatConnection:Disconnect()
					end
				end)
				connection = heartbeatConnection
			else
				connection = nil
			end

			return function()
				if connection then
					connection:Disconnect()
				end
			end
		else
			local current = ref.current

			if current then
				current.Position = UDim2.fromOffset(props.x, props.y)
				current.Rotation = 0
				current.ImageTransparency = imageTransparency
			end
		end
	end

	React.useLayoutEffect(fn, {
		effect or false,
		props.entrance == true and visible,
		v,
		props.x,
		props.y,
		imageTransparency
	})
	return React.createElement("ImageLabel", {
		ref = ref,
		BackgroundTransparency = 1,
		Image = props.sprite.Image,
		ImageRectOffset = props.sprite.ImageRectOffset or Vector2.zero,
		ImageRectSize = props.sprite.ImageRectSize or Vector2.zero,
		ImageTransparency = imageTransparency,
		Position = UDim2.fromOffset(props.x, props.y),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromOffset(props.width, props.height),
		Visible = visible
	})
end)
local memo3 = React.memo(function(props)
	local word = props.word
	local rect = props.rect
	local effect = word.animate and word.animate.effect
	local effect2

	if effect then
		effect2 = Effects[effect]
	end

	if not effect2 or effect2.wholeText == true then
		effect2 = nil
	end

	local v2 = not word.bubble and 0 or rect.height * 0.12
	local children = {}

	if word.bubble then
		children.bubble = React.createElement(Bubble, {
			color = word.bubble.color,
			position = UDim2.fromOffset(rect.x, rect.y),
			size = UDim2.fromOffset(rect.width, rect.height),
			effect = effect2,
			visible = props.visibleCount > 0,
			zIndex = 0
		})
	end

	if word.sprite then
		children.sprite = React.createElement(memo2, {
			sprite = word.sprite,
			x = rect.x + v2,
			y = rect.y,
			width = rect.width - v2 * 2,
			height = rect.height,
			imageTransparency = props.textTransparency,
			effect = effect2,
			entrance = not props.settled,
			visible = props.visibleCount > 0
		})
	elseif effect2 == nil or effect2.splitCharacters == true or not props.settled then
		for k, char in rect.chars do
			children[`char{k}`] = React.createElement(memo, {
				rich = char.rich,
				x = rect.x + v2 + char.x,
				y = rect.y,
				width = char.width,
				height = rect.height,
				textSize = props.textSize,
				renderTextSize = props.renderTextSize,
				textColor = props.textColor,
				textTransparency = props.textTransparency,
				stroke = props.stroke,
				effect = effect2,
				entrance = not props.settled,
				visible = k <= props.visibleCount
			})
		end
	else
		children.label = React.createElement(memo, {
			rich = word.rich,
			x = rect.x + v2,
			y = rect.y,
			width = rect.width - v2 * 2,
			height = rect.height,
			textSize = props.textSize,
			renderTextSize = props.renderTextSize,
			textColor = props.textColor,
			textTransparency = props.textTransparency,
			stroke = props.stroke,
			effect = effect2,
			maxVisibleGraphemes = props.visibleCount >= props.graphemes and -1 or props.visibleCount,
			visible = props.visibleCount > 0
		})
	end

	if props.isolate then
		return (React.createElement("ScreenGui", {
			AutoLocalize = false,
			DisplayOrder = 6,
			ResetOnSpawn = false
		}, {
			origin = React.createElement("Frame", {
				ref = props.originRef,
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(0, 0)
			}, children)
		}))
	end

	return (React.createElement("Frame", {
		AutoLocalize = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1)
	}, children))
end)

local function DialogueText(props)
	local ref = React.useRef(nil)
	local state, setState = React.useState(Vector2.zero)
	local state2, setState2 = React.useState(false)
	local state3, setState3 = React.useState((props.visibleGraphemes or -1) == -1)
	local state4, setState4 = React.useState(TextSizing.preferenceKey())
	local v = wholeTextEffectFor(props.words)
	local position = props.position or UDim2.fromScale(0.5, 0.46)
	local ref2 = React.useRef({})
	local ref3 = React.useRef({})

	local function originRef(p: number)
		local v2 = ref3.current[p]

		if v2 then
			return v2
		end

		local function callback(p2)
			ref2.current[p] = p2
			local current = ref.current

			if p2 and current then
				local absolutePosition = current.AbsolutePosition
				p2.Position = UDim2.fromOffset(absolutePosition.X, absolutePosition.Y)
			end
		end

		ref3.current[p] = callback
		return callback
	end

	React.useEffect(function()
		local connection = TextSizing.onPreferenceChanged(function()
			setState4(TextSizing.preferenceKey())
		end)
		return function()
			if connection then
				connection:Disconnect()
			end
		end
	end, {})
	React.useEffect(function()
		local current = ref.current

		if not current then
			return
		end

		setState(current.AbsoluteSize)
		setState2(props.isolateWords == true and v == nil and current:FindFirstAncestorOfClass("PlayerGui") ~= nil)
		local absoluteSizeChangedConnection = current:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			setState(current.AbsoluteSize)
		end)
		local absolutePositionChangedConnection = current:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			local absolutePosition = current.AbsolutePosition

			for _, v4 in ref2.current do
				v4.Position = UDim2.fromOffset(absolutePosition.X, absolutePosition.Y)
			end
		end)
		return function()
			absoluteSizeChangedConnection:Disconnect()
			absolutePositionChangedConnection:Disconnect()
		end
	end, { props.isolateWords == true, v or false })
	React.useEffect(function()
		if state3 or (props.visibleGraphemes or -1) ~= -1 then
			return
		end

		local thread = task.delay(0.2, function()
			setState3(true)
		end)
		return function()
			pcall(task.cancel, thread)
		end
	end, { props.visibleGraphemes or -1, state3 })
	local v2 = React.useMemo(function()
		return getTaggedTextXAlignment(props.words) or normalizeTextXAlignment(
			props.textXAlignment,
			Enum.TextXAlignment.Center
		)
	end, { props.words, props.textXAlignment or false })
	local v3 = React.useMemo(function()
		return getTaggedTextYAlignment(props.words) or normalizeTextYAlignment(
			props.textYAlignment,
			Enum.TextYAlignment.Center
		)
	end, { props.words, props.textYAlignment or false })
	local v4 = React.useMemo(function()
		local result = {}

		for k, word in props.words do
			result[k] = word.sprite and 1 or utf8.len(word.raw) or #word.raw
		end

		return result
	end, { props.words })
	local v5 = effectCapLinesFor(props.words) or props.capLines or 3
	local v6 = math.max(1, props.minTextSize or 1)
	local state5, setState5 = React.useState(nil)
	local useLayoutEffect = React.useLayoutEffect

	local function fn()
		local current = ref.current

		if not current then
			return
		end

		if v then
			local total = 0
			local total2 = 1e999
			local zero = Vector2.zero
			local rotation = 0
			local v8 = not state5 and 20 or state5.textSize

			local function step(p: number)
				total += p
				total2 += p

				if total2 >= v.interval then
					total2 = 0
					local v9

					if v.offset then
						v9 = v.offset(v8, total)
					else
						v9 = Vector2.zero
					end

					zero = v9
					rotation = not v.rotation and 0 or v.rotation(v8, total)
				end

				local current2 = ref.current

				if current2 then
					current2.Position = position + UDim2.fromOffset(zero.X, zero.Y)
					current2.Rotation = rotation
				end
			end

			step(0)
			local heartbeatConnection = RunService.Heartbeat:Connect(step)
			return function()
				heartbeatConnection:Disconnect()
				local current2 = ref.current

				if current2 then
					current2.Position = position
					current2.Rotation = 0
				end
			end
		else
			current.Position = position
			current.Rotation = 0
		end
	end

	local v9

	if state5 then
		v9 = state5.textSize
	else
		v9 = false
	end

	useLayoutEffect(fn, { v or false, position, v9 })
	React.useEffect(function()
		if props.frozen or state.X < 1 or state.Y < 1 then
			return
		end

		local v10 = false
		task.spawn(function()
			local v11 = computeLayout(props.words, state, v2, v3, v5, v6)

			if not v10 then
				setState5(v11)
			end
		end)
		return function()
			v10 = true
		end
	end, {
		props.words,
		state,
		v2,
		v3,
		v5,
		v6,
		props.frozen or false,
		state4
	})
	local children = {}

	if state5 and hasSameLayoutWords(state5.words, props.words) then
		local isolate = state2 and v == nil
		local visibleGraphemes = props.visibleGraphemes or -1
		local total = 0

		for k, word in props.words do
			local graphemes = v4[k] or 0
			local visibleCount

			if visibleGraphemes == -1 then
				visibleCount = graphemes
			else
				visibleCount = math.clamp(visibleGraphemes - total, 0, graphemes)
			end

			total += graphemes + 1
			local rect = state5.rects[k]

			if not rect then
				continue
			end

			local formatted = `word{k}`
			local createElement = React.createElement
			local v14 = {
				word = word,
				rect = rect,
				graphemes = graphemes,
				visibleCount = visibleCount,
				textSize = state5.textSize,
				renderTextSize = state5.renderTextSize,
				settled = state3,
				isolate = isolate,
				originRef = 0,
				textColor = 0,
				textTransparency = 0,
				stroke = 0
			}
			local callback

			if isolate then
				callback = ref3.current[k]

				if not callback then
					local v15 = k

					callback = function(p)
						ref2.current[v15] = p
						local current = ref.current

						if p and current then
							local absolutePosition = current.AbsolutePosition
							p.Position = UDim2.fromOffset(absolutePosition.X, absolutePosition.Y)
						end
					end

					ref3.current[k] = callback
				end
			end

			v14.originRef = callback
			v14.textColor = props.textColor
			v14.textTransparency = props.textTransparency
			v14.stroke = props.stroke
			children[formatted] = createElement(memo3, v14)
		end
	end

	return React.createElement("Frame", {
		ref = ref,
		AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = position,
		Size = props.size or UDim2.fromScale(0.85, 0.52)
	}, children)
end

return React.memo(DialogueText)