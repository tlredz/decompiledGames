local useTime = require(game.ReplicatedStorage.React.Hooks.Animation.useTime)
return function(flag: boolean, p: number)
	return (math.sin(6.283185307179586 * (useTime(flag) % p / p)))
end