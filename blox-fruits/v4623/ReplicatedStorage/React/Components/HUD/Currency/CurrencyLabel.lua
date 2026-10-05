local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	return createElement("TextLabel", RobloxTypes.mergeTextLabel({
		AutoLocalize = false,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		TextScaled = true,
		TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
		TextXAlignment = Enum.TextXAlignment.Left
	}, p), {
		UIStroke = React.createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.025
		})
	})
end