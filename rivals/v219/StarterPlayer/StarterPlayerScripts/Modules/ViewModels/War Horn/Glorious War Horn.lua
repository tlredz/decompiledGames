local Players = game:GetService("Players")
local WarHorn = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["War Horn"])
local object = setmetatable({}, WarHorn)
object.__index = object

function object.new(...)
	local self = setmetatable(WarHorn.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object