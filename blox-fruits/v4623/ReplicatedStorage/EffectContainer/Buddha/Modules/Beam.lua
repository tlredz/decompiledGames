local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local vector2 = Vector3.new()
local inverse = CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
local inverse2 = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local beam = FX:WaitForChild("BuddhaEffects").Beam
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local lightningBolt2 = Util.LightningBolt2
local promise = Util.Promise
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local Explosion = require(script.Parent:WaitForChild("Explosion"))

local function RandomVectorOffsetBetween(unit, p, p2)
	return (CFrame.lookAt(Vector3.new(), unit) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p2), (math.cos(p))))),
		0,
		0
	)).LookVector
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cubicHermite(p, p2, p3, p4, p5)
	return (2 * p ^ 3 - 3 * p ^ 2 + 1) * p2 + (p ^ 3 - 2 * p ^ 2 + p) * p3 + (-2 * p ^ 3 + 3 * p ^ 2) * p4 + (p ^ 3 - p ^ 2) * p5
end

local function buddhaBeam(position, p, p2, p3, p4)
	local _ = Workspace.CurrentCamera
	local v = 300 / p3
	local model = Instance.new("Model")
	model.Parent = _WorldOrigin
	local v2 = {}
	local v3 = {}
	v2.WorldPosition = vector2
	v2.WorldAxis = vector2
	v3.WorldPosition = vector2
	v3.WorldAxis = vector2
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(2, 2, 2)
	part.Shape = Enum.PartType.Ball
	part.CFrame = CFrame.new(position)
	local attachment = Instance.new("Attachment", part)
	local attachment2 = Instance.new("Attachment", part)
	attachment.Position = createVector(0, -1, 0)
	attachment2.Position = createVector(0, 1, 0)
	local clone = script.Trail:Clone()
	clone.Attachment0 = attachment
	clone.Attachment1 = attachment2
	clone.Parent = part
	local v6 = p - position
	local unit = v6.Unit
	local magnitude = v6.Magnitude
	local v7 = magnitude / p3
	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.CastShadow = false
	part2.CanTouch = false
	part2.Shape = Enum.PartType.Cylinder
	part2.Size = Vector3.new(0.1, p2, p2)
	part2.CFrame = CFrame.lookAt(position, p + unit) * inverse
	part2.Color = Color3.fromHSV(0.166667, 0.501961, 1)
	part2.Material = Enum.Material.Neon
	part2.TopSurface = 0
	part2.BottomSurface = 0
	part2.Parent = model
	local clone2 = nil
	local clone3 = nil
	local clone4 = nil

	if p4 == true then
		clone2 = beam.Source:Clone()
		clone2.Size = createVector(1, 1, 1) * p2 * 2
		clone2.CFrame = CFrame.new(position)
		clone2.Attachment.BigSpark.Size = NumberSequence.new(2.7 * p2)
		clone2.Attachment.OuterSpark.Size = NumberSequence.new(3.7 * p2)
		clone2.Parent = model
		clone3 = beam.HeatwaveRing:Clone()
		clone3.Size = createVector(10, 3.5, 10) * p2 * 1.1
		clone3.CFrame = CFrame.lookAt(position, p) * inverse2
		clone3.Parent = model
		clone4 = beam.SpiralWind:Clone()
		clone4.Size = createVector(10, 7, 7.5) * p2 * 1.1
		clone4.CFrame = CFrame.lookAt(position + unit * clone4.Size.X * 0.5, p) * inverse
		clone4.Parent = model
		heartbeatLoopFor2(v7 + v, function(p5)
			local transparency = p5 / (v7 + v)
			clone3.Size = createVector(10, 3.5, 10) * p2 * (1.1 + 0.8999999999999999 * transparency)
			clone3.CFrame *= CFrame.Angles(0, 0.15, 0)
			clone3.Transparency = transparency
			clone4.Size = createVector(10, 7, 7.5) * p2 * (1.1 + 0.8999999999999999 * transparency)
			clone4.CFrame = CFrame.lookAt(position + unit * clone4.Size.X * 0.5, p) * inverse * CFrame.Angles(
				5 * p5,
				0,
				0
			)
			clone4.Transparency = transparency

			if transparency < 0.5 then
				local v10 = position
				local v11 = RandomVectorOffsetBetween(unit, 1.2217304763960306, 1.5707963267948966) * p2 * 50
				local v12 = p
				local v13 = unit * p2 * 5
				local clone5 = part:Clone()
				clone5.CFrame = CFrame.new(v10)
				clone5.Parent = model
				heartbeatLoopFor2(v7, function(p6)
					local v14 = p6 / v7
					clone5.CFrame = CFrame.new(cubicHermite(v14, v10, v11, v12, v13))
				end, function()
					clone5:Destroy()
				end)
			end
		end, function()
			clone3.Transparency = 1
			clone4.Transparency = 1
		end)
	end

	local clone5 = beam.ShockRing:Clone()
	clone5.Size = createVector(5.5, 0.14, 5.5) * p2 * 1.1
	clone5.CFrame = CFrame.lookAt(position + unit * (24 * p2 - clone5.Size.X * 1.5), p) * inverse2
	clone5.Parent = model
	local clone6 = beam.ShockRing:Clone()
	clone6.Size = createVector(2.5, 0.14, 2.5) * p2 * 1.1
	clone6.CFrame = CFrame.lookAt(position + unit * clone6.Size.X * 2, p) * inverse2
	clone6.Parent = model
	local clone7 = beam.ShockRing:Clone()
	clone7.Size = createVector(3.2, 0.14, 3.2) * p2 * 1.1
	clone7.CFrame = CFrame.lookAt(position + unit * p2 * 1.1, p) * inverse2
	clone7.Parent = model
	heartbeatLoopFor2(v7 + v, function(p5)
		local v8 = p5 / (v7 + v)
		local transparency = math.sin((v8 - 0.5) * 3.141592653589793) ^ 2 * 0.5 + 0.5
		local v10 = inverse2 * CFrame.Angles(0, -5 * p5, 0)
		clone5.Size = createVector(5.5, 0.14, 5.5) * p2 * (1.1 + 1.9 * v8)
		clone5.CFrame = CFrame.lookAt(position + unit * (24 * p2 - clone5.Size.X * 1.5), p) * v10
		clone5.Transparency = transparency
		clone6.Size = createVector(2.5, 0.14, 2.5) * p2 * (1.1 + 1.9 * v8)
		clone6.CFrame = CFrame.lookAt(position + unit * clone6.Size.X * 2, p) * v10
		clone6.Transparency = transparency
		clone7.Size = createVector(3.2, 0.14, 3.2) * p2 * (1.1 + 3.9 * v8 ^ 7)
		clone7.CFrame = CFrame.lookAt(
			position + unit * p2 * (1.1 + (0.025 * magnitude - 1.1) * math.sin(v8 * 0.8 * 3.141592653589793)),
			p
		) * v10
		clone7.Transparency = math.pow(v8, 5)
	end, function()
		clone5.Transparency = 1
		clone6.Transparency = 1
		clone7.Transparency = 1
	end)

	if p4 == true then
		promise.try(function()
			for _ = 1, 4 do
				local v8 = lightningBolt2.new(v2, v3, 9)
				v8.MaxRadius = 0
				v8.AnimationSpeed = 0
				v8.Thickness = math.clamp(0.5 * p2, 2, 20)
				v8.MinThicknessMultiplier = 1
				v8.MaxThicknessMultiplier = 1
				v8.PulseSpeed = 1000
				v8.Color = Color3.fromHSV(0.15, 0.35, 1)
				local v10 = 0
				local lookVector = RandomVectorOffsetBetween(unit, 0.5235987755982988, 1.0471975511965976)

				function v8.SpaceCurveFunction(p5)
					return position + lookVector * v10 * p5
				end

				heartbeatLoopFor2(1, function(p5)
					v10 = p2 * (p5 / (v7 + v)) * 20
				end)
				promise.delay(0.3):andThen(function()
					v8:DestroyDissipate(0.7, 1)
				end)
			end
		end)
	end

	awaitHeartbeatLoopFor(v7, function(p5)
		local v8 = p5 / v7
		part2.Size = Vector3.new(v8 * magnitude, p2, p2)
		part2.CFrame = CFrame.lookAt(position + unit * v8 * magnitude * 0.5, p + unit) * inverse
	end)
	promise.try(function()
		Explosion(p, 2 * p2, not p4)
	end)
	awaitHeartbeatLoopFor(v, function(p5)
		local v8 = p5 / v
		part2.Size = Vector3.new(magnitude, p2 * (1 - v8), p2 * (1 - v8))
	end)
	part2.Transparency = 1

	if p4 == true then
		clone2.Attachment.BigSpark.Enabled = false
		clone2.Attachment.OuterSpark.Enabled = false
	end

	promise.delay(0.5 + 0.5 * v7):await()
	part:Destroy()
	model:Destroy()
end

return buddhaBeam