local React = require(game.ReplicatedStorage.Packages.React)
local OutlinedMaterialIconsHD = require(game.ReplicatedStorage.Packages.OutlinedMaterialIconsHD)
local OptionButton = require(script.Parent.OptionButton)
local color = Color3.fromRGB(180, 180, 180)
local icon = {
	image = OutlinedMaterialIconsHD.lock.Image,
	imageRectOffset = OutlinedMaterialIconsHD.lock.ImageRectOffset,
	imageRectSize = OutlinedMaterialIconsHD.lock.ImageRectSize,
	color = color,
	transparency = 0.25,
	scaleType = Enum.ScaleType.Fit,
	position = UDim2.fromScale(0.0247287, 0.5),
	size = UDim2.fromScale(0.115925, 0.736524)
}

local function QuestLockedButton(props)
	return React.createElement(OptionButton, {
		text = props.text,
		words = props.words,
		iconOverride = props.icon,
		effect = props.effect,
		textColor = color,
		textTransparency = 0.25,
		backgroundColor = Color3.fromRGB(40, 40, 40),
		borderColor = Color3.fromRGB(72, 72, 72),
		icon = icon,
		layoutOrder = props.layoutOrder,
		visible = props.visible,
		dismiss = props.dismiss,
		modal = props.modal,
		onHoverStateChanged = props.onHoverStateChanged
	})
end

return QuestLockedButton