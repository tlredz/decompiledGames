local createVector = vector.create
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("t"))
local CameraShakeInstance = require(script.CameraShakeInstance)
local CameraShakePresets = require(script.CameraShakePresets)
local profilebegin = debug.profilebegin
local profileend = debug.profileend
local count = 0
local new2 = CFrame.new
local angles = CFrame.Angles
local rad = math.rad
local vector2 = Vector3.new()
local cameraShakeState = CameraShakeInstance.CameraShakeState
local value = Enum.RenderPriority.Last.Value
local currentCamera = workspace.CurrentCamera
local CameraShaker = {}
CameraShaker.__index = CameraShaker
CameraShaker.CameraShakeInstance = CameraShakeInstance
CameraShaker.Presets = CameraShakePresets

local function defaultCallback(cframe: CFrame)
	currentCamera.CFrame *= cframe
end

function CameraShaker.new(p: number?, callback, flag: boolean?)
	t.strict(t.optional(t.number))(p)
	t.strict(t.optional(t.callback))(callback)
	return (setmetatable({
		_running = false,
		_renderName = CameraShaker.NextRenderName(),
		_renderPriority = p or value,
		_posAddShake = vector2,
		_rotAddShake = vector2,
		_camShakeInstances = {},
		_removeInstances = {},
		_callback = callback or defaultCallback,
		_optimizeDrift = flag or false,
		_driftConn = nil,
		_renderBindings = {},
		_renderDriftConnections = {}
	}, CameraShaker))
end

function CameraShaker.NextRenderName()
	count += 1
	return ("__shake_%.4i__"):format(count)
end

function CameraShaker:Start(p: string?)
	if self._running then
		return
	end

	t.strict(t.optional(t.string))(p)
	self._running = true
	local v = p or self._renderName
	local _callback = self._callback
	local cFrame = nil
	RunService:BindToRenderStep(v, self._renderPriority, function(p2: number)
		cFrame = currentCamera.CFrame
		profilebegin("CameraShakerUpdate")
		local v2 = self:Update(p2)
		profileend()
		_callback(v2)
	end)
	self._renderBindings[v] = true

	if not self._optimizeDrift then
		return
	end

	self._renderDriftConnections[v] = RunService.Heartbeat:Connect(function()
		if not cFrame then
			return
		end

		currentCamera.CFrame = cFrame
	end)
end

function CameraShaker:StopByRenderName(p2: string)
	t.strict(t.string)(p2)
	assert(self._renderBindings[p2], (`Attempt to remove an unBinded render name: "{p2}"`))
	local _renderDriftConnection = self._renderDriftConnections[p2]

	if _renderDriftConnection then
		_renderDriftConnection:Disconnect()
		self._renderDriftConnections[p2] = nil
	end

	self._renderBindings[p2] = nil
	RunService:UnbindFromRenderStep(p2)
end

function CameraShaker:Stop()
	if not self._running then
		return
	end

	self._running = false

	for k in self._renderBindings do
		self:StopByRenderName(k)
	end
end

function CameraShaker:StopSustained(p2: number)
	for _, _camShakeInstance in pairs(self._camShakeInstances) do
		if _camShakeInstance.fadeOutDuration == 0 then
			_camShakeInstance:StartFadeOut(p2 or _camShakeInstance.fadeInDuration)
		end
	end
end

function CameraShaker:Update(p2: number)
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

function CameraShaker:Shake(p2)
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

function CameraShaker:ShakeFromPresetName(p)
	t.strict(t.string)(p)
	return self:Shake(CameraShakePresets[p])
end

function CameraShaker:ShakeSustain(object)
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

function CameraShaker:ShakeOnce(p2: number, p3: number, p4: number?, p5: number?, vector3: Vector3?, vector4: Vector3?)
	local v = CameraShakeInstance.new(p2, p3, p4, p5)
	v.PositionInfluence = typeof(vector3) == "Vector3" and vector3 or createVector(0.15, 0.15, 0.15)
	v.RotationInfluence = typeof(vector4) == "Vector3" and vector4 or createVector(1, 1, 1)
	self._camShakeInstances[#self._camShakeInstances + 1] = v
	return v
end

function CameraShaker:StartShake(p2: number, p3: number, p4: number, vector3: Vector3?, vector4: Vector3?)
	local v = CameraShakeInstance.new(p2, p3, p4)
	v.PositionInfluence = typeof(vector3) == "Vector3" and vector3 or createVector(0.15, 0.15, 0.15)
	v.RotationInfluence = typeof(vector4) == "Vector3" and vector4 or createVector(1, 1, 1)
	v:StartFadeIn(p4)
	self._camShakeInstances[#self._camShakeInstances + 1] = v
	return v
end

return CameraShaker