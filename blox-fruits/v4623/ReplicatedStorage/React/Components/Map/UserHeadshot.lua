local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	return createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Image = `rbxthumb://type=AvatarHeadShot&id={props.UserId}&w=420&h=420`
	}, props), {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
		}),
		UIStroke = createElement("UIStroke", {
			Color = props.BorderColor3 or CONSTANTS.COLOR.PALETTE.WHITE,
			Thickness = props.BorderSizePixel or 2
		})
	})
end