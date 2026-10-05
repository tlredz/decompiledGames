local Players = game:GetService("Players")
local SubspaceTripmine = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Subspace Tripmine"])
local object = setmetatable({}, SubspaceTripmine)
object.__index = object

function object.new(...)
	local self = setmetatable(SubspaceTripmine.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object