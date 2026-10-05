local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local SubspaceTripmine = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Subspace Tripmine"])
local hazardSignExplosionEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("HazardSignExplosionEffect")
local hazardSignChark = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("HazardSignChark")
local object = setmetatable({}, SubspaceTripmine)
object.__index = object

function object.new(...)
	local self = setmetatable(SubspaceTripmine.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(p, position)
	local part = Instance.new("Part")
	part.CanCollide = false
	part.CanQuery = false
	part.Anchored = true
	part.Transparency = 1
	part.CFrame = CFrame.new(position) * CFrame.fromOrientation(1.5707963267948966, 1.5707963267948966, 0)
	part.Parent = workspace
	BetterDebris:AddItem(part, 5)
	Utility:CreateSound("rbxassetid://17812496122", 1, 0.9 + 0.2 * math.random(), part, true, 10)

	for _, child in pairs(hazardSignExplosionEffect:GetChildren()) do
		local clone_2 = child:Clone()
		clone_2.Parent = part
	end

	for _, emitter in pairs(part:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p.ClientItem.Info.ExplosionRadius / 6)
		end
	end

	part.PointLight.Range = p.ClientItem.Info.ExplosionRadius * 2
	Utility:PlayParticles(part)
	task.spawn(function()
		local clone = hazardSignChark:Clone()
		clone.Parent = workspace
		BetterDebris:AddItem(clone, 5)
		local v = CFrame.new(position) * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) + createVector(
			0,
			5,
			0
		)
		local v2 = v - createVector(0, 25, 0)
		Utility:RenderstepForLoop(0, 100, 3, function(p2)
			clone:PivotTo(v:Lerp(v2, (p2 / 100) ^ 4))
		end)
		clone:Destroy()
	end)
end

function object:_Init() end

return object