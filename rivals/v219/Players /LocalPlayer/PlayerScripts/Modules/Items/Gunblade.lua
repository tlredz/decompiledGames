local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
require(ReplicatedStorage.Modules.BetterDebris)
local Gun = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
local object = setmetatable({}, Gun)
object.__index = object

function object.new(...)
	local self = setmetatable(Gun.new(...), object)
	self.ToggleAimEnabled = nil
	self._transition_cooldown = 0
	self._blade_cooldown = 0
	self._blade_attack_num = 0
	self._last_blade_animation_name = nil
	self._dash_cooldown = 0
	self._fov_offset_speed = 1
	self._blade_critical_hit_hash = 0
	self._transition_animation_playing = 0
	self:_Init()
	return self
end

function object:CanQuickAttack()
	local v

	if not (tick() > self._transition_cooldown) then
		v = false
		return false
	end

	if self:Get("Mode") == "Gun" then
		return (Gun.CanQuickAttack(self))
	end

	return tick() > self._blade_cooldown and not self:IsEquipping()
end

function object.GetAutoShootReactionTime(object2)
	if object2:Get("Mode") == "Blade" then
		return 0
	end

	return (Gun.GetAutoShootReactionTime(object2))
end

function object.GetAutoShootReach(object2)
	if object2:Get("Mode") == "Blade" then
		return object2.Info.BladeReach
	end

	return (Gun.GetAutoShootReach(object2))
end

function object:GetAimSpeed()
	return self._fov_offset_speed
end

function object.GetMobileInputSettings(object2)
	if object2:Get("Mode") == "Blade" then
		return object2.Info.BladeModeMobileInputSettings
	end

	return (Gun.GetMobileInputSettings(object2))
end

function object:StartShooting(p, p2, ...)
	local v = p2 or self:Get("Mode")

	if not p and (tick() < self._transition_cooldown or self:IsEquipping()) then
		return false
	end

	self.ViewModel:StopAnimation("To" .. v)

	if v == "Gun" then
		return Gun.StartShooting(self, p, ...)
	elseif v == "Blade" then
		return self:_StartShootingBladeMode(p, ...)
	end

	return false
end

function object:StartAiming(p, p2, ...)
	local v = p2 or self:Get("Mode")

	if not p and (v == "Gun" and tick() < self._transition_cooldown or self:IsEquipping()) then
		return false
	end

	self.ViewModel:StopAnimation("To" .. v)

	if v == "Gun" then
		return Gun.StartAiming(self, p, ...)
	elseif v == "Blade" then
		return self:_StartAimingBladeMode(p, ...)
	end

	return false
end

function object:ReplicateFromServer(p, ...)
	if p ~= "BladeCriticalHit" then
		Gun.ReplicateFromServer(self, p, ...)
		return
	end

	if not (self:IsRendered() and self.IsEquipped) then
		return
	end

	local v = ... and "BladeAttackOnHitNoAmmo" or "BladeAttackOnHit"
	self._blade_critical_hit_hash += 1
	local _blade_critical_hit_hash = self._blade_critical_hit_hash
	self._fov_offset_speed = 5
	self:SetReplicate("FOVOffset", -5)

	if self._last_blade_animation_name then
		self.ViewModel:StopAnimation(self._last_blade_animation_name)
	end

	self.ViewModel:PlayAnimation(v, nil, 0)
	wait(AnimationLibrary.Info[self.ViewModel.Info.Animations[v]].ActionTimestamp)

	if self._blade_critical_hit_hash ~= _blade_critical_hit_hash then
		return
	end

	self:SetReplicate("FOVOffset", 5)
	self:_Recoil(2)
	self.ViewModel:MuzzleFlash()
	wait(0.125)

	if self._blade_critical_hit_hash ~= _blade_critical_hit_hash then
		return
	end

	self._fov_offset_speed = 1
	self:SetReplicate("FOVOffset", 0)
end

