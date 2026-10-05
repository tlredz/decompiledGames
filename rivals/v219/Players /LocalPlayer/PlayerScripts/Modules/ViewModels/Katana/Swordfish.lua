local Players = game:GetService("Players")
local Katana = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Katana)
local object = setmetatable({}, Katana)
object.__index = object

function object.new(...)
	local self = setmetatable(Katana.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object