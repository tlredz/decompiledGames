local React = require(game.ReplicatedStorage.Packages.React)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local useData = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useData)
local useAdorneeData = require(game.ReplicatedStorage.React.Hooks.Item.Modification.useAdorneeData)
return function()
	local v = useData()
	local v2 = useAdorneeData()
	return React.useMemo(function()
		local equipped = Modification.getEquipped(v, v2)
		table.freeze(equipped)
		return equipped
	end, { v, v2 })
end