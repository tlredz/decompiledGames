local React = require(game.ReplicatedStorage.Packages.React)
local Navigation = require(game.ReplicatedStorage.React.Contexts.Inventory.Navigation)
require(game.ReplicatedStorage.PseudoEnum)
local useConfig = require(game.ReplicatedStorage.React.Hooks.Inventory.useConfig)
return function()
	local v = useConfig()
	local v2 = React.useContext(Navigation)
	local v3 = React.useMemo(function()
		if v.Layout[v2.Group] then
			return v2.Group
		end

		local v4 = {}

		for k, _ in v.Layout do
			table.insert(v4, k)
		end

		table.sort(v4, function(a, b)
			return a < b
		end)
		return v4[1]
	end, { v2.Group, v })
	assert(v3, "no valid groups exist")
	return v3, function(p)
		if p == v2.Group then
			return
		end

		local v4 = v.Layout[p]

		if v4 then
			local bracket = v2.Bracket

			if bracket and not table.find(v4.Brackets, bracket) then
				bracket = nil
			end

			local sortType = v2.SortType

			if sortType and not table.find(v4.SortingTypes, sortType) then
				sortType = nil
			end

			v2.SetNavigation(p, bracket, sortType, v2.InitialSelection)
		end
	end
end