local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local GrenadeLauncher = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Grenade Launcher"])
local swashbucklerExplosion = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("SwashbucklerExplosion")
local object = setmetatable({}, GrenadeLauncher)
object.__index = object

function object.new(...)
	local self = setmetatable(GrenadeLauncher.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(_, position, p)
	local part = Instance.new("Part")
	part.CanCollide = false
	part.CanQuery = false
	part.Anchored = true
	part.Transparency = 1
	part.CFrame = CFrame.new(position) * CFrame.fromOrientation(1.5707963267948966, 1.5707963267948966, 0)
	part.Parent = workspace
	BetterDebris:AddItem(part, 5)
	Utility:CreateSound("rbxassetid://17812496122", 1, 0.9 + 0.2 * math.random(), part, true, 10)

	for _, child in pairs(swashbucklerExplosion:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = part
	end

	for _, emitter in pairs(part:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 9)
		end
	end

	Utility:PlayParticles(part)
end

function object:_Init() end

return object