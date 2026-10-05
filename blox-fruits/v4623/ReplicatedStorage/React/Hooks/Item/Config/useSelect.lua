local React = require(game.ReplicatedStorage.Packages.React)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
return function(p)
	return React.useMemo(function()
		if p then
			return ItemConfig.Query.select(p)
		end

		return {}
	end, { p })
end