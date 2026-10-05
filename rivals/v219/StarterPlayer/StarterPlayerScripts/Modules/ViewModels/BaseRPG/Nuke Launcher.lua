local Players = game:GetService("Players")
local FunctionsController = require(Players.LocalPlayer.PlayerScripts.Controllers.FunctionsController)
local BaseRPG = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseRPG)
local object = setmetatable({}, BaseRPG)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseRPG.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(object2, p, p2)
	FunctionsController:FireAsync(object2:ToEnum("NukeEffect"), p, p2, nil, true)
end

function object:_Init()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("Head"))
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("Neck"))
end

return object