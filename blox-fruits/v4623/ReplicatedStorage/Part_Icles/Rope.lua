local createVector = vector.create
local Graph = require(script.Parent.Graph)
local Range = require(script.Parent.Range)
local Pool = require(script.Parent.Pool)
local NestedEmit = require(script.Parent.NestedEmit)
local Particles = require(script.Parent.Particles)
local Turbulence = require(script.Parent.Turbulence)
local PartConstants = require(script.Parent.PartConstants)
local VerletSim = require(script.VerletSim)
local Anchors = require(script.Anchors)
local PDataBuilder = require(script.PDataBuilder)
local cframe = CFrame.new(1000000000, 1000000000, 1000000000)
local object = setmetatable({}, {
	__mode = "k"
})
return function(p)
	function p._isRope(part)
		return part:IsA("BasePart") and part:GetAttribute("IsRope") == true
	end

	local function buildSegment(p2)
		local copyBare = Pool.copyBare(p2)
		copyBare.Anchored = true
		copyBare.CanCollide = false
		copyBare.CanQuery = false
		copyBare.CanTouch = false
		copyBare.Massless = true
		copyBare.Locked = true
		copyBare.Archivable = false
		return copyBare, copyBare:FindFirstChildWhichIsA("Decal") or copyBare:FindFirstChildWhichIsA("Texture")
	end

	local function segCapFor(p2)
		return (math.clamp(math.floor((p2.SegmentCount and p2.SegmentCount.Max or 12) + 0.5), 2, 48))
	end

	local function buildRig(data)
		local v = math.clamp(math.floor((not data.SegmentCount and 12 or data.SegmentCount.Max or 12) + 0.5), 2, 48)
		local model = Instance.new("Model")
		model.Name = "Rope"
		model.Archivable = false
		model:SetAttribute("_lightningBolt", true)
		local v2 = {
			segCap = v,
			partCount = v,
			parts = table.create(v),
			decals = table.create(v),
			segLen = table.create(v),
			widthScale = table.create(v),
			writeCFs = table.create(v),
			posBuf = table.create(v + 1),
			prevPosBuf = table.create(v + 1)
		}

		for i = 1, v do
			local renderTemplate = data.RenderTemplate
			local copyBare = Pool.copyBare(renderTemplate)
			copyBare.Anchored = true
			copyBare.CanCollide = false
			copyBare.CanQuery = false
			copyBare.CanTouch = false
			copyBare.Massless = true
			copyBare.Locked = true
			copyBare.Archivable = false
			local decal = copyBare:FindFirstChildWhichIsA("Decal") or copyBare:FindFirstChildWhichIsA("Texture")
			copyBare.Name = "Seg" .. i
			copyBare.CFrame = cframe
			copyBare.Parent = model
			v2.parts[i] = copyBare
			v2.decals[i] = decal
			v2.segLen[i] = 0.05
			v2.widthScale[i] = 1
			v2.writeCFs[i] = cframe
		end

		object[model] = v2
		return model, v2
	end

	local function acquireRope(data)
		local v = math.clamp(math.floor((not data.SegmentCount and 12 or data.SegmentCount.Max or 12) + 0.5), 2, 48)
		local v2 = data.Pool == true and Pool.acquire(data.RenderTemplate, "Rope")

		if v2 then
			local v3 = object[v2]

			if v3 and v3.segCap == v and v3.parts[1] and v3.parts[1].Parent == v2 then
				v2:SetAttribute("_PartIcleEmit", true)
				return v2, v3
			else
				pcall(function()
					v2:Destroy()
				end)
			end
		end

		local rig, v3 = buildRig(data)
		rig:SetAttribute("_PartIcleEmit", true)
		return rig, v3
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

		local v = not graphs.Brightness and 1 or Graph.QueryPointsWithTime(p2, graphs.Brightness, seeds.Brightness) or 1
		local color

		if graphs.Color and not state.SkipColor then
			local colorPointWithTime = Graph.QueryColorPointWithTime(p2, graphs.Color)
			color = Color3.new(
				math.min(colorPointWithTime.R * v, 1),
				math.min(colorPointWithTime.G * v, 1),
				(math.min(colorPointWithTime.B * v, 1))
			)
		end

		local curThick = graphs.Thickness and Graph.QueryPointsWithTime(p2, graphs.Thickness, seeds.Thickness)
		local _rig = state._rig
		local v3 = curThick and curThick ~= state._curThick

		if curThick then
			state._curThick = curThick
		end

		state._curTrans = _curTrans

		for i = 1, _rig.segCap do
			local part = _rig.parts[i]
			part.Transparency = _curTrans

			if color then
				part.Color = color
			end

			local decal = _rig.decals[i]

			if decal then
				decal.Transparency = _curTrans

				if color then
					decal.Color3 = color
				end
			end

			if not v3 then
				continue
			end

			local v4 = math.max(0.05, curThick * _rig.widthScale[i])
			part.Size = Vector3.new(v4, v4, _rig.segLen[i])
		end
	end

	local function writeSegments(data, p2)
		local _rig = data._rig
		local posBuf = _rig.posBuf
		local _segCount = data._segCount
		local _curThick = data._curThick or 0.15

		for i = 1, _segCount do
			local v = posBuf[i]
			local v2 = posBuf[i + 1]
			local magnitude = (v2 - v).Magnitude
			local v3 = (v + v2) * 0.5

			if magnitude > 0.0001 then
				_rig.writeCFs[i] = CFrame.lookAt(v3, v2)
			else
				_rig.writeCFs[i] = CFrame.new(v3)
			end

			if not (math.abs(magnitude - _rig.segLen[i]) > 0.01) then
				continue
			end

			_rig.segLen[i] = math.max(magnitude, 0.05)
			local v4 = math.max(0.05, _curThick * _rig.widthScale[i])
			_rig.parts[i].Size = Vector3.new(v4, v4, _rig.segLen[i])
		end

		for i = _segCount + 1, _rig.segCap do
			_rig.writeCFs[i] = cframe
		end

		if not p2 then
			workspace:BulkMoveTo(_rig.parts, _rig.writeCFs, Enum.BulkMoveMode.FireCFrameChanged)
			return
		end

		for i = 1, _rig.segCap do
			_rig.parts[i].CFrame = _rig.writeCFs[i]
		end
	end

	function p.EmitRope(object2, p2, p3, p4)
		if not (p2 and p2.Parent) then
			return
		end

		local data = object2:GetData(p2)

		if not (data and data.RenderTemplate) then
			return
		end

		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local v = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local v2, v3 = acquireRope(data)
		local v4 = PDataBuilder.build(p2, data, v2, v3, v, p4, p3)
		p._seedTsOverride(v4, p2)

		if data.Pool == true then
			v4._sourceRT = data.RenderTemplate
			v4._poolKind = "Rope"
		end

		Anchors.seedPose(v4)
		v4._curThick = not data.Thickness and 0.15 or Graph.QueryPointsWithTime(0, data.Thickness, v4.Seeds.Thickness) or 0.15
		writeSegments(v4, true)
		writeVisuals(v4, 0)
		v2.Parent = data.EmitParent or object2:GetFolder()
		Pool.restoreTrails(v2, "Rope")
		Particles.EnableEmit(v2, object2:_makeAliveCheck())
		v4._nestedAlive = { true }
		object2:_registerEmit(v4, p4)
		NestedEmit.walk(object2, data.RenderTemplate, v2, v4._nestedAlive, p4)
	end

	function p.EmitRopeAnimate(object2, animateItem, p2, p3)
		if not (animateItem and animateItem.Parent) or object2.ActiveAnimates[animateItem] then
			return
		end

		local data = object2:GetData(animateItem)

		if not (data and data.RenderTemplate) then
			return
		end

		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local v = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local rig, v2 = buildRig(data)
		rig:SetAttribute("_PartIcleEmit", true)
		local v3 = PDataBuilder.build(animateItem, data, rig, v2, v, p3, p2)
		v3.IsAnimate = true
		v3.AnimateItem = animateItem
		p._seedTsOverride(v3, animateItem)
		Anchors.seedPose(v3)
		v3._curThick = not data.Thickness and 0.15 or Graph.QueryPointsWithTime(0, data.Thickness, v3.Seeds.Thickness) or 0.15
		writeSegments(v3, true)
		writeVisuals(v3, 0)
		rig.Parent = data.EmitParent or object2:GetFolder()
		Particles.EnableEmit(rig, object2:_makeAliveCheck())
		v3._nestedAlive = { true }
		object2.ActiveAnimates[animateItem] = v3
		object2:_registerEmit(v3, p3)
		NestedEmit.walk(object2, data.RenderTemplate, rig, v3._nestedAlive, p3)
	end

	function p.UpdateRope(_, state, p2, p3)
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
		local effectiveElapsed = v4 < 0 and 0 or v4

		if lifeTime < effectiveElapsed then
			effectiveElapsed = lifeTime
		end

		state._effectiveElapsed = effectiveElapsed
		local visualPart = state.VisualPart

		if not (visualPart and visualPart.Parent) or state.TotalKeyFrames <= 0 then
			return true
		end

		local v6

		if v >= 1 then
			v6 = lifeTime <= effectiveElapsed or effectiveElapsed <= 0
		else
			v6 = false
		end

		if not v6 then
			local v7 = state._timeFrozen == true and 0 or math.min(math.abs(v3), 0.25)
			local v8 = math.clamp(effectiveElapsed - _effectiveElapsed, -0.25, 0.25)
			local v9 = math.min(math.max(effectiveElapsed / lifeTime, 0), 1)
			local v10 = not (state._growIn > 0 and v9 < state._growIn) and 1 or math.max(v9 / state._growIn, 0.02)

			if state._deathMode == "Retract" then
				local v11 = 1 - state._deathWindow

				if v11 < v9 then
					v10 *= math.max(1 - (v9 - v11) / state._deathWindow, 0.02)
				end
			elseif state._deathMode == "Release" and not state._released and 1 - state._deathWindow < v9 then
				state._released = true
				state._pinStart = false
				state._pinEnd = false
			end

			state._restLenEff = state._restLen * v10

			if state._hasMotion and v8 ~= 0 then
				local v11 = not state.Graphs.Speed and 0 or Graph.QueryPointsWithTime(
					v9,
					state.Graphs.Speed,
					state.Seeds.Speed
				) or 0

				if state._drag ~= 0 then
					v11 *= math.exp(-state._drag * effectiveElapsed)
				end

				state._motionAccelVel += state._accel * v8
				state._motionOffset = state._motionOffset + (state._speedDir or state._motionDir) * (v11 * v8) + state._motionAccelVel * v8
			end

			if state._hasDisp or state._hasTurb or state._hasMotion then
				local vector2

				if state._hasDisp then
					local graphs = state.Graphs
					local seeds = state.Seeds
					vector2 = Vector3.new(
						not graphs.PosOffsetX and 0 or Graph.QueryPointsWithTime(
							v9,
							graphs.PosOffsetX,
							seeds.PosOffsetX
						) or 0,
						not graphs.PosOffsetY and 0 or Graph.QueryPointsWithTime(
							v9,
							graphs.PosOffsetY,
							seeds.PosOffsetY
						) or 0,
						not graphs.PosOffsetZ and 0 or Graph.QueryPointsWithTime(
							v9,
							graphs.PosOffsetZ,
							seeds.PosOffsetZ
						) or 0
					)
				else
					vector2 = createVector(0, 0, 0)
				end

				if state._hasTurb then
					vector2 += Turbulence.sampleRaw(
						state.Graphs.Turbulence,
						state.Seeds.Turbulence,
						state._turbSeed,
						state._turbFreq,
						lifeTime,
						v9
					)
				end

				if state._dispMode ~= "Global" then
					vector2 = Anchors.resolveStart(state).Rotation:VectorToWorldSpace(vector2)
				end

				if state._hasMotion then
					vector2 += state._motionOffset
				end

				state._anchorOffWorld = vector2
			else
				state._anchorOffWorld = nil
			end

			if state._pinMode == "Launch" then
				if state._launchArrived then
					if state._launchT then
						local _target = state._target

						if _target and _target.Parent then
							state._launchPos = PartConstants.resolveLinkCFrame(_target).Position
						end
					end
				elseif state._launchT and state._launchT <= effectiveElapsed then
					state._launchArrived = true
					local _target = state._target

					if _target and _target.Parent then
						state._launchPos = PartConstants.resolveLinkCFrame(_target).Position
					end
				else
					local v11 = state._launchVel * effectiveElapsed + state._gravity * (0.5 * effectiveElapsed * effectiveElapsed)

					if not state._launchT then
						local v12 = state._restLen * state._segCount

						if v12 <= v11.Magnitude then
							v11 = v11.Unit * v12
							state._launchArrived = true
						end
					end

					state._launchPos = state._launchOrigin + v11
				end
			end

			if v7 > 1e-6 then
				state._windPhase += state._windFreq * v7
				local _rig = state._rig
				local v11 = math.min(v7, VerletSim.SUBSTEP)
				local v12 = state._accum + v7
				local count = 0

				while v11 <= v12 and count < VerletSim.MAX_SUBSTEPS do
					Anchors.repin(state)
					VerletSim.step(_rig.posBuf, _rig.prevPosBuf, state._segCount, state, v11, state._windPhase)
					v12 -= v11
					count += 1
				end

				state._accum = count == VerletSim.MAX_SUBSTEPS and 0 or v12
				Anchors.repin(state)
				writeSegments(state, false)
			end
		end

		local currentStep = math.floor(math.min(math.max(effectiveElapsed / lifeTime, 0), 1) * state.TotalKeyFrames)

		if currentStep ~= state.CurrentStep then
			state.CurrentStep = currentStep
			writeVisuals(state, currentStep / state.TotalKeyFrames)
		end

		return v6
	end

	function p._refreshRopeAnimate(object2, state, data)
		state.Link = nil
		local _segCount = state._segCount
		local _restLen = state._restLen
		local v

		if math.clamp(math.floor((not data.SegmentCount and 12 or data.SegmentCount.Max or 12) + 0.5), 2, 48) == state._rig.segCap or not data.RenderTemplate then
			v = false
		else
			local visualPart = state.VisualPart
			local parent = visualPart and visualPart.Parent
			local rig, rig2 = buildRig(data)
			rig:SetAttribute("_PartIcleEmit", true)
			state.VisualPart = rig
			state._rig = rig2
			rig.Parent = parent or object2:GetFolder()

			if visualPart then
				pcall(function()
					visualPart:Destroy()
				end)
			end

			v = true
		end

		PDataBuilder.readRopeParams(state, data, state._rig)
		state._accum = 0
		state._released = false
		state.SkipColor = nil

		if v or state._segCount ~= _segCount or math.abs((state._restLen or 0) - (_restLen or 0)) > 0.0001 then
			Anchors.seedPose(state)
			state._launchArrived = false
			state._launchPos = nil
		end

		state._curThick = data.Thickness and Graph.QueryPointsWithTime(0, data.Thickness, state.Seeds.Thickness) or state._curThick
		writeSegments(state, false)
		writeVisuals(state, 0)
	end
end