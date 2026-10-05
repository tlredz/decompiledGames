local useStrictLerp = require(game.ReplicatedStorage.React.Hooks.Animation.useStrictLerp)
local CONSTANTS = require(game.ReplicatedStorage.React.Components.WorldTeleporter.CONSTANTS)
local TRANSITION = CONSTANTS.TRANSITION
return function(flag: boolean)
	local v = flag and 1 or 0
	return useStrictLerp(v, v, TRANSITION.DURATION, TRANSITION.EASING_STYLE, TRANSITION.EASING_DIRECTION)
end