local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.Util.AssetItemData)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local main = p.Icon.Main
	local modifier = p.Icon.Modifier
	local modifierColor = p.Icon.ModifierColor
	local variant = p.Icon.Variant
	local variantColor = p.Icon.VariantColor
	local mergeImageLabel = RobloxTypes.mergeImageLabel
	local v3 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = 0,
		ImageRectOffset = 0,
		ImageRectSize = 0,
		ScaleType = 0
	}
	local image

	if type(main.Image) == "string" then
		image = main.Image
	end

	v3.Image = image
	v3.ImageRectOffset = main.ImageRectOffset
	v3.ImageRectSize = main.ImageRectSize
	v3.ScaleType = Enum.ScaleType.Fit
	local v5 = mergeImageLabel(v3, p)
	local v6 = {
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint"),
		ModifierIcon = 0,
		VariantIcon = 0
	}
	local modifierIcon

	if modifier ~= nil then
		local v10 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0,
			ImageColor3 = 0,
			Position = 0,
			ScaleType = 0,
			Size = 0,
			SizeConstraint = 0,
			ZIndex = 0
		}
		local image2

		if type(modifier.Image) == "string" then
			image2 = modifier.Image
		end

		v10.Image = image2
		v10.ImageRectOffset = modifier.ImageRectOffset
		v10.ImageRectSize = modifier.ImageRectSize
		v10.ImageColor3 = modifierColor or CONSTANTS.COLOR.PALETTE.WHITE
		v10.Position = UDim2.fromScale(0.2, 0.8)
		v10.ScaleType = Enum.ScaleType.Fit
		v10.Size = UDim2.fromScale(0.42, 0.42)
		v10.SizeConstraint = Enum.SizeConstraint.RelativeXX
		v10.ZIndex = CONSTANTS.LAYER.OVERLAY
		modifierIcon = createElement("ImageLabel", v10)
	end

	v6.ModifierIcon = modifierIcon
	local variantIcon

	if variant ~= nil then
		local v11 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0,
			ImageColor3 = 0,
			Position = 0,
			ScaleType = 0,
			Size = 0,
			SizeConstraint = 0,
			ZIndex = 0
		}
		local image2

		if type(variant.Image) == "string" then
			image2 = variant.Image
		end

		v11.Image = image2
		v11.ImageRectOffset = variant.ImageRectOffset
		v11.ImageRectSize = variant.ImageRectSize
		v11.ImageColor3 = variantColor or CONSTANTS.COLOR.PALETTE.WHITE
		v11.Position = UDim2.fromScale(0.8, 0.8)
		v11.ScaleType = Enum.ScaleType.Fit
		v11.Size = UDim2.fromScale(0.55, 0.55)
		v11.SizeConstraint = Enum.SizeConstraint.RelativeXX
		v11.ZIndex = CONSTANTS.LAYER.OVERLAY
		variantIcon = createElement("ImageLabel", v11)
	end

	v6.VariantIcon = variantIcon
	return createElement("ImageLabel", v5, v6)
end