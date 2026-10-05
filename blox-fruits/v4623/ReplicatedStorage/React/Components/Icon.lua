local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Util.TypeUtil)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local image

	if type(props.Icon) == "table" then
		image = props.Icon.Image
	else
		image = props.Icon or props.Image or ""
	end

	local imageRectOffset

	if type(props.Icon) == "table" then
		imageRectOffset = props.Icon.ImageRectOffset
	else
		imageRectOffset = props.ImageRectOffset or Vector2.zero
	end

	local imageRectSize

	if type(props.Icon) == "table" then
		imageRectSize = props.Icon.ImageRectSize
	else
		imageRectSize = props.ImageRectSize or Vector2.zero
	end

	local image2

	if type(props.BorderIcon) == "table" then
		image2 = props.BorderIcon.Image
	else
		image2 = props.BorderIcon
	end

	local imageRectOffset2

	if type(props.BorderIcon) == "table" then
		imageRectOffset2 = props.BorderIcon.ImageRectOffset
	end

	local imageRectSize2

	if type(props.BorderIcon) == "table" then
		imageRectSize2 = props.BorderIcon.ImageRectSize
	end

	local scaleType = props.ScaleType or Enum.ScaleType.Fit
	local active

	if type(props.Active) == "boolean" then
		active = props.Active
	else
		active = false
	end

	if image2 then
		return createElement("ImageLabel", RobloxTypes.mergeImageLabel({
			Active = active,
			Image = image2,
			ImageColor3 = props.BorderColor3 or Color3.new(),
			ImageRectOffset = imageRectOffset2,
			ImageRectSize = imageRectSize2,
			ImageTransparency = props.BorderTransparency,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ScaleType = scaleType
		}, props), {
			Icon = createElement("ImageLabel", {
				Active = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = props.BorderOffset and UDim2.new(
					UDim.new(0.5, 0) - props.BorderOffset.X,
					UDim.new(0.5, 0) + props.BorderOffset.Y
				) or UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				ImageTransparency = props.ImageTransparency,
				Image = image,
				ImageRectOffset = imageRectOffset,
				ImageRectSize = imageRectSize,
				ScaleType = scaleType
			})
		})
	end

	return createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		Active = active,
		Image = image,
		ImageRectOffset = imageRectOffset,
		ImageRectSize = imageRectSize,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ScaleType = scaleType
	}, props))
end