local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Signal = require(ReplicatedStorage.Packages.Signal)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local CameraShakeController = require(ReplicatedStorage.Modules.Client.PlayerController.CameraShakeController)
local FreeCamController = require(ReplicatedStorage.Modules.Client.PlayerController.FreeCamController)
local VehicleBoostConstants = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleBoostConstants)
local v = Component.new({
	Tag = "VehicleBoostLines"
})
local v2 = nil
local flag = false
local v3 = Signal.new()

function v.CalculateEffectFactor(p: number, p2: number)
	if p < VehicleBoostConstants.EFFECT_CHANGE_START_SPEED then
		return 0
	end

	local v4 = VehicleBoostConstants.EFFECT_CHANGE_END_SPEED - VehicleBoostConstants.EFFECT_CHANGE_START_SPEED
	return math.clamp((p - VehicleBoostConstants.EFFECT_CHANGE_START_SPEED) / v4, 0, 1) * p2 * VehicleBoostConstants.EFFECT_SPEED_FRACTION + p2 * (1 - VehicleBoostConstants.EFFECT_SPEED_FRACTION)
end

function v.GetShared()
	if v2 ~= nil then
		return v2
	end

	if flag then
		v3:Wait()
		return v2
	end

	flag = true
	local clone = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Particles"):WaitForChild("BoostParticles"):Clone()
	clone.Parent = workspace.CurrentCamera
	clone:AddTag(v.Tag)
	v2 = ComponentUtil.GetComponentFromInstance(clone, v)
	flag = false
	v3:Fire()
	return v2
end

function v:Construct()
	self._sources = {}
	self._cameraShakeInstance = nil
	self._cameraShakeFadeOutTask = nil
	self._aimDirection = nil
	self._isEmitting = nil
end

function v:Start()
	self.camera = workspace.CurrentCamera
	self.emitter = self.Instance:FindFirstChild("ParticleEmitter")
	self:SetEmitting(false)
end

function v:SetSourceIntensity(p2, intensity: number, vehicle)
	if intensity <= 0 then
		self._sources[p2] = nil
	else
		self._sources[p2] = {
			intensity = intensity,
			vehicle = vehicle
		}
	end
end

function v:TriggerCameraShake()
	if FreeCamController.IsFreecamEnabled() then
		return
	end

	if self._cameraShakeFadeOutTask ~= nil then
		task.cancel(self._cameraShakeFadeOutTask)
		self._cameraShakeFadeOutTask = nil
	end

	if self._cameraShakeInstance == nil then
		self._cameraShakeInstance = CameraShakeController.CamShake:StartShake(
			VehicleBoostConstants.CAMERA_SHAKE_MAGNITUDE,
			VehicleBoostConstants.CAMERA_SHAKE_ROUGHNESS,
			VehicleBoostConstants.CAMERA_SHAKE_FADE_IN,
			VehicleBoostConstants.CAMERA_SHAKE_POSITION_INFLUENCE,
			VehicleBoostConstants.CAMERA_SHAKE_ROTATION_INFLUENCE
		)
	end

	self._cameraShakeFadeOutTask = task.delay(VehicleBoostConstants.CAMERA_SHAKE_DURATION, function()
		self._cameraShakeFadeOutTask = nil
		self:StopCameraShake()
	end)
end

function v:StopCameraShake()
	if self._cameraShakeFadeOutTask ~= nil then
		task.cancel(self._cameraShakeFadeOutTask)
		self._cameraShakeFadeOutTask = nil
	end

	if self._cameraShakeInstance == nil then
		return
	end

	self._cameraShakeInstance:StartFadeOut(VehicleBoostConstants.CAMERA_SHAKE_FADE_OUT)
	self._cameraShakeInstance = nil
end

function v:SetEmitting(flag2: boolean)
	if flag2 == self._isEmitting then
		return
	end

	self._isEmitting = flag2
	self.emitter.Enabled = flag2

	if not flag2 then
		self.emitter.Rate = 0
		self.emitter:Clear()
	end
end

function v:UpdateAim(instance, p2: number)
	if instance == nil or instance.PrimaryPart == nil then
		return self._aimDirection
	end

	local assemblyLinearVelocity = instance.PrimaryPart.AssemblyLinearVelocity
	local vector = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)

	if vector.Magnitude < 1 then
		return self._aimDirection
	end

	local unit = vector.Unit
	local _aimDirection = self._aimDirection

	if _aimDirection == nil then
		self._aimDirection = unit
		return unit
	end

	local lerped = _aimDirection:Lerp(unit, 1 - math.exp(-p2 * VehicleBoostConstants.AIM_SMOOTHING))

	if not (lerped.Magnitude < 0.001) then
		unit = lerped.Unit
	end

	self._aimDirection = unit
	return self._aimDirection
end

function v:IsFastEnough(instance)
	if instance == nil or instance.PrimaryPart == nil then
		return true
	end

	local assemblyLinearVelocity = instance.PrimaryPart.AssemblyLinearVelocity
	local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude
	local v4

	if self._isEmitting == true then
		v4 = VehicleBoostConstants.MIN_EMISSION_SPEED_EXIT
	else
		v4 = VehicleBoostConstants.MIN_EMISSION_SPEED
	end

	return v4 <= magnitude
end

function v:SteppedUpdate(p: number)
	if FreeCamController.IsFreecamEnabled() then
		self:SetEmitting(false)
		self:StopCameraShake()
	else
		local intensity = 0
		local vehicle = nil

		for _, _source in self._sources do
			if not (intensity < _source.intensity) then
				continue
			end

			intensity = _source.intensity
			vehicle = _source.vehicle
		end

		local v4 = self:UpdateAim(vehicle, p)

		if intensity <= 0 or not self:IsFastEnough(vehicle) then
			self:SetEmitting(false)
			return
		end

		self:SetEmitting(true)
		self.emitter.Rate = VehicleBoostConstants.MAX_PARTICLE_RATE * intensity
		local instance = self.Instance
		local position = (self.camera.CFrame * CFrame.new(VehicleBoostConstants.PARTICLE_OFFSET)).Position

		if v4 == nil then
			instance.CFrame = CFrame.new(position)
		else
			instance.CFrame = CFrame.lookAt(position, position + v4)
		end
	end
end

function v:Stop()
	self:SetEmitting(false)
	self:StopCameraShake()
end

return v