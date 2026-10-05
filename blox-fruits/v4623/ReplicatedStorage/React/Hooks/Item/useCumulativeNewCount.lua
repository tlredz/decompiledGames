local React = require(game.ReplicatedStorage.Packages.React)
local ItemReplication = require(game.ReplicatedStorage.React.Factories.Hooks.ItemReplication)
local v = ItemReplication.useAll(ItemReplication.KEYS.NEW_COUNT)
return function(p)
	local v2 = v(p)
	return React.useMemo(function()
		local total = 0

		for _, v3 in v2 do
			if type(v3.Value) == "number" then
				total += v3.Value
			end
		end

		return total
	end, { v2 })
end