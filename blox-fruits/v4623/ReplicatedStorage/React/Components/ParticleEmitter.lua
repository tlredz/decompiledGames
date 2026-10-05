local React = require(game.ReplicatedStorage.Packages.React)
local useTime = require(game.ReplicatedStorage.React.Hooks.Animation.useTime)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local numberRange = NumberRange.new(2, 2)
local numberRange2 = NumberRange.new(0.5, 0.5)
local numberRange3 = NumberRange.new(0, 0)
local numberRange4 = NumberRange.new(0, 0)
local numberRange5 = NumberRange.new(0, 0)
local numberSequence = NumberSequence.new(0.1)
local numberSequence2 = NumberSequence.new(0)
local colorSequence = ColorSequence.new(CONSTANTS.COLOR.PALETTE.WHITE)
local v = {
	[Enum.NormalId.Top] = Vector2.new(0, -1),
	[Enum.NormalId.Bottom] = Vector2.new(0, 1),
	[Enum.NormalId.Left] = Vector2.new(-1, 0),
	[Enum.NormalId.Right] = Vector2.new(1, 0),
	[Enum.NormalId.Front] = Vector2.zero,
	[Enum.NormalId.Back] = Vector2.zero
}
local v2 = {
	[Enum.NormalId.Front] = 1,
	[Enum.NormalId.Back] = -1
}
local createElement = React.createElement

local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function hash(p: number, p2: number, p3: number)
	local v3 = math.sin(p * 12.9898 + p2 * 78.233 + p3 * 37.719) * 43758.5453
	return v3 - math.floor(v3)
end

local function sampleNumberSequence(keypoints, p: number, p2: number)
	local count = #keypoints

	if count == 0 then
		return 0
	end

	local v3 = keypoints[1]

	if count == 1 or p <= v3.Time then
		return v3.Value + v3.Envelope * p2
	end

	local v4 = keypoints[count]

	if v4.Time <= p then
		return v4.Value + v4.Envelope * p2
	end

	for i = 1, count - 1 do
		local v5 = keypoints[i]
		local v6 = keypoints[i + 1]

		if not (v5.Time <= p and p <= v6.Time) then
			continue
		end

		local v7 = v6.Time - v5.Time
		local v8 = not (v7 > 0) and 0 or (p - v5.Time) / v7
		local value = v5.Value
		local v9 = value + (v6.Value - value) * v8
		local envelope = v5.Envelope
		return v9 + (envelope + (v6.Envelope - envelope) * v8) * p2
	end

	return v4.Value + v4.Envelope * p2
end

local function sampleColorSequence(keypoints, p: number)
	local count = #keypoints

	if count == 0 then
		return CONSTANTS.COLOR.PALETTE.WHITE
	end

	local v3 = keypoints[1]

	if count == 1 or p <= v3.Time then
		return v3.Value
	end

	local v4 = keypoints[count]

	if v4.Time <= p then
		return v4.Value
	end

	for i = 1, count - 1 do
		local v5 = keypoints[i]
		local v6 = keypoints[i + 1]

		if not (v5.Time <= p and p <= v6.Time) then
			continue
		end

		local v7 = v6.Time - v5.Time
		local v8 = not (v7 > 0) and 0 or (p - v5.Time) / v7
		return v5.Value:Lerp(v6.Value, v8)
	end

	return v4.Value
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getParticleRotation(orientation, p: number, p2: number, p3: number)
	if orientation == Enum.ParticleOrientation.VelocityParallel then
		return p + math.deg((math.atan2(p3, p2)))
	end

	if orientation == Enum.ParticleOrientation.VelocityPerpendicular then
		return p + math.deg((math.atan2(p3, p2))) + 90
	end

	if orientation == Enum.ParticleOrientation.FacingCameraWorldUp then
		return 0
	end

	return p
end

