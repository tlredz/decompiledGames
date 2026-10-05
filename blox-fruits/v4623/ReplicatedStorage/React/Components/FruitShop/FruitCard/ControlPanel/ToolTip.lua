local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	return createElement("TextLabel", RobloxTypes.mergeTextLabel({
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.BODY,
		Position = UDim2.fromScale(0.5, -0.185),
		Size = UDim2.fromScale(10, 0.5),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextWrapped = true
	}, p), {
		UIStroke = createElement("UIStroke")
	})
end