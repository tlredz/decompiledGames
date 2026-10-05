local createVector = vector.create
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local CameraShaker = {}
CameraShaker.__index = CameraShaker
local profilebegin = debug.profilebegin
local profileend = debug.profileend
local new2 = CFrame.new
local angles = CFrame.Angles
local rad = math.rad
local vector2 = Vector3.new()
local CameraShakeInstance = require(script.CameraShakeInstance)
local cameraShakeState = CameraShakeInstance.CameraShakeState
CameraShaker.CameraShakeInstance = CameraShakeInstance
CameraShaker.Presets = require(script.CameraShakePresets)

function CameraShaker.new(renderPriority, callback)
	assert(type(renderPriority) == "number", "RenderPriority must be a number (e.g.: Enum.RenderPriority.Camera.Value)")
	assert(type(callback) == "function", "Callback must be a function")
	return (setmetatable({
		_running = false,
		_renderName = "CameraShaker",
		_renderPriority = renderPriority,
		_posAddShake = vector2,
		_rotAddShake = vector2,
		_camShakeInstances = {},
		_removeInstances = {},
		_callback = callback
	}, CameraShaker))
end

function CameraShaker:Start()
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

function CameraShaker:Stop()
	if not self._running then
		return
	end

	local RunService = game:GetService("RunService")
	RunService:UnbindFromRenderStep(self._renderName)
	self._running = false
end

function CameraShaker:StopSustained(p2)
	for _, _camShakeInstance in pairs(self._camShakeInstances) do
		if _camShakeInstance.fadeOutDuration == 0 then
			_camShakeInstance:StartFadeOut(p2 or _camShakeInstance.fadeInDuration)
		end
	end
end

function CameraShaker:Update(p2)
	local v = p2 > 0.5 and 0.5 or p2
	local v2 = vector2
	local v3 = vector2
	local _camShakeInstances = self._camShakeInstances

	for i = 1, #_camShakeInstances do
		local _camShakeInstance = _camShakeInstances[i]
		local state = _camShakeInstance:GetState()

		if state == cameraShakeState.Inactive and _camShakeInstance.DeleteOnInactive then
			self._removeInstances[#self._removeInstances + 1] = i
		elseif state ~= cameraShakeState.Inactive then
			local v4 = _camShakeInstance:UpdateShake(v)
			v2 += v4 * _camShakeInstance.PositionInfluence
			v3 += v4 * _camShakeInstance.RotationInfluence
		end
	end

	for i = #self._removeInstances, 1, -1 do
		local _removeInstance = self._removeInstances[i]
		table.remove(_camShakeInstances, _removeInstance)
		self._removeInstances[i] = nil
	end

	return new2(v2) * angles(0, rad(v3.Y), 0) * angles(rad(v3.X), 0, (rad(v3.Z)))
end

local v = {
	StartFadeOut = function() end,
	StartFadeIn = function() end
}

function CameraShaker:Shake(p2)
	if not _G.Settings.ScreenShake then
		return v
	end

	local v2

	if type(p2) == "table" then
		v2 = p2._camShakeInstance
	else
		v2 = false
	end

	assert(v2, "ShakeInstance must be of type CameraShakeInstance")
	self._camShakeInstances[#self._camShakeInstances + 1] = p2
	return p2
end

function CameraShaker:ShakeSustain(object)
	if not _G.Settings.ScreenShake then
		return v
	end

	local v2

	if type(object) == "table" then
		v2 = object._camShakeInstance
	else
		v2 = false
	end

	assert(v2, "ShakeInstance must be of type CameraShakeInstance")
	self._camShakeInstances[#self._camShakeInstances + 1] = object
	object:StartFadeIn(object.fadeInDuration)
	return object
end

function CameraShaker:ShakeOnce(p2, p3, p4, p5, p6, p7)
	if not _G.Settings.ScreenShake then
		return v
	end

	local v2 = CameraShakeInstance.new(p2, p3, p4, p5)
	v2.PositionInfluence = typeof(p6) == "Vector3" and p6 or createVector(0.15, 0.15, 0.15)
	v2.RotationInfluence = typeof(p7) == "Vector3" and p7 or createVector(1, 1, 1)
	self._camShakeInstances[#self._camShakeInstances + 1] = v2
	return v2
end

function CameraShaker:StartShake(p2, p3, p4, p5, p6)
	if not _G.Settings.ScreenShake then
		return v
	end

	local v2 = CameraShakeInstance.new(p2, p3, p4)
	v2.PositionInfluence = typeof(p5) == "Vector3" and p5 or createVector(0.15, 0.15, 0.15)
	v2.RotationInfluence = typeof(p6) == "Vector3" and p6 or createVector(1, 1, 1)
	v2:StartFadeIn(p4)
	self._camShakeInstances[#self._camShakeInstances + 1] = v2
	return v2
end

local currentShaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(p)
	workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * p
end)
currentShaker:Start()
CameraShaker.CurrentShaker = currentShaker
return CameraShaker