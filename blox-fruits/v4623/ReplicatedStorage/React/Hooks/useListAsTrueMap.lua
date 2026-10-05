local React = require(game.ReplicatedStorage.Packages.React)
return function(list)
	return React.useMemo(function()
		local result = {}

		for _, v in list do
			result[v] = true
		end

		if table.isfrozen(list) then
			table.freeze(result)
		end

		return result
	end, { list })
end