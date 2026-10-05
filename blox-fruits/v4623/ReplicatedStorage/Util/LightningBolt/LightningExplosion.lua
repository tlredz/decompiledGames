local createVector = vector.create

local function ScaleParticle(state, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, state.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	return NumberSequence.new(numberSequenceKeypoints)
end

local parentModule = require(script.Parent)
local LightningSparks = require(script.Parent.LightningSparks)
local random = Random.new()

function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.new(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

function CreateLightningExplosion(p, p2, value)
	local v = value or 1
	coroutine.resume(coroutine.create(function()
		local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
		local part = Instance.new("Part")
		part.Name = "LightningExplosion"
		part.Anchored = true
		part.CanCollide = false
		part.Locked = true
		part.CastShadow = false
		part.Transparency = 1
		part.Size = createVector(0.05, 0.05, 0.05)
		part.CFrame = CFrame.new(p + createVector(0, 0.5, 0))
		part.Parent = _WorldOrigin
		local attachment = Instance.new("Attachment")
		attachment.Parent = part
		attachment.CFrame = CFrame.new()
		local clone = script.ParticleEmitter:Clone()
		clone.Parent = part
		local clone2 = script.ParticleEmitter2:Clone()
		clone2.Parent = part
		local clone3 = script.Particles:Clone()
		clone3.Parent = part

		if p2 and v then
			for _, v2 in next, { clone, clone2, clone3 }, nil do
				v2.Color = ColorSequence.new(p2)
				v2.Size = ScaleParticle(v2, v)
			end
		end

		local v2 = v
		local v4 = {}
		local v3 = {
			WorldPosition = attachment.WorldPosition,
			WorldAxis = RandomVectorOffsetBetween(createVector(0, 1, 0), 1.2217304763960306, 1.3962634015954636)
		}
		local worldPosition = attachment.WorldPosition + (v3.WorldAxis * createVector(1, 0, 1)).Unit * random:NextNumber(
			20,
			40
		) * 0.2
		local worldAxis = RandomVectorOffsetBetween(createVector(0, -1, 0), 1.2217304763960306, 1.9198621771937625)
		v4.WorldPosition = worldPosition
		v4.WorldAxis = worldAxis
		v3.Parent = "parent"
		v4.Parent = "parent"
		local v8 = random:NextNumber(0, 50) * v2
		local v9 = random:NextNumber(0, 50) * v2
		local v10 = parentModule.new(v3, v4, v8, v9, 10)
		v10.MaxAngleOffset = 3.141592653589793
		v10.SizingOffset = 0.1
		v10.Thickness = 0.8
		v10.Color = p2 or Color3.new(0, random:NextNumber(0.8, 1), random:NextNumber(0.2, 0.3))
		v10.PulseLength = 0.5
		v10.FadeLength = 0.2
		v10.PulseSpeed = 5
		v10.MinThicknessMultiplier = 0.7
		v10.MaxThicknessMultiplier = 1
		local v11 = (v4.WorldPosition - v3.WorldPosition).Unit * 0.2
		local v12 = random:NextNumber(0, 10) * v2
		local v13 = random:NextNumber(0, 10) * v2
		local v14 = LightningSparks.new(v10, 5)
		local minDistance = 7.5 * v2
		local maxDistance = 10 * v2
		v14.MinDistance = minDistance
		v14.MaxDistance = maxDistance
		v14.MinSpeed = 6
		v14.MaxSpeed = 6
		spawn(function()
			for _ = 1, 100 do
				wait()
				v4.WorldPosition += v11
				local v17 = v10
				local v18 = v10
				local curveSize = v10.CurveSize0 + v12
				local curveSize2 = v10.CurveSize1 + v13
				v17.CurveSize0 = curveSize
				v18.CurveSize1 = curveSize2
			end
		end)
		clone.Enabled = true
		clone2.Enabled = true
		clone3.Enabled = true
		wait(0.2)
		clone.Enabled = false
		clone2.Enabled = false
		clone3.Enabled = false
		wait(0.5)
		part:Destroy()
	end))
end

return CreateLightningExplosion