local React = require(game.ReplicatedStorage.Packages.React)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local useData = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useData)
local useAdorneeData = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useAdorneeData)
return function()
	local v = useData()
	local v2 = useAdorneeData()
	return React.useMemo(function()
		local usable = Modification.getUsable(v, v2)
		table.freeze(usable)
		return usable
	end, { v, v2 })
end