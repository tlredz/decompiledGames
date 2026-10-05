local createVector = vector.create
local PartConstants = require(script.Parent.Parent.PartConstants)
local Endpoints = {}

local function resolveDispFrame(p, cframe, p2)
	local _dispMode = p._dispMode

	if _dispMode == "Local" then
		if p._originRot then
			cframe = cframe.Rotation * p._originRot or cframe
		end

		return cframe:VectorToWorldSpace(p2)
	elseif _dispMode == "RigidLocal" then
		return cframe.Rotation:VectorToWorldSpace(p2)
	else
		return p2
	end
end

function Endpoints:sampleShape(data, part)
	self._shapeLocalOffset = nil
	self._shapeDirLocal = nil
	self._shapeUsesPart = nil

	if not data.UseShape then
		return
	end

	local shapeFunction = PartConstants.shapeFunctions[data.Shape]
	local shapePart = data.ShapePart

	if not (shapePart and shapePart:IsA("BasePart") and shapePart) then
		if part and part:IsA("BasePart") and part then
			shapePart = part
		else
			shapePart = nil
		end
	end

	if not (shapeFunction and shapePart) then
		return
	end

	local shapeLocalOffset, _, shapeDirLocal = shapeFunction(shapePart, {
		ShapePartial = data.ShapePartial or 0
	})
	self._shapeLocalOffset = shapeLocalOffset

	if shapePart == part or not shapePart then
		shapePart = nil
	end

	self._shapeUsesPart = shapePart

	if data.ShapeDirection == "Radial" and self._endpointMode == "Directional" and shapeDirLocal then
		local shapeInOut = data.ShapeInOut

		if shapeInOut == Enum.ParticleEmitterShapeInOut.Inward then
			shapeDirLocal = -shapeDirLocal
		elseif shapeInOut == Enum.ParticleEmitterShapeInOut.InAndOut and math.random() < 0.5 then
			shapeDirLocal = -shapeDirLocal
		end

		self._shapeDirLocal = shapeDirLocal
	end
end

