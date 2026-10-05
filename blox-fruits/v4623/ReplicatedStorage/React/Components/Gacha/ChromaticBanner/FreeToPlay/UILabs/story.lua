local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local FreeToPlay = require(game.ReplicatedStorage.React.Components.Gacha.ChromaticBanner.FreeToPlay)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
local v = {
	["2 Weeks"] = 1209600,
	["1 Day"] = 86400,
	["7 Hours"] = 25200,
	["1 Hour"] = 3600,
	["65 Seconds"] = 65,
	["10 Seconds"] = 10
}
local v2 = {}

for k, _ in pairs(v) do
	table.insert(v2, k)
end

return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Timer = UILabs.Choose(v2, 1)
	}
}, function(p)
	local v3 = DateTime.now().UnixTimestamp + v[p.controls.Timer]
	return createElement("Frame", {
		Size = UDim2.fromScale(0.4, 0.4),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, {
		AspectRatio = createElement("UIAspectRatioConstraint", {
			AspectRatio = 2.7
		}),
		Banner = createElement(FreeToPlay, {
			TimeEnds = DateTime.fromUnixTimestamp(v3),
			BoxName = "PremiumChromaticMagnetGacha26",
			OnItemSelected = function(p2)
				print("OnItemSelected", p2)
			end
		})
	})
end)