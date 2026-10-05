local createVector = vector.create
local new = CFrame.new
local angles = CFrame.Angles
local new2 = Vector3.new
local _ = math.rad
local atan2 = math.atan2
local acos = math.acos
local min = math.min
local max = math.max
local abs = math.abs
local log = math.log
return {
	CreateSolver = function(_, instance, p)
		local v = {}
		local parent = instance.Parent
		local v2 = 1.2
		local v3 = 0.85
		local v4 = 1.65
		local v5 = 0.6
		local v6 = 1

		local function flatten(data)
			local X = data.X
			local Y = data.Y
			local Z = data.Z
			local X2 = data.lookVector.X
			local Z2 = data.lookVector.Z
			return new(X, Y, Z) * angles(0, atan2(X2, Z2), 0)
		end

		local p2 = nil
		local now = nil
		local flag = false

		local function getVelocity(cFrame)
			if flag then
				flag = true
				tick()
				p2 = cFrame.p
				return (new2())
			elseif now then
				local now2 = tick()
				local p3 = cFrame.p
				local v7 = (p3 - p2) * 1 / (now2 - now)
				now = now2
				p2 = p3
				return v7
			else
				now = tick()
				p2 = cFrame.p
				return (new2())
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getWalkSpeed(velocity)
			return new2(velocity.x, 0, velocity.z).magnitude
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getWalkDirection(velocity)
			if velocity.magnitude > 0 then
				return velocity.unit
			end

			return createVector(0, 0, -1)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isWalking(p3)
			return getWalkSpeed(p3) > 2
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getBaseCFrame()
			return instance.CFrame * new(0, -instance.Size.Y / 2 - 2, 0)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getBaseRotationY()
			local lookVector = (getBaseCFrame()).lookVector
			return (atan2(lookVector.X, lookVector.Z))
		end

		local FindCollidablePartOnRay = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("FindCollidablePartOnRay"))

		local function FindPartOnRay(p3, p4)
			return FindCollidablePartOnRay(p3.Origin, p3.Direction, p4, instance)
		end

		local otherLeg = nil
		local otherLeg2 = nil
		local v9 = {}
		local v10 = nil

		local function initLegs()
			local baseCFrame = getBaseCFrame() -- equivalent call inferred; original call site unknown
			local X = baseCFrame.X
			local Y = baseCFrame.Y
			local Z = baseCFrame.Z
			local X2 = baseCFrame.lookVector.X
			local Z2 = baseCFrame.lookVector.Z
			local v11 = new(X, Y, Z) * angles(0, atan2(X2, Z2), 0)
			v10 = v11
			otherLeg = {
				OffsetModifier = new(-v2 / 2, 0, 0),
				Side = -1,
				StepCycle = 0,
				FootPosition = v11 * new(-v2 / 2, 0, 0).p,
				LastStepTo = v11 * new(-v2 / 2, 0, 0).p,
				Takeoff = v11 * new(-v2 / 2, 0, 0).p
			}
			otherLeg2 = {
				OffsetModifier = new(v2 / 2, 0, 0),
				Side = 1,
				StepCycle = 0,
				FootPosition = v11 * new(v2 / 2, 0, 0).p,
				LastStepTo = v11 * new(-v2 / 2, 0, 0).p,
				Takeoff = v11 * new(-v2 / 2, 0, 0).p
			}
			otherLeg.OtherLeg = otherLeg2
			otherLeg2.OtherLeg = otherLeg
			v9 = { otherLeg2, otherLeg }
		end

		local v11 = 1

		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateScaling()
			local value = p and p.Value or 1
			local v12 = value / v11
			v11 = value
			v2 *= v12
			v3 *= v12
			v4 *= v12
			v5 *= v12
			v6 *= v12
			otherLeg.OffsetModifier = new(-v2 / 2, 0, 0)
		end

		if p then
			p.Changed:Connect(function()
				if otherLeg then
					UpdateScaling() -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local v12 = 1
		local v13 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getStrideForward()
			if v12 > 0 then
				return v3 + v3 * 1 * v12
			end

			return v3 + v3 * 0.5 * v12
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getStrideFull()
			if v12 > 0 then
				return v3 + v4 + (v3 + v4) * 1.5 * v12
			end

			return v3 + v4 + (v3 + v4) * 0.5 * v12
		end

		local function snapDown(p3)
			local v14 = p3 + createVector(0, 2, 0)
			local ray = Ray.new(v14, createVector(0, -500, 0))
			local v16, v17 = FindCollidablePartOnRay(ray.Origin, ray.Direction, parent, instance)

			if not v16 then
				return p3, createVector(0, 1, 0)
			end

			local ray2 = Ray.new(v14 + createVector(0, 0, 0.01), createVector(0, -500, 0))
			local v19, v20 = FindCollidablePartOnRay(ray2.Origin, ray2.Direction, parent, instance)
			local ray3 = Ray.new(v14 + createVector(0, 0, -0.01), createVector(0, -500, 0))
			local v22, v23 = FindCollidablePartOnRay(ray3.Origin, ray3.Direction, parent, instance)
			local ray4 = Ray.new(v14 + createVector(0.01, 0, 0), createVector(0, -500, 0))
			local v25, v26 = FindCollidablePartOnRay(ray4.Origin, ray4.Direction, parent, instance)
			local unit

			if v19 and v22 and v25 then
				unit = (v20 - v23):Cross(v23 - v26).unit

				if unit.Y < 0 then
					unit = -unit
				end
			end

			return v17, unit
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fixFeetPositionsY()
			for _, v14 in pairs(v9) do
				local footPosition, _ = snapDown(v14.FootPosition)
				v14.FootPosition = footPosition
			end
		end

		local v14 = nil

		function v.GetFeetCFrames(_)
			if not otherLeg2 then
				initLegs()
				UpdateScaling() -- equivalent call inferred; original call site unknown
			end

			local now2 = tick()

			if not v14 then
				v14 = now2
			end

			local stepCycle = now2 - v14
			v14 = now2
			local velocity = getVelocity(instance.CFrame)
			local walkSpeed = getWalkSpeed(velocity) -- equivalent call inferred; original call site unknown
			local cFrame = instance.CFrame
			local X = cFrame.X
			local Y = cFrame.Y
			local Z = cFrame.Z
			local X2 = cFrame.lookVector.X
			local Z2 = cFrame.lookVector.Z
			local v16 = new(X, Y, Z) * angles(0, atan2(X2, Z2), 0)
			local lookVector = v16.lookVector
			local cross = lookVector:Cross(createVector(0, 1, 0))
			local walkDirection = getWalkDirection(velocity) -- equivalent call inferred; original call site unknown
			local cross2 = walkDirection:Cross(createVector(0, 1, 0))
			v12 = max(-1, (min(1, log(walkSpeed / 16) / 0.6931471805599453)))
			local v20 = otherLeg2.StepCycle > 0
			local v21 = otherLeg.StepCycle > 0
			local spline

			spline = function(p3, p4, list)
				if p4 == 1 then
					return list[1]
				end

				local v22 = 1 - p3

				for i = 1, p4 - 1 do
					list[i] = v22 * list[i] + p3 * list[i + 1]
				end

				return spline(p3, p4 - 1, list)
			end

			local function positionFootByCycle(state, lastStepTo)
				local v22 = lastStepTo - state.Takeoff
				local v23 = cross2 * state.Side
				local _ = v22.magnitude
				local v24 = v23 * (v2 / 2) * 0.3
				local vector2 = new2(0, v5 * 1.3 * (1 / state.StepSpeedMod), 0)
				local v26 = state.Takeoff + v22 * 1 / 2 + vector2 + v24
				local v27 = state.Takeoff + v22 * 0.9 + vector2 + v24
				local v28 = state.StepCycle ^ (_G.A or 1)
				local v29 = {
					state.Takeoff,
					v26,
					v27,
					lastStepTo
				}
				local v30 = 1 - v28
				v29[1] = v30 * v29[1] + v28 * v29[2]
				v29[2] = v30 * v29[2] + v28 * v29[3]
				v29[3] = v30 * v29[3] + v28 * v29[4]
				local v31 = spline(v28, 3, v29)
				local magnitude = (v31 - state.FootPosition).magnitude
				local footPosition3

				if stepCycle * walkSpeed * 2 < magnitude then
					local v33 = (1 - state.StepCycle) * state.FootPosition + state.StepCycle * v31
					footPosition3 = state.FootPosition + (v31 - state.FootPosition).unit * stepCycle * walkSpeed * 2

					if (v33 - v31).magnitude < (footPosition3 - v31).magnitude then
						footPosition3 = v33
					end
				else
					footPosition3 = v31
				end

				state.FootPosition = footPosition3
				state.LastStepTo = lastStepTo
			end

			local v22 = isWalking(velocity)

			if v22 then
				v13 = false
			end

			if v22 then
				local v23 = cross2 * (v2 / 2) * 0.5
				local v24 = v16 * otherLeg.OffsetModifier
				local strideForward = getStrideForward() -- equivalent call inferred; original call site unknown
				local p3 = (v24 + strideForward * walkDirection - otherLeg.Side * v23).p
				local v25 = v16 * otherLeg2.OffsetModifier
				local strideForward2 = getStrideForward() -- equivalent call inferred; original call site unknown
				local p4 = (v25 + strideForward2 * walkDirection - otherLeg2.Side * v23).p
				local aheadStep, normalHint = snapDown(p3)
				local aheadStep2, normalHint2 = snapDown(p4)

				if v21 and otherLeg.AheadStep and not ((aheadStep - otherLeg.AheadStep).magnitude < stepCycle * walkSpeed) then
					otherLeg.AheadStep += (aheadStep - otherLeg.AheadStep).unit * stepCycle * walkSpeed * 2
				else
					otherLeg.AheadStep = aheadStep
				end

				otherLeg.NormalHint = normalHint

				if v20 and otherLeg2.AheadStep and not ((aheadStep2 - otherLeg2.AheadStep).magnitude < stepCycle * walkSpeed) then
					otherLeg2.AheadStep += (aheadStep2 - otherLeg2.AheadStep).unit * stepCycle * walkSpeed * 2
				else
					otherLeg2.AheadStep = aheadStep2
				end

				otherLeg2.NormalHint = normalHint2
				local v30 = 0.9 - max(0, v12) * 0.3
				local strideFull = getStrideFull() -- equivalent call inferred; original call site unknown
				local v31 = walkSpeed / strideFull * v30

				if v20 or v21 then
					if v20 and v21 then
						for _, v32 in pairs(v9) do
							v32.StepCycle = min(1, v32.StepCycle + stepCycle * v31 * v32.StepSpeedMod)
							positionFootByCycle(v32, v32.AheadStep)

							if v32.StepCycle == 1 then
								v32.StepCycle = 0
							end
						end
					else
						for _, v32 in pairs(v9) do
							if not (v32.StepCycle > 0) then
								continue
							end

							v32.StepCycle = min(1, v32.StepCycle + stepCycle * v31 * v32.StepSpeedMod)
							positionFootByCycle(v32, v32.AheadStep)

							if v30 < v32.StepCycle then
								v32.OtherLeg.StepSpeedMod = 1
								v32.OtherLeg.StepCycle = stepCycle
								v32.OtherLeg.Takeoff = v32.OtherLeg.FootPosition
								positionFootByCycle(v32.OtherLeg, v32.AheadStep)
							end

							if v32.StepCycle ~= 1 then
								break
							end

							v32.StepCycle = 0
							break
						end
					end
				elseif (otherLeg2.FootPosition - otherLeg2.AheadStep).magnitude < (otherLeg.FootPosition - otherLeg.AheadStep).magnitude then
					local magnitude = (otherLeg2.FootPosition - otherLeg2.AheadStep).magnitude
					local strideFull2 = getStrideFull() -- equivalent call inferred; original call site unknown
					local v36 = min(0.9, (max(0, magnitude / strideFull2)))
					otherLeg2.StepSpeedMod = 1 / (1 - v36)
					otherLeg2.StepCycle = stepCycle
					otherLeg2.Takeoff = otherLeg2.FootPosition
				else
					local magnitude = (otherLeg.FootPosition - otherLeg.AheadStep).magnitude
					local strideFull2 = getStrideFull() -- equivalent call inferred; original call site unknown
					local v36 = min(0.9, (max(0, magnitude / strideFull2)))
					otherLeg.StepSpeedMod = 1 / (1 - v36)
					otherLeg.StepCycle = stepCycle
					otherLeg.Takeoff = otherLeg.FootPosition
				end
			else
				if v20 or v21 then
					for _, v23 in pairs(v9) do
						if not (v23.StepCycle > 0) then
							continue
						end

						v23.StepCycle = min(1, v23.StepCycle + stepCycle * 2)
						local p3 = (v16 * v23.OffsetModifier).p
						local v25 = v23.LastStepTo - p3
						local magnitude = v25.magnitude
						local v26

						if v6 < magnitude then
							v26 = p3 + v25.unit * v6
						else
							v26 = v23.LastStepTo
						end

						local aheadStep, normalHint = snapDown(v26)
						v23.AheadStep = aheadStep
						v23.NormalHint = normalHint
						positionFootByCycle(v23, aheadStep)

						if v23.StepCycle == 1 then
							v23.StepCycle = 0
						end
					end
				else
					fixFeetPositionsY() -- equivalent call inferred; original call site unknown
				end

				if otherLeg.StepCycle == 0 and otherLeg2.StepCycle == 0 then
					local p3 = (v16 * otherLeg.OffsetModifier).p
					local p4 = (v16 * otherLeg2.OffsetModifier).p
					local vector2 = otherLeg.FootPosition - p3
					local vector3 = otherLeg2.FootPosition - p4
					local v24 = abs(vector2:Dot(lookVector) - vector3:Dot(lookVector)) > 3
					local v27 = acos((min(1, (max(-1, vector2.unit:Dot(vector3.unit))))))
					local v29 = abs(vector2.magnitude - vector3.magnitude)
					local dot = vector2:Dot(cross)

					if v2 / 4 < dot then
						v13 = false
						otherLeg.Takeoff = otherLeg.FootPosition
						otherLeg.StepCycle = stepCycle
						local v30 = vector3.unit * 0.5

						if vector3.magnitude == 0 then
							v30 = -cross * 0.5
						elseif vector3:Dot(cross) > 0 then
							v30 = (vector3 - 2 * cross * vector3:Dot(cross)).unit * 0.5
						end

						otherLeg.LastStepTo = p3 + v30

						if (otherLeg.LastStepTo - otherLeg.Takeoff).magnitude < 0.5 then
							otherLeg.StepCycle = 0
						end

						local magnitude = (otherLeg.FootPosition - otherLeg.LastStepTo).magnitude
						local strideFull = getStrideFull() -- equivalent call inferred; original call site unknown
						local v35 = min(0.9, (max(0, magnitude / strideFull)))
						otherLeg.StepSpeedMod = 1 / (1 - v35)
					elseif vector3:Dot(cross) < -v2 / 4 then
						v13 = false
						otherLeg2.Takeoff = otherLeg2.FootPosition
						otherLeg2.StepCycle = stepCycle
						local v30 = vector2.unit * 0.5

						if vector2.magnitude == 0 then
							v30 = cross * 0.5
						elseif vector2:Dot(cross) < 0 then
							v30 = (vector2 - 2 * cross * vector2:Dot(cross)).unit * 0.5
						end

						otherLeg2.LastStepTo = p4 + v30

						if (otherLeg.LastStepTo - otherLeg.Takeoff).magnitude < 0.5 then
							otherLeg.StepCycle = 0
						end

						local magnitude = (otherLeg2.FootPosition - otherLeg2.LastStepTo).magnitude
						local strideFull = getStrideFull() -- equivalent call inferred; original call site unknown
						local v35 = min(0.9, (max(0, magnitude / strideFull)))
						otherLeg2.StepSpeedMod = 1 / (1 - v35)
					elseif not v13 and (v27 < 2.6179938779914944 or v29 > 0.2 or v24) then
						v13 = true
						local v30

						if vector2.magnitude > vector3.magnitude then
							v30 = otherLeg
						else
							v30 = otherLeg2
							p3 = p4
							vector3 = vector2
						end

						v30.StepCycle = stepCycle
						v30.Takeoff = v30.FootPosition
						v30.StepSpeedMod = 1

						if v24 then
							v30.LastStepTo = p3 - 0.5 * vector3
						else
							v30.LastStepTo = p3 - vector3
						end

						if (v30.Takeoff - v30.LastStepTo).magnitude < 0.2 then
							v30.StepCycle = 0
						end
					end
				end

				fixFeetPositionsY() -- equivalent call inferred; original call site unknown
			end

			local footPosition = otherLeg2.FootPosition
			local footPosition2 = otherLeg.FootPosition
			local baseRotationY = getBaseRotationY() -- equivalent call inferred; original call site unknown
			local cframe = angles(0, 0.08726646259971647 + baseRotationY, 0)
			local cframe2 = angles(0, -0.08726646259971647 + baseRotationY, 0)
			return new(footPosition) * cframe, new(footPosition2) * cframe2
		end

		function v.OffsetFeet(_, p3)
			flag = true

			for _, v15 in pairs(v9) do
				v15.FootPosition += p3
				v15.LastStepTo += p3

				if v15.Takeoff then
					v15.Takeoff += p3
				end

				if v15.AheadStep then
					v15.AheadStep += p3
				end
			end

			flag = true
		end

		return v
	end
}