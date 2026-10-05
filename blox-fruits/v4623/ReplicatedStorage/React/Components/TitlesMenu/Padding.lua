local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(script.Parent.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	return createElement("Frame", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Size = UDim2.new(1, 0, 1, 0),
		LayoutOrder = p.LayoutOrder
	}, { createElement("UIAspectRatioConstraint", {
			AspectRatio = p.AspectRatio
		}) })
end