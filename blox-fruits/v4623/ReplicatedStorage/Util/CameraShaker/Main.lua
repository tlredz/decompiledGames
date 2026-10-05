local createVector = vector.create
local Main = {}
Main.__index = Main
local profilebegin = debug.profilebegin
local profileend = debug.profileend
local new2 = CFrame.new
local angles = CFrame.Angles
local rad = math.rad
local vector2 = Vector3.new()
local CameraShakeInstance = require(script.CameraShakeInstance)
local cameraShakeState = CameraShakeInstance.CameraShakeState
Main.CameraShakeInstance = CameraShakeInstance
Main.Presets = require(script.CameraShakePresets)

function Main.new(renderPriority, callback)
	assert(type(renderPriority) == "number", "RenderPriority must be a number (e.g.: Enum.RenderPriority.Camera.Value)")
	assert(type(callback) == "function", "Callback must be a function")
	local HttpService = game:GetService("HttpService")
	local v = {
		_running = false,
		_renderName = "CameraShaker_" .. HttpService:GenerateGUID(false),
		_renderPriority = renderPriority,
		_posAddShake = vector2,
		_rotAddShake = vector2,
		_camShakeInstances = {},
		_removeInstances = {},
		_callback = callback
	}
	return (setmetatable(v, Main))
end

function Main:Start()
	if self._running then
		return
	end

	self._running = true
	local _callback = self._callback
	local RunService = game:GetService("RunService")
	RunService:BindToRenderStep(self._renderName, self._renderPriority, function(p)
		profilebegin("CameraShakerUpdate")
		local success, result = pcall(self.Update, self, p)
		profileend()

		if success then
			_callback(result)
		else
			warn("[CAMERA SHAKER]", result)
		end
	end)
end

function Main:Stop()
	if not self._running then
		return
	end

	local RunService = game:GetService("RunService")
	RunService:UnbindFromRenderStep(self._renderName)
	self._running = false
end

function Main:StopSustained(p2)
	for _, _camShakeInstance in pairs(self._camShakeInstances) do
		if _camShakeInstance.fadeOutDuration == 0 then
			_camShakeInstance:StartFadeOut((math.max(p2 or _camShakeInstance.fadeInDuration or 0, 0.008333333333333333)))
		end
	end
end

function Main:Update(p2: number)
	local v = vector2
	local v2 = vector2
	local _camShakeInstances = self._camShakeInstances
	local currentCamera = workspace.CurrentCamera
	local viewportSize

	if currentCamera then
		viewportSize = currentCamera.ViewportSize
	else
		viewportSize = Vector2.new(1920, 1080)
	end

	local v3 = math.clamp(viewportSize.Magnitude / 1000, 0.33, 1)
	local v4 = not (viewportSize.Y > 0) and 1 or math.clamp(2 - viewportSize.X / viewportSize.Y / 1.9, 0.5, 1)

	for i = 1, #_camShakeInstances do
		local _camShakeInstance = _camShakeInstances[i]
		local state = _camShakeInstance:GetState()

		if state == cameraShakeState.Inactive and _camShakeInstance.DeleteOnInactive then
			self._removeInstances[#self._removeInstances + 1] = i
		elseif state ~= cameraShakeState.Inactive then
			local v5 = _camShakeInstance:UpdateShake(p2)
			v += v5 * _camShakeInstance.PositionInfluence * v3
			v2 += v5 * _camShakeInstance.RotationInfluence * v4
		end
	end

	for i = #self._removeInstances, 1, -1 do
		local _removeInstance = self._removeInstances[i]
		table.remove(_camShakeInstances, _removeInstance)
		self._removeInstances[i] = nil
	end

	return new2(v) * angles(0, rad(v2.Y), 0) * angles(rad(v2.X), 0, (rad(v2.Z)))
end

function Main:Shake(value, value2)
	if typeof(value) == "string" then
		value = Main.Presets[value]
	end

	local v = value2 or 1
	local v2

	if type(value) == "table" then
		v2 = value._camShakeInstance
	else
		v2 = false
	end

	assert(v2, "ShakeInstance must be of type CameraShakeInstance")
	value.Magnitude *= v
	value.Roughness *= v
	value.fadeOutDuration *= v
	value.fadeInDuration *= v
	self._camShakeInstances[#self._camShakeInstances + 1] = value
	return value
end

function Main:ShakeSustain(object, value)
	local v = value or 1
	local v2

	if type(object) == "table" then
		v2 = object._camShakeInstance
	else
		v2 = false
	end

	assert(v2, "ShakeInstance must be of type CameraShakeInstance")
	object.Magnitude *= v
	object.Roughness *= v
	object.fadeOutDuration *= v
	object.fadeInDuration *= v
	self._camShakeInstances[#self._camShakeInstances + 1] = object
	object:StartFadeIn(object.fadeInDuration)
	return object
end

function Main:ShakeOnce(p2, p3, p4, p5, p6, p7, value)
	local v = value or 1
	local v2 = CameraShakeInstance.new(p2 * v, p3 * v, p4 * v, p5 * v)
	v2.PositionInfluence = typeof(p6) == "Vector3" and p6 or createVector(0.15, 0.15, 0.15)
	v2.RotationInfluence = typeof(p7) == "Vector3" and p7 or createVector(1, 1, 1)
	self._camShakeInstances[#self._camShakeInstances + 1] = v2
	return v2
end

function Main:StartShake(p2, p3, p4, p5, p6, value)
	local v = value or 1
	local v2 = CameraShakeInstance.new(p2 * v, p3 * v, p4 * v)
	v2.PositionInfluence = typeof(p5) == "Vector3" and p5 or createVector(0.15, 0.15, 0.15)
	v2.RotationInfluence = typeof(p6) == "Vector3" and p6 or createVector(1, 1, 1)
	v2:StartFadeIn(p4)
	self._camShakeInstances[#self._camShakeInstances + 1] = v2
	return v2
end

return Main