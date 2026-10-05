local Players = game:GetService("Players")
local BaseDaggers = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseDaggers)
local object = setmetatable({}, BaseDaggers)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseDaggers.new(...), object)
	self.DontUseAmmoReserveToChangeCoreAnimations = true
	self:_Init()
	return self
end

function object:_Init()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Toast 1"):WaitForChild("MeshPart1"), 1)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Toast 1"):WaitForChild("MeshPart2"), 1)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Toast 2"):WaitForChild("MeshPart1"), 2)
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Toast 2"):WaitForChild("MeshPart2"), 2)
end

return object