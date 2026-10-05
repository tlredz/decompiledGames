local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local Icon = require(script.Parent.Parent.Icon)
local Bubble = require(script.Parent.Parent.Bubble)
local Effects = require(script.Parent.Parent.Effects)
local DialogueText = require(script.Parent.Parent.DialogueText)
local OptionRowHeight = require(script.Parent.Parent.OptionRowHeight)
local OptionBubbleSync = require(script.Parent.Parent.OptionBubbleSync)
local TextSizing = require(script.Parent.Parent.TextSizing)
local OptionButtonEffects = require(script.Parent.OptionButtonEffects)
local rbxassetfontsfamiliesHighwayGothicjson = Font.new("rbxasset://fonts/families/HighwayGothic.json")
local rbxassetfontsfamiliesArimojson = Font.new("rbxasset://fonts/families/Arimo.json")
local uDim = UDim.new(0.1, 0)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.78, 0),
	NumberSequenceKeypoint.new(1, 1)
})
local numberSequence2 = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
local element = React.createElement("UIStroke", {
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
	Thickness = 0.04
}, {
	uIGradient = React.createElement("UIGradient", {
		Transparency = numberSequence
	})
})
local element2 = React.createElement("UICorner", {
	CornerRadius = uDim
})
local element3 = React.createElement("UIGradient", {
	Transparency = numberSequence
})
local element4 = React.createElement("UIGradient", {
	Transparency = numberSequence2
})

