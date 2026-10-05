local React = require(game.ReplicatedStorage.Packages.React)
local Map = require(game.ReplicatedStorage.Definitions.Map)
require(game.ReplicatedStorage.Definitions.Map.Types)
return function()
	local currentMap = Map.findCurrentMap()
	return React.useMemo(function()
		if currentMap then
			return table.freeze(table.clone(currentMap.Islands))
		end

		return table.freeze({})
	end, { currentMap and currentMap.Key or nil })
end