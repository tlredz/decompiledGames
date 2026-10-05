local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local ClientHumanoidEntity = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity.ClientHumanoidEntity)
local State = {}
State.__index = State

function State.new(clientFighterCharacter)
	local self = setmetatable({}, State)
	self.ClientFighterCharacter = clientFighterCharacter
	self._last_is_alive_check = nil
	self._last_is_grounded_check = nil
	self._is_grounded_time = nil
	self:_Init()
	return self
end

function State:IsAliveCached()
	local _ = self._last_is_alive_check == nil
	local last_is_alive_check = self.ClientFighterCharacter.Head and ClientHumanoidEntity.IsAlive(self.ClientFighterCharacter)
	self._last_is_alive_check = last_is_alive_check
	return last_is_alive_check
end

function State:IsGroundedCached()
	if self._last_is_grounded_check ~= nil then
		return self._last_is_grounded_check
	end

	if not self.ClientFighterCharacter:IsAlive() then
		self._last_is_grounded_check = false
		return false
	end

	local last_is_grounded_check = not self.ClientFighterCharacter:IsHumanoidStateAirborne()
	self._last_is_grounded_check = last_is_grounded_check
	return last_is_grounded_check
end

function State:Update(_, _)
	self._last_is_alive_check = nil
	self._last_is_grounded_check = nil
end

function State.Destroy(_) end

function State:_UpdateHumanoidStates()
	if not self.ClientFighterCharacter.Humanoid then
		return
	end

	local platformStand = self.ClientFighterCharacter:Get("IsFrozen") and true or false
	self.ClientFighterCharacter.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	self.ClientFighterCharacter.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	self.ClientFighterCharacter.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, platformStand)
	self.ClientFighterCharacter.Humanoid.PlatformStand = platformStand
end

function State:_Init()
	self.ClientFighterCharacter:GetDataChangedSignal("IsFrozen"):Connect(function()
		self:_UpdateHumanoidStates()
	end)
	self:_UpdateHumanoidStates()
end

return State