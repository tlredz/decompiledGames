local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local Custom = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Custom)
local object = setmetatable({}, Custom)
object.__index = object

function object.new(...)
	local self = setmetatable(Custom.new(...), object)
	self.Airblasted = Signal.new()
	self._is_using = false
	self._use_cooldown = 0
	self._airblast_cooldown = 0
	self:_Init()
	return self
end

function object.GetAutoShootReactionTime(_)
	return 0
end

function object.GetAutoShootReach(p)
	return p.Info.Reach
end

function object:CanQuickAttack()
	return tick() > self._airblast_cooldown and not self:IsEquipping()
end

function object:StartShooting(p)
	if not p and (self._is_using or tick() < self._use_cooldown or self:Get("Ammo") <= 0 or self:IsEquipping()) then
		return false
	end

	self._is_using = true
	self._use_cooldown = tick() + self.Info.InternalUseCooldown
	self.ViewModel:SetFlameParticlesEnabled(true)
	self.ViewModel:SetCustomSprintingEnabled(1e999)

	if self.ViewModel.Info.Animations.Using then
		self.ViewModel:PlayAnimation("Using")
	end

	return true, "StartShooting"
end

function object:FinishShooting(p)
	if p or self._is_using then
		self:_StopUsing()
		return true, "FinishShooting"
	else
		return false
	end
end

function object:StartAiming(p)
	if not p and (tick() < self._airblast_cooldown or self:IsEquipping()) then
		return false
	end

	self._airblast_cooldown = tick() + self.Info.AirblastCooldown
	self.Airblasted:Fire()
	self:CooldownEffect("rbxassetid://16828140099", self.Info.AirblastCooldown, "Airblast")
	self.ViewModel:Impulse(createVector(0, 0, 30), 0.5)
	self.ViewModel:StopAnimation("Inspect")
	self.ViewModel:SetCustomSprintingEnabled(not self._is_using and 0.5 or nil, true)
	self:_Recoil(2)

	if self:Get("QuickAttackQueued") then
		task.delay(0.1, function()
			self.ViewModel:AirblastEffect()
		end)
	else
		self.ViewModel:AirblastEffect()
	end

	local cameraData = self.ClientFighter:GetCameraData()

	if self.ClientFighter.IsLocalPlayer then
		self.ClientFighter.Entity.RootPart.Velocity = self.ClientFighter.Entity.RootPart.Velocity * createVector(
			1,
			0,
			1
		) + Vector3.new(0, math.max(0, self.ClientFighter.Entity.RootPart.Velocity.Y), 0) + Utility:DecodeCFrame(cameraData[utf8.char(0)]).LookVector * createVector(
			0,
			1,
			0
		) * -25 * self.Info.AirblastRecoilKnockback
	end

	return true, "StartAiming", cameraData
end

function object:Equip(...)
	Custom.Equip(self, ...)
	self:_StopUsing()
end

function object:Unequip(...)
	self:_StopUsing()
	Custom.Unequip(self, ...)
end

function object:ReplicateFromServer(p, ...)
	if p == "StopUsing" then
		self:_StopUsing()
	else
		Custom.ReplicateFromServer(self, p, ...)
	end
end

function object:Destroy()
	self.Airblasted:Destroy()
	self:_StopUsing()
	Custom.Destroy(self)
end

function object:_StopUsing()
	if not self._is_using then
		return
	end

	self._is_using = false
	self.ViewModel:SetFlameParticlesEnabled(false)
	self.ViewModel:SetCustomSprintingEnabled(0)

	if self.ViewModel.Info.Animations.Using then
		self.ViewModel:StopAnimation("Using")
	end
end

function object:_Init()
	table.insert(self._connections, self.ClientFighter.Interrupted:Connect(function()
		self:_StopUsing()
	end))
end

return object