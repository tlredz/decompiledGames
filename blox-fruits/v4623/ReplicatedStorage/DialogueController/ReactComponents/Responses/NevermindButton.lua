local React = require(game.ReplicatedStorage.Packages.React)
local OptionButton = require(script.Parent.OptionButton)
local icon = {
	image = "rbxassetid://117642311710245",
	position = UDim2.fromScale(0.025, 0.5),
	size = UDim2.fromScale(0.115925, 0.736524)
}

local function NevermindButton(props)
	return React.createElement(OptionButton, {
		text = props.text or "Nevermind",
		words = props.words,
		iconOverride = props.icon,
		effect = props.effect,
		icon = icon,
		hoverColor = Color3.fromRGB(255, 79, 79),
		layoutOrder = props.layoutOrder or 9999,
		visible = props.visible,
		dismiss = props.dismiss,
		modal = props.modal,
		onActivated = props.onActivated,
		onHoverStateChanged = props.onHoverStateChanged
	})
end

return NevermindButton