local createVector = vector.create
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)

function DiscretePulse(p, p2, p3, p4, p5)
	return (math.clamp(p3 / (2 * p4) - math.abs((p - p5 * p2 + 0.5 * p3) / p4), 0, 1))
end

function NoiseBetween(p, p2, p3, p4, p5)
	return p4 + (p5 - p4) * (math.noise(p, p2, p3) + 0.5)
end

function CubicBezier(p, p2, p3, p4, p5)
	return p * (1 - p5) ^ 3 + p2 * 3 * p5 * (1 - p5) ^ 2 + p3 * 3 * (1 - p5) * p5 ^ 2 + p4 * p5 ^ 3
end

local RunService = game:GetService("RunService")
local part

if RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	part = Instance.new("Part")
	assert(part, "bad bolt-part")
	part.TopSurface = 0
	part.BottomSurface = 0
	part.Anchored = true
	part.CanCollide = false
	part.Locked = true
	part.CastShadow = false
	part.CanQuery = false
	part.CanTouch = false
	part.Shape = "Block"
	part.Name = "BoltPart"
	part.Material = Enum.Material.Neon
	part.Color = Color3.new(1, 1, 1)
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
else
	part = nil
end

Random.new()
local inverse = CFrame.new(Vector3.new(), createVector(1, 0, 0)):inverse()
local v = {}
local v2 = 0
local count = 0
local heartbeatConnection = nil
local fn
local fn2
local LightningBolt = {}
LightningBolt.__index = LightningBolt

function LightningBolt.new(attachment, attachment2, curveSize, curveSize2, p, p2)
	local object = setmetatable({}, LightningBolt)
	object.Attachment0 = attachment
	object.Attachment1 = attachment2
	object.CurveSize0 = curveSize
	object.CurveSize1 = curveSize2
	object.MaxAngleOffset = 1.2217304763960306
	object.SizingOffset = 0.4
	object.AnimationSpeed = 7
	object.Thickness = 1
	object.MinThicknessMultiplier = 0.2
	object.MaxThicknessMultiplier = 1
	object.PulseLength = 100000
	object.PulseSpeed = 10
	object.FadeLength = 0.2
	object.Color = p2 or Color3.new(1, 1, 1)
	object.AddTransparency = 0
	object.Parts = {}
	math.cos(object.MaxAngleOffset)
	local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
	local worldPosition = attachment.WorldPosition
	local v3 = attachment.WorldPosition + attachment.WorldAxis * curveSize
	local v4 = attachment2.WorldPosition - attachment2.WorldAxis * curveSize2
	local worldPosition2 = attachment2.WorldPosition
	local v5 = worldPosition
	local v6 = v5
	v5 = v6

	for i = 1, p do
		local v8 = i / p
		local v9 = CubicBezier(worldPosition, v3, v4, worldPosition2, v8)
		local position

		if i == p then
			position = v9
		else
			position = CFrame.new(v5, v9).Position or v9
		end

		assert(part, "bad bolt-part")
		local clone = part:Clone()
		clone.Color = object.Color
		clone.CFrame = CFrame.new(0.5 * (v6 + position), position) * inverse
		local specialMesh = Instance.new("SpecialMesh", clone)
		specialMesh.MeshType = "Cylinder"
		specialMesh.Scale = Vector3.new((position - v6).Magnitude, 1, 1)
		clone.Parent = _WorldOrigin
		object.Parts[i] = clone
		v5 = v9
		v6 = position
	end

	object.StartT = tick()
	object.RanNum = math.random()
	count += 1
	object.RefIndex = count
	object.Destroyed = false
	v[object.RefIndex] = object
	v2 += 1
	fn()
	return object
end

function LightningBolt:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	v[self.RefIndex] = nil
	v2 -= 1

	if v2 == 0 then
		fn2()
	end

	for i = 1, #self.Parts do
		self.Parts[i]:Destroy()

		if i % 100 == 0 then
			wait()
		end
	end
end

local v3 = false
local total = 0
local RunService2 = game:GetService("RunService")

if RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	local RunService3 = game:GetService("RunService")
	local v4 = nil

	local function updateBranches()
		v4 = v4 or require(game.ReplicatedStorage.Global)

		if total > 100 or v4.FastMode then
			v3 = not v3

			if v3 then
				return
			end
		end

		total = 0

		for _, v5 in pairs(v) do
			local v6 = math.min(math.abs(v5.MaxAngleOffset), 3.141592653589793)
			local sizingOffset = v5.SizingOffset
			local thickness = v5.Thickness
			local v7 = math.cos(v6)
			local parts = v5.Parts
			local count2 = #parts
			local ranNum = v5.RanNum
			local startT = v5.StartT
			local animationSpeed = v5.AnimationSpeed
			local minThicknessMultiplier = v5.MinThicknessMultiplier
			local maxThicknessMultiplier = v5.MaxThicknessMultiplier
			local attachment0 = v5.Attachment0
			local attachment1 = v5.Attachment1
			local curveSize0 = v5.CurveSize0
			local curveSize1 = v5.CurveSize1
			local worldPosition = attachment0.WorldPosition
			local v8 = attachment0.WorldPosition + attachment0.WorldAxis * curveSize0
			local v9 = attachment1.WorldPosition - attachment1.WorldAxis * curveSize1
			local worldPosition2 = attachment1.WorldPosition
			local v10 = tick() - startT
			local pulseLength = v5.PulseLength
			local pulseSpeed = v5.PulseSpeed
			local fadeLength = v5.FadeLength
			local _ = v5.Color
			local addTransparency = v5.AddTransparency

			if v10 < (pulseLength + 1) / pulseSpeed then
				total += count2
				local v11 = worldPosition
				local v12 = v11
				v11 = v12

				for i = 1, count2 do
					local part2 = parts[i]
					local v14 = i / count2
					local v15 = DiscretePulse(v14, pulseSpeed, pulseLength, fadeLength, v10)
					local v16 = CubicBezier(worldPosition, v8, v9, worldPosition2, v14)
					local v17 = -v10
					local v18 = animationSpeed * v17 + i * 10 / count2 - 0.2 + ranNum * 4
					local v19 = 5 * (animationSpeed * 0.01 * v17 / 10 + i / count2) + ranNum * 4
					local v20 = NoiseBetween(v18, 1.5, 0.2 * v19, 0, 6.283185307179586)
					local v21 = math.acos((math.clamp(NoiseBetween(v19, v18, 2.7, v7, 1), -1, 1)))
					local v22 = (v16 - v12).Magnitude * NoiseBetween(3.4, v19, v18, 1 - sizingOffset, 1 + sizingOffset)
					local v23 = NoiseBetween(2.3, v19, v18, minThicknessMultiplier, maxThicknessMultiplier)
					local position

					if i == count2 then
						position = v16
					else
						position = (CFrame.new(v12, v16) * CFrame.Angles(0, 0, v20) * CFrame.Angles(v21, 0, 0) * CFrame.new(
							0,
							0,
							-v22
						)).Position or v16
					end

					part2.Mesh.Scale = Vector3.new(
						(position - v11).Magnitude,
						thickness * v23 * v15,
						thickness * v23 * v15
					)
					part2.CFrame = CFrame.new(0.5 * (v11 + position), position) * inverse
					part2.Transparency = math.floor(1 - v15 + addTransparency)
					v11 = position
					v12 = v16
				end
			else
				local v11 = v5
				task.spawn(function()
					v11:Destroy()
				end)
			end

			if not (attachment0.Parent == nil or attachment1.Parent == nil) then
				continue
			end

			local v11 = v5
			task.spawn(function()
				v11:Destroy()
			end)
		end
	end

	fn = function()
		if heartbeatConnection == nil and v2 > 0 then
			heartbeatConnection = RunService3.Heartbeat:Connect(updateBranches)
		end
	end

	fn2 = function()
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end
else
	fn = function() end

	fn2 = function() end
end

return LightningBolt