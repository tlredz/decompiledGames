local ReplicatedFirst = game:GetService("ReplicatedFirst")
local React = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("React"))
local RobloxTypes = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("RobloxTypes"))
local useOscillation = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("Hooks"):WaitForChild("Animation"):WaitForChild("useOscillation"))
local TEXTURES = require(script.Parent.Parent.TEXTURES)
local createElement = React.createElement
return function(props)
	local v = React.useMemo(function()
		return math.random() * 10
	end, {})
	local v2 = useOscillation(true, props.DriftPeriod or 10, true, v) * (props.MaxDrift or 0.01)
	local v3 = useOscillation(true, props.BobPeriod or 10, true, v) * (props.MaxBob or 0.025)
	local v4 = useOscillation(true, props.TiltPeriod or 10, true, v) * (props.MaxTilt or 5)
	return createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		Image = props.Image or TEXTURES.IMAGES.SAIL_BOAT_1,
		ImageColor3 = props.ImageColor3 or Color3.fromRGB(39, 76, 136),
		AnchorPoint = (props.AnchorPoint or Vector2.new(0, 0)) + Vector2.new(v2, v3),
		Rotation = v4 + (props.TiltOffset or 5)
	}, props))
end