local function seekScan(state, position)
	local _seekRayFn = state._seekRayFn

	if not _seekRayFn then
		return
	end

	local _seekRadius = state._seekRadius or 30
	local v = {}

	for _ = 1, 8 do
		local vector2 = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1)

		if not (vector2.Magnitude > 0.001) then
			continue
		end

		local hit = _seekRayFn(position, vector2.Unit * _seekRadius)

		if hit then
			v[#v + 1] = {
				hit = hit,
				dist = (hit.Position - position).Magnitude
			}
		end
	end

	if #v > 0 then
		table.sort(v, function(a, b)
			return a.dist < b.dist
		end)
		local _seekBias = state._seekBias or 0
		local hit = v[math.clamp(math.floor(math.random() ^ (1 + _seekBias * 8) * #v) + 1, 1, #v)].hit
		state._seekHit = {
			Position = hit.Position,
			Normal = hit.Normal,
			Instance = hit.Instance
		}
		state._seekNewHit = true
	else
		state._seekHit = nil
		local vector2 = Vector3.new(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1)
		state._seekFallbackDir = vector2.Magnitude > 0.001 and vector2.Unit or createVector(0, 1, 0)
	end
end

function Endpoints:glideStep(p)
	local _seekCurrentPos = self._seekCurrentPos
	local _seekGoalPos = self._seekGoalPos

	if (self._retargetSpeed or 0) <= 0 or not (_seekCurrentPos and _seekGoalPos) then
		return false
	end

	local v = _seekGoalPos - _seekCurrentPos
	local magnitude = v.Magnitude

	if magnitude <= 0.001 then
		return false
	end

	local v2 = self._retargetSpeed * p
	self._seekCurrentPos = magnitude <= v2 and _seekGoalPos or _seekCurrentPos + v * (v2 / magnitude)
	return true
end

function Endpoints:glideArrived()
	if (self._retargetSpeed or 0) <= 0 then
		return true
	end

	local _seekCurrentPos = self._seekCurrentPos
	local _seekGoalPos = self._seekGoalPos
	return not (_seekCurrentPos and _seekGoalPos) or (_seekCurrentPos - _seekGoalPos).Magnitude <= 0.01
end

function Endpoints:resolveEndpoints()
	local _parentLink = self._parentLink
	local _startCFOverride

	if self._startCFOverride then
		_startCFOverride = self._startCFOverride
	elseif _parentLink and _parentLink.Parent then
		_startCFOverride = PartConstants.resolveLinkCFrame(_parentLink)
	else
		local _sourceItem = self._sourceItem

		if _sourceItem and _sourceItem.Parent then
			_startCFOverride = _sourceItem.CFrame
		else
			_startCFOverride = self._lastStartCF or CFrame.new()
		end
	end

	self._lastStartCF = _startCFOverride
	local position = _startCFOverride.Position
	local cFrame

	if self._shapeLocalOffset then
		local _shapeUsesPart = self._shapeUsesPart

		if _shapeUsesPart and _shapeUsesPart.Parent then
			cFrame = _shapeUsesPart.CFrame or _startCFOverride
		else
			cFrame = _startCFOverride
		end

		position = (cFrame * CFrame.new(self._shapeLocalOffset)).Position
	else
		cFrame = _startCFOverride
	end

	local _originOffset = self._originOffset

	if _originOffset then
		if self._originOffsetGlobal then
			position += _originOffset
		else
			local cframe

			if self._originRot then
				cframe = _startCFOverride.Rotation * self._originRot or _startCFOverride
			else
				cframe = _startCFOverride
			end

			position += cframe:VectorToWorldSpace(_originOffset)
		end
	end

	local _motionOffset = self._motionOffset

	if _motionOffset and _motionOffset ~= createVector(0, 0, 0) then
		position += _motionOffset
	end

	local _dispRaw = self._dispRaw

	if _dispRaw then
		local _dispMode = self._dispMode

		if _dispMode == "Local" then
			local cframe

			if self._originRot then
				cframe = _startCFOverride.Rotation * self._originRot or _startCFOverride
			else
				cframe = _startCFOverride
			end

			_dispRaw = cframe:VectorToWorldSpace(_dispRaw)
		elseif _dispMode == "RigidLocal" then
			_dispRaw = _startCFOverride.Rotation:VectorToWorldSpace(_dispRaw)
		end

		position += _dispRaw
	end

	local _turbRaw = self._turbRaw

	if _turbRaw then
		local _dispMode = self._dispMode

		if _dispMode == "Local" then
			local cframe

			if self._originRot then
				cframe = _startCFOverride.Rotation * self._originRot or _startCFOverride
			else
				cframe = _startCFOverride
			end

			_turbRaw = cframe:VectorToWorldSpace(_turbRaw)
		elseif _dispMode == "RigidLocal" then
			_turbRaw = _startCFOverride.Rotation:VectorToWorldSpace(_turbRaw)
		end

		position += _turbRaw
	end

	local _dispMode = self._dispMode
	local sagDirWorld

	if _dispMode == "Local" then
		local cframe

		if self._originRot then
			cframe = _startCFOverride.Rotation * self._originRot or _startCFOverride
		else
			cframe = _startCFOverride
		end

		sagDirWorld = cframe:VectorToWorldSpace(createVector(0, 1, 0))
	else
		sagDirWorld = _dispMode ~= "RigidLocal" and createVector(0, 1, 0) or _startCFOverride.Rotation:VectorToWorldSpace(createVector(
			0,
			1,
			0
		))
	end

	self._sagDirWorld = sagDirWorld
	local position2

	if self._endpointMode == "Point" then
		local _target = self._target

		if _target and _target.Parent then
			position2 = PartConstants.resolveLinkCFrame(_target).Position
		else
			position2 = self._lastEndPos or position
		end

		local v2 = position2 - position

		if v2.Magnitude > 0.0001 then
			self._lastDirWorld = v2.Unit
		end
	elseif self._endpointMode == "Seek" then
		local v2 = not Endpoints.glideArrived(self)

		if self._seekRetarget and not v2 or not (self._seekHit or self._seekFallbackDir) then
			seekScan(self, position)
		end

		local position3

		if self._seekHit then
			position3 = self._seekHit.Position
		else
			position3 = position + self._seekFallbackDir * ((self._seekRadius or 30) * 0.5)
		end

		self._seekGoalPos = position3

		if (self._retargetSpeed or 0) <= 0 or not self._seekCurrentPos then
			self._seekCurrentPos = position3
		end

		position2 = self._seekCurrentPos
		local v3 = position2 - position

		if v3.Magnitude > 0.0001 then
			self._lastDirWorld = v3.Unit
		end
	else
		local _dirLocalVec

		if self._shapeDirLocal then
			_dirLocalVec = cFrame:VectorToWorldSpace(self._shapeDirLocal)
		elseif self._dirGlobal then
			_dirLocalVec = self._dirLocalVec
		else
			_dirLocalVec = _startCFOverride.Rotation:VectorToWorldSpace(self._dirLocalVec)
		end

		self._lastDirWorld = _dirLocalVec
		position2 = position + _dirLocalVec * self._length
	end

	self._lastEndPos = position2
	return _startCFOverride, position, position2
end

return Endpoints