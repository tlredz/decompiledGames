local React = require(game.ReplicatedStorage.Packages.React)
local ShopContext = require(game.ReplicatedStorage.React.Contexts.ShopContext)
return function(p)
	local v = React.useContext(ShopContext)
	return p or v
end