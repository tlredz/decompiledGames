local React = require(game.ReplicatedStorage.Packages.React)
local GlobalState = require(game.ReplicatedStorage.React.Contexts.GlobalState)
return function(p)
	local v = React.useMemo(function()
		return {
			Cache = {},
			Hooks = {}
		}
	end, {})
	return React.createElement(GlobalState.Provider, {
		value = p.State or v
	}, p.children)
end