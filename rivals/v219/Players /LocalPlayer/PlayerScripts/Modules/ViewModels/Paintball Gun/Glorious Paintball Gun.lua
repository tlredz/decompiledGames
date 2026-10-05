local Players = game:GetService("Players")
local PaintballGun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Paintball Gun"])
local object = setmetatable({}, PaintballGun)
object.__index = object

function object.new(...)
	local self = setmetatable(PaintballGun.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object