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
		Health = UILabs.Slider(72, 0, 100, 1),
		Overshield = UILabs.Slider(0, 0, 100, 1),
		Energy = UILabs.Slider(45, 0, 100, 1),
		PainTransformed = false
	}
}, function(p)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.3)
	}, {
		UIListLayout = createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = CONSTANTS.SPACING.PADDING.SCALE.LG,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		Health = createElement(parentModule, {
			Alpha = p.controls.Health / 100,
			Label = "Health",
			ValueText = `{p.controls.Health}/100`,
			LayoutOrder = 1,
			OverflowAlpha = p.controls.Overshield / 100,
			Size = UDim2.fromScale(0.8, 0.2),
			Variant = p.controls.PainTransformed and "Red" or "Green"
		}),
		Energy = createElement(parentModule, {
			Alpha = p.controls.Energy / 100,
			Label = "Energy",
			ValueText = `{p.controls.Energy}/100`,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.8, 0.2),
			Variant = "Blue"
		})
	})
end)