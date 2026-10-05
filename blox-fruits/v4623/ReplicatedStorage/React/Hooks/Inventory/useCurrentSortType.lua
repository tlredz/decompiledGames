local React = require(game.ReplicatedStorage.Packages.React)
local Navigation = require(game.ReplicatedStorage.React.Contexts.Inventory.Navigation)
require(game.ReplicatedStorage.PseudoEnum)
local useConfig = require(game.ReplicatedStorage.React.Hooks.Inventory.useConfig)
local useCurrentGroup = require(game.ReplicatedStorage.React.Hooks.Inventory.useCurrentGroup)
return function()
	local v = useConfig()
	local v2 = React.useContext(Navigation)
	local v3 = useCurrentGroup()
	local v4 = v.Layout[v3]
	local sortType = v2.SortType
	local _ = sortType and v4 and not table.find(v4.SortingTypes, sortType)
	return v2.SortType, function(p)
		if p == v2.SortType then
			return
		end

		local v5 = v.Layout[v3]

		if not v5 then
			return
		end

		if p and not table.find(v5.SortingTypes, p) then
			p = nil
		end

		v2.SetNavigation(v3, v2.Bracket, p, v2.InitialSelection)
	end
end