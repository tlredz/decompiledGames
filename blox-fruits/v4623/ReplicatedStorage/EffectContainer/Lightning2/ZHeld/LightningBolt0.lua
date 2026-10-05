local clock = os.clock

function DiscretePulse(p, p2, p3, p4, p5, min, max)
	return (math.clamp(p3 / (2 * p4) - math.abs((p - p5 * p2 + 0.5 * p3) / p4), min, max))
end

function NoiseBetween(p, p2, p3, p4, p5)
	return p4 + (p5 - p4) * (math.noise(p, p2, p3) + 0.5)
end

function CubicBezier(p, p2, p3, p4, p5)
	return p * (1 - p5) ^ 3 + p2 * 3 * p5 * (1 - p5) ^ 2 + p3 * 3 * (1 - p5) * p5 ^ 2 + p4 * p5 ^ 3
end

local part = Instance.new("Part")
part.TopSurface = 0
part.BottomSurface = 0
part.Anchored = true
part.CanCollide = false
part.CastShadow = false
part.CanQuery = false
part.CanTouch = false
part.Shape = "Cylinder"
part.Name = "BoltPart"
part.Material = Enum.Material.Neon
part.Color = Color3.new(1, 1, 1)
part.Transparency = 1
Random.new()
local inverse = CFrame.lookAt(Vector3.new(), vector.create(1, 0, 0)):inverse()
local v = {}
local LightningBolt0 = {}
LightningBolt0.__index = LightningBolt0

function LightningBolt0.new(attachment, attachment2, value, thickness, parent, curveSize, curveSize2)
	local object = setmetatable({}, LightningBolt0)
	object.Enabled = true
	object.Attachment0 = attachment
	object.Attachment1 = attachment2
	object.CurveSize0 = curveSize
	object.CurveSize1 = curveSize2
	object.MinRadius = 0
	object.MaxRadius = 5
	object.Frequency = 0.35
	object.AnimationSpeed = 5
	object.Thickness = thickness
	local maxThicknessMultiplier = math.random(1, 2)
	object.MinThicknessMultiplier = 0.35
	object.MaxThicknessMultiplier = maxThicknessMultiplier
	object.MinTransparency = 0
	object.MaxTransparency = 1
	object.PulseSpeed = math.random(5, 7)
	object.PulseLength = 10000
	object.FadeLength = 0.2
	object.ContractFrom = 0.5
	object.Color = Color3.new(0.45098, 0.992157, 1)
	object.ColorOffsetSpeed = 5
	object.Parts = {}
	local worldPosition = attachment.WorldPosition
	local v3 = attachment.WorldPosition + attachment.WorldAxis * object.CurveSize0
	local v4 = attachment2.WorldPosition - attachment2.WorldAxis * object.CurveSize1
	local worldPosition2 = attachment2.WorldPosition
	local v5 = value or 30
	local v6 = worldPosition
	local v7 = v6
	v6 = v7

	for i = 1, v5 do
		local v9 = i / v5
		local v10 = CubicBezier(worldPosition, v3, v4, worldPosition2, v9)
		local position

		if i == v5 then
			position = v10
		else
			position = CFrame.lookAt(v6, v10).Position or v10
		end

		local clone = part:Clone()
		clone.Size = Vector3.new((position - v7).Magnitude, 0, 0)
		clone.CFrame = CFrame.lookAt(0.5 * (v7 + position), position) * inverse
		clone.Parent = parent
		clone.Locked = true
		clone.CastShadow = false
		object.Parts[i] = clone
		v6 = v10
		v7 = position
	end

	object.PartsHidden = false
	object.DisabledTransparency = 1
	object.StartT = clock()
	object.RanNum = math.random() * 100
	object.RefIndex = #v + 1
	v[object.RefIndex] = object
	return object
end

function LightningBolt0:Destroy()
	v[self.RefIndex] = nil

	for i = 1, #self.Parts do
		self.Parts[i]:Destroy()

		if i % 100 == 0 then
			wait()
		end
	end
end

local RunService = game:GetService("RunService")
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
					local v13 = DiscretePulse(v12, pulseSpeed, pulseLength, fadeLength, v7, v3, v4)
					local v14 = CubicBezier(worldPosition, v5, v6, worldPosition2, v12)
					local v15 = -v7
					local v16 = animationSpeed * v15 + frequency * 10 * v12 - 0.2 + ranNum * 4
					local v17 = 5 * (animationSpeed * 0.01 * v15 / 10 + frequency * v12) + ranNum * 4
					local v18 = NoiseBetween(5 * v16, 1.5, 1 * v17, 0, 0.6283185307179586) + NoiseBetween(
						0.5 * v16,
						1.5,
						0.1 * v17,
						0,
						5.654866776461628
					)
					local v19 = NoiseBetween(3.4, v17, v16, minRadius, maxRadius) * math.exp((v12 - 0.5) ^ 10 * -5000)
					local v20 = NoiseBetween(2.3, v17, v16, minThicknessMultiplier, maxThicknessMultiplier)
					local position

					if i == count then
						position = v14
					else
						position = (CFrame.new(v9, v14) * CFrame.Angles(0, 0, v18) * CFrame.Angles(
							math.acos((math.clamp(NoiseBetween(v17, v16, 2.7, 6.123233995736766e-17, 1), -1, 1))),
							0,
							0
						) * CFrame.new(0, 0, -v19)).Position or v14
					end

					if v8 < v13 then
						part2.Size = Vector3.new(
							(position - v10).Magnitude,
							thickness * v20 * v13,
							thickness * v20 * v13
						)
						part2.CFrame = CFrame.lookAt(0.5 * (v10 + position), position) * inverse
						part2.Transparency = 0
					elseif v8 - 1 / (count * fadeLength) < v13 then
						local v21 = (1 - (v13 - (v8 - 1 / (count * fadeLength))) * count * fadeLength) * (v12 < v7 * pulseSpeed - 0.5 * pulseLength and 1 or -1)
						part2.Size = Vector3.new(
							(1 - math.abs(v21)) * (position - v10).Magnitude,
							thickness * v20 * v13,
							thickness * v20 * v13
						)
						part2.CFrame = CFrame.lookAt(
							v10 + (position - v10) * (math.max(0, v21) + (1 - math.abs(v21)) * 0.5),
							position
						) * inverse
						part2.Transparency = 0
					else
						part2.Transparency = 1
					end

					if typeof(color) == "Color3" then
						part2.Color = color
					else
						local v21 = (ranNum + v12 - v7 * colorOffsetSpeed) % 1
						local keypoints = color.Keypoints

						for i2 = 1, #keypoints - 1 do
							if not (keypoints[i2].Time < v21 and v21 < keypoints[i2 + 1].Time) then
								continue
							end

							part2.Color = keypoints[i2].Value:lerp(
								keypoints[i2 + 1].Value,
								(v21 - keypoints[i2].Time) / (keypoints[i2 + 1].Time - keypoints[i2].Time)
							)
							break
						end
					end

					v9 = v14
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
return LightningBolt0