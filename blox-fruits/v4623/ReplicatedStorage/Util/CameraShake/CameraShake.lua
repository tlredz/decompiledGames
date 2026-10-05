local createVector = vector.create
local CameraShake = {}
CameraShake.__index = CameraShake
local profilebegin = debug.profilebegin
local profileend = debug.profileend
local new2 = CFrame.new
local angles = CFrame.Angles
local rad = math.rad
local vector2 = Vector3.new()
local CameraShakeInstance = require(script.CameraShakeInstance)
local cameraShakeState = CameraShakeInstance.CameraShakeState
CameraShake.CameraShakeInstance = CameraShakeInstance
CameraShake.Presets = require(script.CameraShakePresets)

function CameraShake.new(renderPriority, callback)
	assert(type(renderPriority) == "number", "RenderPriority must be a number (e.g.: Enum.RenderPriority.Camera.Value)")
	assert(type(callback) == "function", "Callback must be a function")
	local HttpService = game:GetService("HttpService")
	local v = {
		_running = false,
		_renderName = "CameraShake_" .. HttpService:GenerateGUID(false),
		_renderPriority = renderPriority,
		_posAddShake = vector2,
		_rotAddShake = vector2,
		_camShakeInstances = {},
		_removeInstances = {},
		_callback = callback
	}
	return (setmetatable(v, CameraShake))
end

function CameraShake:Start()
	if self._running then
		return
	end

	self._running = true
	local _callback = self._callback
	local RunService = game:GetService("RunService")
	RunService:BindToRenderStep(self._renderName, self._renderPriority, function(p)
		profilebegin("CameraShakerUpdate")
		local v = self:Update(p)
		profileend()
		_callback(v)
	end)
end

function CameraShake:Stop()
	if not self._running then
		return
	end

	local RunService = game:GetService("RunService")
	RunService:UnbindFromRenderStep(self._renderName)
	self._running = false
end

function CameraShake:Update(p2: number)
	local v = vector2
	local v2 = vector2
	local _camShakeInstances = self._camShakeInstances

	for i = 1, #_camShakeInstances do
		local _camShakeInstance = _camShakeInstances[i]
		local state = _camShakeInstance:GetState()

		if state == cameraShakeState.Inactive and _camShakeInstance.DeleteOnInactive then
			self._removeInstances[#self._removeInstances + 1] = i
		elseif state ~= cameraShakeState.Inactive then
			local v3 = _camShakeInstance:UpdateShake(p2)
			v += v3 * _camShakeInstance.PositionInfluence
			v2 += v3 * _camShakeInstance.RotationInfluence
		end
	end

	for i = #self._removeInstances, 1, -1 do
		local _removeInstance = self._removeInstances[i]
		table.remove(_camShakeInstances, _removeInstance)
		self._removeInstances[i] = nil
	end

	return new2(v) * angles(0, rad(v2.Y), 0) * angles(rad(v2.X), 0, (rad(v2.Z)))
end

function CameraShake:Shake(p2)
	local v

	if type(p2) == "table" then
		v = p2._camShakeInstance
	else
		v = false
	end

	assert(v, "ShakeInstance must be of type CameraShakeInstance")
	self._camShakeInstances[#self._camShakeInstances + 1] = p2
	return p2
end

function CameraShake:ShakeSustain(object)
	local v

	if type(object) == "table" then
		v = object._camShakeInstance
	else
		v = false
	end

	assert(v, "ShakeInstance must be of type CameraShakeInstance")
	self._camShakeInstances[#self._camShakeInstances + 1] = object
	object:StartFadeIn(object.fadeInDuration)
	return object
end

function CameraShake:StopSustained(p2)
	for _, _camShakeInstance in pairs(self._camShakeInstances) do
		if _camShakeInstance.fadeOutDuration == 0 then
			_camShakeInstance:StartFadeOut(p2 or _camShakeInstance.fadeInDuration)
		end
	end
end

function CameraShake:ShakeOnce(p2, p3, p4, p5, p6, p7)
	local v = CameraShakeInstance.new(p2, p3, p4, p5)
	v.PositionInfluence = typeof(p6) == "Vector3" and p6 or createVector(0.15, 0.15, 0.15)
	v.RotationInfluence = typeof(p7) == "Vector3" and p7 or createVector(1, 1, 1)
	self._camShakeInstances[#self._camShakeInstances + 1] = v
	return v
end

function CameraShake:StartShake(p2, p3, p4, p5, p6)
	local v = CameraShakeInstance.new(p2, p3, p4)
	v.PositionInfluence = typeof(p5) == "Vector3" and p5 or createVector(0.15, 0.15, 0.15)
	v.RotationInfluence = typeof(p6) == "Vector3" and p6 or createVector(1, 1, 1)
	v:StartFadeIn(p4)
	self._camShakeInstances[#self._camShakeInstances + 1] = v
	return v
end

return CameraShake