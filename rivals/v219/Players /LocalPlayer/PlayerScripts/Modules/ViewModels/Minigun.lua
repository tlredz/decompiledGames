local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("CameraController"))
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self.IsChargingMinigun = false
	self.IsWindingMinigun = false
	self._active_shooting_finish = 0
	self._last_winding_sounds = nil
	self._last_shooting_sounds = nil
	self._last_ammo_belt_count = 20
	self._ammo_belt_models = {}
	self:_Init()
	return self
end

function object:StartChargingMinigun()
	self._active_shooting_finish = tick() + math.max(0.1, CameraController:GetLastHeartbeatDeltaTime() * 3)
	self:_ChargeLoop(true)
end

function object.Unequip(object2, ...)
	object2:StopAnimation("ChargeStart")
	object2:StopAnimation("ChargeLoop")
	object2:StopAnimation("ChargeFinish", nil, 0)
	ClientViewModel.Unequip(object2, ...)
end

function object:_CreateMinigunShootingSounds()
	local sound = self:CreateSound("rbxassetid://17246880027", 8.75, 1, true)
	sound.TimePosition = 0.25 + 0.25 * math.random()
	sound.Looped = true
	return { sound }
end

function object:_CreateMinigunWindingSounds()
	local sound = self:CreateSound("rbxassetid://17251084003", 0.5, 1, true)
	sound.TimePosition = 2
	sound.Looped = true
	return { sound }
end

function object:_UpdateAmmoBelt()
	local ammo = self.ClientItem:Get("Ammo")

	if self._last_ammo_belt_count == ammo then
		return
	end

	self._last_ammo_belt_count = ammo

	for k, _ammo_belt_model in pairs(self._ammo_belt_models) do
		for _, v in pairs(_ammo_belt_model) do
			self:_LocalTransparencyModifier(v, "AmmoVisual", self._last_ammo_belt_count < k and 1 or 0)
		end
	end
end

function object:_ChargeLoop(p)
	if self.IsChargingMinigun then
		return
	end

	self.IsChargingMinigun = true
	self:StopAnimation("ChargeFinish")
	local _CreateMinigunWindingSounds = self:_CreateMinigunWindingSounds()
	local v = {}

	for _, _CreateMinigunWindingSound in pairs(_CreateMinigunWindingSounds) do
		v[_CreateMinigunWindingSound] = {
			Volume = _CreateMinigunWindingSound.Volume,
			PlaybackSpeed = _CreateMinigunWindingSound.PlaybackSpeed
		}
		_CreateMinigunWindingSound.Volume = 0
	end

	if self._last_winding_sounds then
		for _, _last_winding_sound in pairs(self._last_winding_sounds) do
			_last_winding_sound:Destroy()
		end
	end

	self._last_winding_sounds = _CreateMinigunWindingSounds

	if p then
		local chargingWindUpLength = self.ClientItem.Info.ChargingWindUpLength
		local v2 = tick() + chargingWindUpLength
		self:PlayAnimation("ChargeStart", AnimationLibrary.Info[self.Info.Animations.ChargeStart].Length)
		self.IsWindingMinigun = true

		while not self._destroyed and self._is_equipped and tick() < v2 and (tick() < self._active_shooting_finish or self.ClientItem:Get("IsAiming")) do
			local v3 = math.clamp((chargingWindUpLength - (v2 - tick())) / chargingWindUpLength, 0, 1)

			for _, _CreateMinigunWindingSound in pairs(_CreateMinigunWindingSounds) do
				_CreateMinigunWindingSound.Volume = v[_CreateMinigunWindingSound].Volume * v3
				_CreateMinigunWindingSound.PlaybackSpeed = v[_CreateMinigunWindingSound].PlaybackSpeed * (v3 * 1.5 + 1)
			end

			RunService.RenderStepped:Wait()
		end

		self.IsWindingMinigun = false
	end

	for i = 1, 1e999 do
		if self._destroyed or not self._is_equipped or tick() > self._active_shooting_finish and not self.ClientItem:Get("IsAiming") then
			break
		end

		if i == 1 then
			self:PlayAnimation("ChargeLoop", 1e999)

			for _, _CreateMinigunWindingSound in pairs(_CreateMinigunWindingSounds) do
				_CreateMinigunWindingSound.Volume = v[_CreateMinigunWindingSound].Volume
				_CreateMinigunWindingSound.PlaybackSpeed = v[_CreateMinigunWindingSound].PlaybackSpeed * 2.5
			end
		end

		RunService.RenderStepped:Wait()
	end

	self.IsChargingMinigun = false
	self:StopAnimation("ChargeStart")
	self:StopAnimation("ChargeLoop")

	if self._is_equipped then
		self:PlayAnimation("ChargeFinish", AnimationLibrary.Info[self.Info.Animations.ChargeFinish].Length)
	end

	local v2 = {}

	for _, _CreateMinigunWindingSound in pairs(_CreateMinigunWindingSounds) do
		v2[_CreateMinigunWindingSound] = {
			Volume = _CreateMinigunWindingSound.Volume,
			PlaybackSpeed = _CreateMinigunWindingSound.PlaybackSpeed
		}
	end

	Utility:RenderstepForLoop(0, 100, 1.5, function(p2)
		local v3 = p2 / 100

		for _, _CreateMinigunWindingSound in pairs(_CreateMinigunWindingSounds) do
			_CreateMinigunWindingSound.Volume = v2[_CreateMinigunWindingSound].Volume + (0 - v2[_CreateMinigunWindingSound].Volume) * (1 - (1 - v3) ^ 4)
			_CreateMinigunWindingSound.PlaybackSpeed = v2[_CreateMinigunWindingSound].PlaybackSpeed + (1 - v2[_CreateMinigunWindingSound].PlaybackSpeed) * v3
		end
	end)

	for _, _CreateMinigunWindingSound in pairs(_CreateMinigunWindingSounds) do
		_CreateMinigunWindingSound:Destroy()
	end
end

function object:_Setup()
	local _ammo_belt = self.ItemModel:FindFirstChild("_ammo_belt", true)

	if _ammo_belt then
		for i = 1, 20 do
			local child = _ammo_belt:WaitForChild(i)
			self._ammo_belt_models[i] = { child:FindFirstChild("Shell"), child:FindFirstChild("Strap") }
		end
	end

	task.defer(function()
		self.ClientItem.Shot:Connect(function()
			self._active_shooting_finish = tick() + 0.1

			if not self._last_shooting_sounds then
				self._last_shooting_sounds = self:_CreateMinigunShootingSounds()
				task.spawn(function()
					while not self._destroyed and tick() < self._active_shooting_finish do
						RunService.RenderStepped:Wait()
					end

					for _, _last_shooting_sound in pairs(self._last_shooting_sounds) do
						_last_shooting_sound:Destroy()
					end

					self._last_shooting_sounds = nil
				end)
			end

			self:_ChargeLoop()
		end)
	end)
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("IsAiming"):Connect(function(p)
		if p then
			self:_ChargeLoop(true)
		end
	end)
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateAmmoBelt()
	end)
	self:_Setup()
	self:_UpdateAmmoBelt()
end

return object