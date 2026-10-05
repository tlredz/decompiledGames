local React = require(game.ReplicatedStorage.Packages.React)
local useTime = require(game.ReplicatedStorage.React.Hooks.Animation.useTime)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(tick())
	local v = (props.Speed or 8) * (props.Direction or 1)
	local v2 = useTime(props.Enabled ~= false)
	React.useEffect(function()
		if ref.current then
			local now = tick()
			local v3 = now - ref2.current
			ref2.current = now

			if props.Enabled ~= false then
				local rotation = ref.current.Rotation + v * v3
				ref.current.Rotation = rotation
			end
		end
	end, { props.Enabled, ref.current, v2 })
	return createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		ref = ref,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://127285517037411",
		ScaleType = Enum.ScaleType.Fit,
		Visible = props.Enabled ~= false,
		Rotation = props.Rotation or 0
	}, props))
end