local createVector = vector.create
local PartConstants = require(script.Parent.Parent.PartConstants)
local VerletSim = require(script.Parent.VerletSim)
local Anchors = {}

local function applySpawnOff(data, p)
	local _spawnOff = data._spawnOff

	if not _spawnOff or _spawnOff.Magnitude == 0 then
		return p
	end

	if data._spawnOffMode == "Global" then
		return p + _spawnOff
	end

	local _spawnRot = data._spawnRot

	if _spawnRot then
		return p + (p.Rotation * _spawnRot):VectorToWorldSpace(_spawnOff)
	end

	return p * CFrame.new(_spawnOff)
end

function Anchors:resolveStart()
	local _startCFOverride

	if self._startCFOverride then
		_startCFOverride = self._startCFOverride
	else
		local _parentLink = self._parentLink

		if _parentLink and _parentLink.Parent then
			_startCFOverride = PartConstants.resolveLinkCFrame(_parentLink)
		else
			local _sourceItem = self._sourceItem
			_startCFOverride = _sourceItem and _sourceItem.Parent and _sourceItem.CFrame or self._lastStartCF or CFrame.new()
		end

		self._lastStartCF = _startCFOverride
	end

	if self._spawnTarget == "End" then
		return _startCFOverride
	end

	local _spawnOff = self._spawnOff

	if not _spawnOff or _spawnOff.Magnitude == 0 then
		return _startCFOverride
	end

	if self._spawnOffMode == "Global" then
		return _startCFOverride + _spawnOff
	end

	local _spawnRot = self._spawnRot

	if _spawnRot then
		return _startCFOverride + (_startCFOverride.Rotation * _spawnRot):VectorToWorldSpace(_spawnOff)
	end

	_startCFOverride *= CFrame.new(_spawnOff)
	return _startCFOverride
end

function Anchors:resolveEnd()
	if not self._pinEnd then
		return nil
	end

	if self._pinMode == "Launch" then
		return self._launchPos or self._launchOrigin
	end

	local _target = self._target

	if _target and _target.Parent then
		local linkCFrame = PartConstants.resolveLinkCFrame(_target)

		if self._spawnTarget == "End" then
			local _spawnOff = self._spawnOff

			if _spawnOff and _spawnOff.Magnitude ~= 0 then
				if self._spawnOffMode == "Global" then
					linkCFrame += _spawnOff
				else
					local _spawnRot = self._spawnRot

					if _spawnRot then
						linkCFrame += (linkCFrame.Rotation * _spawnRot):VectorToWorldSpace(_spawnOff)
					else
						linkCFrame *= CFrame.new(_spawnOff)
					end
				end
			end
		end

		self._lastEndPos = linkCFrame.Position
		return linkCFrame.Position
	else
		self._pinEnd = false
		local _rig = self._rig
		VerletSim.calm(_rig.posBuf, _rig.prevPosBuf, self._segCount)
		return nil
	end
end

function Anchors:repin()
	local _rig = self._rig
	local posBuf = _rig.posBuf
	local prevPosBuf = _rig.prevPosBuf
	local _segCount = self._segCount
	local _anchorOffWorld = self._anchorOffWorld

	if self._pinStart ~= false then
		local position = Anchors.resolveStart(self).Position

		if _anchorOffWorld and self._motionTarget == "Start" then
			position += _anchorOffWorld
		end

		local v = position - posBuf[1]

		if v.Magnitude > 50 then
			VerletSim.translate(posBuf, prevPosBuf, _segCount, v)
		end

		posBuf[1] = position
		prevPosBuf[1] = position
	end

	local v = Anchors.resolveEnd(self)

	if v then
		if _anchorOffWorld and self._motionTarget == "End" then
			v += _anchorOffWorld
		end

		posBuf[_segCount + 1] = v
		prevPosBuf[_segCount + 1] = v
	end
end

function Anchors:seedPose()
	local _rig = self._rig
	local posBuf = _rig.posBuf
	local _segCount = self._segCount
	local position = Anchors.resolveStart(self).Position

	if (self._growIn or 0) > 0 and self._pinMode ~= "Launch" then
		local _motionDir = self._motionDir or createVector(0, -1, 0)
		local v = self._restLen * 0.02

		for i = 1, _segCount + 1 do
			posBuf[i] = position + _motionDir * (v * (i - 1))
		end

		VerletSim.calm(posBuf, _rig.prevPosBuf, _segCount)
	elseif self._pinMode == "Launch" then
		local _launchVel = self._launchVel
		local unit = _launchVel and _launchVel.Magnitude > 0.0001 and _launchVel.Unit or createVector(0, 1, 0)
		local v = self._restLen * 0.05

		for i = 1, _segCount + 1 do
			posBuf[i] = position + unit * (v * (i - 1))
		end

		VerletSim.calm(posBuf, _rig.prevPosBuf, _segCount)
	else
		local v = Anchors.resolveEnd(self)

		if v then
			local v2 = v - position
			local v3 = math.max(self._restLen * _segCount - v2.Magnitude, 0)

			for i = 1, _segCount + 1 do
				local v4 = (i - 1) / _segCount
				posBuf[i] = position + v2 * v4 - Vector3.new(0, v3 * 0.5 * 4 * v4 * (1 - v4), 0)
			end
		else
			local _motionDir = self._motionDir or createVector(0, -1, 0)

			for i = 1, _segCount + 1 do
				posBuf[i] = position + _motionDir * (self._restLen * (i - 1))
			end
		end

		VerletSim.calm(posBuf, _rig.prevPosBuf, _segCount)
	end
end

return Anchors