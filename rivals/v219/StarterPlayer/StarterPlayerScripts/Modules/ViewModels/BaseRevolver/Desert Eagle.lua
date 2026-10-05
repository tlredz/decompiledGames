local Players = game:GetService("Players")
local BaseRevolver = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseRevolver)
local object = setmetatable({}, BaseRevolver)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseRevolver.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object