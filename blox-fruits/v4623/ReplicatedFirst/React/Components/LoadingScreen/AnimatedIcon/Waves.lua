local ReplicatedFirst = game:GetService("ReplicatedFirst")
local React = require(ReplicatedFirst:WaitForChild("Packages"):WaitForChild("React"))
local RobloxTypes = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("RobloxTypes"))
local useOscillation = require(ReplicatedFirst:WaitForChild("React"):WaitForChild("Hooks"):WaitForChild("Animation"):WaitForChild("useOscillation"))
local TEXTURES = require(script.Parent.Parent.TEXTURES)
local createElement = React.createElement

function wave(props)
	local v = useOscillation(true, props.DriftPeriod or 1, true, props.AnimationOffset) * (props.MaxDrift or 0)
	local v2 = useOscillation(true, props.BobPeriod or 5, true, props.AnimationOffset) * (props.MaxBob or 0.05)
	local v3 = useOscillation(true, props.TiltPeriod or 4.5, true, props.AnimationOffset) * (props.MaxTilt or 5)
	return createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		BackgroundTransparency = 1,
		Image = TEXTURES.IMAGES.WAVES,
		ImageColor3 = Color3.fromRGB(39, 76, 136),
		ScaleType = Enum.ScaleType.Stretch,
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		AnchorPoint = (props.AnchorPoint or Vector2.new(0, 0)) + Vector2.new(v, v2),
		Rotation = v3 + (props.TiltOffset or 5)
	}, props))
end

return function(props)
	local animationOffset = React.useMemo(function()
		return math.random() * 5
	end, {})
	return createElement("Frame", RobloxTypes.mergeGuiObject({
		BackgroundTransparency = 1
	}, props), {
		LeftWave = createElement(wave, {
			MaxBob = props.MaxBob,
			BobPeriod = props.BobPeriod,
			MaxDrift = props.MaxDrift,
			DriftPeriod = props.DriftPeriod,
			MaxTilt = props.MaxTilt,
			TiltOffset = props.TiltOffset,
			TiltPeriod = props.TiltPeriod,
			AnimationOffset = animationOffset,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.35),
			Size = UDim2.fromScale(0.535, 0.5)
		}),
		RightWave = createElement(wave, {
			MaxBob = props.MaxBob,
			BobPeriod = props.BobPeriod,
			MaxDrift = props.MaxDrift,
			DriftPeriod = props.DriftPeriod,
			MaxTilt = props.MaxTilt,
			TiltOffset = props.TiltOffset,
			TiltPeriod = props.TiltPeriod,
			AnimationOffset = animationOffset,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.65),
			Size = UDim2.fromScale(0.535, 0.5)
		})
	})
end