local Players = game:GetService("Players")
local FlareGun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseFlareGun["Flare Gun"])
local object = setmetatable({}, FlareGun)
object.__index = object

function object.new(...)
	local self = setmetatable(FlareGun.new(...), object)
	self:_Init()
	return self
end

function object:_Init() end

return object