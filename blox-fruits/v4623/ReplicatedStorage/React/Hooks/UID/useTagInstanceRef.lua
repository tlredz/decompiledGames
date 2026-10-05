local use = require(game.ReplicatedStorage.React.Hooks.UID.use)
local useTagRef = require(game.ReplicatedStorage.React.Hooks.Instance.useTagRef)
return function(p: string, flag: boolean?)
	local v = use(p)
	return useTagRef(v, flag), v
end