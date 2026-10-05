local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local molotovExplosionEffects = Players.LocalPlayer.PlayerScripts.Assets.Misc:WaitForChild("MolotovExplosionEffects")
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self:_Init()
	return self
end

function object.ExplosionEffect(p, p2, p3)
	local clone = (molotovExplosionEffects:FindFirstChild(p.Name) or molotovExplosionEffects.Default):Clone()
	clone.CFrame = CFrame.new(p2, p2 + createVector(0, 1, 0))
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 5)
	Utility:CreateSound("rbxassetid://17167035482", 0.25, 1.5 + 0.25 * math.random(), clone, true, 10)

	for _, emitter in pairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			Utility:ScaleParticleEmitter(emitter, p3 / 16)
		end
	end

	Utility:PlayParticles(clone.Attachment)
	Utility:PlayParticles(clone.Attachment)
	WrapController:ApplyWrap(WrapController:RecordOriginalWrapProperties(clone), p.ClientItem:GetWrap(), true)
	return clone
end

function object:_Init() end

return object