local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local Grenade = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.Grenade)
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("KeynadeExplosionEffect"):WaitForChild("Attachment")
local object = setmetatable({}, Grenade)
object.__index = object

function object.new(...)
	local self = setmetatable(Grenade.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(p, position, p2)
	local part = Instance.new("Part")
	part.CanCollide = false
	part.CanQuery = false
	part.Anchored = true
	part.Transparency = 1
	part.CFrame = CFrame.new(position)
	part.Parent = workspace
	BetterDebris:AddItem(part, 5)
	Utility:CreateSound("rbxassetid://13455969017", 0.5, 0.9 + 0.2 * math.random(), part, true, 10)
	Utility:CreateSound("rbxassetid://18179281854", 2, 0.9 + 0.2 * math.random(), part, true, 10)
	local clone = attachment:Clone()

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p2 / 10)
		end
	end

	clone.PointLight.Range = p2 * 2
	clone.Parent = part
	WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(clone), p.ClientItem:GetWrap(), true)
	Utility:PlayParticles(clone)
end

function object:_Init() end

return object