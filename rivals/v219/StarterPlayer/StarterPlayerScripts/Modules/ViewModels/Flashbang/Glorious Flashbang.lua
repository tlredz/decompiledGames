local Players = game:GetService("Players")
local Flashbang = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Flashbang)
local object = setmetatable({}, Flashbang)
object.__index = object

function object.new(...)
	local self = setmetatable(Flashbang.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object