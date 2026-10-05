local createVector = vector.create
local Graph = require(script.Parent.Graph)
local Range = require(script.Parent.Range)
local Pool = require(script.Parent.Pool)
local PartConstants = require(script.Parent.PartConstants)
local AxisLinks = require(script.Parent.AxisLinks)
local NestedEmit = require(script.Parent.NestedEmit)
local Particles = require(script.Parent.Particles)
local Turbulence = require(script.Parent.Turbulence)
local Events = require(script.Parent.Events)
local BoltGen = require(script.BoltGen)
local directionVectors = PartConstants.DirectionVectors
local cframe = CFrame.new(1000000000, 1000000000, 1000000000)
local Rig = require(script.Rig)
local buildRig = Rig.buildRig
local acquireBolt = Rig.acquireBolt
local layoutFor = Rig.layoutFor
local v = -1
local count = 0
local flag = false
local count2 = 0
return function(p)
	function p._isLightning(part)
		return part:IsA("BasePart") and part:GetAttribute("IsLightning") == true
	end

	local Endpoints = require(script.Endpoints)
	local sampleShape = Endpoints.sampleShape
	local resolveEndpoints = Endpoints.resolveEndpoints

	local function rebuildRevealMask(_rig, _tipDist, _growReversed)
		local maxReveal = _rig.maxReveal or 0
		local v2 = 0

		for i = 1, _rig.partCount do
			local v3 = _rig.revealOrder[i]
			local v4 = _rig.revealDist[v3]
			local v5

			if _growReversed then
				if v4 == 1e999 then
					v5 = false
				else
					local v6 = v4 + _rig.segLen[v3]
					v5 = maxReveal - _tipDist <= v6
				end
			else
				v5 = v4 <= _tipDist
			end

			if v5 then
				_rig.writeCFs[v3] = _rig.rollCFs[v3]
				v2 = i
			else
				_rig.writeCFs[v3] = cframe
			end
		end

		return v2
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function flushCFrames(state, p2)
		local _rig = state._rig
		local v2 = state._lSpeed ~= 0

		if v2 then
			state._revealPtr = rebuildRevealMask(_rig, state._tipDist or 0, state._growReversed)
		end

		local writeCFs = v2 and _rig.writeCFs or _rig.rollCFs

		if not p2 then
			workspace:BulkMoveTo(_rig.parts, writeCFs, Enum.BulkMoveMode.FireCFrameChanged)
			return
		end

		for i = 1, _rig.partCount do
			_rig.parts[i].CFrame = writeCFs[i]
		end
	end

	local function writeSizes(_rig, p2, p3)
		for i = 1, BoltGen.planSizes(_rig, p2, p3) do
			local v2 = _rig.sizeWriteIdx[i]
			local v3 = math.max(0.05, p2 * _rig.widthScale[v2])
			_rig.parts[v2].Size = Vector3.new(v3, v3, _rig.segLen[v2])
		end
	end

	local function applyRoll(state, p2)
		local _rig = state._rig
		local endpoints, v2, v3 = resolveEndpoints(state)
		state._totalLen = BoltGen.roll(_rig, state, v2, v3, cframe)

		if state._shapeMode ~= "Jitter" then
			BoltGen.applyScroll(_rig, state, state._scrollPhase or 0)
			BoltGen.applyScrollForks(_rig, state, state._scrollPhase or 0)
		end

		local diffLive = BoltGen.diffLive(_rig)
		local gradient = state.Graphs.Gradient

		if not p2 and diffLive > 0 then
			local _curTrans = state._curTrans
			local _curColor

			if not gradient then
				_curColor = state._curColor or nil
			end

			for i = 1, diffLive do
				local v4 = _rig.newlyLiveIdx[i]
				local part = _rig.parts[v4]

				if _curTrans then
					part.Transparency = _curTrans
				end

				if _curColor then
					part.Color = _curColor
				end

				local decal = _rig.decals[v4]

				if not decal then
					continue
				end

				if _curTrans then
					decal.Transparency = _curTrans
				end

				if _curColor then
					decal.Color3 = _curColor
				end
			end
		end

		if gradient and not state.SkipColor then
			local v4 = 1 / math.max(_rig.maxReveal or 0, 0.0001)
			local _curTint = state._curTint

			for i = 1, _rig.partCount do
				if not _rig.prevLive[i] then
					continue
				end

				local v5 = math.clamp((_rig.revealDist[i] + _rig.segLen[i] * 0.5) * v4, 0, 1)
				local color = Graph.QueryColorPointWithTime(v5, gradient)
				_rig.gradColor[i] = color

				if p2 then
					continue
				end

				if _curTint then
					color = Color3.new(
						math.min(color.R * _curTint.R, 1),
						math.min(color.G * _curTint.G, 1),
						(math.min(color.B * _curTint.B, 1))
					) or color
				end

				_rig.parts[i].Color = color
				local decal = _rig.decals[i]

				if decal then
					decal.Color3 = color
				end
			end
		end

		writeSizes(_rig, state._curThick or 0.15, p2)
		pcall(function()
			state.VisualPart.WorldPivot = CFrame.new(v2) * endpoints.Rotation
		end)
		flushCFrames(state, p2)
	end

	local function writeVisuals(state, p2)
		local graphs = state.Graphs
		local seeds = state.Seeds
		local _curTrans = not graphs.Transparency and 0 or Graph.QueryPointsWithTime(
			p2,
			graphs.Transparency,
			seeds.Transparency
		) or 0

		if state.SkipTransparency then
			_curTrans = state._curTrans or _curTrans
		end

		local v2 = not graphs.Brightness and 1 or Graph.QueryPointsWithTime(p2, graphs.Brightness, seeds.Brightness) or 1
		local color

		if graphs.Color and not state.SkipColor then
			local colorPointWithTime = Graph.QueryColorPointWithTime(p2, graphs.Color)
			color = Color3.new(
				math.min(colorPointWithTime.R * v2, 1),
				math.min(colorPointWithTime.G * v2, 1),
				(math.min(colorPointWithTime.B * v2, 1))
			)
		end

		local curThick = graphs.Thickness and Graph.QueryPointsWithTime(p2, graphs.Thickness, seeds.Thickness)
		local _rig = state._rig
		local v4 = curThick and curThick ~= state._curThick

		if curThick then
			state._curThick = curThick
		end

		state._curTrans = _curTrans

		if color then
			state._curColor = color
			state._curTint = color
		end

		local gradient = graphs.Gradient

		for i = 1, _rig.partCount do
			if not _rig.prevLive[i] then
				continue
			end

			local part = _rig.parts[i]
			part.Transparency = _curTrans
			local decal = _rig.decals[i]

			if decal then
				decal.Transparency = _curTrans
			end

			if not color then
				continue
			end

			local color2

			if gradient then
				local v5 = _rig.gradColor[i]

				if v5 then
					color2 = Color3.new(
						math.min(v5.R * color.R, 1),
						math.min(v5.G * color.G, 1),
						(math.min(v5.B * color.B, 1))
					)
				else
					color2 = color
				end
			else
				color2 = color
			end

			part.Color = color2

			if decal then
				decal.Color3 = color2
			end
		end

		if v4 then
			writeSizes(_rig, curThick, false)
		end
	end

	local PDataBuilder = require(script.PDataBuilder)
	local build = PDataBuilder.build

	local function buildSeekParams(object, p2)
		if p2._endpointMode ~= "Seek" then
			return
		end

		local hitParams = Events.makeHitParams(p2)
		hitParams.RespectCanCollide = true
		pcall(function()
			hitParams:AddToFilter(object:GetFolder())
			hitParams:AddToFilter(object:GetPoolFolder())
		end)

		function p2._seekRayFn(p3, p4)
			return workspace:Raycast(p3, p4, hitParams)
		end
	end

	local function fireSeekHit(p2, state)
		if not (state._seekNewHit and Endpoints.glideArrived(state)) then
			return
		end

		state._seekNewHit = nil

		if not (state.Events and state.Events.OnHit and state._seekHit) then
			return
		end

		local _seekHit = state._seekHit
		local payload = Events.makePayload(p2, state, "OnHit", nil)
		payload.HitInstance = _seekHit.Instance
		payload.Other = _seekHit.Instance
		payload.HitPosition = _seekHit.Position
		payload.HitNormal = _seekHit.Normal
		Events.fire(p2, state, "OnHit", state.EventChainCtx, payload)
	end

	function p.EmitLightning(object, instance, parentLink, data)
		if not (instance and instance.Parent) then
			return
		end

		local data2 = object:GetData(instance)

		if not (data2 and data2.RenderTemplate) then
			return
		end

		local randomValueFromRange = Range.RandomValueFromRange(data2.Lifetime)
		local v2 = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local v3, v4 = acquireBolt(data2)
		local v5 = build(instance, data2, v3, v4, v2, data)
		v5._parentLink = parentLink

		if data then
			local v6

			if data.EventOriginResolver then
				v6 = data.EventOriginResolver()
			end

			local v7 = v6 or data.EventOriginCF

			if v7 then
				v5._startCFOverride = data.UseFullOrigin and v7 or CFrame.new(v7.Position) * instance.CFrame.Rotation
			end
		end

		p._seedTsOverride(v5, instance)

		if data2.Pool ~= false then
			v5._sourceRT = data2.RenderTemplate
			v5._poolKind = "Lightning"
		end

		v5._curThick = not data2.Thickness and 0.15 or Graph.QueryPointsWithTime(0, data2.Thickness, v5.Seeds.Thickness) or 0.15
		buildSeekParams(object, v5)
		count += 1
		applyRoll(v5, true)
		writeVisuals(v5, 0)
		v3.Parent = data2.EmitParent or object:GetFolder()
		Pool.restoreTrails(v3, "Lightning")
		Particles.EnableEmit(v3, object:_makeAliveCheck())
		object:_registerEmit(v5, data)
		NestedEmit.walk(object, data2.RenderTemplate, v3, v5._nestedAlive, data)
		fireSeekHit(object, v5)
	end

	function p.EmitLightningAnimate(object, animateItem, parentLink, p2)
		if not (animateItem and animateItem.Parent) or object.ActiveAnimates[animateItem] then
			return
		end

		local data = object:GetData(animateItem)

		if not (data and data.RenderTemplate) then
			return
		end

		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local v2 = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local rig, v3 = buildRig(data)
		rig:SetAttribute("_PartIcleEmit", true)
		local v4 = build(animateItem, data, rig, v3, v2, p2)
		v4._parentLink = parentLink
		v4.IsAnimate = true
		v4.AnimateItem = animateItem
		p._seedTsOverride(v4, animateItem)
		v4._curThick = not data.Thickness and 0.15 or Graph.QueryPointsWithTime(0, data.Thickness, v4.Seeds.Thickness) or 0.15
		buildSeekParams(object, v4)
		count += 1
		applyRoll(v4, true)
		writeVisuals(v4, 0)
		rig.Parent = data.EmitParent or object:GetFolder()
		Particles.EnableEmit(rig, object:_makeAliveCheck())
		object.ActiveAnimates[animateItem] = v4
		object:_registerEmit(v4, p2)
		NestedEmit.walk(object, data.RenderTemplate, rig, v4._nestedAlive, p2)
		fireSeekHit(object, v4)
	end

	function p.UpdateLightning(p2, state, p3, rollPendingStamp)
		local v2 = math.min(math.max((rollPendingStamp - state.StartTime) / state.LifeTime, 0), 1)
		local v3

		if state._tsOverride == nil or not (rollPendingStamp < (state._tsOverrideUntil or 0)) then
			v3 = not state.Graphs.Timescale and 1 or Graph.QueryPointsWithTime(
				v2,
				state.Graphs.Timescale,
				state.Seeds.Timescale
			) or 1
		else
			v3 = state._tsOverride
		end

		local v4 = p3 * v3
		local lifeTime = state.LifeTime
		local _effectiveElapsed = state._effectiveElapsed or 0
		local v5 = _effectiveElapsed + (state._timeFrozen and 0 or v4)
		local effectiveElapsed = v5 < 0 and 0 or v5

		if lifeTime < effectiveElapsed then
			effectiveElapsed = lifeTime
		end

		state._effectiveElapsed = effectiveElapsed
		local visualPart = state.VisualPart

		if not (visualPart and visualPart.Parent) or state.TotalKeyFrames <= 0 then
			return true
		end

		local v7

		if v2 >= 1 then
			v7 = lifeTime <= effectiveElapsed or effectiveElapsed <= 0
		else
			v7 = false
		end

		local _rig = state._rig

		if rollPendingStamp ~= v then
			v = rollPendingStamp
			count = 0

			if p3 > 0.025 then
				flag = true
				count2 = 0
			elseif flag then
				if p3 < 0.01818181818181818 then
					count2 += 1

					if count2 >= 2 then
						flag = false
					end
				else
					count2 = 0
				end
			end
		end

		if not v7 then
			local v8 = effectiveElapsed - _effectiveElapsed

			if state._hasMotion and v8 ~= 0 then
				local v9 = math.min(math.max(effectiveElapsed / lifeTime, 0), 1)
				local v10 = not state.Graphs.Speed and 0 or Graph.QueryPointsWithTime(
					v9,
					state.Graphs.Speed,
					state.Seeds.Speed
				) or 0

				if state._drag ~= 0 then
					v10 *= math.exp(-state._drag * effectiveElapsed)
				end

				state._motionAccelVel += state._accel * v8
				state._motionOffset = state._motionOffset + (state._lastDirWorld or createVector(0, 0, 0)) * (v10 * v8) + state._motionAccelVel * v8
			end

			if state._hasDisp then
				local v9 = math.min(math.max(effectiveElapsed / lifeTime, 0), 1)
				state._dispRaw = Vector3.new(
					not state.Graphs.PosOffsetX and 0 or Graph.QueryPointsWithTime(
						v9,
						state.Graphs.PosOffsetX,
						state.Seeds.PosOffsetX
					) or 0,
					not state.Graphs.PosOffsetY and 0 or Graph.QueryPointsWithTime(
						v9,
						state.Graphs.PosOffsetY,
						state.Seeds.PosOffsetY
					) or 0,
					not state.Graphs.PosOffsetZ and 0 or Graph.QueryPointsWithTime(
						v9,
						state.Graphs.PosOffsetZ,
						state.Seeds.PosOffsetZ
					) or 0
				)
			end

			if state._hasTurb then
				local v9 = math.min(math.max(effectiveElapsed / lifeTime, 0), 1)
				state._turbRaw = Turbulence.sampleRaw(
					state.Graphs.Turbulence,
					state.Seeds.Turbulence,
					state._turbSeed,
					state._turbFreq,
					lifeTime,
					v9
				)
			end

			if state._rollPending and state._rollPendingStamp ~= rollPendingStamp then
				state._rollPending = nil
				state._rollPendingStamp = nil
				state._jitterAccum = 0
				count += 1
				applyRoll(state, false)
				fireSeekHit(p2, state)
			end

			if Endpoints.glideStep(state, (math.abs(v8))) and state._jitterInterval == 1e999 then
				if flag and count >= 8 then
					state._rollPending = true
					state._rollPendingStamp = rollPendingStamp
				else
					count += 1
					applyRoll(state, false)
					fireSeekHit(p2, state)
				end
			end

			state._jitterAccum += math.abs(v4)

			if state._jitterAccum >= state._jitterInterval and not state._rollPending then
				if flag and count >= 8 then
					state._rollPending = true
					state._rollPendingStamp = rollPendingStamp
				else
					state._jitterAccum = 0
					count += 1
					applyRoll(state, false)
					fireSeekHit(p2, state)
				end
			end

			if state._lSpeed ~= 0 then
				local tipDist = math.abs(state._lSpeed) * effectiveElapsed

				if tipDist ~= state._tipDist then
					state._tipDist = tipDist

					if state._growReversed then
						if state._shapeMode == "Jitter" then
							flushCFrames(state, false) -- equivalent call inferred; original call site unknown
						end
					elseif state._shapeMode == "Jitter" then
						local revealOrder = _rig.revealOrder
						local revealDist = _rig.revealDist
						local writeCFs = _rig.writeCFs
						local rollCFs = _rig.rollCFs
						local _revealPtr = state._revealPtr
						local flag2 = false

						while _revealPtr < _rig.partCount and revealDist[revealOrder[_revealPtr + 1]] <= tipDist do
							_revealPtr += 1
							local v10 = revealOrder[_revealPtr]
							writeCFs[v10] = rollCFs[v10]
							flag2 = true
						end

						while _revealPtr > 0 and tipDist < revealDist[revealOrder[_revealPtr]] do
							writeCFs[revealOrder[_revealPtr]] = cframe
							_revealPtr -= 1
							flag2 = true
						end

						state._revealPtr = _revealPtr

						if flag2 then
							workspace:BulkMoveTo(_rig.parts, _rig.writeCFs, Enum.BulkMoveMode.FireCFrameChanged)
						end
					end
				end
			end

			if state._shapeMode ~= "Jitter" then
				state._scrollPhase += state._scrollSpeed * (state._timeFrozen and 0 or v4)
				BoltGen.applyScroll(_rig, state, state._scrollPhase)
				BoltGen.applyScrollForks(_rig, state, state._scrollPhase)
				writeSizes(_rig, state._curThick or 0.15, false)
				flushCFrames(state, false) -- equivalent call inferred; original call site unknown
			end
		end

		local currentStep = math.floor(math.min(math.max(effectiveElapsed / lifeTime, 0), 1) * state.TotalKeyFrames)

		if currentStep ~= state.CurrentStep then
			state.CurrentStep = currentStep
			writeVisuals(state, currentStep / state.TotalKeyFrames)
		end

		return v7
	end

	function p._refreshLightningAnimate(object, state, data)
		state.Link = nil
		state._endpointMode = data.TargetMode == "Seek" and "Seek" or data.TargetMode == "Point" and data.Target and data.Target.Parent and "Point" or "Directional"
		state._target = data.Target
		state._seekRadius = math.max(Range.RandomValueFromRange(data.SeekRadius), 1)
		state._seekRetarget = data.SeekRetarget == true
		state._seekBias = math.clamp(data.SeekBias or 0, 0, 1)
		state._retargetSpeed = math.max(data.RetargetSpeed or 0, 0)
		state._seekHit = nil
		state._seekFallbackDir = nil
		state._seekNewHit = nil
		state._seekCurrentPos = nil
		state._seekGoalPos = nil
		buildSeekParams(object, state)
		state._length = math.max(0.1, Range.RandomValueFromRange(data.Length))
		state._amplitude = Range.RandomValueFromRange(data.Amplitude)
		state._decay = Range.RandomValueFromRange(data.AmplitudeDecay)
		state._forkChance = Range.RandomValueFromRange(data.ForkChance)
		state._forkDepth = math.floor(Range.RandomValueFromRange(data.ForkDepth) + 0.5)
		state._forkLenScale = Range.RandomValueFromRange(data.ForkLengthScale)
		state._sag = Range.RandomValueFromRange(data.Sag)
		state._sagShape = Range.RandomValueFromRange(data.SagShape)
		state._shapeMode = data.ShapeMode or "Jitter"
		state._scrollSpeed = Range.RandomValueFromRange(data.ScrollSpeed)
		state._waves = math.max(0.25, Range.RandomValueFromRange(data.Waves))
		state._scrollPhase = 0
		state._noiseSeedA = math.random() * 1000
		state._noiseSeedB = 500 + math.random() * 1000
		local randomValueFromRange = Range.RandomValueFromRange(data.JitterRate)
		state._jitterInterval = randomValueFromRange > 0 and 1 / randomValueFromRange or 1e999
		state._jitterAccum = 0
		state._lSpeed = data.GrowthSpeed or 0
		state._growReversed = (data.GrowthSpeed or 0) < 0
		state._tipDist = 0
		state._revealPtr = 0
		local v2 = directionVectors[data.EmissionDirection] or directionVectors[Enum.NormalId.Top]
		local v3 = CFrame.new()[v2.vector] * v2.multiplier
		local spreadAngle = data.SpreadAngle or Vector2.new(0, 0)
		local rangeAxes = AxisLinks.sampleRangeAxes(data, data.AxisLinks, { "RotX", "RotY", "RotZ" }, Range, nil)
		local rotation = PartConstants.composeRotation(
			data.RotOrder or "Global",
			rangeAxes.RotX or 0,
			rangeAxes.RotY or 0,
			rangeAxes.RotZ or 0
		)
		local cframe2 = CFrame.lookAt(createVector(0, 0, 0), v3)

		if data.DirMode == "Local" then
			cframe2 *= rotation
		end

		if spreadAngle.X > 0 or spreadAngle.Y > 0 then
			cframe2 *= CFrame.Angles(
				math.rad((math.random() * 2 - 1) * spreadAngle.X),
				math.rad((math.random() * 2 - 1) * spreadAngle.Y),
				0
			)
		end

		state._dirLocalVec = cframe2.LookVector
		state._dirGlobal = data.DirMode == "Global"
		state._originRot = rotation
		local rangeAxes2 = AxisLinks.sampleRangeAxes(data, data.AxisLinks, { "PosX", "PosY", "PosZ" }, Range, nil)
		local posX = rangeAxes2.PosX or 0
		local posY = rangeAxes2.PosY or 0
		local posZ = rangeAxes2.PosZ or 0

		if posX == 0 and posY == 0 and posZ == 0 then
			state._originOffset = nil
		else
			state._originOffset = Vector3.new(posX, posY, posZ)
			state._originOffsetGlobal = data.PosMode == "Global"
		end

		state._accel = data.Acceleration or createVector(0, 0, 0)
		state._drag = data.Drag or 0
		state._dispMode = data.DisplacementMode or "Global"
		state._motionOffset = createVector(0, 0, 0)
		state._motionAccelVel = createVector(0, 0, 0)
		state._dispRaw = nil
		state._hasMotion = PDataBuilder.liveGraph(data.Speed) ~= nil or state._accel.Magnitude > 0
		state._hasDisp = PDataBuilder.liveGraph(data.PosOffsetX) ~= nil or PDataBuilder.liveGraph(data.PosOffsetY) ~= nil or PDataBuilder.liveGraph(data.PosOffsetZ) ~= nil
		state.Graphs.Gradient = PDataBuilder.liveColor(data.Gradient)
		state.Graphs.Turbulence = Turbulence.isLive(data.Turbulence)
		state._hasTurb = state.Graphs.Turbulence ~= nil
		state._turbFreq = data.TurbulenceFrequency or 1
		state._turbSeed = math.random() * 997 + 0.5
		state._turbRaw = nil
		sampleShape(state, data, state.AnimateItem)

		if layoutFor(data) ~= state._rig.partCount and data.RenderTemplate then
			local visualPart = state.VisualPart
			local parent = visualPart and visualPart.Parent
			local rig, rig2 = buildRig(data)
			rig:SetAttribute("_PartIcleEmit", true)
			state.VisualPart = rig
			state._rig = rig2
			rig.Parent = parent or object:GetFolder()

			if visualPart then
				pcall(function()
					visualPart:Destroy()
				end)
			end
		end

		state._segCount = math.clamp(
			math.floor(Range.RandomValueFromRange(data.SegmentCount) + 0.5),
			2,
			state._rig.mainSegs
		)
		state._curThick = data.Thickness and Graph.QueryPointsWithTime(0, data.Thickness, state.Seeds.Thickness) or state._curThick
		state._rollPending = nil
		state._rollPendingStamp = nil
		count += 1
		applyRoll(state, false)
		writeVisuals(state, 0)
		fireSeekHit(object, state)
	end
end