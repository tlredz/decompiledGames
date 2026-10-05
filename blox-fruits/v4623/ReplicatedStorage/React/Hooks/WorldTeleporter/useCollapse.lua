local React = require(game.ReplicatedStorage.Packages.React)
local useStrictLerp = require(game.ReplicatedStorage.React.Hooks.Animation.useStrictLerp)
local CONSTANTS = require(game.ReplicatedStorage.React.Components.WorldTeleporter.CONSTANTS)
local COLLAPSE = CONSTANTS.COLLAPSE
return function(flag: boolean, callback)
	local state, setState = React.useState(false)
	local v = useStrictLerp(
		0,
		flag and state and 1 or 0,
		COLLAPSE.DURATION,
		COLLAPSE.EASING_STYLE,
		COLLAPSE.EASING_DIRECTION
	)
	local v2 = flag and state and v >= 1
	React.useEffect(function()
		if not flag then
			setState(false)
		end
	end, { flag })
	React.useEffect(function()
		if v2 and callback then
			callback()
		end
	end, { v2 })
	return not flag and 0 or v, (React.useCallback(function()
		setState(true)
	end, {}))
end