local React = require(game.ReplicatedStorage.Packages.React)
local OptionButton = require(script.Parent.OptionButton)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local GOLD_600 = CONSTANTS.COLOR.PALETTE.GOLD_600
local icon = {
	image = "rbxassetid://140195625329127",
	color = GOLD_600,
	position = UDim2.fromScale(0.0172194, 0.5),
	size = UDim2.fromScale(0.103021, 0.837936),
	effect = "Wiggle"
}

local function GachaButton(props)
	return React.createElement(OptionButton, {
		text = props.text,
		words = props.words,
		iconOverride = props.icon,
		effect = "PartyGlow",
		textColor = GOLD_600,
		icon = icon,
		hoverColor = GOLD_600,
		layoutOrder = props.layoutOrder or -99998,
		visible = props.visible,
		dismiss = props.dismiss,
		modal = props.modal,
		onActivated = props.onActivated,
		onHoverStateChanged = props.onHoverStateChanged
	})
end

return GachaButton