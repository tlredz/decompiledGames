local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local GrenadeLauncher = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Grenade Launcher"])
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("BalloonExplosionEffect"):WaitForChild("Attachment")
local v = {
	ColorSequence.new(Color3.fromRGB(61, 90, 255)),
	ColorSequence.new(Color3.fromRGB(88, 255, 62)),
	ColorSequence.new(Color3.fromRGB(255, 232, 57))
}
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
	part.CFrame = CFrame.new(position)
	part.Parent = workspace
	BetterDebris:AddItem(part, 5)
	Utility:CreateSound("rbxassetid://13455969017", 0.375, 0.75 + 0.15 * math.random(), part, true, 10)
	Utility:CreateSound("rbxassetid://101824947434055", 1.25, 0.9 + 0.2 * math.random(), part, true, 10)
	local color = v[math.random(#v)]
	local clone = attachment:Clone()
	clone.flash.Color = color
	clone.impact1.Color = color
	clone.impact2.Color = color
	clone.specs2Balloon.Color = color
	clone.specs2Balloon2.Color = color
	clone.Parent = part

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p / 12)
		end
	end

	Utility:PlayParticles(clone)
end

function object:_Init() end

return object