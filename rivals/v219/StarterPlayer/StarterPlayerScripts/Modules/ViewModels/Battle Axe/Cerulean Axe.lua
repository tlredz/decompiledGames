local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local BattleAxe = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Battle Axe"])
local object = setmetatable({}, BattleAxe)
object.__index = object

function object.new(...)
	local self = setmetatable(BattleAxe.new(...), object)
	self._equip_effect_hash = 0
	self._vfx_attachment = self.ItemModel:WaitForChild("Body"):WaitForChild("Gem"):WaitForChild("VFX")
	self._blade1 = self.ItemModel:WaitForChild("Body"):WaitForChild("Blade1")
	self._blade2 = self.ItemModel:WaitForChild("Body"):WaitForChild("Blade2")
	self:_Init()
	return self
end

function object:Unequip(...)
	self._equip_effect_hash += 1
	BattleAxe.Unequip(self, ...)
end

function object:Destroy()
	self._equip_effect_hash += 1
	BattleAxe.Destroy(self)
end

function object:_EquipEffect(p)
	self._equip_effect_hash += 1
	local _equip_effect_hash = self._equip_effect_hash
	self:_LocalTransparencyModifier(self._blade1, "EquipEffect", 1)
	self:_LocalTransparencyModifier(self._blade2, "EquipEffect", 1)

	if not p then
		wait(0.55)
	end

	if self._equip_effect_hash ~= _equip_effect_hash then
		return
	end

	Utility:PlayParticles(self._vfx_attachment)
	self:CreateSound("rbxassetid://117746175185603", 0.5, 0.5 + 0.125 * math.random(), true, 0.3)

	if not p then
		wait(0.3)
	end

	if self._equip_effect_hash ~= _equip_effect_hash then
		return
	end

	self:CreateSound("rbxassetid://75313977551180", 0.875, 1 + 0.2 * math.random(), true, 5)
	self:CreateSound("rbxassetid://107162559513589", 0.875, 1 + 0.2 * math.random(), true, 5)
	self:CreateSound("rbxassetid://115716079009988", 0.875, 1 + 0.2 * math.random(), true, 5)
	self:_LocalTransparencyModifier(self._blade1, "EquipEffect", 0)
	self:_LocalTransparencyModifier(self._blade2, "EquipEffect", 0)
end

function object:_Init()
	self.Equipped:Connect(function(p)
		self:_EquipEffect(p)
	end)
end

return object