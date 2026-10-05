local React = require(game.ReplicatedStorage.Packages.React)
local OptionButton = require(script.Parent.OptionButton)
local color = Color3.fromRGB(255, 214, 49)
local icon = {
	image = "rbxassetid://110886030681086",
	color = color,
	position = UDim2.fromScale(0.0247287, 0.5),
	size = UDim2.fromScale(0.115925, 0.736524)
}

local function QuestRecommendedButton(props)
	return React.createElement(OptionButton, {
		text = props.text,
		words = props.words,
		iconOverride = props.icon,
		effect = props.effect,
		textColor = color,
		icon = icon,
		hoverColor = color,
		layoutOrder = props.layoutOrder,
		visible = props.visible,
		dismiss = props.dismiss,
		modal = props.modal,
		onActivated = props.onActivated,
		onHoverStateChanged = props.onHoverStateChanged
	})
end

return QuestRecommendedButton