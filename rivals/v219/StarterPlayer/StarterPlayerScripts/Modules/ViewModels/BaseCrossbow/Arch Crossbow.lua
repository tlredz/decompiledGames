local Players = game:GetService("Players")
local ViewModelParticlesLogic = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModelParticlesLogic)
local BaseCrossbow = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseCrossbow)
local colorSequence = ColorSequence.new(Color3.fromRGB(8, 255, 152))
local object = setmetatable({}, BaseCrossbow)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseCrossbow.new(...), object)
	self.ShouldPlayReloadAnimationInstantly = true
	self._particles_logic = ViewModelParticlesLogic.new(self)
	self._is_empty = nil
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object:Unequip(...)
	self._particles_logic:CancelEffect()
	BaseCrossbow.Unequip(self, ...)
end

function object:Destroy()
	self._particles_logic:Destroy()
	BaseCrossbow.Destroy(self)
end

function object:_UpdateDefaultAnimationsFromAmmo()
	local ammo = self.ClientItem:Get("Ammo")
	self.ClientItem:Get("AmmoReserve")
	local is_empty = ammo <= 0

	if is_empty == self._is_empty then
		return
	end

	self._is_empty = is_empty
	self:ChangeInspectAnimation("Inspect" .. (self._is_empty and "Empty" or ""))
end

function object:_Init()
	self.Equipped:Connect(function(p)
		self._particles_logic:PlayEffect(0, p and 0 or 0.7)
	end)
	self.ClientItem:GetDataChangedSignal("AmmoReserve"):Connect(function()
		self:_UpdateDefaultAnimationsFromAmmo()
	end)
	self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateDefaultAnimationsFromAmmo()
	end)
	self:_UpdateDefaultAnimationsFromAmmo()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("MeshPart"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Arrow"):WaitForChild("MeshPart"):WaitForChild("Attachment"):WaitForChild("arrow"))
end

return object