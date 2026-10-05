local React = require(game.ReplicatedStorage.Packages.React)
local OptionButton = require(script.Parent.OptionButton)
local color = Color3.fromRGB(142, 67, 255)
local icon = {
	image = "rbxassetid://114075795708440",
	color = color,
	scaleType = Enum.ScaleType.Fit,
	position = UDim2.fromScale(0.0247287, 0.5),
	size = UDim2.fromScale(0.115925, 0.736524)
}

local function QuestBossButton(props)
	return React.createElement(OptionButton, {
		text = props.text,
		words = props.words,
		iconOverride = props.icon,
		effect = props.effect,
		textColor = color,
		icon = icon,
		layoutOrder = props.layoutOrder,
		visible = props.visible,
		dismiss = props.dismiss,
		modal = props.modal,
		onActivated = props.onActivated,
		onHoverStateChanged = props.onHoverStateChanged
	})
end

return QuestBossButton