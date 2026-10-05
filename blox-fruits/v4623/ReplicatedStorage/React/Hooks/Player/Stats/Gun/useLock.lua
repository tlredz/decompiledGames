local useGun = require(game.ReplicatedStorage.React.Hooks.Player.useGun)
return function()
	return useGun() == nil
end