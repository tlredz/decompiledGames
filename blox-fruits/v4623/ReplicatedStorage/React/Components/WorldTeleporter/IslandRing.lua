local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local OrbitButton = require(game.ReplicatedStorage.React.Components.WorldTeleporter.OrbitButton)
require(game.ReplicatedStorage.React.Components.WorldTeleporter.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local children = {}

	for _, island in p.Islands do
		local v = island
		children[island.Key] = createElement(OrbitButton, {
			Slot = island,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			AnchorPoint = Vector2.new(0.5, 0.5),
			OnClick = function()
				local onSelect = p.OnSelect
				local v2

				if not v.IsCentered then
					v2 = v.Island
				end

				onSelect(v2)
			end
		})
	end

	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, p), children)
end