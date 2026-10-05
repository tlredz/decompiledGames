local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Name = "Angel",
		Version = "V3",
		RerollCount = UILabs.Slider(9, 0, 50, 1)
	}
}, function(_)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.3, 0.85),
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}, {
		Inspect = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(-0.02, 0.5),
			Size = UDim2.fromScale(1, 1)
		}, {
			ItemInspect = createElement(parentModule, {
				OnAction = function(p)
					print("action", p)
				end,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(1.02686, 0.511275),
				Size = UDim2.fromScale(0.39104, 0.766386)
			})
		})
	})
end)