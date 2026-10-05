local Players = game:GetService("Players")
local PaintballGun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Paintball Gun"])
local color = Color3.fromRGB(255, 248, 52)
local object = setmetatable({}, PaintballGun)
object.__index = object

function object.new(...)
	local self = setmetatable(PaintballGun.new(...), object)
	self:_Init()
	return self
end

function object.GetPaintballColor(_)
	return color
end

function object:_Init() end

return object