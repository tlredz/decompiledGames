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
		IsActive = true,
		Rotation = UILabs.Slider(0, -180, 180, 1),
		SizePx = UILabs.Slider(260, 40, 720, 1)
	}
}, function(p)
	local sizePx = p.controls.SizePx
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(math.round(sizePx * 1.4), (math.round(sizePx * 1.4)))
	}, {
		Surface = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(sizePx, sizePx)
		}, {
			GlowGradient = createElement(parentModule, {
				IsActive = p.controls.IsActive,
				Rotation = p.controls.Rotation
			})
		})
	})
end)