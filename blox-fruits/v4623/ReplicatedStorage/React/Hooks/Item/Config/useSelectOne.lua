local React = require(game.ReplicatedStorage.Packages.React)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
return function(p)
	return React.useMemo(function()
		if p then
			return ItemConfig.Query.selectOne(p):asNullable()
		end

		return nil
	end, { p })
end