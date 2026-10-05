local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
return function(p, p2, p3: number, p4: number, p5, p6: number)
	return useSpring(p5[p] or p6, p5[p2] or p6, p3, p4)
end