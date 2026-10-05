local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Molotov = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Molotov)
local object = setmetatable({}, Molotov)
object.__index = object

function object.new(...)
	local self = setmetatable(Molotov.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(p, p2, p3)
	local explosionEffect = Molotov.ExplosionEffect(p, p2, p3)
	Utility:CreateSound("rbxassetid://100889848836357", 1, 1 + 0.25 * math.random(), explosionEffect, true, 10)
end

function object:_Init() end

return object