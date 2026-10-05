local createVector = vector.create
local Graph = require(script.Parent.Graph)
local PartConstants = require(script.Parent.PartConstants)
local EventsCollision = require(script.Parent.EventsCollision)
local Turbulence = require(script.Parent.Turbulence)
local directionVectors = PartConstants.DirectionVectors

local function _posOffsetFrameDelta(state, p)
	if not (state.HasPosOffsetGraphs or state.HasTurbulence) then
		return createVector(0, 0, 0)
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
		return v + Turbulence.frameDelta(state, p)
	end

	return v
end

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

return function(p)
	function p.UpdateModel(_, state, p2, p3)
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

		local v11 = v10 and (v7 or v8)
		local v12 = math.min(math.max(v9, 0), 1)
		state.AccumulatedDT += lastEffectiveDt
		local currentStep2 = math.floor(v12 * state.TotalKeyFrames)

		if currentStep2 == state.CurrentStep then
			return v11
		end

		local currentStep = state.CurrentStep
		local v14 = currentStep < currentStep2 and 1 or -1
		local v15 = math.abs(currentStep2 - currentStep)
		local accumulatedDT = state.AccumulatedDT
		local v16 = accumulatedDT / v15
		state.AccumulatedDT = 0
		local _spinRate = state._spinRate

		if _spinRate and (_spinRate.X ~= 0 or _spinRate.Y ~= 0 or _spinRate.Z ~= 0) then
			state._spinAccumX = (state._spinAccumX or 0) + _spinRate.X * accumulatedDT
			state._spinAccumY = (state._spinAccumY or 0) + _spinRate.Y * accumulatedDT
			state._spinAccumZ = (state._spinAccumZ or 0) + _spinRate.Z * accumulatedDT
		end

		local speedMultiplier = state.SpeedMultiplier or 1
		local _spinAccumX = state._spinAccumX or 0
		local _spinAccumY = state._spinAccumY or 0
		local _spinAccumZ = state._spinAccumZ or 0
		local rotOrder = state.RotOrder or "Global"

		if state.InvertMotion then
			state.CurrentStep = currentStep2
			local v17 = state.TotalKeyFrames - currentStep2
			local localWorldCF = state.SimLocalCFrames[v17] or state.SimLocalCFrames[0]
			local linkCF = getLinkCF(state)
			state.VisualPart:PivotTo(linkCF * localWorldCF)
			state._localWorldCF = localWorldCF
			state.CurrentPosition = state.VisualPart:GetPivot().Position
		elseif state.NeedsFullIteration then
			local hasDrag = state.HasDrag
			local hasAccel = state.HasAccel
			local _accelVel = state._accelVel or createVector(0, 0, 0)

			for i = currentStep + v14, currentStep2, v14 do
				local v17 = i / state.TotalKeyFrames
				local v18 = v17 * state.LifeTime
				local _speedOverride = state._speedOverride or (state._staticSpeed or Graph.QueryPointsWithTime(
					v17,
					state.Graphs.Speed,
					state.Seeds.Speed
				)) * speedMultiplier

				if hasDrag then
					_speedOverride = _speedOverride * math.exp(-state.Drag * v18) or _speedOverride
				end

				local v19

				if hasAccel then
					_accelVel += PartConstants.applyContactAccel(state.Acceleration, state, v16) * v16
					v19 = (state.BaseDirection * _speedOverride + _accelVel) * v16
				else
					v19 = state.BaseDirection * (_speedOverride * v16)
				end

				local v20 = v19 + _posOffsetFrameDelta(state, v17)
				local linkCF, v21 = getLinkCF(state)

				if v21 then
					v20 = linkCF:VectorToObjectSpace(v20) or v20
				end

				state.LocalCF = CFrame.new(v20) * state.LocalCF
				local _settleRotDamp = state._settleRotDamp or 1
				local v22 = (state._staticRotSpeedX or Graph.QueryPointsWithTime(
					v17,
					state.Graphs.RotSpeedX,
					state.Seeds.RotSpeedX
				)) * _settleRotDamp
				local v23 = (state._staticRotSpeedY or Graph.QueryPointsWithTime(
					v17,
					state.Graphs.RotSpeedY,
					state.Seeds.RotSpeedY
				)) * _settleRotDamp
				local v24 = (state._staticRotSpeedZ or Graph.QueryPointsWithTime(
					v17,
					state.Graphs.RotSpeedZ,
					state.Seeds.RotSpeedZ
				)) * _settleRotDamp
				local v25

				if state.RotMode == "Speed" then
					state.AccRotX += v22 * v16
					state.AccRotY += v23 * v16
					state.AccRotZ += v24 * v16
					v25 = PartConstants.composeRotation(
						rotOrder,
						state.AccRotX + _spinAccumX,
						state.AccRotY + _spinAccumY,
						state.AccRotZ + _spinAccumZ
					)
				else
					v25 = PartConstants.composeRotation(
						rotOrder,
						v22 + _spinAccumX,
						v23 + _spinAccumY,
						v24 + _spinAccumZ
					)
				end

				state.VisualPart:PivotTo(linkCF * state.LocalCF * v25)
				state._localWorldCF = state.LocalCF * v25
				state.CurrentPosition = state.VisualPart:GetPivot().Position
				local v26 = state.VisualPart:GetPivot() * state.SpreadRotation
				local v27 = directionVectors[state.EmissionDirection] or directionVectors[Enum.NormalId.Top]
				state.BaseDirection = v26[v27.vector] * v27.multiplier
			end

			state._accelVel = _accelVel
			state.CurrentStep = currentStep2
		elseif state.NeedsRotAccum then
			local hasDrag = state.HasDrag
			local hasAccel = state.HasAccel
			local _accelVel = state._accelVel or createVector(0, 0, 0)
			local total = 0
			local v17 = createVector(0, 0, 0)

			for i = currentStep + v14, currentStep2, v14 do
				local v18 = i / state.TotalKeyFrames
				local v19 = v18 * state.LifeTime
				local _speedOverride = state._speedOverride or (state._staticSpeed or Graph.QueryPointsWithTime(
					v18,
					state.Graphs.Speed,
					state.Seeds.Speed
				)) * speedMultiplier

				if hasDrag then
					_speedOverride *= math.exp(-state.Drag * v19)
				end

				total += _speedOverride * v16

				if hasAccel then
					_accelVel += PartConstants.applyContactAccel(state.Acceleration, state, v16) * v16
					v17 += _accelVel * v16
				end

				local _settleRotDamp = state._settleRotDamp or 1
				local v20 = (state._staticRotSpeedX or Graph.QueryPointsWithTime(
					v18,
					state.Graphs.RotSpeedX,
					state.Seeds.RotSpeedX
				)) * _settleRotDamp
				local v21 = (state._staticRotSpeedY or Graph.QueryPointsWithTime(
					v18,
					state.Graphs.RotSpeedY,
					state.Seeds.RotSpeedY
				)) * _settleRotDamp
				local v22 = (state._staticRotSpeedZ or Graph.QueryPointsWithTime(
					v18,
					state.Graphs.RotSpeedZ,
					state.Seeds.RotSpeedZ
				)) * _settleRotDamp
				state.AccRotX += v20 * v16
				state.AccRotY += v21 * v16
				state.AccRotZ += v22 * v16
			end

			state._accelVel = _accelVel
			local v18 = state.BaseDirection * total + v17 + _posOffsetFrameDelta(
				state,
				currentStep2 / state.TotalKeyFrames
			)
			local linkCF, v19 = getLinkCF(state)

			if v19 then
				v18 = linkCF:VectorToObjectSpace(v18) or v18
			end

			state.LocalCF = CFrame.new(v18) * state.LocalCF
			local rotation = PartConstants.composeRotation(
				rotOrder,
				state.AccRotX + _spinAccumX,
				state.AccRotY + _spinAccumY,
				state.AccRotZ + _spinAccumZ
			)
			state.VisualPart:PivotTo(linkCF * state.LocalCF * rotation)
			state._localWorldCF = state.LocalCF * rotation
			state.CurrentPosition = state.VisualPart:GetPivot().Position
			state.CurrentStep = currentStep2
		else
			local hasDrag = state.HasDrag
			local hasAccel = state.HasAccel
			local _accelVel = state._accelVel or createVector(0, 0, 0)
			local total = 0
			local v17 = createVector(0, 0, 0)

			for i = currentStep + v14, currentStep2, v14 do
				local v18 = i / state.TotalKeyFrames
				local v19 = v18 * state.LifeTime
				local _speedOverride = state._speedOverride or (state._staticSpeed or Graph.QueryPointsWithTime(
					v18,
					state.Graphs.Speed,
					state.Seeds.Speed
				)) * speedMultiplier

				if hasDrag then
					_speedOverride *= math.exp(-state.Drag * v19)
				end

				total += _speedOverride * v16

				if not hasAccel then
					continue
				end

				_accelVel += PartConstants.applyContactAccel(state.Acceleration, state, v16) * v16
				v17 += _accelVel * v16
			end

			state._accelVel = _accelVel
			local v18 = state.BaseDirection * total + v17 + _posOffsetFrameDelta(
				state,
				currentStep2 / state.TotalKeyFrames
			)
			local linkCF, v19 = getLinkCF(state)

			if v19 then
				v18 = linkCF:VectorToObjectSpace(v18) or v18
			end

			state.LocalCF = CFrame.new(v18) * state.LocalCF
			local v20 = currentStep2 / state.TotalKeyFrames
			local _settleRotDamp = state._settleRotDamp or 1
			local v21 = (state._staticRotSpeedX or Graph.QueryPointsWithTime(
				v20,
				state.Graphs.RotSpeedX,
				state.Seeds.RotSpeedX
			)) * _settleRotDamp
			local v22 = (state._staticRotSpeedY or Graph.QueryPointsWithTime(
				v20,
				state.Graphs.RotSpeedY,
				state.Seeds.RotSpeedY
			)) * _settleRotDamp
			local v23 = (state._staticRotSpeedZ or Graph.QueryPointsWithTime(
				v20,
				state.Graphs.RotSpeedZ,
				state.Seeds.RotSpeedZ
			)) * _settleRotDamp
			local rotation = PartConstants.composeRotation(
				rotOrder,
				v21 + _spinAccumX,
				v22 + _spinAccumY,
				v23 + _spinAccumZ
			)
			state.VisualPart:PivotTo(linkCF * state.LocalCF * rotation)
			state._localWorldCF = state.LocalCF * rotation
			state.CurrentPosition = state.VisualPart:GetPivot().Position
			state.CurrentStep = currentStep2
		end

		local v17 = currentStep2 / state.TotalKeyFrames
		local v18 = math.max(
			0.001,
			state._staticScale or Graph.QueryPointsWithTime(v17, state.Graphs.Scale, state.Seeds.Scale)
		) * PartConstants.getParentScaleFactor(state.ParentScale, p3, Graph)
		state.VisualPart:ScaleTo(v18)

		if state._visualBeams then
			for _, _visualBeam in ipairs(state._visualBeams) do
				if _visualBeam.Parent and _visualBeam.Segments < 20 then
					_visualBeam.Segments = 20
				end
			end
		end

		return v11
	end
end