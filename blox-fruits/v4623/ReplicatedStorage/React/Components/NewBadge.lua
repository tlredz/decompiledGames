local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	return createElement("TextLabel", {
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO, Enum.FontWeight.Heavy, Enum.FontStyle.Italic),
		Position = props.Position or UDim2.fromScale(0.9, 0.15),
		Size = props.Size or UDim2.fromScale(1.1, 1.1),
		Text = "!",
		TextColor3 = Color3.new(1, 0, 0),
		TextScaled = true,
		TextWrapped = true,
		Visible = props.Visible == nil or props.Visible,
		ZIndex = props.ZIndex or 10
	}, {
		uIStroke = createElement("UIStroke")
	})
end