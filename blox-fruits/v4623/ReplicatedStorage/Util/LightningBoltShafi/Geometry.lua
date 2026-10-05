local inverse = CFrame.lookAt(Vector3.new(), vector.create(1, 0, 0)):Inverse()

-- equivalent calls inferred from this helper; original call sites unknown
local function discretePulse(p: number, pulseSpeed: number, pulseLength: number, fadeLength: number, timePassed: number, minOpacity: number, maxOpacity: number)
	return (math.clamp(
		pulseLength / (fadeLength * 2) - math.abs((p - timePassed * pulseSpeed + pulseLength * 0.5) / fadeLength),
		minOpacity,
		maxOpacity
	))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function noiseBetween(p: number, p2: number, p3: number, minThicknessMultiplier: number, maxThicknessMultiplier: number)
	return minThicknessMultiplier + (maxThicknessMultiplier - minThicknessMultiplier) * (math.noise(p, p2, p3) + 0.5)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cubicBezier(P0: Vector3, P1: Vector3, P2: Vector3, P3: Vector3, p: number)
	return P0 * (1 - p) ^ 3 + P1 * 3 * p * (1 - p) ^ 2 + P2 * 3 * (1 - p) * p ^ 2 + P3 * p ^ 3
end

local function setRingTransform(p, data, p2: number, cframe: CFrame, p3: number)
	local v = p2 * 2 - 1
	p[v] = data.BindInverseA[p2] * cframe * CFrame.fromAxisAngle(data.RigAxis, p3) * data.BindRotA[p2]
	p[v + 1] = data.BindInverseB[p2] * cframe * CFrame.fromAxisAngle(data.RigAxis, -p3) * data.BindRotB[p2]
end

