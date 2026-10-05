local Players = game:GetService("Players")
local FreezeRay = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Freeze Ray"])
local object = setmetatable({}, FreezeRay)
object.__index = object

function object.new(...)
	local self = setmetatable(FreezeRay.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object