local React = require(game.ReplicatedStorage.Packages.React)
local Util = require(script.Parent.Util)
local rbxassetfontsfamiliesHighwayGothicjson = Font.new(
	"rbxasset://fonts/families/HighwayGothic.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)
local color = Color3.fromRGB(118, 118, 118)
local color2 = Color3.fromRGB(65, 65, 65)
local color3 = Color3.fromRGB(150, 150, 150)
local color4 = Color3.fromRGB(255, 79, 79)
local color5 = Color3.fromRGB(131, 40, 40)
local color6 = Color3.fromRGB(255, 112, 112)

local function AbandonQuestButton(props)
	local state, setState = React.useState(false)
	React.useEffect(function()
		if not Util.valueOrDefault(props.Visible, true) then
			setState(false)
		end

		return function() end
	end, { props.Visible })
	React.useEffect(function()
		if not state then
			return function() end
		end

		local thread = task.delay(Util.valueOrDefault(props.ConfirmTimeout, 3), function()
			setState(false)
		end)
		return function()
			task.cancel(thread)
		end
	end, { state, props.ConfirmTimeout })
	local mergeProps = Util.mergeProps
	local v = {
		AnchorPoint = Vector2.new(1, 0.5)
	}
	local backgroundColor

	if state then
		backgroundColor = color4
	else
		backgroundColor = color
	end

	v.BackgroundColor3 = backgroundColor
	local borderColor

	if state then
		borderColor = color5
	else
		borderColor = color2
	end

	v.BorderColor3 = borderColor
	v.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	v.LayoutOrder = -999
	v.Position = UDim2.fromScale(0.96, 0.5)
	local size

	if state then
		size = UDim2.fromScale(0.36, 0.75)
	else
		size = UDim2.fromScale(0.75, 0.75)
	end

	v.Size = size
	v.Text = ""
	v.TextColor3 = Color3.new()
	v.TextScaled = true
	v.TextStrokeColor3 = Color3.new(1, 1, 1)
	v.Visible = Util.valueOrDefault(props.Visible, true)
	v.ZIndex = 2

	v[React.Event.Activated] = function()
		if not state then
			setState(true)
		elseif props.OnActivated then
			props.OnActivated()
		end
	end

	local v5 = mergeProps(v, props.RootProps)
	local createElement = React.createElement
	local createElement2 = React.createElement
	local mergeProps2 = Util.mergeProps
	local v8 = {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = 0,
		BorderSizePixel = 0,
		Position = 0,
		Size = 0
	}
	local backgroundColor2

	if state then
		backgroundColor2 = color6
	else
		backgroundColor2 = color3
	end

	v8.BackgroundColor3 = backgroundColor2
	v8.Position = UDim2.fromScale(0.5, 0.5)
	v8.Size = UDim2.fromScale(0.94, 0.47)
	local children = {
		trans = createElement2("Frame", mergeProps2(v8, props.HighlightProps)),
		icon = React.createElement("ImageLabel", Util.mergeProps({
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = props.Icon or "rbxassetid://127503254560275",
			ImageRectSize = Vector2.new(100, 100),
			Position = UDim2.fromScale(0.51, 0.5),
			Size = UDim2.fromScale(1, 1),
			Visible = not state and Util.valueOrDefault(props.ShowIcon, false)
		}, props.IconProps)),
		uIAspectRatioConstraint = 0,
		textLabel = 0
	}
	local uIAspectRatioConstraint

	if not state then
		uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", props.AspectRatioProps)
	end

	children.uIAspectRatioConstraint = uIAspectRatioConstraint
	local createElement3 = React.createElement
	local mergeProps3 = Util.mergeProps
	local v12 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesHighwayGothicjson,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Text = 0,
		TextColor3 = 0,
		TextScaled = true,
		ZIndex = 0
	}
	local toText = Util.toText
	local v13

	if state then
		v13 = props.ConfirmText
	else
		v13 = props.Text
	end

	v12.Text = toText(v13, state and "Abandon" or "?")
	v12.TextColor3 = Color3.new(1, 1, 1)
	v12.ZIndex = v5.ZIndex
	children.textLabel = createElement3("TextLabel", mergeProps3(v12, props.TextProps), {
		uIStroke = React.createElement("UIStroke", Util.mergeProps({}, props.TextStrokeProps))
	})
	return createElement("TextButton", v5, children)
end

return React.memo(AbandonQuestButton)