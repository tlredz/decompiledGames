local Graph = require(script.Parent.Graph)
local Range = require(script.Parent.Range)
local Pool = require(script.Parent.Pool)
local Events = require(script.Parent.Events)
local NestedEmit = require(script.Parent.NestedEmit)
local Particles = require(script.Parent.Particles)
local PartConstants = require(script.Parent.PartConstants)
local Trajectory = require(script.Trajectory)
local PDataBuilder = require(script.PDataBuilder)
local cframe = CFrame.new(1000000000, 1000000000, 1000000000)
local object = setmetatable({}, {
	__mode = "k"
})
return function(p)
	function p._isRocks(part)
		return part:IsA("BasePart") and part:GetAttribute("IsRocks") == true
	end

	local function buildChunk(p2)
		local copyBare = Pool.copyBare(p2)
		copyBare.Anchored = true
		copyBare.CanCollide = false
		copyBare.CanQuery = false
		copyBare.CanTouch = false
		copyBare.Massless = false
		copyBare.Locked = true
		copyBare.Archivable = false
		copyBare.CastShadow = true
		copyBare.Transparency = 0
		return copyBare, copyBare:FindFirstChildWhichIsA("Decal") or copyBare:FindFirstChildWhichIsA("Texture")
	end

	local function chunkCapFor(p2)
		return (math.clamp(math.floor((p2.ChunkCount and p2.ChunkCount.Max or 10) + 0.5), 1, 32))
	end

	local function buildRig(data)
		local chunkCap = math.clamp(math.floor((not data.ChunkCount and 10 or data.ChunkCount.Max or 10) + 0.5), 1, 32)
		local model = Instance.new("Model")
		model.Name = "RockBurst"
		model.Archivable = false
		local v2 = {
			chunkCap = chunkCap,
			parts = table.create(chunkCap),
			decals = table.create(chunkCap),
			baseSize = table.create(chunkCap),
			halfExt = table.create(chunkCap),
			bounciness = table.create(chunkCap),
			launchVel = table.create(chunkCap),
			launchAng = table.create(chunkCap),
			spawnPos = table.create(chunkCap),
			spawnRot = table.create(chunkCap),
			trajs = table.create(chunkCap),
			touched = table.create(chunkCap),
			writeCFs = table.create(chunkCap)
		}

		for i = 1, chunkCap do
			local renderTemplate = data.RenderTemplate
			local copyBare = Pool.copyBare(renderTemplate)
			copyBare.Anchored = true
			copyBare.CanCollide = false
			copyBare.CanQuery = false
			copyBare.CanTouch = false
			copyBare.Massless = false
			copyBare.Locked = true
			copyBare.Archivable = false
			copyBare.CastShadow = true
			copyBare.Transparency = 0
			local decal = copyBare:FindFirstChildWhichIsA("Decal") or copyBare:FindFirstChildWhichIsA("Texture")
			copyBare.Name = "Chunk" .. i
			copyBare.CFrame = cframe
			copyBare.Parent = model
			v2.parts[i] = copyBare
			v2.decals[i] = decal
			v2.baseSize[i] = copyBare.Size
			v2.writeCFs[i] = cframe
		end

		object[model] = v2
		return model, v2
	end

	local function acquireRocks(data)
		local v = math.clamp(math.floor((not data.ChunkCount and 10 or data.ChunkCount.Max or 10) + 0.5), 1, 32)
		local v2 = data.Pool ~= false and Pool.acquire(data.RenderTemplate, "Rocks")

		if v2 then
			local v3 = object[v2]

			if v3 and v3.chunkCap == v and v3.parts[1] and v3.parts[1].Parent == v2 then
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

		local curScale = graphs.Scale and Graph.QueryPointsWithTime(p2, graphs.Scale, seeds.Scale)
		local _rig = state._rig
		local v3 = curScale and curScale ~= state._curScale

		if curScale then
			state._curScale = curScale
		end

		state._curTrans = _curTrans

		for i = 1, _rig.chunkCap do
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

			if v3 then
				part.Size = _rig.baseSize[i] * math.max(curScale, 0.01)
			end
		end
	end

	local function buildRockParams(object2, p2)
		local hitParams = Events.makeHitParams(p2)
		hitParams.RespectCanCollide = true
		pcall(function()
			hitParams:AddToFilter(object2:GetFolder())
			hitParams:AddToFilter(object2:GetPoolFolder())
		end)
		p2._rockParams = hitParams

		function p2._raycastFn(p3, p4)
			return workspace:Raycast(p3, p4, hitParams)
		end
	end

	local function buildTrajectories(state)
		local _rig = state._rig
		local _raycastFn = state._raycastFn
		local _curScale = state._curScale or 1
		local impactT = 1e999
		local restT = 0
		local hit = nil
		local v = false

		for i = 1, state._chunkCount do
			local v2 = Trajectory.build(
				_rig.spawnPos[i],
				_rig.launchVel[i],
				_rig.spawnRot[i],
				_rig.launchAng[i],
				_rig.halfExt[i],
				_curScale,
				state._gravity,
				_rig.bounciness[i],
				state._friction,
				_raycastFn
			)
			_rig.trajs[i] = v2

			if v2.impactT and v2.impactT < impactT then
				impactT = v2.impactT
				hit = v2.hit
			end

			if v2.restT == 1e999 then
				v = true
			elseif restT < v2.restT then
				restT = v2.restT
			end
		end

		state._firstImpactT = impactT
		state._firstHitInfo = hit
		state._maxRestT = (not (restT > 0) or v or not restT) and 1e999 or restT
		state._restWritten = false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function startPhysics(object2, p2)
		buildRockParams(object2, p2)
		buildTrajectories(p2)
	end

	function p.EmitRocks(object2, p2, p3, p4)
		if not (p2 and p2.Parent) then
			return
		end

		local data = object2:GetData(p2)

		if not (data and data.RenderTemplate) then
			return
		end

		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local v = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local v2, v3 = acquireRocks(data)
		local v4 = PDataBuilder.build(p2, data, v2, v3, v, p4, p3)
		p._seedTsOverride(v4, p2)

		if data.Pool ~= false then
			v4._sourceRT = data.RenderTemplate
			v4._poolKind = "Rocks"
		end

		writeVisuals(v4, 0)
		v2.Parent = data.EmitParent or object2:GetFolder()
		startPhysics(object2, v4) -- equivalent call inferred; original call site unknown
		Pool.restoreTrails(v2, "Rocks")
		Particles.EnableEmit(v2, object2:_makeAliveCheck())
		v4._nestedAlive = { true }
		object2:_registerEmit(v4, p4)
		NestedEmit.walk(object2, data.RenderTemplate, v2, v4._nestedAlive, p4)
	end

	function p.EmitRocksAnimate(object2, animateItem, animateLink, p2)
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
		local v3 = PDataBuilder.build(animateItem, data, rig, v2, v, p2, animateLink)
		v3.IsAnimate = true
		v3.AnimateItem = animateItem
		v3._animateLink = animateLink
		p._seedTsOverride(v3, animateItem)
		writeVisuals(v3, 0)
		rig.Parent = data.EmitParent or object2:GetFolder()
		startPhysics(object2, v3) -- equivalent call inferred; original call site unknown
		Particles.EnableEmit(rig, object2:_makeAliveCheck())
		v3._nestedAlive = { true }
		object2.ActiveAnimates[animateItem] = v3
		object2:_registerEmit(v3, p2)
		NestedEmit.walk(object2, data.RenderTemplate, rig, v3._nestedAlive, p2)
	end

	function p.UpdateRocks(p2, state, p3, p4)
		local v = math.min(math.max((p4 - state.StartTime) / state.LifeTime, 0), 1)
		local v2

		if state._tsOverride == nil or not (p4 < (state._tsOverrideUntil or 0)) then
			v2 = not state.Graphs.Timescale and 1 or Graph.QueryPointsWithTime(
				v,
				state.Graphs.Timescale,
				state.Seeds.Timescale
			) or 1
		else
			v2 = state._tsOverride
		end

		local v3 = p3 * v2
		local lifeTime = state.LifeTime
		local v4 = (state._effectiveElapsed or 0) + (state._timeFrozen and 0 or v3)
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
			local _rig = state._rig
			local v7 = state._sinkOut and effectiveElapsed / lifeTime > 0.85

			if effectiveElapsed < state._maxRestT or v7 or not state._restWritten then
				local v8

				if v7 then
					local v9 = (effectiveElapsed / lifeTime - 0.85) / 0.15000000000000002
					v8 = v9 * v9
				else
					v8 = 0
				end

				for i = 1, state._chunkCount do
					local traj = _rig.trajs[i]

					if not traj then
						continue
					end

					local evaluate = Trajectory.evaluate(traj, effectiveElapsed, state._gravity)

					if v8 > 0 and traj.restT < effectiveElapsed then
						local v9 = _rig.baseSize[i]
						local v10 = math.max(v9.X, v9.Y, v9.Z) * math.max(state._curScale or 1, 0.01) * 1.5
						evaluate = evaluate.Rotation + (evaluate.Position - Vector3.new(0, v10 * v8, 0))
					end

					_rig.writeCFs[i] = evaluate

					if not state._inheritFloor or _rig.touched[i] or not traj.impactT or not (traj.impactT <= effectiveElapsed) then
						continue
					end

					if not traj.hit then
						continue
					end

					_rig.touched[i] = true
					local v9 = _rig.parts[i]
					local v10 = traj
					pcall(function()
						v9.Material = v10.hit.Instance.Material
						v9.Color = v10.hit.Instance.Color
					end)
					state.SkipColor = true
				end

				workspace:BulkMoveTo(_rig.parts, _rig.writeCFs, Enum.BulkMoveMode.FireCFrameChanged)
				state._restWritten = state._maxRestT <= effectiveElapsed and not v7
			end

			if not state._hitFired and state.Events and state.Events.OnHit and state._firstHitInfo and state._firstImpactT <= effectiveElapsed then
				state._hitFired = true
				local _firstHitInfo = state._firstHitInfo
				local payload = Events.makePayload(p2, state, "OnHit", nil)
				payload.HitInstance = _firstHitInfo.Instance
				payload.Other = _firstHitInfo.Instance
				payload.HitPosition = _firstHitInfo.Position
				payload.HitNormal = _firstHitInfo.Normal
				Events.fire(p2, state, "OnHit", state.EventChainCtx, payload)
			end
		end

		local currentStep = math.floor(math.min(math.max(effectiveElapsed / lifeTime, 0), 1) * state.TotalKeyFrames)

		if currentStep ~= state.CurrentStep then
			state.CurrentStep = currentStep
			writeVisuals(state, currentStep / state.TotalKeyFrames)
		end

		return v6
	end

	function p._refreshRocksAnimate(object2, state, data)
		state.Link = nil
		state._gravity = data.Gravity or 196.2
		state._friction = math.clamp(data.Friction or 0.3, 0, 1)
		state._sinkOut = data.SinkOut ~= false
		state._inheritFloor = data.InheritFloor == true
		state._hitFired = false
		state.SkipColor = nil

		if math.clamp(math.floor((not data.ChunkCount and 10 or data.ChunkCount.Max or 10) + 0.5), 1, 32) ~= state._rig.chunkCap and data.RenderTemplate then
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
		end

		local _animateLink = state._animateLink
		local cFrame

		if _animateLink and _animateLink.Parent then
			cFrame = PartConstants.resolveLinkCFrame(_animateLink)
		end

		local animateItem = state.AnimateItem

		if not cFrame and animateItem and animateItem.Parent then
			cFrame = animateItem.CFrame
		end

		local _rig = state._rig
		PDataBuilder.rollChunks(state, data, _rig, cFrame or CFrame.new())
		writeVisuals(state, 0)
		startPhysics(object2, state) -- equivalent call inferred; original call site unknown
	end
end