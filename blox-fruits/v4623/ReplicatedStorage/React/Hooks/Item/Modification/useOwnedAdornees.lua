local React = require(game.ReplicatedStorage.Packages.React)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local useAdorneeData = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useAdorneeData)
return function()
	local v = useAdorneeData()
	return React.useMemo(function()
		local ownedAdornees = Modification.getOwnedAdornees(v)
		table.freeze(ownedAdornees)
		return ownedAdornees
	end, { v })
end