return function(p)
	local WhitescreenTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.WhitescreenTransitionEffect)
	WhitescreenTransitionEffect.Play(p.duration)
end