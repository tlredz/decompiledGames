local createVector = vector.create

local function ScaleParticle(clone, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, clone.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local FX = require(game.ReplicatedStorage.FX)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local mochiMochi = FX:WaitForChild("Mochi-Mochi")
require(ReplicatedStorage.Util.Debris)
local Effect = require(ReplicatedStorage.Effect)
local Mouse = require(game.ReplicatedStorage.Mouse)
local v = {}
RunService:BindToRenderStep(script.Parent.Name .. script.Name, Enum.RenderPriority.Last.Value, function(p)
	local now = tick()

	for k, v2 in pairs(v) do
		if now - v2.Start > v2.Lifetime or not (v2.Point and v2.Point:IsDescendantOf(workspace)) then
			if not v2.DestroyDuration then
				v2.End = now
				v2.DestroyDuration = math.clamp(math.random(), 0.5, 1) * 0.25
			end

			local v3 = (now - v2.End) / v2.DestroyDuration

			if v3 > 1 then
				v2.Fist:Destroy()
				v2.Arm:Destroy()
				v[k] = nil
			else
				v2.Fist.Size = createVector(1, 1, 1) * v2.Scale * 0.85 * (1 - v3)
				v2.Arm.Mesh.Scale = Vector3.new(
					v2.Arm.Mesh.Scale.X,
					0.5 * v2.Scale * (1 - v3),
					0.5 * v2.Scale * (1 - v3)
				)
			end
		else
			v2.Extend = v2.Extend % v2.ExtendDuration + p
			local v3 = v2.Extend / v2.ExtendDuration
			local v4 = math.sin(3.141592653589793 * v3) ^ 2
			local position = v2.Point and v2.Point:IsDescendantOf(workspace) and v2.Point.Position or v2.LastPoint

			if v4 >= 0.99 and v2.Ground and not v2.SPAM then
				v2.SPAM = true

				if Mouse.Target then
					if math.random() > 0.5 then
						Effect.new("Mochi-Mochi.StrongHit"):replicate({ position, 1.2 * v2.Scale, true })
						Effect.new("Mochi-Mochi.Shockwave"):replicate({
							CFrame.new(position, v2.Origin.p) * CFrame.new(0, v2.Scale / 3, 0),
							8 * v2.Scale,
							0.2,
							v2.Scale / 3
						})
					end

					if v2.Point and v2.Point:IsDescendantOf(workspace) then
						local clone = mochiMochi.DustExplosion:Clone()
						clone.Color = ColorSequence.new(v2.Ground.Color)
						clone.Size = ScaleParticle(clone, 0.9 * v2.Scale)
						clone.Parent = v2.Point
						clone:Emit(5)
					end
				end
			else
				v2.SPAM = false
			end

			local magnitude = (v2.Point.Position - v2.Origin.p).Magnitude
			v2.Fist.CFrame = CFrame.new(v2.Origin.p, v2.Point.Position) * CFrame.new(0, 0, -magnitude * v4) * CFrame.Angles(
				0,
				1.5707963267948966,
				0
			)
			v2.Arm.CFrame = CFrame.new(v2.Origin.p, v2.Point.Position) * CFrame.new(0, 0, -magnitude / 2 * v4) * CFrame.Angles(
				0,
				1.5707963267948966,
				0
			)
			v2.Arm.Mesh.Scale = Vector3.new(magnitude * v4, 0.5 * v2.Scale, 0.5 * v2.Scale)
			v2.LastPoint = position
		end
	end

	local v2 = {}

	for k, v3 in pairs(v) do
		if v3 then
			v2[k] = v3
		end
	end

	v = v2
end)
return function(list)
	local v2, point, v4, v5, lifetime, ground = unpack(list)
	local scale = v4 * math.clamp(math.random(), 0.5, 1)
	local clone = mochiMochi.Fist:Clone()
	clone.Size = createVector(1, 1, 1) * scale * 0.85
	clone.CFrame = v2
	local clone2 = mochiMochi.FistExtend:Clone()
	clone2.Mesh.Scale = Vector3.new(1, 0.5 * scale, 0.5 * scale)
	clone2.CFrame = v2
	clone.Parent = _WorldOrigin
	clone2.Parent = _WorldOrigin
	table.insert(v, {
		Ground = ground,
		Lifetime = lifetime,
		Origin = v2,
		Point = point,
		LastPosition = point.Position,
		Scale = scale,
		Fist = clone,
		Arm = clone2,
		ExtendDuration = v5 * math.clamp(math.random(), 0.5, 1),
		Extend = math.random(),
		Start = tick()
	})
end