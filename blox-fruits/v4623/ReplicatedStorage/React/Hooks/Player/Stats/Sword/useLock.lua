local useSword = require(game.ReplicatedStorage.React.Hooks.Player.useSword)
return function()
	return useSword() == nil
end