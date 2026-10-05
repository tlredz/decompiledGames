local React = require(game.ReplicatedStorage.Packages.React)
local Util = require(script.Parent.Util)
local rbxassetfontsfamiliesHighwayGothicjson = Font.new("rbxasset://fonts/families/HighwayGothic.json")

local function OutlinedText(props)
	local text = Util.toText(props.Text)
	local zIndex = props.ZIndex or 1
	local mergeProps = Util.mergeProps({
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		FontFace = props.FontFace or rbxassetfontsfamiliesHighwayGothicjson,
		Position = props.Position or UDim2.fromScale(0, 0.5),
		Size = props.Size or UDim2.fromScale(1, 1),
		Text = text,
		TextColor3 = props.TextColor or Color3.new(1, 1, 1),
		TextScaled = Util.valueOrDefault(props.TextScaled, true),
		TextTransparency = props.TextTransparency or 0,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
		ZIndex = zIndex
	}, props.RootProps)
	local children = {}

	if Util.valueOrDefault(props.ShowStroke, true) then
		children.uIStroke = React.createElement("UIStroke", Util.mergeProps({}, props.StrokeProps))
	end

	if not Util.valueOrDefault(props.Layered, false) then
		return React.createElement("TextLabel", mergeProps, children)
	end

	local createElement = React.createElement
	local mergeProps2 = Util.mergeProps({
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		FontFace = props.FontFace or rbxassetfontsfamiliesHighwayGothicjson,
		Position = props.FrontPosition or UDim2.fromScale(0.5, 0.435),
		Size = props.FrontSize or UDim2.fromScale(1, 1),
		Text = text,
		TextColor3 = props.FrontTextColor or Color3.new(1, 1, 1),
		TextScaled = Util.valueOrDefault(props.TextScaled, true),
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
		ZIndex = zIndex + 1
	}, props.FrontTextProps)
	local uIStroke

	if Util.valueOrDefault(props.ShowStroke, true) then
		uIStroke = React.createElement("UIStroke", Util.mergeProps({}, props.FrontStrokeProps))
	end

	children.textLabel = createElement("TextLabel", mergeProps2, {
		uIStroke = uIStroke
	})
	return React.createElement("TextLabel", mergeProps, children)
end

return React.memo(OutlinedText)