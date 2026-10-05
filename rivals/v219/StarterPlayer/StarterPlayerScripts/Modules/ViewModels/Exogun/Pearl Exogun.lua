local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Exogun = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Exogun)
local pearlExogunExplosionParticles = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("PearlExogunExplosionParticles")
local colorSequence = ColorSequence.new(Color3.fromRGB(255, 215, 246))
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
	Exogun.ExplosionEffect(p, p2, p3, pearlExogunExplosionParticles)
	Utility:CreateSound("rbxassetid://121938614359106", 1, 1 + 0.25 * math.random(), p2, true, 10)
end

function object:_Init() end

return object