local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- equivalent calls inferred from this helper; original call sites unknown
local function DiscretePulse(p, pulseSpeed, pulseLength, fadeLength, p2, min, max)
	return (math.clamp(
		pulseLength / (2 * fadeLength) - math.abs((p - p2 * pulseSpeed + 0.5 * pulseLength) / fadeLength),
		min,
		max
	))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function NoiseBetween(p, p2, p3, minThicknessMultiplier, maxThicknessMultiplier)
	return minThicknessMultiplier + (maxThicknessMultiplier - minThicknessMultiplier) * (math.noise(p, p2, p3) + 0.5)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function CubicBezier(worldPosition, p, p2, worldPosition2, p3)
	return worldPosition * (1 - p3) ^ 3 + p * 3 * p3 * (1 - p3) ^ 2 + p2 * 3 * (1 - p3) * p3 ^ 2 + worldPosition2 * p3 ^ 3
end

local part = Instance.new("Part")
part.TopSurface = 0
part.BottomSurface = 0
part.Anchored = true
part.CanCollide = false
part.Shape = "Cylinder"
part.Name = "BoltPart"
part.Material = Enum.Material.Neon
part.Color = Color3.new(1, 1, 1)
part.Transparency = 1
part.CastShadow = false
part.Locked = true
local clock = os.clock
Random.new()
local inverse = CFrame.lookAt(Vector3.new(), vector.create(1, 0, 0)):Inverse()
local v = {}
local LightningBolt = {}
LightningBolt.__index = LightningBolt

function LightningBolt.new(attachment, attachment2, value)
	local object = setmetatable({}, LightningBolt)
	object.Enabled = true
	object.Attachment0 = attachment
	object.Attachment1 = attachment2
	object.CurveSize0 = 0
	object.CurveSize1 = 0
	object.MinRadius = 0
	object.MaxRadius = 2.4
	object.Frequency = 1
	object.AnimationSpeed = 7
	object.Thickness = 1
	object.MinThicknessMultiplier = 0.2
	object.MaxThicknessMultiplier = 1
	object.MinTransparency = 0
	object.MaxTransparency = 1
	object.PulseSpeed = 2
	object.PulseLength = 1000000
	object.FadeLength = 0.2
	object.ContractFrom = 0.5
	object.Color = Color3.new(1, 1, 1)
	object.ColorOffsetSpeed = 3
	object.Parts = {}
	local currentCamera = workspace.CurrentCamera
	local worldPosition = attachment.WorldPosition
	local v2 = attachment.WorldPosition + attachment.WorldAxis * object.CurveSize0
	local v3 = attachment2.WorldPosition - attachment2.WorldAxis * object.CurveSize1
	local worldPosition2 = attachment2.WorldPosition
	local v4 = value or 30
	local v5 = worldPosition
	local v6 = v5
	v5 = v6

	for i = 1, v4 do
		local cubicBezier = CubicBezier(worldPosition, v2, v3, worldPosition2, i / v4)
		local position

		if i == v4 then
			position = cubicBezier
		else
			position = CFrame.lookAt(v5, cubicBezier).Position or cubicBezier
		end

		local clone = part:Clone()
		clone.Size = Vector3.new((position - v6).Magnitude, 0, 0)
		clone.CFrame = CFrame.lookAt(0.5 * (v6 + position), position) * inverse
		clone.Parent = currentCamera
		Debris:AddItem(clone, 10)
		object.Parts[i] = clone
		v5 = cubicBezier
		v6 = position
	end

	object.PartsHidden = false
	object.DisabledTransparency = 1
	object.StartT = clock()
	object.RanNum = math.random() * 100
	object.RefIndex = #v + 1
	v[object.RefIndex] = object
	return object
end

function LightningBolt:Destroy()
	v[self.RefIndex] = nil

	for i = 1, #self.Parts do
		self.Parts[i]:Destroy()

		if i % 100 == 0 then
			wait()
		end
	end
end