local function solveEmission(data, p: number, p2: number, p3: number, p4: number, p5: number, p6: number)
	local shape = data.Shape or Enum.ParticleEmitterShape.Box
	local shapeStyle = data.ShapeStyle or Enum.ParticleEmitterShapeStyle.Volume
	local emissionDirection = data.EmissionDirection or Enum.NormalId.Top
	local v3 = v[emissionDirection] or Vector2.new(0, -1)
	local v4 = v2[emissionDirection] or 0
	local X, Y

	if shape == Enum.ParticleEmitterShape.Box then
		if shapeStyle == Enum.ParticleEmitterShapeStyle.Surface then
			local v5 = p * 2
			local v6 = p2 * 2
			local v7 = p3 * (v5 + v6) * 2

			if v7 < v5 then
				p = v7 - p
				p2 = -p2
			elseif v7 < v5 + v6 then
				p2 = v7 - v5 - p2
			elseif v7 < v5 * 2 + v6 then
				p -= v7 - v5 - v6
			else
				p = -p
				p2 -= v7 - v5 * 2 - v6
			end
		else
			local v5 = -p
			p = v5 + (p - v5) * p3
			local v6 = -p2
			p2 = v6 + (p2 - v6) * p4
		end

		if v4 == 0 then
			X = v3.X
			Y = v3.Y
		else
			local v5 = math.sqrt(p * p + p2 * p2)

			if v5 > 0 then
				X = p / v5 * v4
				Y = p2 / v5 * v4
			else
				local v6 = p5 * 3.141592653589793 * 2
				X = math.cos(v6)
				Y = math.sin(v6)
			end
		end
	else
		local v5 = (1 - math.clamp(data.ShapePartial or 0, 0, 1)) * 3.141592653589793 * 2
		local v6 = not (v3.Magnitude > 0) and 0 or math.atan2(v3.Y, v3.X)
		local v7 = -v5 / 2
		local v8 = v6 + (v7 + (v5 / 2 - v7) * p3)
		local v9 = shapeStyle == Enum.ParticleEmitterShapeStyle.Surface and 1 or math.sqrt(p4)
		p = math.cos(v8) * p * v9
		p2 = math.sin(v8) * p2 * v9
		local shapeInOut = data.ShapeInOut or Enum.ParticleEmitterShapeInOut.Outward
		local v10

		if shapeInOut == Enum.ParticleEmitterShapeInOut.Inward then
			v10 = -1
		elseif shapeInOut ~= Enum.ParticleEmitterShapeInOut.InAndOut then
			v10 = 1
		elseif p5 < 0.5 then
			v10 = -1
		else
			v10 = 1
		end

		X = math.cos(v8) * v10
		Y = math.sin(v8) * v10
	end

	local spreadAngle = data.SpreadAngle or numberRange3
	local min = spreadAngle.Min
	local v5 = math.rad(min + (spreadAngle.Max - min) * p6)

	if v5 == 0 then
		return p, p2, X, Y
	end

	local v6 = math.cos(v5)
	local v7 = math.sin(v5)
	local v8 = X * v6 - Y * v7
	Y = X * v7 + Y * v6
	X = v8
	return p, p2, X, Y
end

