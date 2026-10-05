local React = require(game.ReplicatedStorage.Packages.React)
local OptionButton = require(script.Parent.OptionButton)
local icon = {
	image = "rbxassetid://82902746806768",
	position = UDim2.fromScale(0.025, 0.5),
	size = UDim2.fromScale(0.115925, 0.736524)
}

local function ChatButton(props)
	return React.createElement(OptionButton, {
		text = props.text,
		words = props.words,
		iconOverride = props.icon,
		effect = props.effect,
		icon = icon,
		hoverColor = Color3.fromRGB(191, 191, 191),
		layoutOrder = props.layoutOrder or 9,
		visible = props.visible,
		dismiss = props.dismiss,
		modal = props.modal,
		onActivated = props.onActivated,
		onHoverStateChanged = props.onHoverStateChanged
	})
end

return ChatButton