RunService.Heartbeat:Connect(function()
	for _, v2 in pairs(v) do
		if v2.Enabled == true then
			v2.PartsHidden = false
			local v3 = 1 - v2.MaxTransparency
			local v4 = 1 - v2.MinTransparency
			local minRadius = v2.MinRadius
			local maxRadius = v2.MaxRadius
			local thickness = v2.Thickness
			local parts = v2.Parts
			local count = #parts
			local ranNum = v2.RanNum
			local startT = v2.StartT
			local animationSpeed = v2.AnimationSpeed
			local frequency = v2.Frequency
			local minThicknessMultiplier = v2.MinThicknessMultiplier
			local maxThicknessMultiplier = v2.MaxThicknessMultiplier
			local attachment0 = v2.Attachment0
			local attachment1 = v2.Attachment1
			local curveSize0 = v2.CurveSize0
			local curveSize1 = v2.CurveSize1
			local worldPosition = attachment0.WorldPosition
			local v5 = attachment0.WorldPosition + attachment0.WorldAxis * curveSize0
			local v6 = attachment1.WorldPosition - attachment1.WorldAxis * curveSize1
			local worldPosition2 = attachment1.WorldPosition
			local v7 = clock() - startT
			local pulseLength = v2.PulseLength
			local pulseSpeed = v2.PulseSpeed
			local fadeLength = v2.FadeLength
			local color = v2.Color
			local colorOffsetSpeed = v2.ColorOffsetSpeed
			local v8 = 1 - v2.ContractFrom

			if v7 < (pulseLength + 1) / pulseSpeed then
				local v9 = worldPosition
				local v10 = v9
				v9 = v10

				for i = 1, count do
					local part2 = parts[i]
					local v12 = i / count
					local discretePulse = DiscretePulse(v12, pulseSpeed, pulseLength, fadeLength, v7, v3, v4) -- equivalent call inferred; original call site unknown
					local cubicBezier = CubicBezier(worldPosition, v5, v6, worldPosition2, v12)
					local v15 = -v7
					local v16 = animationSpeed * v15 + frequency * 10 * v12 - 0.2 + ranNum * 4
					local v17 = 5 * (animationSpeed * 0.01 * v15 / 10 + frequency * v12) + ranNum * 4
					local v18 = 5 * v16
					local v19 = 1 * v17
					local v20 = 0 + 0.6283185307179586 * (math.noise(v18, 1.5, v19) + 0.5)
					local v21 = 0.5 * v16
					local v22 = 0.1 * v17
					local v23 = v20 + (0 + 5.654866776461628 * (math.noise(v21, 1.5, v22) + 0.5))
					local v24 = NoiseBetween(3.4, v17, v16, minRadius, maxRadius) * math.exp((v12 - 0.5) ^ 10 * -5000)
					local noiseBetween = NoiseBetween(2.3, v17, v16, minThicknessMultiplier, maxThicknessMultiplier) -- equivalent call inferred; original call site unknown
					local position

					if i == count then
						position = cubicBezier
					else
						position = (CFrame.new(v9, cubicBezier) * CFrame.Angles(0, 0, v23) * CFrame.Angles(
							math.acos((math.clamp(
								6.123233995736766e-17 + 0.9999999999999999 * (math.noise(v17, v16, 2.7) + 0.5),
								-1,
								1
							))),
							0,
							0
						) * CFrame.new(0, 0, -v24)).Position or cubicBezier
					end

					if v8 < discretePulse then
						part2.Size = Vector3.new(
							(position - v10).Magnitude,
							thickness * noiseBetween * discretePulse,
							thickness * noiseBetween * discretePulse
						)
						part2.CFrame = CFrame.lookAt(0.5 * (v10 + position), position) * inverse
						part2.Transparency = 1 - discretePulse
					elseif v8 - 1 / (count * fadeLength) < discretePulse then
						local v26 = (1 - (discretePulse - (v8 - 1 / (count * fadeLength))) * count * fadeLength) * (v12 < v7 * pulseSpeed - 0.5 * pulseLength and 1 or -1)
						part2.Size = Vector3.new(
							(1 - math.abs(v26)) * (position - v10).Magnitude,
							thickness * noiseBetween * discretePulse,
							thickness * noiseBetween * discretePulse
						)
						part2.CFrame = CFrame.lookAt(
							v10 + (position - v10) * (math.max(0, v26) + (1 - math.abs(v26)) * 0.5),
							position
						) * inverse
						part2.Transparency = 1 - discretePulse
					else
						part2.Transparency = 1
					end

					if typeof(color) == "Color3" then
						part2.Color = color
					else
						local v26 = (ranNum + v12 - v7 * colorOffsetSpeed) % 1
						local keypoints = color.Keypoints

						for i2 = 1, #keypoints - 1 do
							if not (keypoints[i2].Time < v26 and v26 < keypoints[i2 + 1].Time) then
								continue
							end

							part2.Color = keypoints[i2].Value:lerp(
								keypoints[i2 + 1].Value,
								(v26 - keypoints[i2].Time) / (keypoints[i2 + 1].Time - keypoints[i2].Time)
							)
							break
						end
					end

					v9 = cubicBezier
					v10 = position
				end
			else
				v2:Destroy()
			end
		elseif v2.PartsHidden == false then
			v2.PartsHidden = true
			local disabledTransparency = v2.DisabledTransparency

			for i = 1, #v2.Parts do
				v2.Parts[i].Transparency = disabledTransparency
			end
		end
	end
end)
return LightningBolt