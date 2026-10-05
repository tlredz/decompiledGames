local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ClientEnemy = require(Players.LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientEntity.ClientHumanoidEntity.ClientEnemy)
local explosiveZombieExplosionEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("ExplosiveZombieExplosionEffect")
local object = setmetatable({}, ClientEnemy)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientEnemy.new(...), object)
	self:_Init()
	return self
end

function object.ReplicateFromServer(object2, p, ...)
	if p ~= "ZombieExplosionEffect" then
		ClientEnemy.ReplicateFromServer(object2, p, ...)
		return
	end

	if not object2:IsRendered() then
		return
	end

	local v, v2 = ...
	local clone = explosiveZombieExplosionEffect:Clone()
	clone.CFrame = CFrame.new(v)
	clone.Parent = object2.Model
	BetterDebris:AddItem(clone, 10)
	Utility:CreateSound("rbxassetid://13455969017", 0.5, 0.75, clone, true, 10)
	Utility:CreateSound("rbxassetid://103343386215625", 1, 0.95 + 0.1 * math.random(), clone, true, 10)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, v2 / 3)
		end
	end

	Utility:PlayParticles(clone)
end

function object:_Init() end

return object