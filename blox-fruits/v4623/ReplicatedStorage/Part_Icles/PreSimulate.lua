local createVector = vector.create
local Graph = require(script.Parent.Graph)
local PartConstants = require(script.Parent.PartConstants)
local Turbulence = require(script.Parent.Turbulence)
local directionVectors = PartConstants.DirectionVectors
return function(p)
	function p.PreSimulateForward(_, data, state, p2, p3, p4, p5, p6, p7, p8)
		local linkMode = data.LinkMode or "Follow"
		local cframe

		if p5 then
			cframe = PartConstants.resolveLinkCFrame(p5)

			if linkMode == "Follow" or linkMode == "Pivot" then
				cframe = CFrame.new(cframe.Position)
			end
		else
			cframe = CFrame.new()
		end

		local v

		if linkMode == "Weld" or linkMode == "WeldWithoutRotation" or linkMode == "RigidLocal" then
			v = p5 ~= nil
		else
			v = false
		end

		local v2 = math.max(1, data.TotalKeyFrames)

		if not (p7 and p7 < v2) then
			p7 = data.InvertMotion and v2 > 500 and 500 or v2
		end

		local v3 = p6 / p7
		local position = p2.Position
		local objectSpace = cframe:ToObjectSpace(p2)
		local emissionDirection = data.EmissionDirection
		local rotMode = data.RotMode or "OverLife"
		local total = 0
		local total2 = 0
		local total3 = 0
		local v4

		if data.AccelerationTowardsInstance == true and data.AccelTarget ~= nil and data.AccelStrength ~= nil then
			v4 = not data.InvertMotion
		else
			v4 = false
		end

		local position2 = nil

		if v4 then
			local accelTarget = data.AccelTarget

			if accelTarget:IsA("Bone") then
				position2 = accelTarget.TransformedWorldCFrame.Position
			elseif accelTarget:IsA("BasePart") then
				position2 = accelTarget.Position
			elseif accelTarget:IsA("Attachment") then
				position2 = accelTarget.WorldPosition
			elseif accelTarget:IsA("Model") then
				local success, pivot = pcall(accelTarget.GetPivot, accelTarget)

				if success and pivot then
					position2 = pivot.Position
				end
			end

			if not position2 then
				v4 = false
			end
		end

		local v5 = createVector(0, 0, 0)
		local accelStrength = state.AccelStrength or {}
		local v6 = data.PosOffsetX ~= nil or data.PosOffsetY ~= nil or data.PosOffsetZ ~= nil
		local rotation = v and cframe:ToObjectSpace(p2).Rotation or p2.Rotation
		local v7 = createVector(0, 0, 0)
		local live = Turbulence.isLive(data.Turbulence)
		local v8

		if live then
			state.Turbulence = state.Turbulence or Graph.GenerateSeed(live)
			state._turbSeed = state._turbSeed or math.random() * 997 + 0.5
			v8 = PartConstants.resolveDisplacement(
				Turbulence.sampleRaw(live, state.Turbulence, state._turbSeed, data.TurbulenceFrequency or 1, p6, 0),
				data.DisplacementMode or "Global",
				rotation,
				p8 or rotation
			)
		else
			v8 = createVector(0, 0, 0)
		end

		local result = {
			[0] = cframe:ToObjectSpace(p2)
		}

		for i = 1, p7 do
			local v9 = i / p7
			local v10 = v9 * p6
			local v11 = Graph.QueryPointsWithTime(v9, data.Speed, state.Speed) * math.exp(-data.ParticleData.Drag * v10)
			local v12 = data.ParticleData.Acceleration * v10
			local v13 = (p3 * v11 + v12) * v3

			if v4 then
				local v14 = position2 - position
				local magnitude = v14.Magnitude

				if magnitude > 0.0001 then
					local pointsWithTime = Graph.QueryPointsWithTime(v9, data.AccelStrength, accelStrength)

					if pointsWithTime and pointsWithTime ~= 0 then
						v5 += v14 * (pointsWithTime * v3 / magnitude)
						v13 += v5 * v3
					end
				end
			end

			local v14

			if v6 then
				local v15 = not data.PosOffsetX and 0 or Graph.QueryPointsWithTime(
					v9,
					data.PosOffsetX,
					state.PosOffsetX
				) or 0
				local v16 = not data.PosOffsetY and 0 or Graph.QueryPointsWithTime(
					v9,
					data.PosOffsetY,
					state.PosOffsetY
				) or 0
				local v17 = not data.PosOffsetZ and 0 or Graph.QueryPointsWithTime(
					v9,
					data.PosOffsetZ,
					state.PosOffsetZ
				) or 0
				local displacement = PartConstants.resolveDisplacement(
					Vector3.new(v15, v16, v17),
					data.DisplacementMode or "Global",
					rotation,
					p8 or rotation
				)
				v14 = displacement - v7
				v7 = displacement
			else
				v14 = createVector(0, 0, 0)
			end

			if live then
				local displacement = PartConstants.resolveDisplacement(
					Turbulence.sampleRaw(live, state.Turbulence, state._turbSeed, data.TurbulenceFrequency or 1, p6, v9),
					data.DisplacementMode or "Global",
					rotation,
					p8 or rotation
				)
				v14 += displacement - v8
				v8 = displacement
			end

			local v15 = v and (data.DisplacementMode or "Global") == "Local"

			if v then
				v13 = cframe:VectorToObjectSpace(v13) or v13
			end

			if v and not v15 then
				v14 = cframe:VectorToObjectSpace(v14) or v14
			end

			objectSpace = CFrame.new(v13 + v14) * objectSpace
			local pointsWithTime = Graph.QueryPointsWithTime(v9, data.RotSpeedX, state.RotSpeedX)
			local pointsWithTime2 = Graph.QueryPointsWithTime(v9, data.RotSpeedY, state.RotSpeedY)
			local pointsWithTime3 = Graph.QueryPointsWithTime(v9, data.RotSpeedZ, state.RotSpeedZ)
			local rotOrder = data.RotOrder or "Global"
			local v16

			if rotMode == "Speed" then
				total += pointsWithTime * v3
				total2 += pointsWithTime2 * v3
				total3 += pointsWithTime3 * v3
				v16 = PartConstants.composeRotation(rotOrder, total, total2, total3)
			else
				v16 = PartConstants.composeRotation(rotOrder, pointsWithTime, pointsWithTime2, pointsWithTime3)
			end

			local v17 = cframe * objectSpace * v16
			position = v17.Position

			if data.VelocityVectored then
				local v18 = directionVectors[emissionDirection] or directionVectors[Enum.NormalId.Top]
				p3 = (v17 * p4)[v18.vector] * v18.multiplier
			end

			result[i] = cframe:ToObjectSpace(v17)
		end

		return result, p7
	end

	function p.PreSimulateAttachmentForward(_, data, state, p2, p3, p4, p5, p6, p7)
		local v = math.max(1, data.TotalKeyFrames)

		if not (p6 and p6 < v) then
			p6 = data.InvertMotion and v > 500 and 500 or v
		end

		local v2 = p5 / p6
		local emissionDirection = data.EmissionDirection
		local rotMode = data.RotMode or "OverLife"
		local total = 0
		local total2 = 0
		local total3 = 0
		local v3 = data.PosOffsetX ~= nil or data.PosOffsetY ~= nil or data.PosOffsetZ ~= nil
		local rotation = p2.Rotation
		local v4 = createVector(0, 0, 0)
		local live = Turbulence.isLive(data.Turbulence)
		local v5

		if live then
			state.Turbulence = state.Turbulence or Graph.GenerateSeed(live)
			state._turbSeed = state._turbSeed or math.random() * 997 + 0.5
			v5 = PartConstants.resolveDisplacement(
				Turbulence.sampleRaw(live, state.Turbulence, state._turbSeed, data.TurbulenceFrequency or 1, p5, 0),
				data.DisplacementMode or "Global",
				rotation,
				p7 or rotation
			)
		else
			v5 = createVector(0, 0, 0)
		end

		local result = {
			[0] = p2
		}

		for i = 1, p6 do
			local v6 = i / p6
			local v7 = v6 * p5
			local v8 = Graph.QueryPointsWithTime(v6, data.Speed, state.Speed) * math.exp(-data.ParticleData.Drag * v7)
			local v9 = data.ParticleData.Acceleration * v7
			local v10 = (p3 * v8 + v9) * v2

			if v3 then
				local v11 = not data.PosOffsetX and 0 or Graph.QueryPointsWithTime(
					v6,
					data.PosOffsetX,
					state.PosOffsetX
				) or 0
				local v12 = not data.PosOffsetY and 0 or Graph.QueryPointsWithTime(
					v6,
					data.PosOffsetY,
					state.PosOffsetY
				) or 0
				local v13 = not data.PosOffsetZ and 0 or Graph.QueryPointsWithTime(
					v6,
					data.PosOffsetZ,
					state.PosOffsetZ
				) or 0
				local displacement = PartConstants.resolveDisplacement(
					Vector3.new(v11, v12, v13),
					data.DisplacementMode or "Global",
					rotation,
					p7 or rotation
				)
				v10 += displacement - v4
				v4 = displacement
			end

			if live then
				local displacement = PartConstants.resolveDisplacement(
					Turbulence.sampleRaw(live, state.Turbulence, state._turbSeed, data.TurbulenceFrequency or 1, p5, v6),
					data.DisplacementMode or "Global",
					rotation,
					p7 or rotation
				)
				v10 += displacement - v5
				v5 = displacement
			end

			p2 = CFrame.new(v10) * p2
			local pointsWithTime = Graph.QueryPointsWithTime(v6, data.RotSpeedX, state.RotSpeedX)
			local pointsWithTime2 = Graph.QueryPointsWithTime(v6, data.RotSpeedY, state.RotSpeedY)
			local pointsWithTime3 = Graph.QueryPointsWithTime(v6, data.RotSpeedZ, state.RotSpeedZ)
			local rotOrder = data.RotOrder or "Global"
			local v11

			if rotMode == "Speed" then
				total += pointsWithTime * v2
				total2 += pointsWithTime2 * v2
				total3 += pointsWithTime3 * v2
				v11 = PartConstants.composeRotation(rotOrder, total, total2, total3)
			else
				v11 = PartConstants.composeRotation(rotOrder, pointsWithTime, pointsWithTime2, pointsWithTime3)
			end

			local v12 = p2 * v11

			if data.VelocityVectored then
				local v13 = directionVectors[emissionDirection] or directionVectors[Enum.NormalId.Top]
				p3 = (v12 * p4)[v13.vector] * v13.multiplier
			end

			result[i] = v12
		end

		return result, p6
	end
end