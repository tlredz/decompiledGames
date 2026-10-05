local Players = game:GetService("Players")
local Gun = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
local object = setmetatable({}, Gun)
object.__index = object

function object.new(...)
	local self = setmetatable(Gun.new(...), object)
	self._charging_move_speed_hash = 0
	self:_Init()
	return self
end

function object.CanQuickAttack(_)
	return false
end

function object:_UpdateChargingMoveSpeed()
	if not self.ClientFighter.IsLocalPlayer then
		return
	end

	self._charging_move_speed_hash += 1
	local _charging_move_speed_hash = self._charging_move_speed_hash

	repeat
		self.ClientFighter.Entity:SetBoost(
			"Speed",
			"MinigunCharge",
			0.5,
			self.IsEquipped and self:Get("IsAiming") and self.Info.ChargingSpeedBoost or 0
		)
		wait(0.25)
	until self._destroyed or _charging_move_speed_hash ~= self._charging_move_speed_hash or not (self.ClientFighter:IsAlive() and self.IsEquipped)
end

function object:_Init()
	self:GetDataChangedSignal("IsAiming"):Connect(function()
		self:_UpdateChargingMoveSpeed()
	end)
	self.EquippedChanged:Connect(function()
		self:_UpdateChargingMoveSpeed()
	end)
end

return object