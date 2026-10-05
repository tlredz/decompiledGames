local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local BaseRPG = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseRPG)
local attachment = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("RPKEYExplosionEffect"):WaitForChild("Attachment")
local object = setmetatable({}, BaseRPG)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseRPG.new(...), object)
	self:_Init()
	return self
end

function object.PlayAimSound(object2, p)
	object2:CreateSound("rbxassetid://96253147006478", 0.375, 2 + (p and 0.1 or 0), true, 5)
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
			Utility:ScaleParticleEmitter(emitter, p2 / 20)
		end
	end

	clone.PointLight.Range = p2 * 2
	clone.Parent = part
	WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(clone), p.ClientItem:GetWrap(), true)
	Utility:PlayParticles(clone)
end

function object:_Init()
	self:_RegisterAmmoVisual(self.ItemModel:WaitForChild("Rocket"):WaitForChild("Head"))
end

return object