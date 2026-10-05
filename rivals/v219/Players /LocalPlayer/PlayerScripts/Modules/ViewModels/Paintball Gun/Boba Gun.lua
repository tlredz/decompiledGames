local Players = game:GetService("Players")
local PaintballGun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Paintball Gun"])
local color = Color3.fromRGB(0, 0, 0)
local object = setmetatable({}, PaintballGun)
object.__index = object

function object.new(...)
	local self = setmetatable(PaintballGun.new(...), object)
	self._bobas_part = self.ItemModel:WaitForChild("Body"):WaitForChild("Bobas")
	self:_Init()
	return self
end

function object.GetPaintballColor(_)
	return color
end

function object:_UpdateAmmoVisual()
	if self._destroyed then
		return
	end

	self:_LocalTransparencyModifier(self._bobas_part, "AmmoVisual", self.ClientItem:Get("Ammo") <= 0 and 1 or 0)
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateAmmoVisual()
	end)
	task.spawn(self._UpdateAmmoVisual, self)
end

return object