local function fadeOutDescendants(folder, tweenInfo)
	local function fade(instance)
		if instance:IsA("GuiObject") and instance.BackgroundTransparency < 1 then
			TweenService:Create(instance, tweenInfo, {
				BackgroundTransparency = 1
			}):Play()
		end

		if instance:IsA("TextLabel") then
			TweenService:Create(instance, tweenInfo, {
				TextTransparency = 1
			}):Play()
		end

		if instance:IsA("ImageLabel") then
			TweenService:Create(instance, tweenInfo, {
				ImageTransparency = 1
			}):Play()
		end

		if instance:IsA("UIStroke") then
			TweenService:Create(instance, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end

	fade(folder)

	for _, descendant in folder:GetDescendants() do
		fade(descendant)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function inputPosition(p)
	local position = p.Position
	return Vector2.new(position.X, position.Y)
end

local function OptionButton(props)
	local state, setState = React.useState(false)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(false)
	local ref4 = React.useRef(nil)
	local ref5 = React.useRef(nil)
	local ref6 = React.useRef(-1e999)
	local dismiss = props.dismiss
	local v = React.useContext(OptionRowHeight)
	ref2.current = props.onHoverStateChanged
	local current3

	if dismiss == nil then
		current3 = props.onActivated
	end

	ref4.current = current3

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reportHovered(current: boolean)
		if ref3.current == current then
			return
		end

		ref3.current = current
		local current2 = ref2.current

		if current2 then
			current2(current)
		end
	end

	local v3 = React.useMemo(function()
		local icon = props.icon
		local iconOverride = props.iconOverride

		if not iconOverride then
			return icon
		end

		local v4 = {
			image = iconOverride.image or icon.image,
			emoji = 0,
			imageRectOffset = 0,
			imageRectSize = 0,
			backgroundImage = 0,
			backgroundImageRectOffset = 0,
			backgroundImageRectSize = 0,
			position = 0,
			size = 0,
			color = 0,
			transparency = 0,
			scaleType = 0,
			effect = 0,
			bubble = 0,
			badge = 0
		}
		local emoji

		if not iconOverride.image then
			emoji = icon.emoji
		end

		v4.emoji = emoji
		local imageRectOffset

		if iconOverride.image then
			imageRectOffset = iconOverride.imageRectOffset
		else
			imageRectOffset = icon.imageRectOffset
		end

		v4.imageRectOffset = imageRectOffset
		local imageRectSize

		if iconOverride.image then
			imageRectSize = iconOverride.imageRectSize
		else
			imageRectSize = icon.imageRectSize
		end

		v4.imageRectSize = imageRectSize
		v4.backgroundImage = iconOverride.backgroundImage
		v4.backgroundImageRectOffset = iconOverride.backgroundImageRectOffset
		v4.backgroundImageRectSize = iconOverride.backgroundImageRectSize
		v4.position = iconOverride.position or icon.position
		v4.size = iconOverride.size or icon.size
		v4.color = iconOverride.color or icon.color
		v4.transparency = iconOverride.transparency or icon.transparency
		v4.scaleType = iconOverride.scaleType or icon.scaleType
		v4.effect = iconOverride.effect or icon.effect
		v4.bubble = iconOverride.bubble
		v4.badge = iconOverride.badge or icon.badge
		return v4
	end, { props.icon, props.iconOverride or false })
	local bubble = v3.bubble
	local badge

	if not bubble then
		badge = v3.badge
	end

	local v4 = React.useContext(OptionBubbleSync)
	local ref7 = React.useRef({})
	local state2, setState2 = React.useState(nil)
	local state3, setState3 = React.useState(nil)
	local state4, setState4 = React.useState(TextSizing.preferenceKey())
	local v5 = not v and 0 or math.floor(v3.size.Y.Scale * v + v3.size.Y.Offset + 0.5)
	local v6 = math.floor(v5 * 0.85 + 0.5)
	local v7 = math.max(math.floor(v6 * 0.8), 8)
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
	local useEffect = React.useEffect

	local function fn()
		if not bubble or v == nil then
			setState2(nil)
			return
		end

		local flag = false
		task.spawn(function()
			local X = TextSizing.bounds(bubble.text, rbxassetfontsfamiliesHighwayGothicjson, v7, true).X
			local textSizeForMeasuredSize = TextSizing.renderTextSizeForMeasuredSize(
				v7,
				rbxassetfontsfamiliesHighwayGothicjson
			)

			if flag then
				return
			end

			setState2({
				width = X,
				textSize = textSizeForMeasuredSize
			})

			if v4 then
				v4.report(ref7.current, X, textSizeForMeasuredSize)
			end
		end)
		return function()
			flag = true
		end
	end

	local v9

	if bubble then
		v9 = bubble.text or false
	else
		v9 = false
	end

	useEffect(fn, {
		v9,
		v4 or false,
		v7,
		v or false,
		state4
	})
	React.useEffect(function()
		if not (v4 and bubble) then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function apply(current: number?, textSize3: number?)
			setState3({
				width = current,
				textSize = textSize3
			})
		end

		local current, textSize4 = v4.current()
		apply(current, textSize4) -- equivalent call inferred; original call site unknown
		local v11 = v4.subscribe(ref7.current, apply)
		return function()
			v11()
			v4.report(ref7.current, nil, nil)
		end
	end, { v4 or false, bubble or false })
	local width = state3 and state3.width
	local textSize = state3 and state3.textSize
	local width2 = state2 and state2.width
	local textSize2 = state2 and state2.textSize
	local v10 = math.floor((width or width2 or v6) + v6 * 0.12 * 2 + 0.5)
	local size = v3.size
	local uDim2 = UDim2.fromScale(0.140052, 0.5)
	local uDim3 = UDim2.fromScale(0.832948, 0.65)

	if v then
		local v11

		if bubble then
			v11 = v10
		else
			v11 = v5
		end

		local v12 = v3.position.X.Offset + v11 + math.floor(v * 0.2 + 0.5)
		size = UDim2.fromOffset(v5, v5)
		uDim2 = UDim2.new(v3.position.X.Scale, v12, 0.5, 0)
		uDim3 = UDim2.new(0.973 - v3.position.X.Scale, -v12, 0.65, 0)
	end

	local size2

	if badge then
		size2 = badge.size or size
	end

	local position

	if badge then
		position = badge.position or v3.position
	end

	local v11 = state and props.onActivated ~= nil
	local v12

	if not (props.effect == nil or dismiss ~= nil) then
		v12 = OptionButtonEffects[props.effect]
	end

	React.useEffect(function()
		local current = ref.current

		if not current or dismiss then
			return
		end

		local v13 = v11 and 1.05 or 1
		local tween = TweenService:Create(
			current,
			TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = UDim2.fromScale(v13, v13)
			}
		)
		tween:Play()
		return function()
			tween:Cancel()
		end
	end, { v11, dismiss or false })
	React.useEffect(function()
		local current = ref.current

		if not (current and dismiss) then
			return
		end

		local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		if dismiss == "chosen" then
			TweenService:Create(current, tweenInfo, {
				Size = UDim2.fromScale(1.25, 1.25)
			}):Play()
		else
			TweenService:Create(current, tweenInfo, {
				Position = UDim2.fromScale(1.15, 0.5)
			}):Play()
		end

		fadeOutDescendants(current, tweenInfo)
	end, { dismiss or false })
	React.useEffect(function()
		if dismiss ~= nil then
			setState(false)
			reportHovered(false) -- equivalent call inferred; original call site unknown
			ref5.current = nil
		end
	end, { dismiss or false })
	React.useEffect(function()
		return function()
			if ref3.current == false then
				return
			end

			ref3.current = false
			local current = ref2.current

			if current then
				current(false)
			end
		end
	end, {})
	React.useEffect(function()
		local function cancelIfDragged(p)
			if p.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			local current = ref5.current

			if current and (inputPosition(p) - current.startPosition).Magnitude > 12 then
				current.moved = true
			end
		end

		local inputChangedConnection = UserInputService.InputChanged:Connect(cancelIfDragged)
		local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			local current = ref5.current

			if not current then
				return
			end

			ref5.current = nil
			ref6.current = time()
			local current2 = ref4.current

			if current2 and not current.moved and (inputPosition(input) - current.startPosition).Magnitude <= 12 then
				current2()
			end
		end)
		return function()
			inputChangedConnection:Disconnect()
			inputEndedConnection:Disconnect()
		end
	end, {})

	local function activated(_, p)
		if p and p.UserInputType == Enum.UserInputType.Touch or (ref5.current or time() - ref6.current < 0.2) then
			return
		end

		local current = ref4.current

		if current then
			current()
		end
	end

	local createElement = React.createElement
	local v14 = {
		ref = ref,
		Active = props.onActivated ~= nil and dismiss == nil,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = props.backgroundColor or Color3.fromRGB(23, 23, 23),
		BackgroundTransparency = 0.1,
		Position = UDim2.fromScale(0.5, 0.5),
		Selectable = props.onActivated ~= nil and dismiss == nil,
		Size = UDim2.fromScale(1, 1),
		Modal = props.modal ~= false,
		Text = ""
	}
	local activated2 = React.Event.Activated

	if dismiss ~= nil or not props.onActivated then
		activated = nil
	end

	v14[activated2] = activated

	v14[React.Event.InputBegan] = function(_, p)
		if p.UserInputType ~= Enum.UserInputType.Touch or ref4.current == nil then
			return
		end

		ref5.current = {
			startPosition = inputPosition(p),
			moved = false
		}
	end

	v14[React.Event.MouseEnter] = function()
		if dismiss ~= nil then
			return
		end

		setState(true)
		reportHovered(true) -- equivalent call inferred; original call site unknown
	end

	v14[React.Event.MouseLeave] = function()
		setState(false)
		reportHovered(false) -- equivalent call inferred; original call site unknown
	end

	local buttonEffect

	if v12 then
		buttonEffect = React.createElement(v12, {})
	end

	local uIStroke

	if props.borderColor then
		uIStroke = React.cloneElement(element, {
			Color = props.borderColor
		})
	else
		uIStroke = element
	end

	local v17 = {
		buttonEffect = buttonEffect,
		uIStroke = uIStroke,
		uICorner = element2,
		uIGradient = element3,
		icon = 0,
		iconBadge = 0,
		textLabel = 0,
		hoverFade = 0
	}
	local icon2

	if bubble then
		local createElement2 = React.createElement
		local v22 = {
			color = bubble.color,
			anchorPoint = Vector2.new(0, 0.5),
			position = v3.position,
			size = 0,
			effect = 0,
			transparent = 0
		}

		if v then
			size = UDim2.fromOffset(v10, v6)
		end

		v22.size = size
		local effect

		if v3.effect then
			effect = Effects[v3.effect]
		end

		v22.effect = effect
		v22.transparent = bubble.transparent
		local createElement3 = React.createElement
		local v26 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutoLocalize = false,
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesHighwayGothicjson,
			Position = UDim2.fromScale(0.5, 0.5),
			RichText = true,
			Size = UDim2.fromScale(1, 0.8),
			Text = bubble.text,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 0,
			TextScaled = 0,
			ZIndex = 2
		}
		local textSize3

		if v then
			textSize3 = textSize or textSize2 or v7
		end

		v26.TextSize = textSize3
		v26.TextScaled = v == nil
		icon2 = createElement2(Bubble, v22, {
			textLabel = createElement3("TextLabel", v26, {
				uIStroke = React.createElement("UIStroke", {
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.05
				})
			})
		})
	elseif v3.emoji then
		icon2 = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			AutoLocalize = false,
			BackgroundTransparency = 1,
			Position = v3.position,
			Size = size,
			Text = v3.emoji,
			TextScaled = true,
			TextTransparency = v3.transparency
		})
	else
		icon2 = React.createElement(Icon, {
			anchorPoint = Vector2.new(0, 0.5),
			image = v3.image,
			imageRectOffset = v3.imageRectOffset,
			imageRectSize = v3.imageRectSize,
			backgroundImage = v3.backgroundImage,
			backgroundImageRectOffset = v3.backgroundImageRectOffset,
			backgroundImageRectSize = v3.backgroundImageRectSize,
			color = v3.color,
			transparency = v3.transparency,
			position = v3.position,
			scaleType = v3.scaleType,
			size = size,
			effect = v3.effect
		})
	end

	v17.icon = icon2
	local iconBadge

	if badge then
		iconBadge = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			AutoLocalize = false,
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesArimojson,
			Position = position,
			RichText = false,
			Size = size2,
			Text = badge.text or "X",
			TextColor3 = badge.color or Color3.fromRGB(255, 79, 79),
			TextScaled = true,
			ZIndex = 3
		}) or nil
	end

	v17.iconBadge = iconBadge
	local textLabel

	if props.words then
		textLabel = React.createElement(DialogueText, {
			words = props.words,
			anchorPoint = Vector2.new(0, 0.5),
			position = uDim2,
			size = uDim3,
			textXAlignment = Enum.TextXAlignment.Left,
			textColor = props.textColor,
			textTransparency = props.textTransparency,
			stroke = false,
			capLines = 1,
			frozen = dismiss ~= nil
		})
	else
		textLabel = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			AutoLocalize = false,
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesHighwayGothicjson,
			Position = uDim2,
			Size = uDim3,
			Text = props.text or "",
			TextColor3 = props.textColor or Color3.new(1, 1, 1),
			TextTransparency = props.textTransparency,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	end

	v17.textLabel = textLabel
	local hoverFade

	if props.hoverColor then
		hoverFade = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = props.hoverColor,
			BackgroundTransparency = 0.75,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.434892, 1),
			Visible = state,
			ZIndex = 0
		}, {
			uIGradient = element4,
			uICorner = element2
		}) or nil
	end

	v17.hoverFade = hoverFade
	local element5 = createElement("TextButton", v14, v17)
	local createElement2 = React.createElement
	local v25 = {
		AutoLocalize = false,
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = 0,
		Visible = 0,
		ZIndex = 0
	}
	local size3

	if v then
		size3 = UDim2.new(1, 0, 0, v)
	else
		size3 = UDim2.fromScale(1, 0.170867)
	end

	v25.Size = size3
	v25.Visible = props.visible
	v25.ZIndex = (v11 or dismiss == "chosen") and 2 or 1
	local aspectRatio

	if not v then
		aspectRatio = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 8,
			AspectType = Enum.AspectType.FitWithinMaxSize
		})
	end

	return createElement2("Frame", v25, {
		aspectRatio = aspectRatio,
		button = element5
	})
end

return React.memo(OptionButton)