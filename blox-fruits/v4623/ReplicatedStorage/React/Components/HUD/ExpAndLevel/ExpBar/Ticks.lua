local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local segmentCount = p.SegmentCount or 9
	local children = {}

	for i = 1, segmentCount - 1 do
		children[`Line{i}`] = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			ClipsDescendants = true,
			Position = UDim2.fromScale(i / segmentCount, 0.5),
			Size = UDim2.new(0, 2, 0.5, 0)
		})
	end

	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ClipsDescendants = true
	}, p), {
		Lines = createElement(React.Fragment, {}, children)
	})
end