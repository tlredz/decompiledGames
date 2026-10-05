local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local useAll = require(game.ReplicatedStorage.React.Hooks.Island.useAll)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local CONSTANTS2 = require(game.ReplicatedStorage.React.Components.WorldTeleporter.CONSTANTS)
local DEFAULT_THEME = CONSTANTS2.DEFAULT_THEME
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		IslandCount = UILabs.Slider(12, 0, 30, 1),
		CenteredIndex = UILabs.Slider(0, 0, 30, 1),
		IsCenteredKeptInOrbit = true
	}
}, function(p)
	local v = useAll()
	local islandCount = p.controls.IslandCount
	local centeredIndex = p.controls.CenteredIndex
	local isCenteredKeptInOrbit = p.controls.IsCenteredKeptInOrbit
	local islands, centered = React.useMemo(function()
		local v4 = v[centeredIndex]
		local v5 = {}

		for i = 1, math.min(#v, islandCount) do
			local v6 = v[i]

			if v6 ~= v4 or isCenteredKeptInOrbit then
				table.insert(v5, v6)
			end
		end

		return table.freeze(v5), v4
	end, {
		v,
		islandCount,
		centeredIndex,
		isCenteredKeptInOrbit
	})
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = DEFAULT_THEME.Background:Lerp(DEFAULT_THEME.Primary, 0.5),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.85, 0.85),
		SizeConstraint = Enum.SizeConstraint.RelativeYY
	}, {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
		}),
		Rings = createElement(parentModule, {
			Islands = islands,
			Centered = centered,
			OnSelect = function(p2)
				print("selected", p2 and p2.Index.Key)
			end
		})
	})
end)