return function(props)
	local state, setState = React.useState(Vector2.zero)
	local enabled = props.Enabled ~= false
	local v3 = useTime(enabled) * math.max(props.TimeScale or 1, 0)
	local lifetime = props.Lifetime or numberRange
	local speed = props.Speed or numberRange2
	local particleRotation = props.ParticleRotation or numberRange4
	local rotSpeed = props.RotSpeed or numberRange5
	local v4 = math.max((lifetime.Min + lifetime.Max) / 2, 0.01)
	local v5 = math.max(props.Rate or 20, 0)
	local v6 = not enabled and 0 or math.min(v5 * v4, 200)
	local keypoints = (props.ParticleSize or numberSequence).Keypoints
	local keypoints2 = (props.ParticleTransparency or numberSequence2).Keypoints
	local keypoints3 = (props.ParticleColor or colorSequence).Keypoints
	local orientation = props.Orientation or Enum.ParticleOrientation.FacingCamera
	local squash = props.Squash or 0
	local v7 = squash == 0 and 1 or 2 ^ squash
	local v8 = math.max(props.Drag or 0, 0)
	local acceleration = props.Acceleration or Vector2.zero
	local v9 = state.X / 2
	local v10 = state.Y / 2
	local v11 = math.max(state.Y, 1)
	local v12 = acceleration.X * v11
	local v13 = acceleration.Y * v11
	local v14 = {}

	for i = 1, math.ceil(v6) do
		local min = lifetime.Min
		local max = lifetime.Max
		local v16 = math.sin(i * 12.9898 + 0 + 0) * 43758.5453
		local v17 = v16 - math.floor(v16)
		local v18 = math.max(min + (max - min) * v17, 0.01)
		local v19 = v3 / v18 + i * 0.6180339887498949 % 1
		local v20 = math.floor(v19)
		local v21 = v19 - v20
		local v22 = v21 * v18
		local v24 = math.sin(i * 12.9898 + v20 * 78.233 + 37.719) * 43758.5453
		local v25 = v24 - math.floor(v24)
		local v26 = math.sin(i * 12.9898 + v20 * 78.233 + 75.438) * 43758.5453
		local v27 = v26 - math.floor(v26)
		local v28 = math.sin(i * 12.9898 + v20 * 78.233 + 113.15700000000001) * 43758.5453
		local v29 = v28 - math.floor(v28)
		local v30 = math.sin(i * 12.9898 + v20 * 78.233 + 150.876) * 43758.5453
		local v31, v32, v33, v34 = solveEmission(props, v9, v10, v25, v27, v29, v30 - math.floor(v30))
		local min2 = speed.Min
		local max2 = speed.Max
		local v35 = math.sin(i * 12.9898 + v20 * 78.233 + 188.595) * 43758.5453
		local v36 = v35 - math.floor(v35)
		local v37 = (min2 + (max2 - min2) * v36) * v11
		local v38 = v33 * v37
		local v39 = v34 * v37
		local v40, v41, v42, v43

		if v8 > 0 then
			local v44 = math.exp(-v8 * v22)
			local v45 = v12 / v8
			local v46 = v13 / v8
			v40 = v45 * v22 + (v38 - v45) * (1 - v44) / v8
			v41 = v46 * v22 + (v39 - v46) * (1 - v44) / v8
			v42 = v45 + (v38 - v45) * v44
			v43 = v46 + (v39 - v46) * v44
		else
			v40 = v38 * v22 + 0.5 * v12 * v22 * v22
			v41 = v39 * v22 + 0.5 * v13 * v22 * v22
			v42 = v38 + v12 * v22
			v43 = v39 + v13 * v22
		end

		local min3 = particleRotation.Min
		local max3 = particleRotation.Max
		local v44 = math.sin(i * 12.9898 + v20 * 78.233 + 226.31400000000002) * 43758.5453
		local v45 = v44 - math.floor(v44)
		local v46 = min3 + (max3 - min3) * v45
		local min4 = rotSpeed.Min
		local max4 = rotSpeed.Max
		local v47 = math.sin(i * 12.9898 + v20 * 78.233 + 264.033) * 43758.5453
		local v48 = v47 - math.floor(v47)
		local v49 = v46 + (min4 + (max4 - min4) * v48) * v22
		local v50 = math.sin(i * 12.9898 + v20 * 78.233 + 301.752) * 43758.5453
		local v51 = (v50 - math.floor(v50)) * 2 - 1
		local v52 = math.max(sampleNumberSequence(keypoints, v21, v51), 0) * v11
		local v53 = math.clamp(v6 - (i - 1), 0, 1)
		local v54 = math.clamp(sampleNumberSequence(keypoints2, v21, v51), 0, 1)
		local formatted = `Particle{i}`
		local v57 = {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, v31 + v40, 0.5, v32 + v41),
			Size = UDim2.fromOffset(v52 / v7, v52 * v7),
			Rotation = 0,
			Image = 0,
			ImageColor3 = 0,
			ImageTransparency = 0,
			ScaleType = 0
		}
		local particleRotation2 = getParticleRotation(orientation, v49, v42, v43) -- equivalent call inferred; original call site unknown
		v57.Rotation = particleRotation2
		v57.Image = props.ParticleTexture
		v57.ImageColor3 = sampleColorSequence(keypoints3, v21)
		v57.ImageTransparency = 1 - (1 - v54) * v53
		v57.ScaleType = Enum.ScaleType.Fit
		v14[formatted] = createElement("ImageLabel", v57)
	end

	return createElement("Frame", RobloxTypes.mergeGuiObject({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ClipsDescendants = false,
		[React.Change.AbsoluteSize] = function(p)
			if state ~= p.AbsoluteSize then
				setState(p.AbsoluteSize)
			end
		end,
		children = {
			Particles = createElement(React.Fragment, {}, v14)
		}
	}, props))
end