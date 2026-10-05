local Players = game:GetService("Players")
local BaseFlareGun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseFlareGun)
local object = setmetatable({}, BaseFlareGun)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseFlareGun.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object