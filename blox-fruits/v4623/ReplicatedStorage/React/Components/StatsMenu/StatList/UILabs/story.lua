local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
require(script.Parent.Parent.Types)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local CONSTANTS2 = require(game.ReplicatedStorage.React.Components.StatsMenu.CONSTANTS)
local STATS = CONSTANTS2.STATS
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		StatCount = UILabs.Slider(#STATS, 1, #STATS, 1),
		InvestAmount = UILabs.Slider(250, 1, 1000, 1),
		AreHintsVisible = true
	}
}, function(p)
	local stats = React.useMemo(function()
		local result = {}

		for i = 1, math.min(#STATS, p.controls.StatCount) do
			table.insert(result, STATS[i])
		end

		return result
	end, { p.controls.StatCount })
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1.3, 0.9),
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}, {
		Stats = createElement(parentModule, {
			Stats = stats,
			InvestAmount = p.controls.InvestAmount,
			AreHintsVisible = p.controls.AreHintsVisible,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.102605),
			Size = UDim2.fromScale(0.97456, 0.758778),
			OnAction = function(p2)
				print("action", p2)
			end
		})
	})
end)