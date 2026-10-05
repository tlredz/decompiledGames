local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local Timer = require(game.ReplicatedStorage.React.Components.Gacha.ChromaticBanner.Timer)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BackgroundTransparency = 0.35
	}, p), {
		UIGradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(250, 245, 5)),
				ColorSequenceKeypoint.new(0.609672, Color3.fromRGB(250, 119, 143)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(206, 99, 216))
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.612702, 0.125),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		TextLabel = createElement(Timer, {
			TimeEnds = p.TimeEnds
		})
	})
end