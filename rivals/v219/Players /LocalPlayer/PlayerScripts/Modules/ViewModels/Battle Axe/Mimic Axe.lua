local Players = game:GetService("Players")
local BattleAxe = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Battle Axe"])
local object = setmetatable({}, BattleAxe)
object.__index = object

function object.new(...)
	local self = setmetatable(BattleAxe.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object