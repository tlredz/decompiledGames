local React = require(game.ReplicatedStorage.Packages.React)
local ItemReplicationOverride = require(game.ReplicatedStorage.React.Contexts.ItemReplicationOverride)
return function(p)
	local v = React.useContext(ItemReplicationOverride)
	return React.createElement(ItemReplicationOverride.Provider, {
		value = p.Override or v
	}, p.children)
end