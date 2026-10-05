local Players = game:GetService("Players")
local Katana = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Katana)
local object = setmetatable({}, Katana)
object.__index = object

function object.new(...)
	local self = setmetatable(Katana.new(...), object)
	self._equip_effect_hash = 0
	self._blade = self.ItemModel:WaitForChild("Body"):WaitForChild("Blade")
	self:_Init()
	return self
end

function object.PlayDeflectHitSounds(object2)
	object2:CreateSound("rbxassetid://17640978084", 1.75, 0.9 + 0.2 * math.random(), true, 5)
end

function object:Unequip(...)
	self._equip_effect_hash += 1
	Katana.Unequip(self, ...)
end

function object:Destroy()
	self._equip_effect_hash += 1
	Katana.Destroy(self)
end

function object:_EquipEffect(p)
	self._equip_effect_hash += 1
	local _equip_effect_hash = self._equip_effect_hash
	self:_LocalTransparencyModifier(self._blade, "EquipEffect", 1)

	if not p then
		wait(0.4)
	end

	if self._equip_effect_hash ~= _equip_effect_hash then
		return
	end

	self:CreateSound("rbxassetid://17641562119", 1.5, 1, true, 5)
	self:_LocalTransparencyModifier(self._blade, "EquipEffect", 0)
end

function object:_Init()
	self.Equipped:Connect(function(p)
		self:_EquipEffect(p)
	end)
end

return object