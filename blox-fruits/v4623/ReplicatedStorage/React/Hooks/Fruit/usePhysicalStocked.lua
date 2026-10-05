local React = require(game.ReplicatedStorage.Packages.React)
local useServerData = require(game.ReplicatedStorage.React.Hooks.Fruit.useServerData)
return function()
	local v = useServerData()
	return React.useMemo(function()
		if not v then
			return nil
		end

		local result = {}

		for _, v2 in v do
			if v2 and v2.OnSale then
				result[v2.Name] = true
			end
		end

		return result
	end, { v })
end