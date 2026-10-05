local createVector = vector.create
local Graph = require(script.Parent.Graph)
local PartConstants = require(script.Parent.PartConstants)
local EventsCollision = require(script.Parent.EventsCollision)
local Turbulence = require(script.Parent.Turbulence)
local directionVectors = PartConstants.DirectionVectors

local function getLinkCF(data)
	local link = data.Link

	if not (link and link.Parent) then
		return CFrame.new(), false
	end

	local _rigidLocalParentCF

	if data.LinkMode == "RigidLocal" then
		_rigidLocalParentCF = data._rigidLocalParentCF or CFrame.new()
	else
		_rigidLocalParentCF = PartConstants.resolveLinkCFrame(link)
	end

	if data.LinkMode == "Follow" or data.LinkMode == "Pivot" then
		return CFrame.new(_rigidLocalParentCF.Position), false
	end

	return _rigidLocalParentCF, true
end

local function getAttachmentLinkCF(data)
	local link = data.Link

	if not (link and link.Parent) then
		return CFrame.new(), false, false
	end

	local parent = data.VisualPart and data.VisualPart.Parent

	if not parent then
		return CFrame.new(), false, false
	end

	local v

	if data.LinkMode == "RigidLocal" then
		v = data._rigidLocalParentCF or CFrame.new()
	else
		v = PartConstants.resolveLinkCFrame(link)
	end

	local objectSpace = (parent:IsA("BasePart") and parent.CFrame or CFrame.new()):ToObjectSpace(v)

	if data.LinkMode == "Follow" or data.LinkMode == "Pivot" then
		return CFrame.new(objectSpace.Position), false, true
	end

	return objectSpace, true, true
end

local function getTargetPosition(accelTarget)
	if not (accelTarget and accelTarget.Parent) then
		return nil
	end

	if accelTarget:IsA("Bone") then
		return accelTarget.TransformedWorldCFrame.Position
	end

	if accelTarget:IsA("BasePart") then
		return accelTarget.Position
	end

	if accelTarget:IsA("Attachment") then
		return accelTarget.WorldPosition
	end

	if accelTarget:IsA("Camera") then
		return accelTarget.CFrame.Position
	end

	if accelTarget:IsA("Model") then
		local success, pivot = pcall(accelTarget.GetPivot, accelTarget)

		if success and pivot then
			return pivot.Position
		end
	end

	return nil
end

local function _posOffsetFrameDelta(state, p, p2)
	if not (state.HasPosOffsetGraphs or state.HasTurbulence) then
		return createVector(0, 0, 0), false
	end

	local v

	if state.HasPosOffsetGraphs then
		local _staticPosOffsetX = state._staticPosOffsetX or not state.Graphs.PosOffsetX and 0 or Graph.QueryPointsWithTime(
			p,
			state.Graphs.PosOffsetX,
			state.Seeds.PosOffsetX
		) or 0
		local _staticPosOffsetY = state._staticPosOffsetY or not state.Graphs.PosOffsetY and 0 or Graph.QueryPointsWithTime(
			p,
			state.Graphs.PosOffsetY,
			state.Seeds.PosOffsetY
		) or 0
		local _staticPosOffsetZ = state._staticPosOffsetZ or not state.Graphs.PosOffsetZ and 0 or Graph.QueryPointsWithTime(
			p,
			state.Graphs.PosOffsetZ,
			state.Seeds.PosOffsetZ
		) or 0
		local displacement = PartConstants.resolveDisplacement(
			Vector3.new(_staticPosOffsetX, _staticPosOffsetY, _staticPosOffsetZ),
			state.DisplacementMode or "Global",
			state.SpawnRotation,
			state.SpawnEmitterRotation,
			state._displacementMirrorX,
			state._displacementMirrorY,
			state._displacementMirrorZ
		)
		v = displacement - state._prevWorldOff
		state._prevWorldOff = displacement
	else
		v = createVector(0, 0, 0)
	end

	if state.HasTurbulence then
		v += Turbulence.frameDelta(state, p)
	end

	return v, p2 and (state.DisplacementMode or "Global") == "Local"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _composeLocalDelta(cframe, p, p2, p3, p4, p5)
	if p then
		return (cframe:VectorToObjectSpace(p2) + (p4 and p3 or cframe:VectorToObjectSpace(p3))) * p5
	end

	return (p2 + p3) * p5
end

