local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local SubspaceTripmine = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Subspace Tripmine"])
local springExplosionEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("SpringExplosionEffect")
local object = setmetatable({}, SubspaceTripmine)
object.__index = object

function object.new(...)
	local self = setmetatable(SubspaceTripmine.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(_, position)
	Utility:CreateSound("rbxassetid://18763806953", 1.75, 0.9 + 0.2 * math.random(), position, true, 10)
	Utility:CreateSound("rbxassetid://105724753475729", 1.5, 0.9 + 0.2 * math.random(), position, true, 10)
	local clone = springExplosionEffect:Clone()
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 5)
	Utility:PlayParticles(clone)
end

function object:_Init() end

return object