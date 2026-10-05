local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	return createElement("TextLabel", RobloxTypes.mergeTextLabel({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = Font.new("rbxasset://fonts/families/Bangers.json"),
		TextColor3 = Color3.fromRGB(255, 0, 0),
		TextScaled = true,
		TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE
	}, p))
end