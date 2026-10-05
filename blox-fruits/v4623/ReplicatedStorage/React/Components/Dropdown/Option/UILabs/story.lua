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
		Text = "Consumables",
		IsSelected = false,
		IsDisabled = false,
		WidthPx = UILabs.Slider(140, 40, 480, 1),
		HeightPx = UILabs.Slider(28, 10, 90, 1)
	}
}, function(p)
	local widthPx = p.controls.WidthPx
	local heightPx = p.controls.HeightPx
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(math.round(widthPx * 1.4), (math.round(heightPx * 3)))
	}, {
		Option = createElement(parentModule, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			HeightPx = heightPx,
			IsDisabled = p.controls.IsDisabled,
			IsSelected = p.controls.IsSelected,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(widthPx, heightPx),
			Text = p.controls.Text,
			OnActivated = function()
				print("activated")
			end
		})
	})
end)