return {
	computeMesh = function(data, p)
		local segmentCount = data.SegmentCount
		local trackSegmentState = data.TrackSegmentState
		local points

		if trackSegmentState then
			points = table.create(segmentCount + 1)
		end

		local radii

		if trackSegmentState then
			radii = table.create(segmentCount)
		end

		local opacities

		if trackSegmentState then
			opacities = table.create(segmentCount)
		end

		local v4 = data.ContractFactor - 1 / (segmentCount * data.FadeLength)

		if data.PackedInvisible then
			local v5 = false

			for i = 1, segmentCount do
				local v7 = discretePulse(
					i / segmentCount,
					data.PulseSpeed,
					data.PulseLength,
					data.FadeLength,
					data.TimePassed,
					data.MinOpacity,
					data.MaxOpacity
				) -- equivalent call inferred; original call site unknown

				if opacities ~= nil and radii ~= nil then
					opacities[i] = v7
					radii[i] = 0
				end

				if not (v4 < v7) then
					continue
				end

				v5 = true
				break
			end

			if not v5 then
				return {
					BranchId = data.BranchId,
					JobId = data.JobId,
					Radii = radii,
					Opacities = opacities,
					PoseCount = 0,
					PackedInvisible = true,
					BindRadius = data.BindRadius,
					GrowTo = 0
				}
			end
		end

		local P0 = data.P0
		local P1 = data.P1
		local P2 = data.P2
		local P3 = data.P3
		local bindRadius = data.BindRadius
		local transforms = table.create(math.min(segmentCount + 2, p.RingCount) * 2)
		local meshOrigin = data.MeshOrigin
		local v6 = P0
		local v7 = v6
		v6 = v7
		local growTo = 0
		local v10 = nil
		local cframe = nil
		local cframe2 = nil
		local v11 = 0
		local rotation = nil
		local v12 = nil

		for i = 1, segmentCount do
			local v13 = i / segmentCount
			local pulseSpeed = data.PulseSpeed
			local pulseLength = data.PulseLength
			local fadeLength = data.FadeLength
			local timePassed = data.TimePassed
			local minOpacity = data.MinOpacity
			local maxOpacity = data.MaxOpacity
			v11 = math.clamp(
				pulseLength / (fadeLength * 2) - math.abs((v13 - timePassed * pulseSpeed + pulseLength * 0.5) / fadeLength),
				minOpacity,
				maxOpacity
			)
			local vector2 = cubicBezier(P0, P1, P2, P3, v13)
			local v14 = -data.TimePassed
			local v15 = data.AnimationSpeed * v14 + data.Frequency * 10 * v13 - 0.2 + data.RandomSeed * 4
			local v16 = (data.AnimationSpeed * 0.01 * v14 / 10 + data.Frequency * v13) * 5 + data.RandomSeed * 4
			local v17 = v15 * 5
			local v18 = v16 * 1
			local v19 = 0 + 0.6283185307179586 * (math.noise(v17, 1.5, v18) + 0.5)
			local v20 = v15 * 0.5
			local v21 = v16 * 0.1
			local v22 = v19 + (0 + 5.654866776461628 * (math.noise(v20, 1.5, v21) + 0.5))
			local v23 = noiseBetween(3.4, v16, v15, data.MinRadius, data.MaxRadius) * math.exp((v13 - 0.5) ^ 10 * -5000)
			local v24 = noiseBetween(2.3, v16, v15, data.MinThicknessMultiplier, data.MaxThicknessMultiplier) -- equivalent call inferred; original call site unknown
			local position

			if i == segmentCount then
				position = vector2
			else
				position = (CFrame.new(v6, vector2) * CFrame.Angles(0, 0, v22) * CFrame.Angles(
					math.acos((math.clamp(
						6.123233995736766e-17 + 0.9999999999999999 * (math.noise(v16, v15, 2.7) + 0.5),
						-1,
						1
					))),
					0,
					0
				) * CFrame.new(0, 0, -v23)).Position
			end

			local v25 = v4 < v11
			local v26, v27

			if v25 then
				v26 = data.Thickness * 0.5 * v24 * v11

				if bindRadius < v26 then
					growTo = math.max(growTo, v26)
					v26 = bindRadius
				end

				v27 = math.acos((math.clamp(v26 / bindRadius, 0, 1)))
			else
				v27 = 1.5707963267948966
				v26 = 0
			end

			if points ~= nil and radii ~= nil and opacities ~= nil then
				points[i] = v7
				radii[i] = v26
				opacities[i] = v11
			end

			if v25 then
				cframe = CFrame.lookAt(v7, position) * inverse
				cframe2 = (cframe - meshOrigin) * p.RigAlign

				if v10 == nil then
					v10 = cframe

					for i2 = 1, i - 1 do
						setRingTransform(transforms, p, i2, cframe2, 1.5707963267948966)
					end
				end

				setRingTransform(transforms, p, i, cframe2, v27)
				rotation = cframe.Rotation
				v12 = v27
			elseif cframe ~= nil then
				setRingTransform(transforms, p, i, cframe2, 1.5707963267948966)
			end

			v6 = vector2
			v7 = position
		end

		if points ~= nil then
			points[segmentCount + 1] = v7
		end

		if v10 == nil then
			local v13 = (CFrame.new(P0) - meshOrigin) * p.RigAlign

			for i = 1, math.min(segmentCount + 2, p.RingCount) do
				setRingTransform(transforms, p, i, v13, 1.5707963267948966)
			end
		else
			if v4 < v11 then
				cframe = rotation + v7
			else
				v12 = 1.5707963267948966
			end

			local vector2 = (cframe - meshOrigin) * p.RigAlign
			setRingTransform(transforms, p, segmentCount + 1, vector2, v12)

			if segmentCount + 2 <= p.RingCount then
				setRingTransform(transforms, p, segmentCount + 2, vector2, 1.5707963267948966)
			end
		end

		return {
			BranchId = data.BranchId,
			JobId = data.JobId,
			Points = points,
			Radii = radii,
			Opacities = opacities,
			Transforms = transforms,
			PoseCount = math.min(segmentCount + 2, p.RingCount),
			PackedInvisible = v10 == nil,
			MeshOrigin = meshOrigin,
			BindRadius = bindRadius,
			GrowTo = growTo
		}
	end
}