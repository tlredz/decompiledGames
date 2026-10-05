local Players = game:GetService("Players")
local GrenadeLauncher = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Grenade Launcher"])
local object = setmetatable({}, GrenadeLauncher)
object.__index = object

function object.new(...)
	local self = setmetatable(GrenadeLauncher.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object