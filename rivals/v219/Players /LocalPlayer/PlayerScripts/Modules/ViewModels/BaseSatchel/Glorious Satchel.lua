local Players = game:GetService("Players")
local BaseSatchel = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseSatchel)
local object = setmetatable({}, BaseSatchel)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseSatchel.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object