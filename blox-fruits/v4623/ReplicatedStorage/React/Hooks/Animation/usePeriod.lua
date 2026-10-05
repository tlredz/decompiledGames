local useTime = require(game.ReplicatedStorage.React.Hooks.Animation.useTime)
return function(flag: boolean, p: number)
	return useTime(flag) % p / p
end