function object:_StartShootingBladeMode(p)
	if not p and tick() < self._blade_cooldown then
		return false
	end

	self._blade_cooldown = tick() + self.Info.BladeCooldown

	if self._last_blade_animation_name then
		self.ViewModel:StopAnimation(self._last_blade_animation_name)
	end

	self._blade_attack_num = self._blade_attack_num % #self.ViewModel:GetAnimationKeys("BladeAttack") + 1
	self._last_blade_animation_name = "BladeAttack" .. self._blade_attack_num
	self.ViewModel:StopAnimation("Dash", 0)
	self.ViewModel:StopAnimation("BladeAttackOnHitNoAmmo")
	self.ViewModel:StopAnimation("BladeAttackOnHit")
	self.ViewModel:StopAnimation("BladeEquip")
	self.ViewModel:StopAnimation("Equip")
	self.ViewModel:PlayAnimation(self._last_blade_animation_name, self.Info.BladeCooldown)
	task.delay(0.1, function()
		self:_Shake("Bump")
	end)
	local cameraData, v = self.ClientFighter:GetCameraData()

	if self.ClientFighter.IsLocalPlayer then
		self:_ImpactMarkerSlash(self.Info.BladeReach, cameraData, v)
	end

	return true, "StartShooting", cameraData
end

function object:_StartAimingBladeMode(p)
	if not p and tick() < self._dash_cooldown then
		return false
	end

	self._dash_cooldown = tick() + self.Info.DashCooldown
	self:CooldownEffect("rbxassetid://16828140099", self.Info.DashCooldown, "Dash")

	if not p then
		local v = self.ClientFighter:GetMoveVector(true, false, workspace.CurrentCamera.CFrame.LookVector) * self.Info.DashSpeed
		self.ClientFighter.Entity:HardDash(v, self.Info.DashDuration)
	end

	self:CreateSound("rbxassetid://16492958314", 1, 1 + 0.1 * math.random(), true)

	if self.ItemInterface then
		self.ItemInterface:PlaySpeedLines(self.Info.DashDuration)
	end

	if not self.ViewModel:GetAnimationTrack("Dash") then
		return true, "StartAiming"
	end

	if self._last_attack_animation_name then
		self.ViewModel:StopAnimation(self._last_attack_animation_name)
	end

	if self._last_blade_animation_name then
		self.ViewModel:StopAnimation(self._last_blade_animation_name)
	end

	self.ViewModel:StopAnimation("BladeAttackOnHitNoAmmo")
	self.ViewModel:StopAnimation("BladeAttackOnHit")
	self.ViewModel:StopAnimation("BladeEquip")
	self.ViewModel:StopAnimation("Equip")
	self.ViewModel:PlayAnimation("Dash")
	return true, "StartAiming"
end

function object:_ModeChanged(p)
	if self._last_shoot_animation_name then
		self.ViewModel:StopAnimation(self._last_shoot_animation_name)
	end

	if self._last_blade_animation_name then
		self.ViewModel:StopAnimation(self._last_blade_animation_name)
	end

	local mode = self:Get("Mode")
	local v = mode == "Blade" and "Blade" or ""
	self.ViewModel:ChangeEquipAnimation(v .. "Equip")
	self.ViewModel:ChangeIdleAnimation(v .. "Idle")
	self.ViewModel:ChangeSprintAnimation(v .. "Sprint")
	self.ViewModel:ChangeInspectAnimation(v .. "Inspect")

	if not p then
		self.ViewModel:PlayAnimation("To" .. mode .. (mode ~= "Gun" and "" or self._blade_attack_num or ""))

		for _, v2 in pairs({ "Shoot", "BladeAttack" }) do
			for i = 1, #self.ViewModel:GetAnimationKeys(v2) do
				self.ViewModel.Animator:BlockAnimation(v2 .. i, 0.25)
			end
		end
	end

	self.ToggleAimEnabled = mode == "Gun"
end

function object:_Setup()
	function self._on_shoot_callback()
		self.ViewModel:StopAnimation("Dash", 0)
	end
end

function object:_Init()
	self.Shot:Connect(function()
		self.ViewModel:StopAnimation("BladeAttackOnHit")
		self.ViewModel:StopAnimation("BladeAttackOnHitNoAmmo")
	end)
	self:GetDataChangedSignal("Mode"):Connect(function()
		task.spawn(self.Input, self, "FinishAiming")
		self._blade_attack_num = self:Get("Mode") == "Blade" and 0 or self._blade_attack_num
		self._transition_cooldown = tick() + self.Info.TransitionCooldown - 0.1
		self:_ModeChanged()
		self.ToggleOffMobileInputButton:Fire("mobile_aim")
	end)
	self:_Setup()
	self:_ModeChanged(true)
end

return object