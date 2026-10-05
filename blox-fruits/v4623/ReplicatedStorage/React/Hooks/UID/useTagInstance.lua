local use = require(game.ReplicatedStorage.React.Hooks.UID.use)
local useFirstTagged = require(game.ReplicatedStorage.React.Hooks.Instance.useFirstTagged)
return function(p: string)
	local v = use(p)
	return useFirstTagged(v), v
end