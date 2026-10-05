local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local Shop = require(game.ReplicatedStorage.React.Components.Gacha.ChromaticBanner.Shop)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox
}, function(_)
	return createElement("Frame", {
		Size = UDim2.fromScale(0.4, 0.4),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, {
		AspectRatio = createElement("UIAspectRatioConstraint", {
			AspectRatio = 2.7
		}),
		Banner = createElement(Shop, {
			TimeEnds = DateTime.fromUnixTimestamp(DateTime.now().UnixTimestamp + 36749),
			BoxName = "PremiumChromaticMagnetGacha26",
			OnPurchase = function()
				print("purchase")
			end,
			OnItemSelected = function(p)
				print("OnItemSelected", p)
			end
		})
	})
end)