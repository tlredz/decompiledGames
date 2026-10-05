local Players = game:GetService("Players")
local Exogun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Exogun)
local wondergunExplosionParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("WondergunExplosionParticles")
local colorSequence = ColorSequence.new(Color3.fromRGB(55, 218, 255))
local object = setmetatable({}, Exogun)
object.__index = object

function object.new(...)
	local self = setmetatable(Exogun.new(...), object)
	self:_Init()
	return self
end

function object.GetFriendlyTracerColor(_)
	return colorSequence
end

function object.ExplosionEffect(p, p2, p3)
	Exogun.ExplosionEffect(p, p2, p3, wondergunExplosionParticles)
end

function object:_Init() end

return object