local React = require(game.ReplicatedStorage.Packages.React)
local OptionButton = require(script.Parent.OptionButton)
local color = Color3.fromRGB(76, 214, 90)
local icon = {
	image = "rbxassetid://126491458606904",
	color = color,
	position = UDim2.fromScale(0.0172194, 0.5),
	size = UDim2.fromScale(0.103021, 0.837936)
}

local function AcceptButton(props)
	return React.createElement(OptionButton, {
		text = props.text or "Accept",
		words = props.words,
		iconOverride = props.icon,
		effect = props.effect,
		textColor = color,
		icon = icon,
		hoverColor = color,
		layoutOrder = props.layoutOrder or -99999,
		visible = props.visible,
		dismiss = props.dismiss,
		modal = props.modal,
		onActivated = props.onActivated,
		onHoverStateChanged = props.onHoverStateChanged
	})
end

return AcceptButton