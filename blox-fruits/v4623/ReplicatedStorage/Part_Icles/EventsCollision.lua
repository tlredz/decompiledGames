local createVector = vector.create
local PartConstants = require(script.Parent.PartConstants)
local Graph = require(script.Parent.Graph)
local v = {
	createVector(1, 0, 0),
	createVector(-1, 0, 0),
	createVector(0, 1, 0),
	createVector(0, -1, 0),
	createVector(0, 0, 1),
	createVector(0, 0, -1)
}

local function _snapshotPData(data, kind)
	return {
		time = data._effectiveElapsed or 0,
		kind = kind,
		BaseDirection = data.BaseDirection,
		SpeedMultiplier = data.SpeedMultiplier,
		_accelVel = data._accelVel,
		TargetVel = data.TargetVel,
		_spinRate = data._spinRate,
		_spinAccumX = data._spinAccumX,
		_spinAccumY = data._spinAccumY,
		_spinAccumZ = data._spinAccumZ,
		AccRotX = data.AccRotX,
		AccRotY = data.AccRotY,
		AccRotZ = data.AccRotZ,
		LocalCF = data.LocalCF,
		_localWorldCF = data._localWorldCF,
		CurrentPosition = data.CurrentPosition,
		_hitFired = data._hitFired,
		LastHitCheckPos = data.LastHitCheckPos,
		_collisionStopped = data._collisionStopped,
		CurrentStep = data.CurrentStep,
		AccumulatedDT = data.AccumulatedDT,
		_displacementMirrorX = data._displacementMirrorX,
		_displacementMirrorY = data._displacementMirrorY,
		_displacementMirrorZ = data._displacementMirrorZ,
		_prevWorldOff = data._prevWorldOff,
		_prevTurbOff = data._prevTurbOff,
		_settleEngaged = data._settleEngaged,
		_restTimer = data._restTimer,
		_settleRotDamp = data._settleRotDamp,
		_settleContactPos = data._settleContactPos,
		_settleSpawnHalf = data._settleSpawnHalf,
		_lastHitNormal = data._lastHitNormal
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _pushHit(state, p)
	state._hitHistory = state._hitHistory or {}

	if #state._hitHistory >= 16 then
		table.remove(state._hitHistory, 1)
	end

	table.insert(state._hitHistory, p)
end

local function applySnapCFrame(state, cFrame)
	local visualPart = state.VisualPart

	if not (visualPart and visualPart.Parent) then
		return
	end

	if state.Type == "Model" then
		visualPart:PivotTo(cFrame)
		return
	end

	if state.Type ~= "Attachment" then
		visualPart.CFrame = cFrame
		return
	end

	local parent = visualPart.Parent

	if parent and parent:IsA("BasePart") then
		cFrame = parent.CFrame:ToObjectSpace(cFrame) or cFrame
	end

	visualPart.CFrame = cFrame
end

local function readWorldCF(state)
	local visualPart = state.VisualPart

	if not (visualPart and visualPart.Parent) then
		return CFrame.new()
	end

	if state.Type == "Model" then
		return visualPart:GetPivot()
	end

	if state.Type ~= "Attachment" then
		return visualPart.CFrame
	end

	local parent = visualPart.Parent
	return parent and parent:IsA("BasePart") and parent.CFrame * visualPart.CFrame or visualPart.CFrame
end

local function bounceParentCF(data)
	local link = data.Link

	if not (link and link.Parent) then
		return CFrame.new()
	end

	local _rigidLocalParentCF

	if data.LinkMode == "RigidLocal" then
		_rigidLocalParentCF = data._rigidLocalParentCF or CFrame.new()
	else
		_rigidLocalParentCF = PartConstants.resolveLinkCFrame(link)
	end

	if not _rigidLocalParentCF then
		return CFrame.new()
	end

	if data.LinkMode == "Follow" or data.LinkMode == "Pivot" then
		return CFrame.new(_rigidLocalParentCF.Position)
	end

	return _rigidLocalParentCF
end

local function attachmentBounceLocalPos(data, p)
	local visualPart = data.VisualPart
	local parent = visualPart and visualPart.Parent
	local cFrame = parent and parent:IsA("BasePart") and parent.CFrame or CFrame.new()
	local link = data.Link
	local cframe

	if link and link.Parent then
		local v2

		if data.LinkMode == "RigidLocal" then
			v2 = data._rigidLocalParentCF or CFrame.new()
		else
			v2 = PartConstants.resolveLinkCFrame(link)
		end

		cframe = cFrame:ToObjectSpace(v2)

		if data.LinkMode == "Follow" or data.LinkMode == "Pivot" then
			cframe = CFrame.new(cframe.Position)
		end
	else
		cframe = CFrame.new()
	end

	return cframe:PointToObjectSpace((cFrame:PointToObjectSpace(p)))
end

local function handleKillOrStop(object, state, p, p2)
	local v2

	if p2 ~= "Kill" then
		v2 = _snapshotPData(state, "Stop") or nil
	end

	local v3 = readWorldCF(state)
	local postUpdateCF = CFrame.new(p.Position) * (v3 - v3.Position)
	applySnapCFrame(state, postUpdateCF)
	state.CurrentPosition = p.Position

	if p2 == "Kill" then
		if object._killParticle then
			object:_killParticle(state, {
				fireOnDeath = true
			})
		end
	else
		if state.LocalCF then
			local v5

			if state.Type == "Attachment" then
				v5 = attachmentBounceLocalPos(state, p.Position)
			else
				v5 = bounceParentCF(state):PointToObjectSpace(p.Position)
			end

			state.LocalCF = CFrame.new(v5) * (state.LocalCF - state.LocalCF.Position)
			state._localWorldCF = state.LocalCF
		end

		state._postUpdateCF = postUpdateCF
		state._collisionStopped = true
		state.LastHitCheckPos = p.Position
		state._hitFired = true

		if v2 then
			_pushHit(state, v2) -- equivalent call inferred; original call site unknown
		end
	end
end

local function handleBounce(state, p, vector2, p2)
	local normal = p.Normal
	local onHit = state.Events.OnHit
	state._bouncinessJitter = state._bouncinessJitter or 1 + (math.random() - 0.5) * 0.4
	state._frictionJitter = state._frictionJitter or 1 + (math.random() - 0.5) * 0.4
	state._restClampJitter = state._restClampJitter or 1 + (math.random() - 0.5) * 0.4
	state._sleepTimeJitter = state._sleepTimeJitter or 1 + (math.random() - 0.5) * 0.4
	local v2 = (onHit.Bounciness or 0.7) * state._bouncinessJitter
	local v3 = (onHit.Friction or 0.2) * state._frictionJitter
	local spin = onHit.Spin or 0.5
	local v4 = (not p2 or p2 <= 0) and 0.016666666666666666 or p2
	local v5 = _snapshotPData(state, "Bounce")
	state._lastHitNormal = normal
	local v6 = math.abs(((vector2 / v4):Dot(normal))) < 0.5 * (state._restClampJitter or 1) and 0 or v2
	local baseDirection = state.BaseDirection

	if baseDirection then
		local v7 = baseDirection:Dot(normal) * normal
		local v8 = baseDirection - v7
		local v9 = -v6 * v7 + (1 - v3) * v8
		local magnitude = v9.Magnitude

		if magnitude > 0.0001 then
			state.BaseDirection = v9.Unit
			state.SpeedMultiplier = (state.SpeedMultiplier or 1) * magnitude
		else
			state.SpeedMultiplier = 0
		end
	end

	local _accelVel = state._accelVel

	if _accelVel then
		local v7 = _accelVel:Dot(normal) * normal
		local v8 = _accelVel - v7
		state._accelVel = -v6 * v7 + (1 - v3) * v8
	end

	local targetVel = state.TargetVel

	if targetVel then
		local v7 = targetVel:Dot(normal) * normal
		local v8 = targetVel - v7
		state.TargetVel = -v6 * v7 + (1 - v3) * v8
	end

	local _spinRate = state._spinRate or createVector(0, 0, 0)
	local v7 = (vector2 - vector2:Dot(normal) * normal) / v4
	local magnitude = (vector2 / v4).Magnitude
	local v8 = not (v7.Magnitude > 0.0001) and createVector(0, 0, 0) or normal:Cross(v7) * (spin * 3.33)
	local v9 = math.min(1, magnitude / 1)
	state._spinRate = _spinRate * (1 - v3) * v9 + v8

	if magnitude < 1 then
		if not state._settleEngaged then
			local visualPart = state.VisualPart

			if visualPart and visualPart:IsA("BasePart") then
				local settleSpawnHalf = visualPart.Size.Magnitude * 0.5
				state._settleSpawnHalf = settleSpawnHalf
				state._settleContactPos = visualPart.Position - normal * settleSpawnHalf
			end
		end

		state._settleEngaged = true
	end

	if state.HasPosOffsetGraphs then
		local function _reflect(vector3)
			return vector3 - 2 * vector3:Dot(normal) * normal
		end

		local _displacementMirrorX = state._displacementMirrorX or createVector(1, 0, 0)
		local _displacementMirrorY = state._displacementMirrorY or createVector(0, 1, 0)
		local _displacementMirrorZ = state._displacementMirrorZ or createVector(0, 0, 1)
		state._displacementMirrorX = _displacementMirrorX - 2 * _displacementMirrorX:Dot(normal) * normal
		state._displacementMirrorY = _displacementMirrorY - 2 * _displacementMirrorY:Dot(normal) * normal
		state._displacementMirrorZ = _displacementMirrorZ - 2 * _displacementMirrorZ:Dot(normal) * normal
		local v10 = (state.CurrentStep or 0) / math.max(state.TotalKeyFrames, 1)
		local v11 = not state.Graphs.PosOffsetX and 0 or Graph.QueryPointsWithTime(
			v10,
			state.Graphs.PosOffsetX,
			state.Seeds.PosOffsetX
		) or 0
		local v12 = not state.Graphs.PosOffsetY and 0 or Graph.QueryPointsWithTime(
			v10,
			state.Graphs.PosOffsetY,
			state.Seeds.PosOffsetY
		) or 0
		local v13 = not state.Graphs.PosOffsetZ and 0 or Graph.QueryPointsWithTime(
			v10,
			state.Graphs.PosOffsetZ,
			state.Seeds.PosOffsetZ
		) or 0
		state._prevWorldOff = PartConstants.resolveDisplacement(
			Vector3.new(v11, v12, v13),
			state.DisplacementMode or "Global",
			state.SpawnRotation,
			state.SpawnEmitterRotation,
			state._displacementMirrorX,
			state._displacementMirrorY,
			state._displacementMirrorZ
		)
	end

	local v10 = p.Position + normal * 0.05

	if state.LocalCF then
		local v11

		if state.Type == "Attachment" then
			v11 = attachmentBounceLocalPos(state, v10)
		else
			v11 = bounceParentCF(state):PointToObjectSpace(v10)
		end

		state.LocalCF = CFrame.new(v11) * (state.LocalCF - state.LocalCF.Position)
		state._localWorldCF = state.LocalCF
	end

	local v11 = readWorldCF(state)
	local postUpdateCF = CFrame.new(v10) * (v11 - v11.Position)
	applySnapCFrame(state, postUpdateCF)
	state._postUpdateCF = postUpdateCF
	state.CurrentPosition = v10
	state.LastHitCheckPos = v10
	state._hitFired = false
	_pushHit(state, v5) -- equivalent call inferred; original call site unknown
end

local EventsCollision = {}

function EventsCollision:restoreHitsOnReverse(p2, p3)
	local _hitHistory = self._hitHistory

	if not _hitHistory then
		return
	end

	for i = #_hitHistory, 1, -1 do
		local v2 = _hitHistory[i]

		if not (p3 < v2.time and v2.time <= p2) then
			continue
		end

		self.BaseDirection = v2.BaseDirection
		self.SpeedMultiplier = v2.SpeedMultiplier
		self._accelVel = v2._accelVel
		self.TargetVel = v2.TargetVel
		self._spinRate = v2._spinRate
		self._spinAccumX = v2._spinAccumX
		self._spinAccumY = v2._spinAccumY
		self._spinAccumZ = v2._spinAccumZ
		self.AccRotX = v2.AccRotX
		self.AccRotY = v2.AccRotY
		self.AccRotZ = v2.AccRotZ
		self.LocalCF = v2.LocalCF
		self._localWorldCF = v2._localWorldCF
		self.CurrentPosition = v2.CurrentPosition
		self._hitFired = v2._hitFired
		self.LastHitCheckPos = v2.LastHitCheckPos
		self._collisionStopped = v2._collisionStopped
		self.CurrentStep = v2.CurrentStep
		self.AccumulatedDT = v2.AccumulatedDT
		self._displacementMirrorX = v2._displacementMirrorX
		self._displacementMirrorY = v2._displacementMirrorY
		self._displacementMirrorZ = v2._displacementMirrorZ
		self._prevWorldOff = v2._prevWorldOff
		self._prevTurbOff = v2._prevTurbOff
		self._settleEngaged = v2._settleEngaged
		self._restTimer = v2._restTimer
		self._settleRotDamp = v2._settleRotDamp
		self._settleContactPos = v2._settleContactPos
		self._settleSpawnHalf = v2._settleSpawnHalf
		self._lastHitNormal = v2._lastHitNormal
		table.remove(_hitHistory, i)
	end
end

function EventsCollision:applySettle(p)
	if not self or self._collisionStopped or not self._settleEngaged or self.NeedsFullIteration then
		return
	end

	if p and p > 0 then
		local v2 = math.exp(-6 * p)
		self._spinRate = (self._spinRate or createVector(0, 0, 0)) * v2
		self._settleRotDamp = (self._settleRotDamp or 1) * math.exp(-6 * p)
	end

	local _lastHitNormal = self._lastHitNormal

	if not _lastHitNormal or _lastHitNormal.Magnitude < 0.0001 then
		return
	end

	local visualPart = self.VisualPart

	if not (visualPart and visualPart.Parent) then
		return
	end

	local cframe = readWorldCF(self)
	local v2 = -_lastHitNormal
	local v3 = v[1]
	local v4 = -1e999

	for _, v5 in ipairs(v) do
		local dot = cframe:VectorToWorldSpace(v5):Dot(v2)

		if not (v4 < dot) then
			continue
		end

		v3 = v5
		v4 = dot
	end

	local vector2 = cframe:VectorToWorldSpace(v3)
	local v5 = math.acos((math.clamp(vector2:Dot(v2), -1, 1)))
	local cross = vector2:Cross(v2)

	if cross.Magnitude > 0.0001 and v5 > 0.0001 and p and p > 0 then
		local magnitude = (self.Acceleration or createVector(0, 0, 0)).Magnitude

		if magnitude > 1 then
			local v6 = math.sin(v5) * magnitude * 0.5
			local v7 = cross.Unit * v6
			self._spinRate = (self._spinRate or createVector(0, 0, 0)) + v7 * p
		end
	end

	if self._settleContactPos and self._settleSpawnHalf and visualPart:IsA("BasePart") then
		local v6 = visualPart.Size.Magnitude * 0.5
		local v7 = self._settleContactPos + _lastHitNormal * v6
		applySnapCFrame(self, CFrame.new(v7) * (cframe - cframe.Position))
	end

	local _sleepRadius = self._sleepRadius or 1
	local v6 = (self._spinRate or createVector(0, 0, 0)).Magnitude * _sleepRadius * 0.017453292519943295

	if math.abs(self.SpeedMultiplier or 0) + (self._accelVel or createVector(0, 0, 0)).Magnitude + v6 < 0.1 then
		self._restTimer = (self._restTimer or 0) + p
	else
		self._restTimer = 0
	end

	if (self._restTimer or 0) >= 0.5 * (self._sleepTimeJitter or 1) and v5 < 0.02 then
		self._collisionStopped = true
		self._spinRate = createVector(0, 0, 0)
		self._accelVel = createVector(0, 0, 0)
		self.SpeedMultiplier = 0
		self.TargetVel = createVector(0, 0, 0)
	end
end

function EventsCollision.handle(p, state, p2, p3, p4)
	local collision = state.Events.OnHit.Collision or "Off"
	local v2 = collision == "Bounce" and state.InvertMotion and "Kill" or collision
	local v3 = state.IsAnimate and (v2 == "Kill" or v2 == "Stop" or v2 == "Bounce") and "Off" or v2

	if v3 == "Kill" or v3 == "Stop" then
		handleKillOrStop(p, state, p2, v3)
		return "snap"
	end

	if v3 == "Bounce" then
		handleBounce(state, p2, p3, p4)
		return "snap"
	end

	state._hitFired = true
	return "off"
end

return EventsCollision