local React = require(game.ReplicatedStorage.Packages.React)
local AlertIcon = require(script.Parent.AlertIcon)
local uDim = UDim2.fromScale(0.0100003, 0.5)
local uDim2 = UDim2.fromScale(0.508295, 0.817692)

local function valueOrDefault(p, p2)
	if p == nil then
		return p2
	end

	return p
end

local function AlertBubble(props)
	local zIndex = props.ZIndex or 20
	local createElement = React.createElement
	local v = {
		Active = false,
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(23, 23, 23),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Interactable = false,
		Position = 0,
		Size = 0,
		Visible = 0,
		ZIndex = 0
	}
	local backgroundTransparency = props.BackgroundTransparency
	v.BackgroundTransparency = backgroundTransparency == nil and 0.1 or backgroundTransparency
	v.Position = props.Position or UDim2.fromScale(0.5, 0.5)
	v.Size = props.Size or UDim2.fromScale(0.1, 0.1)
	local visible = props.Visible
	v.Visible = visible == nil or visible
	v.ZIndex = zIndex
	local children = {
		uICorner = React.createElement("UICorner", {
			BottomLeftRadius = UDim.new(1, 0),
			BottomRightRadius = UDim.new(1, 0),
			CornerRadius = UDim.new(1, 0),
			TopLeftRadius = UDim.new(1, 0),
			TopRightRadius = UDim.new(1, 0)
		}),
		uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint"),
		uIStroke = React.createElement("UIStroke", {
			Color = props.BorderColor or Color3.new(),
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = props.BorderThickness or 0.04
		}),
		colorFade = 0,
		arrow = 0,
		AlertIcon = 0
	}
	local createElement2 = React.createElement
	local v2 = {
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = props.GlowColor or Color3.fromRGB(255, 230, 53),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Interactable = false,
		Position = 0,
		Size = 0,
		ZIndex = 0
	}
	local glowTransparency = props.GlowTransparency
	v2.BackgroundTransparency = glowTransparency == nil and 0.6 or glowTransparency
	v2.Position = UDim2.fromScale(0.5, 0.5)
	v2.Size = UDim2.fromScale(1, 1)
	v2.ZIndex = zIndex - 1
	children.colorFade = createElement2("Frame", v2, {
		uIGradient = React.createElement("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.626401, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		uICorner = React.createElement("UICorner", {
			BottomLeftRadius = UDim.new(1, 0),
			BottomRightRadius = UDim.new(1, 0),
			CornerRadius = UDim.new(1, 0),
			TopLeftRadius = UDim.new(1, 0),
			TopRightRadius = UDim.new(1, 0)
		})
	})
	local createElement3 = React.createElement
	local v3 = {
		Active = false,
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Image = props.ArrowImage or "rbxassetid://89175120476098",
		Interactable = false,
		Position = props.ArrowPosition or uDim,
		Rotation = 0,
		ScaleType = 0,
		Size = 0,
		Visible = 0,
		ZIndex = 0
	}
	local arrowAngle = props.ArrowAngle
	v3.Rotation = arrowAngle == nil and 0 or arrowAngle
	v3.ScaleType = Enum.ScaleType.Fit
	v3.Size = props.ArrowSize or uDim2
	local showArrow = props.ShowArrow
	v3.Visible = showArrow == nil or showArrow
	v3.ZIndex = zIndex + 1
	children.arrow = createElement3("ImageLabel", v3, {
		uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.621622
		}),
		uIGradient = React.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 230, 53)),
				ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 214, 49)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(171, 29, 10))
			})
		})
	})
	children.AlertIcon = React.createElement(AlertIcon, {
		Icon = props.Icon,
		IconRectOffset = props.IconRectOffset,
		IconRectSize = props.IconRectSize,
		IconColor = props.IconColor,
		Position = props.AlertIconPosition,
		Size = props.AlertIconSize,
		Text = props.Text,
		TextBackColor = props.TextBackColor,
		TextFrontColor = props.TextFrontColor,
		TextBackStrokeColor = props.TextBackStrokeColor,
		TextFrontStrokeColor = props.TextFrontStrokeColor,
		ZIndex = zIndex + 1
	})
	return createElement("Frame", v, children)
end

return React.memo(AlertBubble)