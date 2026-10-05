local Players = game:GetService("Players")
local BaseFlareGun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseFlareGun)
local object = setmetatable({}, BaseFlareGun)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseFlareGun.new(...), object)
	self:_Init()
	return self
end

function object:_UpdateViewModelAnimations()
	self.Animator:ChangeRareInspectAnimation(self.ClientItem:Get("Ammo") > 0 and "RareInspect" or "nil")
end

function object:_Init()
	table.insert(self._connections, self.ClientItem:GetDataChangedSignal("Ammo"):Connect(function()
		self:_UpdateViewModelAnimations()
	end))
	self:_RegisterDefaultAmmoVisuals()
	task.defer(self._UpdateViewModelAnimations, self)
end

return object