local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.Components.Map.Types)
require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local DEFINITIONS = require(game.ReplicatedStorage.React.Components.Map.DEFINITIONS)
return function(p)
	return React.useMemo(function()
		if p == "Sea1" then
			return DEFINITIONS.Sea1
		end

		return nil
	end, { p })
end