return function(p)
	function p.UpdatePart(_, state, p2, p3)
		local v = math.min(math.max((p3 - state.StartTime) / state.LifeTime, 0), 1)
		local v2

		if state._tsOverride == nil or not (p3 < (state._tsOverrideUntil or 0)) then
			v2 = not state.Graphs.Timescale and 1 or Graph.QueryPointsWithTime(
				v,
				state.Graphs.Timescale,
				state.Seeds.Timescale
			) or 1
		else
			v2 = state._tsOverride
		end

		local v3 = p2 * v2
		local lifeTime = state.LifeTime
		local _effectiveElapsed = state._effectiveElapsed or 0
		local v4 = _effectiveElapsed + (state._timeFrozen and 0 or v3)

		if v3 < 0 and state._hitHistory and #state._hitHistory > 0 then
			EventsCollision.restoreHitsOnReverse(state, _effectiveElapsed, v4)
		end

		local effectiveElapsed = v4 < 0 and 0 or v4

		if lifeTime < effectiveElapsed then
			effectiveElapsed = lifeTime
		end

		state._effectiveElapsed = effectiveElapsed
		local lastEffectiveDt = effectiveElapsed - _effectiveElapsed
		state._lastEffectiveDt = lastEffectiveDt
		local v7 = lifeTime <= effectiveElapsed
		local v8 = effectiveElapsed <= 0
		local v9 = effectiveElapsed / lifeTime

		if not (state.VisualPart and state.VisualPart.Parent) or state.TotalKeyFrames <= 0 then
			return true
		end

		local v10 = v >= 1

		if state._collisionStopped then
			return v10 and (v7 or v8)
		end

		local v11, v12, v13

		if state.ParentScale then
			v11 = PartConstants.getParentScaleFactor(state.ParentScale, p3, Graph)
			v12 = PartConstants.getParentScaleFactor(state.ParentScale, p3, Graph, "motion")
			v13 = PartConstants.getParentScaleFactor(state.ParentScale, p3, Graph, "rotation")
		else
			v12 = 1
			v13 = 1
			v11 = 1
		end

		local v14 = v10 and (v7 or v8)
		local v15 = math.min(math.max(v9, 0), 1)
		state.AccumulatedDT += lastEffectiveDt
		local currentStep2 = math.floor(v15 * state.TotalKeyFrames)

		if currentStep2 == state.CurrentStep then
			return v14
		end

		local currentStep = state.CurrentStep
		local v17 = currentStep < currentStep2 and 1 or -1
		local v18 = math.abs(currentStep2 - currentStep)
		local v19 = state.AccumulatedDT / v18
		local accumulatedDT = state.AccumulatedDT
		state.AccumulatedDT = 0
		local _spinRate = state._spinRate

		if _spinRate and (_spinRate.X ~= 0 or _spinRate.Y ~= 0 or _spinRate.Z ~= 0) then
			state._spinAccumX = (state._spinAccumX or 0) + _spinRate.X * accumulatedDT
			state._spinAccumY = (state._spinAccumY or 0) + _spinRate.Y * accumulatedDT
			state._spinAccumZ = (state._spinAccumZ or 0) + _spinRate.Z * accumulatedDT
		end

		local speedMultiplier = state.SpeedMultiplier or 1

		if state.InvertMotion then
			state.CurrentStep = currentStep2
			local v20 = state.TotalKeyFrames - currentStep2
			local localWorldCF = state.SimLocalCFrames[v20] or state.SimLocalCFrames[0]
			local linkCF = getLinkCF(state)
			state.VisualPart.CFrame = linkCF * localWorldCF
			state._localWorldCF = localWorldCF
			state.CurrentPosition = state.VisualPart.Position
		elseif state.NeedsFullIteration then
			local hasDrag = state.HasDrag
			local hasAccel = state.HasAccel
			local linkCF, v20 = getLinkCF(state)
			local v21 = directionVectors[state.EmissionDirection] or directionVectors[Enum.NormalId.Top]
			local localCF = state.LocalCF
			local accRotX = state.AccRotX
			local accRotY = state.AccRotY
			local accRotZ = state.AccRotZ
			local baseDirection = state.BaseDirection
			local _accelVel = state._accelVel or createVector(0, 0, 0)
			local targetVel = state.TargetVel
			local position = state.VisualPart.Position
			local rotMode = state.RotMode
			local rotOrder = state.RotOrder or "Global"
			local cFrame = nil
			local localWorldCF = nil

			for i = currentStep + v17, currentStep2, v17 do
				local v24 = i / state.TotalKeyFrames
				local v25 = v24 * state.LifeTime
				local _speedOverride = state._speedOverride or (state._staticSpeed or Graph.QueryPointsWithTime(
					v24,
					state.Graphs.Speed,
					state.Seeds.Speed
				)) * speedMultiplier

				if hasDrag then
					_speedOverride = _speedOverride * math.exp(-state.Drag * v25) or _speedOverride
				end

				local v26

				if hasAccel then
					_accelVel += PartConstants.applyContactAccel(state.Acceleration, state, v19) * v19
					v26 = (baseDirection * _speedOverride + _accelVel) * v19
				else
					v26 = baseDirection * (_speedOverride * v19)
				end

				if state.HasTargetAccel then
					local targetPosition = getTargetPosition(state.AccelTarget)

					if targetPosition then
						local v27 = targetPosition - position
						local magnitude = v27.Magnitude

						if magnitude > 0.0001 then
							local _staticAccelStrength = state._staticAccelStrength or Graph.QueryPointsWithTime(
								v24,
								state.Graphs.AccelStrength,
								state.Seeds.AccelStrength
							)

							if _staticAccelStrength and _staticAccelStrength ~= 0 then
								targetVel += v27 * (_staticAccelStrength * v19 / magnitude)
								v26 += targetVel * v19
							end
						end
					end
				end

				local v27, v28 = _posOffsetFrameDelta(state, v24, v20)
				local v29 = _composeLocalDelta(linkCF, v20, v26, v27, v28, v12) -- equivalent call inferred; original call site unknown
				localCF = CFrame.new(v29) * localCF
				local v30 = (state._settleRotDamp or 1) * v13
				local v31 = (state._staticRotSpeedX or Graph.QueryPointsWithTime(
					v24,
					state.Graphs.RotSpeedX,
					state.Seeds.RotSpeedX
				)) * v30
				local v32 = (state._staticRotSpeedY or Graph.QueryPointsWithTime(
					v24,
					state.Graphs.RotSpeedY,
					state.Seeds.RotSpeedY
				)) * v30
				local v33 = (state._staticRotSpeedZ or Graph.QueryPointsWithTime(
					v24,
					state.Graphs.RotSpeedZ,
					state.Seeds.RotSpeedZ
				)) * v30
				local _spinAccumX = state._spinAccumX or 0
				local _spinAccumY = state._spinAccumY or 0
				local _spinAccumZ = state._spinAccumZ or 0
				local v34

				if rotMode == "Speed" then
					accRotX += v31 * v19
					accRotY += v32 * v19
					accRotZ += v33 * v19
					v34 = PartConstants.composeRotation(
						rotOrder,
						accRotX + _spinAccumX,
						accRotY + _spinAccumY,
						accRotZ + _spinAccumZ
					)
				else
					v34 = PartConstants.composeRotation(
						rotOrder,
						v31 + _spinAccumX,
						v32 + _spinAccumY,
						v33 + _spinAccumZ
					)
				end

				cFrame = linkCF * localCF * v34
				localWorldCF = localCF * v34
				position = cFrame.Position
				baseDirection = (cFrame * state.SpreadRotation)[v21.vector] * v21.multiplier
			end

			state.LocalCF = localCF
			state.AccRotX = accRotX
			state.AccRotY = accRotY
			state.AccRotZ = accRotZ
			state.BaseDirection = baseDirection
			state._accelVel = _accelVel
			state.TargetVel = targetVel
			state.CurrentPosition = position
			state.CurrentStep = currentStep2

			if cFrame then
				state.VisualPart.CFrame = cFrame
				state._localWorldCF = localWorldCF
			end
		elseif state.NeedsRotAccum then
			local hasDrag = state.HasDrag
			local hasAccel = state.HasAccel
			local _accelVel = state._accelVel or createVector(0, 0, 0)
			local total = 0
			local v20 = createVector(0, 0, 0)

			for i = currentStep + v17, currentStep2, v17 do
				local v21 = i / state.TotalKeyFrames
				local v22 = v21 * state.LifeTime
				local _speedOverride = state._speedOverride or (state._staticSpeed or Graph.QueryPointsWithTime(
					v21,
					state.Graphs.Speed,
					state.Seeds.Speed
				)) * speedMultiplier

				if hasDrag then
					_speedOverride *= math.exp(-state.Drag * v22)
				end

				total += _speedOverride * v19

				if hasAccel then
					_accelVel += PartConstants.applyContactAccel(state.Acceleration, state, v19) * v19
					v20 += _accelVel * v19
				end

				local v23 = (state._settleRotDamp or 1) * v13
				local v24 = (state._staticRotSpeedX or Graph.QueryPointsWithTime(
					v21,
					state.Graphs.RotSpeedX,
					state.Seeds.RotSpeedX
				)) * v23
				local v25 = (state._staticRotSpeedY or Graph.QueryPointsWithTime(
					v21,
					state.Graphs.RotSpeedY,
					state.Seeds.RotSpeedY
				)) * v23
				local v26 = (state._staticRotSpeedZ or Graph.QueryPointsWithTime(
					v21,
					state.Graphs.RotSpeedZ,
					state.Seeds.RotSpeedZ
				)) * v23
				state.AccRotX += v24 * v19
				state.AccRotY += v25 * v19
				state.AccRotZ += v26 * v19
			end

			state._accelVel = _accelVel
			local v21 = state.BaseDirection * total + v20

			if state.HasTargetAccel then
				local targetPosition = getTargetPosition(state.AccelTarget)

				if targetPosition then
					local v22 = targetPosition - state.VisualPart.Position
					local magnitude = v22.Magnitude

					if magnitude > 0.0001 then
						local v23 = v19 * (currentStep2 - currentStep)
						local v24 = (currentStep + 1 + currentStep2) * 0.5 / state.TotalKeyFrames
						local _staticAccelStrength = state._staticAccelStrength or Graph.QueryPointsWithTime(
							v24,
							state.Graphs.AccelStrength,
							state.Seeds.AccelStrength
						)

						if _staticAccelStrength and _staticAccelStrength ~= 0 then
							state.TargetVel += v22 * (_staticAccelStrength * v23 / magnitude)
							v21 += state.TargetVel * v23
						end
					end
				end
			end

			local linkCF, v22 = getLinkCF(state)
			local v23, v24 = _posOffsetFrameDelta(state, currentStep2 / state.TotalKeyFrames, v22)
			local v25 = _composeLocalDelta(linkCF, v22, v21, v23, v24, v12) -- equivalent call inferred; original call site unknown
			state.LocalCF = CFrame.new(v25) * state.LocalCF
			local _spinAccumX = state._spinAccumX or 0
			local _spinAccumY = state._spinAccumY or 0
			local _spinAccumZ = state._spinAccumZ or 0
			local rotation = PartConstants.composeRotation(
				state.RotOrder or "Global",
				state.AccRotX + _spinAccumX,
				state.AccRotY + _spinAccumY,
				state.AccRotZ + _spinAccumZ
			)
			state.VisualPart.CFrame = linkCF * state.LocalCF * rotation
			state._localWorldCF = state.LocalCF * rotation
			state.CurrentPosition = state.VisualPart.Position
			state.CurrentStep = currentStep2
		else
			local hasDrag = state.HasDrag
			local hasAccel = state.HasAccel
			local v20 = 0
			local v21 = createVector(0, 0, 0)
			local _accelVel = state._accelVel or createVector(0, 0, 0)

			if hasDrag then
				for i = currentStep + v17, currentStep2, v17 do
					local v22 = i / state.TotalKeyFrames
					local v23 = v22 * state.LifeTime
					v20 += (state._speedOverride or (state._staticSpeed or Graph.QueryPointsWithTime(
						v22,
						state.Graphs.Speed,
						state.Seeds.Speed
					)) * speedMultiplier) * math.exp(-state.Drag * v23) * v19

					if not hasAccel then
						continue
					end

					_accelVel += PartConstants.applyContactAccel(state.Acceleration, state, v19) * v19
					v21 += _accelVel * v19
				end
			else
				local v22 = 1 / state.TotalKeyFrames
				local v23 = currentStep * v22
				local v24 = currentStep2 * v22
				local _speedOverride = state._speedOverride

				if _speedOverride then
					v20 = _speedOverride * (v24 - v23) * state.LifeTime
				elseif state._staticSpeed then
					v20 = state._staticSpeed * speedMultiplier * (v24 - v23) * state.LifeTime
				else
					v20 = state.LifeTime * speedMultiplier * (Graph.IntegrateUpTo(
						v24,
						state.Graphs.Speed,
						state.Seeds.Speed
					) - Graph.IntegrateUpTo(v23, state.Graphs.Speed, state.Seeds.Speed))
				end

				if hasAccel then
					local v25 = (v24 - v23) * state.LifeTime
					local v26 = PartConstants.applyContactAccel(state.Acceleration, state, v25)
					v21 = _accelVel * v25 + v26 * (v25 * v25 * 0.5)
					_accelVel += v26 * v25
				end
			end

			state._accelVel = _accelVel
			local v22 = state.BaseDirection * v20 + v21

			if state.HasTargetAccel then
				local targetPosition = getTargetPosition(state.AccelTarget)

				if targetPosition then
					local v23 = targetPosition - state.VisualPart.Position
					local magnitude = v23.Magnitude

					if magnitude > 0.0001 then
						local v24 = v19 * (currentStep2 - currentStep)
						local v25 = (currentStep + 1 + currentStep2) * 0.5 / state.TotalKeyFrames
						local _staticAccelStrength = state._staticAccelStrength or Graph.QueryPointsWithTime(
							v25,
							state.Graphs.AccelStrength,
							state.Seeds.AccelStrength
						)

						if _staticAccelStrength and _staticAccelStrength ~= 0 then
							state.TargetVel += v23 * (_staticAccelStrength * v24 / magnitude)
							v22 += state.TargetVel * v24
						end
					end
				end
			end

			local linkCF, v23 = getLinkCF(state)
			local v24, v25 = _posOffsetFrameDelta(state, currentStep2 / state.TotalKeyFrames, v23)
			local v26 = _composeLocalDelta(linkCF, v23, v22, v24, v25, v12) -- equivalent call inferred; original call site unknown
			state.LocalCF = CFrame.new(v26) * state.LocalCF
			local v27 = currentStep2 / state.TotalKeyFrames
			local v28 = (state._settleRotDamp or 1) * v13
			local v29 = (state._staticRotSpeedX or Graph.QueryPointsWithTime(
				v27,
				state.Graphs.RotSpeedX,
				state.Seeds.RotSpeedX
			)) * v28 + (state._spinAccumX or 0)
			local v30 = (state._staticRotSpeedY or Graph.QueryPointsWithTime(
				v27,
				state.Graphs.RotSpeedY,
				state.Seeds.RotSpeedY
			)) * v28 + (state._spinAccumY or 0)
			local v31 = (state._staticRotSpeedZ or Graph.QueryPointsWithTime(
				v27,
				state.Graphs.RotSpeedZ,
				state.Seeds.RotSpeedZ
			)) * v28 + (state._spinAccumZ or 0)
			local rotation = PartConstants.composeRotation(state.RotOrder or "Global", v29, v30, v31)
			state.VisualPart.CFrame = linkCF * state.LocalCF * rotation
			state._localWorldCF = state.LocalCF * rotation
			state.CurrentPosition = state.VisualPart.Position
			state.CurrentStep = currentStep2
		end

		local v20 = currentStep2 / state.TotalKeyFrames

		if not state.SkipSize then
			local _staticSizeX = state._staticSizeX or Graph.QueryPointsWithTime(
				v20,
				state.Graphs.SizeX,
				state.Seeds.SizeX
			)
			local _staticSizeY = state._staticSizeY or Graph.QueryPointsWithTime(
				v20,
				state.Graphs.SizeY,
				state.Seeds.SizeY
			)
			local _staticSizeZ = state._staticSizeZ or Graph.QueryPointsWithTime(
				v20,
				state.Graphs.SizeZ,
				state.Seeds.SizeZ
			)

			if v11 ~= 1 then
				_staticSizeX *= v11
				_staticSizeY *= v11
				_staticSizeZ *= v11
			end

			if state.SpecialMesh then
				state.SpecialMesh.Scale = Vector3.new(_staticSizeX, _staticSizeY, _staticSizeZ)
			else
				state.VisualPart.Size = Vector3.new(_staticSizeX, _staticSizeY, _staticSizeZ)
			end
		end

		local _staticTransparency = state._staticTransparency or Graph.QueryPointsWithTime(
			v20,
			state.Graphs.Transparency,
			state.Seeds.Transparency
		)

		if state.SurfaceAppearance then
			local _staticBrightness = state._staticBrightness or Graph.QueryPointsWithTime(
				v20,
				state.Graphs.Brightness,
				state.Seeds.Brightness
			)
			local colorPointWithTime = Graph.QueryColorPointWithTime(v20, state.Graphs.Color)

			if not state.SkipTransparency then
				state.VisualPart.Transparency = _staticTransparency
			end

			if not state.SkipColor then
				state.VisualPart.Color = Color3.fromRGB(
					colorPointWithTime.R * 255,
					colorPointWithTime.G * 255,
					colorPointWithTime.B * 255
				)
				state.SurfaceAppearance.Color = Color3.fromRGB(
					colorPointWithTime.R * 255,
					colorPointWithTime.G * 255,
					colorPointWithTime.B * 255
				)
				pcall(function()
					state.SurfaceAppearance.EmissiveTint = Color3.new(
						colorPointWithTime.R * _staticBrightness,
						colorPointWithTime.G * _staticBrightness,
						colorPointWithTime.B * _staticBrightness
					)
				end)
				return v14
			end
		elseif state.HasDecal then
			local _staticBrightness = state._staticBrightness or Graph.QueryPointsWithTime(
				v20,
				state.Graphs.Brightness,
				state.Seeds.Brightness
			)
			local colorPointWithTime = Graph.QueryColorPointWithTime(v20, state.Graphs.Color)

			if not state.SkipTransparency then
				state.Decal.Transparency = _staticTransparency
			end

			if not state.SkipColor then
				state.Decal.Color3 = Color3.fromRGB(
					colorPointWithTime.R * 255 * _staticBrightness,
					colorPointWithTime.G * 255 * _staticBrightness,
					colorPointWithTime.B * 255 * _staticBrightness
				)
				return v14
			end
		else
			local colorPointWithTime = Graph.QueryColorPointWithTime(v20, state.Graphs.Color)

			if not state.SkipTransparency then
				state.VisualPart.Transparency = _staticTransparency
			end

			if not state.SkipColor then
				state.VisualPart.Color = Color3.fromRGB(
					colorPointWithTime.R * 255,
					colorPointWithTime.G * 255,
					colorPointWithTime.B * 255
				)
			end
		end

		return v14
	end

	function p.UpdateAttachment(_, state, p2, p3)
		local v = math.min(math.max((p3 - state.StartTime) / state.LifeTime, 0), 1)
		local v2

		if state._tsOverride == nil or not (p3 < (state._tsOverrideUntil or 0)) then
			v2 = not state.Graphs.Timescale and 1 or Graph.QueryPointsWithTime(
				v,
				state.Graphs.Timescale,
				state.Seeds.Timescale
			) or 1
		else
			v2 = state._tsOverride
		end

		local v3 = p2 * v2
		local lifeTime = state.LifeTime
		local _effectiveElapsed = state._effectiveElapsed or 0
		local v4 = _effectiveElapsed + (state._timeFrozen and 0 or v3)

		if v3 < 0 and state._hitHistory and #state._hitHistory > 0 then
			EventsCollision.restoreHitsOnReverse(state, _effectiveElapsed, v4)
		end

		local effectiveElapsed = v4 < 0 and 0 or v4

		if lifeTime < effectiveElapsed then
			effectiveElapsed = lifeTime
		end

		state._effectiveElapsed = effectiveElapsed
		local lastEffectiveDt = effectiveElapsed - _effectiveElapsed
		state._lastEffectiveDt = lastEffectiveDt
		local v7 = lifeTime <= effectiveElapsed
		local v8 = effectiveElapsed <= 0
		local v9 = effectiveElapsed / lifeTime

		if not (state.VisualPart and state.VisualPart.Parent) or state.TotalKeyFrames <= 0 then
			return true
		end

		local v10 = v >= 1

		if state._collisionStopped then
			return v10 and (v7 or v8)
		end

		local v11, v12

		if state.ParentScale then
			PartConstants.getParentScaleFactor(state.ParentScale, p3, Graph)
			v11 = PartConstants.getParentScaleFactor(state.ParentScale, p3, Graph, "motion")
			v12 = PartConstants.getParentScaleFactor(state.ParentScale, p3, Graph, "rotation")
		else
			v11 = 1
			v12 = 1
		end

		local v13 = v10 and (v7 or v8)
		local v14 = math.min(math.max(v9, 0), 1)
		state.AccumulatedDT += lastEffectiveDt
		local currentStep2 = math.floor(v14 * state.TotalKeyFrames)

		if currentStep2 == state.CurrentStep then
			return v13
		end

		local currentStep = state.CurrentStep
		local v16 = currentStep < currentStep2 and 1 or -1
		local v17 = math.abs(currentStep2 - currentStep)
		local v18 = state.AccumulatedDT / v17
		local accumulatedDT = state.AccumulatedDT
		state.AccumulatedDT = 0
		local _spinRate = state._spinRate

		if _spinRate and (_spinRate.X ~= 0 or _spinRate.Y ~= 0 or _spinRate.Z ~= 0) then
			state._spinAccumX = (state._spinAccumX or 0) + _spinRate.X * accumulatedDT
			state._spinAccumY = (state._spinAccumY or 0) + _spinRate.Y * accumulatedDT
			state._spinAccumZ = (state._spinAccumZ or 0) + _spinRate.Z * accumulatedDT
		end

		local speedMultiplier = state.SpeedMultiplier or 1
		local attachmentLinkCF, v19 = getAttachmentLinkCF(state)

		if state.InvertMotion then
			state.CurrentStep = currentStep2
			local v20 = state.TotalKeyFrames - currentStep2
			local v21 = state.SimLocalCFrames[v20] or state.SimLocalCFrames[0]
			state.VisualPart.CFrame = attachmentLinkCF * v21
			state.LocalCF = v21
			state._localWorldCF = v21
			return v13
		elseif state.NeedsFullIteration then
			local hasDrag = state.HasDrag
			local hasAccel = state.HasAccel
			local _accelVel = state._accelVel or createVector(0, 0, 0)
			local _spinAccumX = state._spinAccumX or 0
			local _spinAccumY = state._spinAccumY or 0
			local _spinAccumZ = state._spinAccumZ or 0
			local rotOrder = state.RotOrder or "Global"

			for i = currentStep + v16, currentStep2, v16 do
				local v20 = i / state.TotalKeyFrames
				local v21 = v20 * state.LifeTime
				local _speedOverride = state._speedOverride or (state._staticSpeed or Graph.QueryPointsWithTime(
					v20,
					state.Graphs.Speed,
					state.Seeds.Speed
				)) * speedMultiplier

				if hasDrag then
					_speedOverride = _speedOverride * math.exp(-state.Drag * v21) or _speedOverride
				end

				local v22

				if hasAccel then
					_accelVel += PartConstants.applyContactAccel(state.Acceleration, state, v18) * v18
					v22 = (state.BaseDirection * _speedOverride + _accelVel) * v18
				else
					v22 = state.BaseDirection * (_speedOverride * v18)
				end

				local v23, v24 = _posOffsetFrameDelta(state, v20, v19)
				local v25 = _composeLocalDelta(attachmentLinkCF, v19, v22, v23, v24, v11) -- equivalent call inferred; original call site unknown
				state.LocalCF = CFrame.new(v25) * state.LocalCF
				local v26 = (state._settleRotDamp or 1) * v12
				local v27 = (state._staticRotSpeedX or Graph.QueryPointsWithTime(
					v20,
					state.Graphs.RotSpeedX,
					state.Seeds.RotSpeedX
				)) * v26
				local v28 = (state._staticRotSpeedY or Graph.QueryPointsWithTime(
					v20,
					state.Graphs.RotSpeedY,
					state.Seeds.RotSpeedY
				)) * v26
				local v29 = (state._staticRotSpeedZ or Graph.QueryPointsWithTime(
					v20,
					state.Graphs.RotSpeedZ,
					state.Seeds.RotSpeedZ
				)) * v26
				local v30

				if state.RotMode == "Speed" then
					state.AccRotX += v27 * v18
					state.AccRotY += v28 * v18
					state.AccRotZ += v29 * v18
					v30 = PartConstants.composeRotation(
						rotOrder,
						state.AccRotX + _spinAccumX,
						state.AccRotY + _spinAccumY,
						state.AccRotZ + _spinAccumZ
					)
				else
					v30 = PartConstants.composeRotation(
						rotOrder,
						v27 + _spinAccumX,
						v28 + _spinAccumY,
						v29 + _spinAccumZ
					)
				end

				state.VisualPart.CFrame = attachmentLinkCF * state.LocalCF * v30
				state._localWorldCF = state.LocalCF * v30
				local v31 = state.VisualPart.CFrame * state.SpreadRotation
				local v32 = directionVectors[state.EmissionDirection] or directionVectors[Enum.NormalId.Top]
				state.BaseDirection = v31[v32.vector] * v32.multiplier
			end

			state._accelVel = _accelVel
			state.CurrentStep = currentStep2
			return v13
		elseif state.NeedsRotAccum then
			local hasDrag = state.HasDrag
			local hasAccel = state.HasAccel
			local _accelVel = state._accelVel or createVector(0, 0, 0)
			local total = 0
			local v20 = createVector(0, 0, 0)

			for i = currentStep + v16, currentStep2, v16 do
				local v21 = i / state.TotalKeyFrames
				local v22 = v21 * state.LifeTime
				local _speedOverride = state._speedOverride or (state._staticSpeed or Graph.QueryPointsWithTime(
					v21,
					state.Graphs.Speed,
					state.Seeds.Speed
				)) * speedMultiplier

				if hasDrag then
					_speedOverride *= math.exp(-state.Drag * v22)
				end

				total += _speedOverride * v18

				if hasAccel then
					_accelVel += PartConstants.applyContactAccel(state.Acceleration, state, v18) * v18
					v20 += _accelVel * v18
				end

				local v23 = (state._settleRotDamp or 1) * v12
				local v24 = (state._staticRotSpeedX or Graph.QueryPointsWithTime(
					v21,
					state.Graphs.RotSpeedX,
					state.Seeds.RotSpeedX
				)) * v23
				local v25 = (state._staticRotSpeedY or Graph.QueryPointsWithTime(
					v21,
					state.Graphs.RotSpeedY,
					state.Seeds.RotSpeedY
				)) * v23
				local v26 = (state._staticRotSpeedZ or Graph.QueryPointsWithTime(
					v21,
					state.Graphs.RotSpeedZ,
					state.Seeds.RotSpeedZ
				)) * v23
				state.AccRotX += v24 * v18
				state.AccRotY += v25 * v18
				state.AccRotZ += v26 * v18
			end

			state._accelVel = _accelVel
			local v21 = state.BaseDirection * total + v20
			local v22, v23 = _posOffsetFrameDelta(state, currentStep2 / state.TotalKeyFrames, v19)
			local v24 = _composeLocalDelta(attachmentLinkCF, v19, v21, v22, v23, v11) -- equivalent call inferred; original call site unknown
			state.LocalCF = CFrame.new(v24) * state.LocalCF
			local _spinAccumX = state._spinAccumX or 0
			local _spinAccumY = state._spinAccumY or 0
			local _spinAccumZ = state._spinAccumZ or 0
			local rotation = PartConstants.composeRotation(
				state.RotOrder or "Global",
				state.AccRotX + _spinAccumX,
				state.AccRotY + _spinAccumY,
				state.AccRotZ + _spinAccumZ
			)
			state.VisualPart.CFrame = attachmentLinkCF * state.LocalCF * rotation
			state._localWorldCF = state.LocalCF * rotation
			state.CurrentStep = currentStep2
			return v13
		else
			local hasDrag = state.HasDrag
			local hasAccel = state.HasAccel
			local v20 = 0
			local v21 = createVector(0, 0, 0)
			local _accelVel = state._accelVel or createVector(0, 0, 0)

			if hasDrag then
				for i = currentStep + v16, currentStep2, v16 do
					local v22 = i / state.TotalKeyFrames
					local v23 = v22 * state.LifeTime
					v20 += (state._speedOverride or (state._staticSpeed or Graph.QueryPointsWithTime(
						v22,
						state.Graphs.Speed,
						state.Seeds.Speed
					)) * speedMultiplier) * math.exp(-state.Drag * v23) * v18

					if not hasAccel then
						continue
					end

					_accelVel += PartConstants.applyContactAccel(state.Acceleration, state, v18) * v18
					v21 += _accelVel * v18
				end
			else
				local v22 = 1 / state.TotalKeyFrames
				local v23 = currentStep * v22
				local v24 = currentStep2 * v22
				local _speedOverride = state._speedOverride

				if _speedOverride then
					v20 = _speedOverride * (v24 - v23) * state.LifeTime
				elseif state._staticSpeed then
					v20 = state._staticSpeed * speedMultiplier * (v24 - v23) * state.LifeTime
				else
					v20 = state.LifeTime * speedMultiplier * (Graph.IntegrateUpTo(
						v24,
						state.Graphs.Speed,
						state.Seeds.Speed
					) - Graph.IntegrateUpTo(v23, state.Graphs.Speed, state.Seeds.Speed))
				end

				if hasAccel then
					local v25 = (v24 - v23) * state.LifeTime
					local v26 = PartConstants.applyContactAccel(state.Acceleration, state, v25)
					v21 = _accelVel * v25 + v26 * (v25 * v25 * 0.5)
					_accelVel += v26 * v25
				end
			end

			state._accelVel = _accelVel
			local v22 = state.BaseDirection * v20 + v21
			local v23, v24 = _posOffsetFrameDelta(state, currentStep2 / state.TotalKeyFrames, v19)
			local v25 = _composeLocalDelta(attachmentLinkCF, v19, v22, v23, v24, v11) -- equivalent call inferred; original call site unknown
			state.LocalCF = CFrame.new(v25) * state.LocalCF
			local v26 = currentStep2 / state.TotalKeyFrames
			local v27 = (state._settleRotDamp or 1) * v12
			local v28 = (state._staticRotSpeedX or Graph.QueryPointsWithTime(
				v26,
				state.Graphs.RotSpeedX,
				state.Seeds.RotSpeedX
			)) * v27 + (state._spinAccumX or 0)
			local v29 = (state._staticRotSpeedY or Graph.QueryPointsWithTime(
				v26,
				state.Graphs.RotSpeedY,
				state.Seeds.RotSpeedY
			)) * v27 + (state._spinAccumY or 0)
			local v30 = (state._staticRotSpeedZ or Graph.QueryPointsWithTime(
				v26,
				state.Graphs.RotSpeedZ,
				state.Seeds.RotSpeedZ
			)) * v27 + (state._spinAccumZ or 0)
			local rotation = PartConstants.composeRotation(state.RotOrder or "Global", v28, v29, v30)
			state.VisualPart.CFrame = attachmentLinkCF * state.LocalCF * rotation
			state._localWorldCF = state.LocalCF * rotation
			state.CurrentStep = currentStep2
		end

		return v13
	end
end