local React = require(game.ReplicatedStorage.Packages.React)
local DrawContext = require(game.ReplicatedStorage.React.Contexts.DrawContext)
return function(p)
	local v = React.useContext(DrawContext)
	return React.createElement(DrawContext.Provider, {
		value = p.Context or v
	}, p.children)
end