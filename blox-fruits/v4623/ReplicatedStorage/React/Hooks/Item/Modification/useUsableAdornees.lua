local React = require(game.ReplicatedStorage.Packages.React)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local useAdorneeData = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useAdorneeData)
return function()
	local v = useAdorneeData()
	return React.useMemo(function()
		local usableAdornees = Modification.getUsableAdornees(v)
		table.freeze(usableAdornees)
		return usableAdornees
	end, { v })
end