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
		IsDisabled = false,
		SizePx = UILabs.Slider(32, 8, 200, 1)
	}
}, function(p)
	local sizePx = p.controls.SizePx
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.HEADER.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(math.round(sizePx * 4), (math.round(sizePx * 2)))
	}, {
		ExitButton = createElement(parentModule, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			IsDisabled = p.controls.IsDisabled,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(sizePx, sizePx),
			OnExit = function()
				print("exit")
			end
		})
	})
end)