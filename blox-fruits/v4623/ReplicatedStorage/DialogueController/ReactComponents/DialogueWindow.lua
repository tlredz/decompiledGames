local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local DialogueTitle = require(script.Parent.DialogueTitle)
local DialogueText = require(script.Parent.DialogueText)
local RenderableLayer = require(script.Parent.RenderableLayer)
local ArrowIndicator = require(script.Parent.ArrowIndicator)
local rbxassetfontsfamiliesHighwayGothicjson = Font.new("rbxasset://fonts/families/HighwayGothic.json")
local element = React.createElement("UICorner", {
	CornerRadius = UDim.new(0.03, 0)
})
local element2 = React.createElement("ImageLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	Image = "rbxassetid://13472538818",
	ImageColor3 = Color3.new(),
	ImageRectOffset = Vector2.new(0, 32),
	ImageRectSize = Vector2.new(64, 32),
	Position = UDim2.fromScale(0.5, 0),
	Size = UDim2.fromScale(1.3, 3),
	ZIndex = 0
})
local uDim = UDim2.fromScale(0.5, 0.46)
local uDim2 = UDim2.fromScale(0.5, 0.34)
local uDim3 = UDim2.fromScale(0.92, 0.75)
local uDim4 = UDim2.fromScale(0, 0.035)
local uDim5 = UDim2.fromScale(0, 0.05)
local uDim6 = UDim2.fromScale(0.5, 0.94)

-- equivalent calls inferred from this helper; original call sites unknown
local function hasText(value: string?)
	return value ~= nil and string.find(value, "%S") ~= nil
end

local function DialogueWindow(props)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(0)
	local subtitle = props.subtitle
	local v

	if subtitle == nil then
		v = false
	else
		v = string.find(subtitle, "%S") ~= nil
	end

	local subtitle2

	if v then
		subtitle2 = props.subtitle
	end

	local v3 = hasText(props.name) or subtitle2 ~= nil or props.titleSprite ~= nil
	local position2

	if subtitle2 then
		position2 = uDim + uDim5
	else
		position2 = uDim2 + uDim4
	end

	local onClick = props.onClick
	local v5

	if onClick == nil then
		v5 = false
	else
		v5 = props.pageButtonSelectable == true
	end

	local position = props.position or UDim2.fromScale(0.5, 0.925)
	local scale = (props.size or UDim2.fromScale(0.75, 0.2)).Y.Scale
	local current4 = 1 - position.Y.Scale + scale * 1.05
	local slide = props.slide or "shown"
	local v7

	if slide == "shown" then
		v7 = 0
	elseif slide == "title" then
		v7 = 1 - position.Y.Scale + scale * 0.64
	else
		v7 = current4
	end

	if ref2.current == nil then
		if not props.entrance then
			current4 = v7
		end

		ref2.current = current4
	end

	React.useEffect(function()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			local current = ref.current

			if not current then
				return
			end

			local current2 = ref2.current or 0
			local current3 = ref3.current or 0
			local v8 = math.min(dt, 0.03333333333333333)
			local current5 = current3 + (140 * (v7 - current2) - 14 * current3) * v8
			local current6 = current2 + current5 * v8

			if math.abs(current6 - v7) < 0.0001 and math.abs(current5) < 0.001 then
				current6 = v7
				heartbeatConnection:Disconnect()
				current5 = 0
			end

			ref2.current = current6
			ref3.current = current5
			current.Position = position + UDim2.fromScale(0, current6)
		end)
		return function()
			heartbeatConnection:Disconnect()
		end
	end, { v7, position })
	local v8 = {
		uICorner = element,
		windowFade = element2,
		pageButton = 0,
		dialogueText = 0,
		renderables = 0,
		dialogueTitleFrame = 0,
		nextArrow = 0
	}
	local pageButton

	if v5 then
		local createElement = React.createElement
		local onClicksByActivated = {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Modal = props.modal ~= false,
			Position = UDim2.fromScale(0.5, 0.5),
			Selectable = true,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			ZIndex = 1,
			[React.Event.Activated] = onClick
		}
		pageButton = createElement("TextButton", onClicksByActivated) or nil
	end

	v8.pageButton = pageButton
	local dialogueText

	if props.words then
		dialogueText = React.createElement(DialogueText, {
			words = props.words,
			visibleGraphemes = props.visibleGraphemes,
			position = position2,
			size = uDim3,
			capLines = 4,
			minTextSize = 18,
			textYAlignment = Enum.TextYAlignment.Top,
			isolateWords = true
		})
	else
		dialogueText = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesHighwayGothicjson,
			MaxVisibleGraphemes = props.maxVisibleGraphemes or -1,
			Position = position2,
			RichText = true,
			Size = uDim3,
			Text = props.text or "",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextYAlignment = Enum.TextYAlignment.Top
		}, {
			uITextSizeConstraint = React.createElement("UITextSizeConstraint", {
				MinTextSize = 18
			}),
			uIStroke = React.createElement("UIStroke", {
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.06
			})
		})
	end

	v8.dialogueText = dialogueText
	local renderables

	if props.renderables and #props.renderables > 0 then
		renderables = React.createElement(RenderableLayer, {
			Renderables = props.renderables,
			Position = position2,
			Size = uDim3,
			ZIndex = 2
		})
	end

	v8.renderables = renderables
	local dialogueTitleFrame

	if v3 then
		dialogueTitleFrame = React.createElement(DialogueTitle, {
			name = props.name,
			titleSprite = props.titleSprite,
			subtitle = subtitle2
		})
	end

	v8.dialogueTitleFrame = dialogueTitleFrame
	local nextArrow

	if props.showNextArrow then
		nextArrow = React.createElement(ArrowIndicator, {
			direction = "down",
			variant = "proceed",
			anchorPoint = Vector2.new(0.5, 1),
			position = uDim6,
			size = UDim2.fromScale(1, 0.12),
			bounce = true,
			zIndex = 3
		})
	end

	v8.nextArrow = nextArrow

	if props.children then
		for k, v14 in props.children do
			v8[k] = v14
		end
	end

	return React.createElement("Frame", {
		ref = ref,
		Active = false,
		AnchorPoint = Vector2.new(0.5, 1),
		AutoLocalize = false,
		BackgroundTransparency = 1,
		Position = position + UDim2.fromScale(0, ref2.current or 0),
		Size = props.size or UDim2.fromScale(0.75, 0.2),
		Visible = props.visible ~= false,
		ZIndex = 2
	}, v8)
end

return DialogueWindow