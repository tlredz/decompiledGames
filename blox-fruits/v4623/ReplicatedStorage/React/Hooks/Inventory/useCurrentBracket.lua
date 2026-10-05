local React = require(game.ReplicatedStorage.Packages.React)
local Navigation = require(game.ReplicatedStorage.React.Contexts.Inventory.Navigation)
require(game.ReplicatedStorage.PseudoEnum)
local useConfig = require(game.ReplicatedStorage.React.Hooks.Inventory.useConfig)
local useCurrentGroup = require(game.ReplicatedStorage.React.Hooks.Inventory.useCurrentGroup)
return function()
	local v = useConfig()
	local v2 = React.useContext(Navigation)
	local bracket = v2.Bracket
	local v3 = useCurrentGroup()
	local v4 = v.Layout[v3]

	if bracket and not table.find(v4.Brackets, bracket) then
		bracket = nil
	end

	return bracket, function(p)
		if p == bracket then
			return
		end

		local v5 = v3
		local v6 = v.Layout[v5]

		if v6 and p and not table.find(v6.Brackets, p) then
			for k, v8 in v.Layout do
				if not (k ~= v5 and table.find(v8.Brackets, p)) then
					continue
				end

				v5 = k
				break
			end
		end

		local v7 = v.Layout[v5]

		if not v7 then
			return
		end

		local sortType = v2.SortType

		if sortType and not table.find(v7.SortingTypes, sortType) then
			sortType = nil
		end

		v2.SetNavigation(v5, p, sortType, v2.InitialSelection)
	end
end